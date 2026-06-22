// アプリが例外なく起動・描画できることを確認するスモークテスト。
//
// 旧テンプレートのカウンターテストは本アプリと無関係だったため、
// 実アプリ(StartUp)のビルドを検証する内容に置き換えている。

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:memory_game/main.dart';
import 'package:memory_game/view/answer.dart';
import 'package:memory_game/view/memorize.dart';

void main() {
  testWidgets('StartUp builds on compact phone and tablet sizes',
      (WidgetTester tester) async {
    for (final size in [
      const Size(320, 568),
      const Size(768, 1024),
    ]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // SharedPreferences をモックしてプラグイン未登録による例外を防ぐ。
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const ProviderScope(child: StartUp()));
      await tester.pump();

      // ルートの MaterialApp が構築され、レイアウト例外が出ていないことを確認。
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('main game flow lays out on iPhone SE and iPad sizes',
      (WidgetTester tester) async {
    for (final size in [
      const Size(375, 667),
      const Size(820, 1180),
    ]) {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(const ProviderScope(child: StartUp()));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Start'), findsOneWidget);

      await tester.tap(find.text('Start'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(MemorizeView), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('OK'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(AnswerView), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
