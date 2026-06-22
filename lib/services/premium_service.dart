import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:memory_game/constant/premium_constant.dart';
import 'package:memory_game/constant/sp_key.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// プレミアム（月額サブスクで広告非表示）の購入状態を一元管理するシングルトン。
///
/// 権利（[isPremium]）は端末の SharedPreferences にキャッシュしておき、
/// 起動直後・オフラインでも即座に判定できるようにする。あわせて起動時に
/// [InAppPurchase.restorePurchases] を呼び、ストア側の最新状態に同期する。
///
/// 状態は [ValueNotifier] で公開し、広告ウィジェット（[isPremium] を購読して
/// 非表示化）やホーム／メニューの導線（[ValueListenableBuilder]）から監視する。
///
/// 注意: サーバーでのレシート検証は行わない簡易構成のため、解約後の失効を
/// 端末だけでは厳密に検知できない（購入・復元の成功をもって有効とみなす）。
/// 厳密な失効管理が必要になったらサーバー検証を追加すること。
class PremiumService {
  PremiumService._();
  static final PremiumService instance = PremiumService._();

  /// プレミアム権利を保持しているか。広告の表示可否はこれを唯一の真実とする。
  final ValueNotifier<bool> isPremium = ValueNotifier<bool>(false);

  /// 月額プレミアム商品の詳細（価格表示などに使う）。未取得時は null。
  final ValueNotifier<ProductDetails?> monthlyProduct =
      ValueNotifier<ProductDetails?>(null);

  /// 購入処理が進行中か（ボタンのローディング表示に使う）。
  final ValueNotifier<bool> purchasePending = ValueNotifier<bool>(false);

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _initialized = false;

  /// ストアから取得できた価格（ローカライズ済み）。未取得時はフォールバック。
  String get priceText => monthlyProduct.value?.price ?? Premium.fallbackPrice;

  /// 起動時に一度だけ呼ぶ。キャッシュ済み権利の反映 → 購入監視 → 商品取得 →
  /// 購入復元、の順で初期化する。
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // 1. キャッシュした権利状態を即時反映（オフライン・起動直後でも判定可能に）。
    final prefs = await SharedPreferences.getInstance();
    isPremium.value = prefs.getBool(SpKey.isPremium.name) ?? false;

    if (!iapSupported) return;

    bool available;
    try {
      available = await _iap.isAvailable();
    } catch (_) {
      available = false;
    }
    if (!available) return;

    // 2. 購入更新の監視を開始（購入・復元・保留・エラーが流れてくる）。
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onDone: () => _subscription?.cancel(),
      onError: (_) {},
    );

    // 3. 商品情報を取得（価格表示・購入に必要）。
    await _loadProducts();

    // 4. 起動時に購入を復元し、サブスクの有効状態を最新化する。
    //    （有効な購入があれば purchaseStream 経由で restored が流れてくる）
    try {
      await _iap.restorePurchases();
    } catch (_) {}
  }

  Future<void> _loadProducts() async {
    try {
      final response =
          await _iap.queryProductDetails({Premium.monthlyProductId});
      if (response.productDetails.isNotEmpty) {
        monthlyProduct.value = response.productDetails.first;
      }
    } catch (_) {
      // 取得失敗時はフォールバック価格で表示し、購入時に再取得を試みる。
    }
  }

  /// 月額プレミアムの購入フローを開始する。
  ///
  /// 実際の購入結果は [purchaseStream] 経由で [_onPurchaseUpdated] に届く。
  Future<void> buyMonthly() async {
    if (!iapSupported) return;
    if (monthlyProduct.value == null) {
      await _loadProducts();
    }
    final product = monthlyProduct.value;
    if (product == null) return;

    purchasePending.value = true;
    try {
      // 自動更新サブスクは in_app_purchase 上では「非消費型」として購入する。
      await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
    } catch (_) {
      purchasePending.value = false;
    }
  }

  /// 過去の購入を復元する（機種変更・再インストール時用）。
  Future<void> restore() async {
    if (!iapSupported) return;
    try {
      await _iap.restorePurchases();
    } catch (_) {}
  }

  Future<void> _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != Premium.monthlyProductId) {
        // 対象外の購入も保留があれば必ず完了させる（ストア要件）。
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        continue;
      }

      switch (purchase.status) {
        case PurchaseStatus.pending:
          purchasePending.value = true;
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _setPremium(true);
          purchasePending.value = false;
          break;
        case PurchaseStatus.error:
        case PurchaseStatus.canceled:
          purchasePending.value = false;
          break;
      }

      // 保留中の購入は必ず完了させないと、再配信され続ける。
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _setPremium(bool value) async {
    isPremium.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SpKey.isPremium.name, value);
  }
}
