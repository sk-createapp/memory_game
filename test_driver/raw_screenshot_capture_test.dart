import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:integration_test/integration_test_driver_extended.dart';

const _outRoot = '/tmp/memory_game_iphone_raw';

Future<void> main() async {
  final driver = await FlutterDriver.connect();
  await integrationDriver(
    driver: driver,
    onScreenshot: (name, bytes, [args]) async {
      final parts = name.split('_');
      if (parts.length != 2) return false;
      final lang = parts[0];
      final scene = parts[1];
      final index = switch (scene) {
        'memorize' => '01',
        'hidden' => '02',
        'answer' => '03',
        'record' => '04',
        'home' => '05',
        _ => null,
      };
      if (index == null) return false;

      final dir = Directory('$_outRoot/$lang');
      dir.createSync(recursive: true);
      final file = File('${dir.path}/store_$index.png');
      file.writeAsBytesSync(bytes, flush: true);
      stdout.writeln('saved ${file.path}');
      return true;
    },
    writeResponseOnFailure: true,
  );
}
