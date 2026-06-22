import 'package:flutter/widgets.dart';

/// メニューから開く外部リンク（法務ページ・お問い合わせフォーム）の一元管理。
///
/// 法務ページは skcreation 共通の法務サイト（Cloudflare Pages）にデプロイされており、
/// 本アプリのスラッグは `memory-game`、言語は日本語(ja)とそれ以外(en)の2系統で配信する。
class AppLinks {
  const AppLinks._();

  /// 法務サイトの本アプリ用ベースURL。
  static const String _legalBase =
      'https://skcreation-legal.pages.dev/memory-game';

  /// お問い合わせフォーム（Google フォーム）。日本語と英語の2種類を用意。
  static const String _contactFormJa = 'https://forms.gle/Xa8C1A8jMhm4WVCB9';
  static const String _contactFormEn = 'https://forms.gle/4c6knQW3qB7yEWMt8';

  /// 表示言語から法務ページの言語セグメントを決める（日本語のみ ja、その他は en）。
  static String _docLang(Locale locale) =>
      locale.languageCode == 'ja' ? 'ja' : 'en';

  /// プライバシーポリシーのURL。
  static String privacyPolicy(Locale locale) =>
      '$_legalBase/${_docLang(locale)}/privacy';

  /// 利用規約のURL。
  static String termsOfService(Locale locale) =>
      '$_legalBase/${_docLang(locale)}/terms';

  /// お問い合わせフォームのURL（日本語のみ日本語フォーム、その他は英語フォーム）。
  static String contactForm(Locale locale) =>
      locale.languageCode == 'ja' ? _contactFormJa : _contactFormEn;
}
