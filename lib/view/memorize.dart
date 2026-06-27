import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memory_game/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory_game/constant/color_constant.dart';
import 'package:memory_game/constant/image_path.dart';
import 'package:memory_game/constant/text_style.dart';
import 'package:memory_game/view/util/extension.dart';
import 'package:memory_game/state/app_info_state.dart';
import 'package:memory_game/services/admob.dart';
import 'package:memory_game/services/sound_service.dart';
import 'package:memory_game/state/item_table_info_state.dart';
import 'package:memory_game/view/answer.dart';
import 'package:memory_game/view/util/pressable.dart';
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
  // タイマー表示だけを更新するための通知。ページ全体のsetState()を避け、
  // アイテムテーブル（SVGタイル）の毎フレーム再構築を防ぐ。
  final ValueNotifier<Duration> _timeNotifier =
      ValueNotifier<Duration>(const Duration());

  @override
  void initState() {
    // プレイ画面（覚える）では集中の妨げになる操作音を止める（触覚は残す）。
    SoundService.instance.suppressTaps = true;
    _timer = Timer.periodic(const Duration(milliseconds: 10), // 10ms毎に定期実行
        (Timer timer) {
      // タイマー表示だけを更新する（setState()しない）ことで、
      // テーブルなどの再構築を避ける。
      _timeNotifier.value = DateTime.now().difference(_startTime);
    });
    super.initState();
  }

  @override
  void dispose() {
    // プレイ画面を離れたら操作音の抑制を解除する。
    SoundService.instance.suppressTaps = false;
    _timer?.cancel();
    _timeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemTableInfo = ref.watch(itemTableInfoProvider);
    final gameLevel = ref.watch(gameLevelProvider);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: DefColor.lightBeige,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final actionHeight =
                  context.circleButtonSize.clamp(context.buttonHeight, 72.0);
              final tableSize = context.tableSizeFor(
                constraints,
                topReserve: context.topBarHeight +
                    context.guideHeight +
                    context.sectionGap * 2,
                bottomReserve:
                    actionHeight + context.bannerReserve + context.sectionGap * 3,
              );

              return Column(
                children: [
                  // タイマー表示の更新だけを_timeNotifierに購読させ、
                  // ティック毎の再構築をGameTopBarに限定する。
                  ValueListenableBuilder<Duration>(
                    valueListenable: _timeNotifier,
                    builder: (context, time, _) {
                      return GameTopBar(
                        level: gameLevel,
                        trailingIcon: Icons.timer_outlined,
                        trailingText: getFormattedTime(time),
                        onHomePressed: () {
                          if (_timer != null) {
                            _timer!.cancel();
                          }
                        },
                      );
                    },
                  ),
                  //メッセージ
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      context.pagePadding,
                      context.sectionGap,
                      context.pagePadding,
                      0,
                    ),
                    child: SizedBox(
                      width: context.contentWidth,
                      height: context.guideHeight,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLocalizations.of(context)!.memorizeGuide,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.guide,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.sectionGap),
                  //アイテムテーブル
                  SizedBox.square(
                      dimension: tableSize,
                      child: _isHidden
                          //隠すボタンの状態によってテーブルを切り替える
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
                        const Spacer(),
                        //完了ボタン
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: context.pagePadding),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth: context.contentMaxWidth),
                            child: SizedBox(
                              height: actionHeight,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  MyTextButton(
                                      onPressed: () {
                                        if (_timer != null) {
                                          _timer!.cancel();
                                        }
                                        ref
                                            .read(
                                                itemTableInfoProvider.notifier)
                                            .setMemorizeTime(
                                                _timeNotifier.value);
                                        List<String> iconChoices =
                                            getItemChoices(
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
                                      // 右側の「かくす」ボタンとの間に余白を作る。
                                      widthRatio: 0.38,
                                      text:
                                          AppLocalizations.of(context)!.cmnOk),
                                  //隠すボタン（長押しでアイテムを隠す）
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: MyCircleButton(
                                      haptic: PressHaptic.medium,
                                      onHoldChanged: (held) {
                                        setState(() {
                                          _isHidden = held;
                                        });
                                      },
                                      // 円形ボタン内に必ず文字が収まるよう、
                                      // 長い翻訳語（Verstecken / Скрывать など）は
                                      // 縮小してフィットさせる。
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .memorizeHide,
                                            maxLines: 1,
                                            softWrap: false,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: DefColor.textWhite,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: context.sectionGap),
                        //バナー
                        //広告のロード状態（読込中／成功／失敗で畳む）に関わらず
                        //下端の確保高さを一定にして、上の完了・隠すボタンが
                        //広告の有無で上下にずれないように固定スロットへ収める。
                        SizedBox(
                          height: context.bannerReserve,
                          child: const Align(
                            alignment: Alignment.bottomCenter,
                            child: AdmobBannerWidget(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
