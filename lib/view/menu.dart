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
              Padding(
                padding: EdgeInsets.all(context.pagePadding),
                child: const Text(
                  "レビューする",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: DefColor.textBlack,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
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
                    const AdmobBannerWidget(),
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
