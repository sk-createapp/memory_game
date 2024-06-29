import 'dart:io';

import 'package:csv/csv.dart';

void main() async {
  const inputFile = "./lib/l10n/list - String.csv";
  const outputFilePath = "./lib/l10n/";
  // CSVファイルの読み込み
  final inputContent = await File(inputFile).readAsString();
  final csvList = const CsvToListConverter().convert(inputContent);
  const langStartColumn = 2;
  const keyColumn = 1;
  const langIDRow = 1;

  // arbファイル生成
  for (int column = langStartColumn; column < csvList[0].length; column++) {
    final arbMessages = {};

    for (int row = langIDRow; row < csvList.length; row++) {
      if (csvList[row].length >= 2) {
        final key = csvList[row][keyColumn].toString();
        final message = csvList[row][column].toString();
        arbMessages[key] = message;
      }
    }
    final arbFileContent = arbMessages.entries
        .map((entry) =>
            '"${entry.key}": "${entry.value.replaceAll('"', r'\"')}"')
        .join(',\n');
    final outputContent = '{\n$arbFileContent\n}';
    // arbファイル書き出し
    await File("${outputFilePath}app_${csvList[langIDRow][column]}.arb")
        .writeAsString(outputContent);
  }
}
