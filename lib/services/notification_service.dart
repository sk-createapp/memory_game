import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:memory_game/constant/notification_messages.dart';
import 'package:memory_game/constant/sp_key.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// 通知がサポートされるプラットフォームか（Android / iOS のみ）。
/// web・デスクトップでは初期化・予約を行わない（広告と同じ方針）。
bool get _notificationsSupported {
  if (kIsWeb) return false;
  return Platform.isAndroid || Platform.isIOS;
}

/// ローカル通知でリテンション（継続利用）を後押しするサービス。
///
/// 「一定期間アプリ起動がない場合に通知する」を、サーバーなしのローカル通知だけで
/// 実現するため、起動・復帰のたびに既存の予約をすべて消し、将来日に向けて
/// 再エンゲージ通知を予約し直す方式を採る。アプリを開き続けている限り予約は
/// 未来へ更新され続けて発火せず、しばらく起動が途絶えると設定間隔で順に発火する。
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // 再エンゲージ予約に使う通知IDの基点（ここから連番）。
  static const int _baseId = 1000;

  // 通知を出す時刻（ローカル時間・時）。高齢者の生活リズムに合わせ日中に出す。
  static const int _reminderHour = 10;

  // しばらく起動がないときに送る「現在からの経過日数」。
  // 最初はこまめに、その後はだんだん間隔をあけて、しつこくならないようにする。
  static const List<int> _offsetDays = [2, 4, 7, 11, 16, 23, 30, 45, 60, 90];

  Future<void> init() async {
    if (_initialized || !_notificationsSupported) return;

    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // 取得に失敗しても既定（UTC）のまま継続する。
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      // 許可は説明ダイアログのあとに明示的に求めるため、ここでは要求しない。
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings:
          const InitializationSettings(android: androidInit, iOS: iosInit),
    );
    _initialized = true;
  }

  /// 説明ダイアログのあとに呼ぶ、OSの通知許可要求。
  /// 許可されたら true を返し、結果をSPに保存する。
  Future<bool> requestPermission() async {
    if (!_notificationsSupported) return false;
    await init();

    var granted = false;
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      granted = await android?.requestNotificationsPermission() ?? false;
    } else if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      granted = await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SpKey.notifEnabled.name, granted);
    return granted;
  }

  Future<bool> _isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(SpKey.notifEnabled.name) ?? false;
  }

  /// 起動・復帰のたびに呼ぶ。既存予約をすべて消し、将来日へ再エンゲージ通知を
  /// 予約し直す。許可がない場合は何もしない。
  Future<void> rescheduleReengagement(String languageCode) async {
    if (!_notificationsSupported) return;
    await init();
    if (!await _isEnabled()) return;

    await _plugin.cancelAll();

    // 同じ文面が並ばないよう、シャッフルした一覧から順に割り当てる。
    final nudges = List<String>.from(NotificationMessages.nudges(languageCode))
      ..shuffle();
    final cta = NotificationMessages.cta(languageCode);

    const androidDetails = AndroidNotificationDetails(
      'reengagement_reminder',
      'Reminders',
      channelDescription:
          'Gentle reminders to keep up your daily brain training',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    for (var i = 0; i < _offsetDays.length; i++) {
      try {
        await _plugin.zonedSchedule(
          id: _baseId + i,
          title: nudges[i % nudges.length],
          body: cta,
          scheduledDate: _instantAfterDays(_offsetDays[i]),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } catch (_) {
        // 端末状況により個別の予約が失敗しても、残りの予約は続行する。
      }
    }
  }

  /// 現在から [days] 日後の [_reminderHour] 時（ローカル）の時刻。
  tz.TZDateTime _instantAfterDays(int days) {
    final target = tz.TZDateTime.now(tz.local).add(Duration(days: days));
    return tz.TZDateTime(
        tz.local, target.year, target.month, target.day, _reminderHour);
  }
}
