import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:memory_game/constant/premium_constant.dart';
import 'package:memory_game/constant/sp_key.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// 月額プレミアム購入フローの結果。呼び出し側が案内表示の要否を判断するのに使う。
enum PurchaseOutcome {
  /// 購入が成立した（権利反映は CustomerInfo 経由で行われる）。
  success,

  /// ユーザーが購入をキャンセルした（失敗ではないため案内は出さない）。
  cancelled,

  /// 承認待ち（ファミリー共有の Ask to Buy・決済保留など）。後で CustomerInfo
  /// リスナー経由で権利が付与される正常ケースなので、失敗案内は出さない。
  pending,

  /// 未構成・商品未取得・ストア接続不良などで購入できなかった（案内を出す）。
  failed,
}

/// プレミアム（月額サブスクで広告非表示）の購入状態を一元管理するシングルトン。
///
/// 権利判定は RevenueCat のエンタイトルメント [Premium.entitlementId] を唯一の
/// 真実とする。RevenueCat はストアのレシートをサーバーで検証し、解約・期限切れに
/// なれば該当エンタイトルメントが自動的に非アクティブになるため、端末側だけで
/// 「失効」を正しく反映できる（旧 in_app_purchase 実装の弱点を解消）。
///
/// 起動直後・オフラインでも判定できるよう、最後に確定した権利は
/// SharedPreferences にキャッシュし、起動時に即時反映する。確定した最新状態は
/// RevenueCat（[CustomerInfo]）から取得して上書きする。
///
/// 状態は [ValueNotifier] で公開し、広告ウィジェット（[isPremium] を購読して
/// 非表示化）やホーム／メニューの導線（[ValueListenableBuilder]）から監視する。
class PremiumService {
  PremiumService._();
  static final PremiumService instance = PremiumService._();

  /// ネイティブ（iOS）の「サブスクリプションの管理」シートを開くためのチャンネル。
  /// AppDelegate 側の同名チャンネルと対になっている。
  static const MethodChannel _subscriptionsChannel =
      MethodChannel('memory_game/subscriptions');

  /// プレミアム権利を保持しているか。広告の表示可否はこれを唯一の真実とする。
  final ValueNotifier<bool> isPremium = ValueNotifier<bool>(false);

  /// 月額プレミアムのパッケージ（価格表示・購入に使う）。未取得時は null。
  final ValueNotifier<Package?> monthlyPackage = ValueNotifier<Package?>(null);

  /// 購入処理が進行中か（ボタンのローディング表示に使う）。
  final ValueNotifier<bool> purchasePending = ValueNotifier<bool>(false);

  bool _initialized = false;

  /// RevenueCat の構成（APIキー設定 & configure）に成功したか。
  /// 失敗時はキャッシュ権利のみで動作し、購入・復元は行わない。
  bool _configured = false;

  /// ストアから取得できた価格（ローカライズ済み）。未取得時はフォールバック。
  String get priceText =>
      monthlyPackage.value?.storeProduct.priceString ?? Premium.fallbackPrice;

  /// 起動時に一度だけ呼ぶ。キャッシュ済み権利の反映 → RevenueCat 構成 →
  /// 権利監視 → 最新権利の取得 → オファリング取得、の順で初期化する。
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // 1. キャッシュした権利状態を即時反映（オフライン・起動直後でも判定可能に）。
    final prefs = await SharedPreferences.getInstance();
    isPremium.value = prefs.getBool(SpKey.isPremium.name) ?? false;

    if (!iapSupported) return;

    // 2. API キー未設定なら課金機能を無効化（クラッシュ回避）。キャッシュ権利で継続。
    final apiKey = Premium.revenueCatApiKey;
    if (apiKey.isEmpty) return;

    try {
      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.warn);
      await Purchases.configure(PurchasesConfiguration(apiKey));
      _configured = true;
    } catch (_) {
      return; // 構成に失敗してもキャッシュ権利で動作を継続する。
    }

    // 3. 権利更新の監視を開始（購入・復元・解約・失効がすべてここに反映される）。
    Purchases.addCustomerInfoUpdateListener(_onCustomerInfo);

    // 4. 最新の権利状態を取得して同期（解約・期限切れもサーバー基準で反映）。
    //    オフライン時は RevenueCat の端末キャッシュが返るため失敗しにくい。
    try {
      final info = await Purchases.getCustomerInfo();
      await _applyCustomerInfo(info);
    } catch (_) {
      // 取得失敗時はキャッシュ済みの権利を維持する（プレミアムを誤って失わない）。
    }

    // 5. オファリング（価格表示・購入に使う）を取得。
    await _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) return;
      // 月額スロットを優先し、無ければ Offering の先頭パッケージで代替する。
      monthlyPackage.value = current.monthly ??
          (current.availablePackages.isNotEmpty
              ? current.availablePackages.first
              : null);
    } catch (_) {
      // 取得失敗時はフォールバック価格で表示し、購入時に再取得を試みる。
    }
  }

  /// 月額プレミアムの購入フローを開始する。
  ///
  /// 結果を [PurchaseOutcome] で返す。未構成・商品未取得・ストア接続不良などで
  /// 購入できなかった場合は [PurchaseOutcome.failed]、ユーザーがキャンセルした
  /// 場合は [PurchaseOutcome.cancelled]、成立した場合は [PurchaseOutcome.success]。
  /// 呼び出し側は failed のときだけ「利用できません」案内を出す。
  Future<PurchaseOutcome> buyMonthly() async {
    if (!_configured) return PurchaseOutcome.failed;
    var package = monthlyPackage.value;
    if (package == null) {
      await _loadOfferings();
      package = monthlyPackage.value;
    }
    if (package == null) return PurchaseOutcome.failed;

    purchasePending.value = true;
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      await _applyCustomerInfo(result.customerInfo);
      return PurchaseOutcome.success;
    } on PlatformException catch (e) {
      // 進行中フラグを戻す（権利はまだ付与しない）。キャンセル・承認待ちは失敗では
      // ないため案内を出さないよう、エラーコードで区別する。
      purchasePending.value = false;
      final code = PurchasesErrorHelper.getErrorCode(e);
      switch (code) {
        case PurchasesErrorCode.purchaseCancelledError:
          return PurchaseOutcome.cancelled;
        case PurchasesErrorCode.paymentPendingError:
          // 承認待ち（Ask to Buy / 決済保留）。承認後にリスナー経由で権利が付く。
          return PurchaseOutcome.pending;
        default:
          return PurchaseOutcome.failed;
      }
    } catch (_) {
      purchasePending.value = false;
      return PurchaseOutcome.failed;
    }
  }

  /// サブスク管理（内容確認・解約）UI を開く。
  ///
  /// iOS ではまず StoreKit の「サブスクリプションの管理」シートをアプリ内に
  /// 表示し、設定アプリやブラウザに飛ばさず操作を完結できるようにする
  /// （meal-plan と同じ体験）。iOS 15 未満やシート表示に失敗した場合、および
  /// iOS 以外では、ストアの管理ページを外部で開くフォールバックに切り替える。
  Future<void> openManageSubscriptions() async {
    if (!iapSupported) return;

    // iOS はネイティブの OS シート（アプリ内モーダル）を優先する。
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        final shown = await _subscriptionsChannel
            .invokeMethod<bool>('showManageSubscriptions');
        if (shown == true) return;
      } catch (_) {
        // チャンネル未対応・表示失敗時は URL フォールバックへ。
      }
    }

    // フォールバック：ストアの管理ページを外部ブラウザ／ストアで開く。
    final url = await manageSubscriptionsUrl();
    if (url == null) return;
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  /// ストアのサブスク管理（内容確認・解約）ページのURLを返す。
  ///
  /// RevenueCat が返す [CustomerInfo.managementURL]（その購入を直接管理できる
  /// 正確なページ）を最優先で使い、取得できない場合は各ストアの既定の管理ページ
  /// （iOS: App Store のサブスク一覧 / Android: Google Play のサブスク一覧）に
  /// フォールバックする。課金非対応プラットフォームでは null。
  Future<String?> manageSubscriptionsUrl() async {
    if (!iapSupported) return null;

    if (_configured) {
      try {
        final info = await Purchases.getCustomerInfo();
        final url = info.managementURL;
        if (url != null && url.isNotEmpty) return url;
      } catch (_) {
        // 取得失敗時は各ストア既定の管理ページにフォールバックする。
      }
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'https://apps.apple.com/account/subscriptions';
      case TargetPlatform.android:
        return 'https://play.google.com/store/account/subscriptions';
      default:
        return null;
    }
  }

  /// 過去の購入を復元する（機種変更・再インストール時用）。
  Future<void> restore() async {
    if (!_configured) return;
    try {
      final info = await Purchases.restorePurchases();
      await _applyCustomerInfo(info);
    } catch (_) {}
  }

  void _onCustomerInfo(CustomerInfo info) {
    // リスナーは同期シグネチャのため、結果を待たずに反映する。
    _applyCustomerInfo(info);
  }

  /// サーバー基準の権利状態を端末へ反映する。
  /// [Premium.entitlementId] が active ならプレミアム有効。解約・期限切れ後は
  /// active から外れるため、自動的に無効へ戻る。
  Future<void> _applyCustomerInfo(CustomerInfo info) async {
    final active = info.entitlements.active.containsKey(Premium.entitlementId);
    purchasePending.value = false;
    await _setPremium(active);
  }

  Future<void> _setPremium(bool value) async {
    isPremium.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SpKey.isPremium.name, value);
  }
}
