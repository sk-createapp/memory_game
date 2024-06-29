import 'dart:async';
import 'dart:ui';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory_game/constant/color_constant.dart';
import 'package:memory_game/constant/image_path.dart';
import 'package:memory_game/view/util/extension.dart';
import 'package:memory_game/state/app_info_state.dart';
import 'package:memory_game/services/admob.dart';
import 'package:memory_game/state/item_table_info_state.dart';
import 'package:memory_game/view/answer.dart';
import 'package:memory_game/view/util/util.dart';
import 'package:memory_game/view/util/widget.dart';

class MemorizeView extends ConsumerStatefulWidget {
  const MemorizeView({super.key});

  @override
  ConsumerState<MemorizeView> createState() => _MemorizeViewState();
}

class _MemorizeViewState extends ConsumerState<MemorizeView> {
  bool _isHidden = false;
  Timer? _timer;
  final DateTime _startTime = DateTime.now();
  Duration _time = const Duration();

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(milliseconds: 10), // 10ms毎に定期実行
        (Timer timer) {
      setState(() {
        // 変更を画面に反映するため、setState()している
        _time = DateTime.now().difference(_startTime);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final itemTableInfo = ref.watch(itemTableInfoProvider);
    final gameLevel = ref.watch(gameLevelProvider);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: DefColor.lightBeige,
        body: SafeArea(
          child: Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                ColoredBox(
                  color: DefColor.darkBeige,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // ホームボタン
                        HomeButton(
                          onPressed: () {
                            if (_timer != null) {
                              _timer!.cancel();
                            }
                          },
                        ),
                        SizedBox(
                          width: context.widthByRatio(0.05),
                        ),
                        //レベル
                        SizedBox(
                          height: context.widthByRatio(1 / 8),
                          child: FittedBox(
                            fit: BoxFit.fitHeight,
                            child: Text("Level ${gameLevel + 1}",
                                style: const TextStyle(
                                  fontFeatures: [FontFeature.tabularFigures()],
                                  color: DefColor.textBlack,
                                )),
                          ),
                        ),
                        //タイム
                        Expanded(
                          child: Container(
                            alignment: Alignment.bottomRight,
                            child: SizedBox(
                              height: context.widthByRatio(1 / 12),
                              child: FittedBox(
                                fit: BoxFit.fitHeight,
                                child: Text("Time ${getFormattedTime(_time)}",
                                    style: const TextStyle(
                                      fontFeatures: [
                                        FontFeature.tabularFigures()
                                      ],
                                      color: DefColor.textBlack,
                                    )),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                //メッセージ
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 24, right: 24),
                  child: SizedBox(
                    height: context.widthByRatio(0.07),
                    child: FittedBox(
                      alignment: Alignment.topLeft,
                      child: Text(
                        AppLocalizations.of(context)!.memorizeGuide,
                        style: const TextStyle(
                          color: DefColor.textBlack,
                        ),
                      ),
                    ),
                  ),
                ),
                //アイテムテーブル
                SizedBox(
                    width: getItemTableWidth(),
                    child: _isHidden
                        //隠すボタンの桜花状態によってテーブルを切り替える
                        ? HiddenTable(
                            rowNum: itemTableInfo.rowNum,
                            tableItems: itemTableInfo.tableItems)
                        : MemorizeTable(
                            rowNum: itemTableInfo.rowNum,
                            tableItems: itemTableInfo.tableItems)),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Spacer(
                        flex: 1,
                      ),
                      //完了ボタン
                      SizedBox(
                        height: context.widthByRatio(1 / 4),
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: MyTextButton(
                                  onPressed: () {
                                    if (_timer != null) {
                                      _timer!.cancel();
                                    }
                                    ref
                                        .read(itemTableInfoProvider.notifier)
                                        .setMemorizeTime(_time);
                                    List<String> iconChoices = getItemChoices(
                                        36,
                                        itemTableInfo.tableItems,
                                        defImages);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AnswerView(
                                              iconChoices: iconChoices)),
                                    );
                                  },
                                  text: AppLocalizations.of(context)!.cmnOk),
                            ),
                            //隠すボタン
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: MyCircleButton(
                                      onPressed: () {},
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .memorizeHide,
                                        style: const TextStyle(
                                            color: DefColor.textWhite),
                                      )),
                                ),
                                onTapDown: (details) {
                                  setState(() {
                                    _isHidden = !_isHidden;
                                  });
                                },
                                onTapCancel: () {
                                  setState(() {
                                    _isHidden = !_isHidden;
                                  });
                                },
                                onTapUp: (details) {
                                  setState(() {
                                    _isHidden = !_isHidden;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(
                        flex: 2,
                      ),
                      //バナー
                      AdmobBanner(
                        adUnitId: AdMobService().getBannerAdUnitId(),
                        adSize: AdmobBannerSize.BANNER,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double getItemTableWidth() {
    //アイテムボックスの幅設定
    double ret = context.widthByRatio(0.9) *
        (context.sizeHeight / context.sizeWidth) /
        1.67;

    if (ret > context.widthByRatio(0.9)) {
      ret = context.widthByRatio(0.9);
    }

    return ret;
  }
}
