//回答対象のアイテム
class TargetItem {
  final int posIndex;
  final String icon;
  final bool isAnswerItem;

  const TargetItem({
    required this.posIndex,
    required this.icon,
    required this.isAnswerItem,
  });
}

//テーブルに表示するアイテム
class TableItem {
  String? icon;
  final bool isShowItem;
  final bool isAnswerItem;
  String? answeredIcon;

  TableItem({
    this.icon,
    required this.isShowItem,
    required this.isAnswerItem,
    this.answeredIcon,
  });

  TableItem copyWith({
    String? icon,
    bool? isShowItem,
    bool? isAnswerItem,
    String? answeredIcon,
  }) {
    return TableItem(
      icon: icon ?? this.icon,
      isShowItem: isShowItem ?? this.isShowItem,
      isAnswerItem: isAnswerItem ?? this.isAnswerItem,
      answeredIcon: answeredIcon ?? this.answeredIcon,
    );
  }
}

// テーブル情報
class ItemTableInfo {
  final List<TableItem> tableItems; //テーブルに表示するアイテム
  final int columnNum; //行数
  final int rowNum; //列数
  final int answerItemNum; //表示するアイテムの数
  final Duration? memorizeTime; //回答時間

  ItemTableInfo({
    required this.tableItems,
    required this.columnNum,
    required this.rowNum,
    required this.answerItemNum,
    this.memorizeTime,
  });

  ItemTableInfo copyWith({
    List<TableItem>? tableItems,
    int? columnNum,
    int? rowNum,
    int? answerItemNum,
    Duration? memorizeTime,
  }) {
    return ItemTableInfo(
      tableItems:
          tableItems ?? List.of(this.tableItems.map((e) => e.copyWith())),
      columnNum: columnNum ?? this.columnNum,
      rowNum: rowNum ?? this.rowNum,
      answerItemNum: answerItemNum ?? this.answerItemNum,
      memorizeTime: memorizeTime ?? this.memorizeTime,
    );
  }
}
