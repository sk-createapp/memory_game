import 'package:flutter/material.dart';

/// アプリ全体のカラーパレット。
///
/// ターゲットである高齢者が長時間見ても疲れにくいよう、暖色系の落ち着いた
/// 色味を基調にしつつ、文字・操作要素は十分なコントラストを確保している。
/// 立体的な「押し込めるボタン」を表現するため、主要色には一段濃い `〜Deep`
/// （ボタンの底面／押下色）を用意している。
class DefColor {
  const DefColor._();

  static const Color none = Color(0x00000000);

  // ===== 背景・サーフェス（暖かいクリーム系） =====
  /// アプリ全体の背景。ほんのり暖色でまぶしさを抑える。
  static const Color lightBeige = Color(0xFFF7F1E4);

  /// 枠線・伏せたタイルなどのサブサーフェス。
  static const Color darkBeige = Color(0xFFE7DBC2);

  /// カードなど一段明るい面。
  static const Color surface = Color(0xFFFFFDF8);

  /// ごく薄い塗り（タイルの地など）。
  static const Color sand = Color(0xFFF0E7D5);

  // ===== プライマリ（テラコッタ：主要アクション・回答タイル） =====
  static const Color orange = Color(0xFFD9734A);

  /// 立体ボタンの底面／押下時の色。
  static const Color orangeDeep = Color(0xFFB0552F);

  /// プライマリの淡いトーン。
  static const Color orangeSoft = Color(0xFFF4DAC8);

  // ===== セカンダリ（落ち着いたティール：タイトル・補助操作） =====
  static const Color darkBlue = Color(0xFF3C8B8B);

  /// セカンダリ立体ボタンの底面／押下色。
  static const Color darkBlueDeep = Color(0xFF2A6868);

  /// 補助の淡い面（選択肢シート背景・レベル未選択）。
  static const Color lightBlue = Color(0xFFBBD6D2);

  // ===== アクセント（選択ハイライト：暖色のゴールド） =====
  static const Color select = Color(0xFFF2B33D);
  static const Color selectDeep = Color(0xFFCE9020);

  // ===== 状態色 =====
  /// 正解マーカー。
  static const Color green = Color(0xFF4E9D6B);

  /// 不正解マーカー・警告。
  static const Color red = Color(0xFFD2492E);
  static const Color redDeep = Color(0xFFA8341F);

  /// ロック済み・無効。
  static const Color gray = Color(0xFFBDB4A2);
  static const Color grayDeep = Color(0xFF978E7C);

  // ===== テキスト =====
  /// 本文・見出し（高コントラストの暖かいダークブラウン）。
  static const Color textBlack = Color(0xFF463E34);

  /// 濃色面の上に置く文字。
  static const Color textWhite = Color(0xFFFBF6EC);

  /// 補足テキスト。
  static const Color textMuted = Color(0xFF7C7361);

  /// タイル等を押し込んだときに重ねる薄い影（約16%の黒）。
  static const Color pressScrim = Color(0x29000000);
}
