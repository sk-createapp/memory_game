import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memory_game/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory_game/constant/color_constant.dart';
import 'package:memory_game/constant/image_path.dart';
import 'package:memory_game/constant/result_messages.dart';
import 'package:memory_game/constant/text_style.dart';
import 'package:memory_game/model/item_table_info.dart';
import 'package:memory_game/view/util/extension.dart';
import 'package:memory_game/state/app_info_state.dart';
import 'package:memory_game/services/admob.dart';
import 'package:memory_game/state/item_table_info_state.dart';
import 'package:memory_game/view/util/confetti.dart';
import 'package:memory_game/view/util/pressable.dart';
import 'package:memory_game/view/util/util.dart';
import 'package:memory_game/view/util/widget.dart';

class ResultView extends ConsumerStatefulWidget {
  // 今回のタイムが自己ベストを更新したか（全問正解時のみ意味を持つ）。
  final bool isNewRecord;

  const ResultView({this.isNewRecord = false, super.key});

  @override
  ConsumerState<ResultView> createState() => _AnswerViewState();
}

class _AnswerViewState extends ConsumerState<ResultView> {
  bool _celebrated = false;

  // 吹き出しメッセージは画面表示ごとに1つだけ決め、
  // 正解アイテムをめくる等の再描画では変わらないよう固定する。
  final int _messageSeed = Random().nextInt(1 << 31);

  @override
  Widget build(BuildContext context) {
    final itemTableInfo = ref.watch(itemTableInfoProvider);
    final gameLevel = ref.watch(gameLevelProvider);

    final cleared =
        isAllCorrect(itemTableInfo.tableItems, itemTableInfo.answerItemNum);
    // 新記録は全問正解時のみ意味を持つ。
    final newRecord = cleared && widget.isNewRecord;

    //全問正解なら一度だけ達成感のある触覚フィードバックを再生する
    if (!_celebrated && cleared) {
      _celebrated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 新記録ならより強い触覚フィードバックを2連続で。
        fireHaptic(PressHaptic.heavy);
        if (newRecord) {
          Future.delayed(const Duration(milliseconds: 140),
              () => fireHaptic(PressHaptic.heavy));
        }
      });
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: DefColor.lightBeige,
        body: Stack(
          children: [
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // 成功・失敗どちらでも吹き出しを出すため、常に高さを確保する。
                  const commentHeight = 52.0;
                  // 新記録バナーを出すぶん、上側の確保領域を広げる。
                  final tableSize = context.tableSizeFor(
                    constraints,
                    topReserve: (newRecord ? 134.0 : 72.0) + context.sectionGap,
                    bottomReserve: context.buttonHeight +
                        commentHeight +
                        context.bannerReserve +
                        context.sectionGap * 4,
                    maxWidthRatio: 0.96,
                  );

                  return Center(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: context.pagePadding),
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(maxWidth: context.contentMaxWidth),
                        child: Column(
                          children: [
                            SizedBox(height: context.sectionGap),
                            //新記録バナー（自己ベスト更新時のみ、大きくポップイン）
                            if (newRecord) ...[
                              NewRecordBanner(
                                text: AppLocalizations.of(context)!
                                    .resultNewRecord,
                              ),
                              SizedBox(height: context.sectionGap),
                            ],
                            //メッセージ
                            Text(
                              getAboveMessageString(itemTableInfo, gameLevel),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.resultTitle,
                            ),
                            //タイム
                            Text(
                              getMemorizeTimeString(itemTableInfo, gameLevel),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.resultTime,
                            ),
                            SizedBox(height: context.sectionGap),
                            //アイテムテーブル
                            SizedBox.square(
                                dimension: tableSize,
                                child: CorrectAnswerTable(
                                    rowNum: itemTableInfo.rowNum,
                                    tableItems: itemTableInfo.tableItems)),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Spacer(),
                                  //ホームボタン
                                  MyTextButton(
                                      onPressed: () {
                                        // ゲーム終了時にインタースティシャルを表示（頻度制御あり）。
                                        // 表示の有無にかかわらずホームへ戻る。
                                        InterstitialAdManager.instance
                                            .maybeShow(
                                          onDone: () {
                                            if (!context.mounted) return;
                                            Navigator.popUntil(context,
                                                (route) => route.isFirst);
                                          },
                                        );
                                      },
                                      text: "Home"),
                                  SizedBox(height: context.sectionGap),
                                  //コメント（キャラクターのしっぽ付き吹き出し）
                                  SizedBox(
                                    height: commentHeight,
                                    child: Row(children: [
                                      Image.asset(
                                        defLevelImages[gameLevel],
                                      ),
                                      Expanded(
                                        child: SpeechBubble(
                                          child: Text(
                                            getResultCommentString(
                                                itemTableInfo),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: DefColor.textBlack,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              height: 1.25,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ]),
                                  ),
                                  SizedBox(height: context.sectionGap),
                                  //バナー
                                  const AdmobBannerWidget(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // クリア時は紙吹雪を画面全体に降らせる。新記録ならより派手に。
            if (cleared)
              Positioned.fill(
                child: ConfettiOverlay(intense: newRecord),
              ),
          ],
        ),
      ),
    );
  }

  //画面上部に表示するメッセージ文
  String getAboveMessageString(ItemTableInfo itemTableInfo, int gameLevel) {
    String message;

    if (isAllCorrect(itemTableInfo.tableItems, itemTableInfo.answerItemNum)) {
      message = AppLocalizations.of(context)!.resultGameClear;
    } else {
      message = AppLocalizations.of(context)!.resultGameFailure;
    }

    return "Level ${gameLevel + 1} $message";
  }

  //吹き出しに表示する一言（成功＝ほめ言葉／新記録／失敗＝励まし）
  String getResultCommentString(ItemTableInfo itemTableInfo) {
    final ResultMessageKind kind;
    if (!isAllCorrect(itemTableInfo.tableItems, itemTableInfo.answerItemNum)) {
      kind = ResultMessageKind.failure;
    } else if (widget.isNewRecord) {
      kind = ResultMessageKind.newRecord;
    } else {
      kind = ResultMessageKind.praise;
    }

    return ResultMessages.pick(
      kind: kind,
      languageCode: Localizations.localeOf(context).languageCode,
      seed: _messageSeed,
    );
  }

  //タイムのテキスト
  String getMemorizeTimeString(ItemTableInfo itemTableInfo, int gameLevel) {
    String ret = " ";

    //メッセージ文生成
    if (isAllCorrect(itemTableInfo.tableItems, itemTableInfo.answerItemNum)) {
      Duration? duration = itemTableInfo.memorizeTime;
      if (duration != null) {
        ret = "Time ${getFormattedTime(duration)}";
      }
    }

    return ret;
  }
}
