// アプリが例外なく起動・描画できることを確認するスモークテスト。
//
// 旧テンプレートのカウンターテストは本アプリと無関係だったため、
// 実アプリ(StartUp)のビルドを検証する内容に置き換えている。

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:memory_game/main.dart';

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
}
