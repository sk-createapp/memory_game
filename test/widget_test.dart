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
  testWidgets('StartUp builds without throwing', (WidgetTester tester) async {
    // 縦長スマートフォン相当の画面サイズを設定（固定レイアウトのため）。
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    // SharedPreferences をモックしてプラグイン未登録による例外を防ぐ。
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ProviderScope(child: StartUp()));
    await tester.pump();

    // ルートの MaterialApp が構築されていることを確認。
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
