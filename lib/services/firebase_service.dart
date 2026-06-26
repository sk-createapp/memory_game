import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:memory_game/firebase_options.dart';

/// Firebase（Analytics / Crashlytics）の初期化と参照を一元管理する。
///
/// 起動経路の最初で [init] を await し、Firebase Core 起動後に未捕捉エラーを
/// Crashlytics へ送る設定を行う。初期化失敗時もアプリ本体は止めない。
class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  FirebaseAnalytics? _analytics;

  /// Analytics への参照。未初期化でも instance は取得できる。
  FirebaseAnalytics get analytics => _analytics ??= FirebaseAnalytics.instance;

  bool _initialized = false;

  /// Firebase Core を初期化し、未捕捉エラーを Crashlytics に送る設定を行う。
  Future<void> init() async {
    if (_initialized) return;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // デバッグビルドでは収集を無効化し、リリースビルドのみ送信する。
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);

      // Flutter フレームワーク内の致命的エラーを Crashlytics に送る。
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      // フレームワーク外（非同期処理など）の未捕捉エラーも送る。
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      _analytics = FirebaseAnalytics.instance;
      _initialized = true;
    } catch (e, st) {
      // 初期化失敗時もアプリは継続させる。ログのみ残す。
      debugPrint('Firebase init failed: $e\n$st');
    }
  }
}
