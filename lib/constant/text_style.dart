import 'package:flutter/material.dart';
import 'package:memory_game/constant/color_constant.dart';

/// アプリ共通のテキストスタイル。
///
/// ターゲットである高齢者にも読みやすいよう、全体的に大きめのサイズと
/// はっきりした字面（太さ）に統一し、字間・行間も少しゆとりを持たせている。
/// 数字を扱う箇所（タイム・ランキング）は桁が揃う等幅数字を使う。
class AppText {
  const AppText._();

  /// アプリ全体で使う丸ゴシック（pubspec.yaml でバンドル）。
  /// テーマの fontFamily に設定し、各スタイルへ自動で適用される。
  static const String fontFamily = 'ZenMaruGothic';

  // 既定の字間。詰まりすぎを防ぐためわずかに広げる。
  static const double _track = 0.2;

  // 数字を等幅にして桁ぶれを防ぐ。
  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  /// ホームのアプリタイトル。
  static const TextStyle title = TextStyle(
    color: DefColor.darkBlue,
    fontSize: 38,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
    height: 1.12,
  );

  /// 画面上部バーなどの見出し（「Level N」）。
  static const TextStyle heading = TextStyle(
    color: DefColor.textBlack,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: _track,
    fontFeatures: _tabular,
  );

  /// セクション見出し（「Best Time」「答え」など）。
  static const TextStyle subheading = TextStyle(
    color: DefColor.textBlack,
    fontSize: 19,
    fontWeight: FontWeight.w700,
    letterSpacing: _track,
  );

  /// 画面上部のガイド文。
  static const TextStyle guide = TextStyle(
    color: DefColor.textBlack,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: _track,
    height: 1.15,
  );

  /// 本文・案内メッセージ。
  static const TextStyle body = TextStyle(
    color: DefColor.textBlack,
    fontSize: 17,
    height: 1.45,
    letterSpacing: _track,
  );

  /// 少し強調した本文。
  static const TextStyle bodyStrong = TextStyle(
    color: DefColor.textBlack,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: _track,
  );

  /// ランキングの記録行（数字主体・等幅）。
  /// 高齢者にも読みやすいよう、やや大きめにする。
  static const TextStyle record = TextStyle(
    color: DefColor.textBlack,
    fontSize: 19,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    fontFeatures: _tabular,
  );

  /// ランキング記録行の日付（記録の下に添える）。
  /// 日付も読み取りやすいよう、しっかりした大きさにする。
  static const TextStyle recordDate = TextStyle(
    color: DefColor.textMuted,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    fontFeatures: _tabular,
  );

  /// 小さなチップ／ラベル（「前回の記録」など）。
  static const TextStyle badge = TextStyle(
    color: DefColor.textWhite,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
  );

  /// ボタンのラベル。
  static const TextStyle button = TextStyle(
    color: DefColor.textWhite,
    fontSize: 21,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
  );

  /// 画面上部バー右側の補助テキスト（「Time …」）。
  static const TextStyle topBarTrailing = TextStyle(
    color: DefColor.textBlack,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: _track,
    fontFeatures: _tabular,
  );

  /// 結果画面の見出し（「Level N クリア！」）。
  static const TextStyle resultTitle = TextStyle(
    color: DefColor.textBlack,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.3,
  );

  /// 結果画面のタイム表示。
  static const TextStyle resultTime = TextStyle(
    color: DefColor.textBlack,
    fontSize: 21,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    fontFeatures: _tabular,
  );

  /// タイル等に表示する大きめの数字（色は呼び出し側で指定）。
  static const TextStyle tileNumber = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    fontFeatures: _tabular,
  );
}
