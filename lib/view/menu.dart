import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory_game/constant/color_constant.dart';
import 'package:memory_game/view/util/extension.dart';
import 'package:memory_game/services/admob.dart';

//メニュー（現状非使用）
class MenuView extends ConsumerStatefulWidget {
  const MenuView({super.key});

  @override
  ConsumerState<MenuView> createState() => _MemorizeViewState();
}

class _MemorizeViewState extends ConsumerState<MenuView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DefColor.lightBeige,
      appBar: AppBar(
        backgroundColor: DefColor.lightBeige,
      ),
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              SizedBox(
                height: context.widthByRatio(1 / 10),
                child: const FittedBox(
                  child: Text(
                    "レビューする",
                    style: TextStyle(
                      color: DefColor.textBlack,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Spacer(
                      flex: 1,
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
    );
  }
}
