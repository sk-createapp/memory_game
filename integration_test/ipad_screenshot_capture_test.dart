import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:memory_game/main.dart' as app;
import 'package:memory_game/services/sound_service.dart';
import 'package:memory_game/state/app_info_state.dart';
import 'package:memory_game/view/answer.dart';
import 'package:memory_game/view/home.dart';
import 'package:memory_game/view/memorize.dart';
import 'package:memory_game/view/record.dart';
import 'package:memory_game/view/util/widget.dart';

const _lang = String.fromEnvironment('SCREENSHOT_LANG', defaultValue: 'ja');

Future<void> _pumpFor(WidgetTester tester, Duration duration) async {
  final end = DateTime.now().add(duration);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 8),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out waiting for $finder');
}

Future<void> _shot(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String scene,
) async {
  await _pumpFor(tester, const Duration(milliseconds: 700));
  await binding.takeScreenshot('${_lang}_$scene');
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.platformDispatcher.localeTestValue = Locale(_lang);

  testWidgets('capture $_lang iPad screenshots', (tester) async {
    app.main();
    SoundService.instance.setEnabled(false);
    await _waitFor(tester, find.byType(HomeView));
    SoundService.instance.setEnabled(false);
    await _pumpFor(tester, const Duration(seconds: 2));

    await _shot(binding, tester, 'home');

    ProviderScope.containerOf(tester.element(find.byType(HomeView)))
        .read(gameLevelProvider.notifier)
        .select(4);
    await _pumpFor(tester, const Duration(milliseconds: 400));

    SoundService.instance.setEnabled(false);
    await tester.tap(find.byType(MyTextButton).last);
    await _waitFor(tester, find.byType(MemorizeView));
    await _shot(binding, tester, 'memorize');

    final hideButton = find.byType(MyCircleButton).last;
    final gesture = await tester.startGesture(tester.getCenter(hideButton));
    await _pumpFor(tester, const Duration(milliseconds: 900));
    await _shot(binding, tester, 'hidden');
    await gesture.up();
    await _pumpFor(tester, const Duration(milliseconds: 300));

    SoundService.instance.setEnabled(false);
    await tester.tap(find.byType(MyTextButton).last);
    await _waitFor(tester, find.byType(AnswerView));
    await _shot(binding, tester, 'answer');

    SoundService.instance.setEnabled(false);
    await tester.tap(find.byType(HomeButton).first);
    await _waitFor(tester, find.byType(HomeView));
    await _pumpFor(tester, const Duration(milliseconds: 700));

    SoundService.instance.setEnabled(false);
    await tester.tap(find.byType(RecordsButton));
    await _waitFor(tester, find.byType(RecordView));
    await _shot(binding, tester, 'record');
  });
}
