import 'dart:math' as math;

import 'package:flutter/material.dart';

extension DispSize on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);
  double get sizeWidth => screenSize.width;
  double get sizeHeight => screenSize.height;
  double get shortSide => math.min(sizeWidth, sizeHeight);

  bool get isCompactWidth => sizeWidth < 360;
  bool get isTabletWidth => sizeWidth >= 600;

  double get pagePadding {
    if (isCompactWidth) {
      return 12;
    }
    if (isTabletWidth) {
      return 32;
    }
    return 20;
  }

  // タブレットでは中央カラムの最大幅を画面幅に応じて段階的に広げ、
  // iPad で左右の余白だけが大きく空く（横幅が一律で狭く見える）のを防ぐ。
  // ただし広げすぎるとボタンや文字が間延びするため上限を設ける。
  double get contentMaxWidth {
    if (!isTabletWidth) return 420;
    return (sizeWidth * 0.72).clamp(560.0, 760.0);
  }
  double get contentWidth {
    return math.min(sizeWidth - pagePadding * 2, contentMaxWidth);
  }

  double get topBarHeight => isCompactWidth ? 58 : 66;
  double get guideHeight => isCompactWidth ? 28 : 32;
  double get buttonHeight => isCompactWidth ? 52 : 58;
  double get circleButtonSize => isCompactWidth ? 56 : 64;
  double get homeButtonSize => isCompactWidth ? 46 : 52;
  double get levelSelectHeight => isCompactWidth ? 70 : 82;
  double get sectionGap => isCompactWidth ? 10 : 16;

  /// アンカー型アダプティブ（Large）バナーのために確保しておく高さ。
  ///
  /// このバナーは画面高さの最大15%まで大きくなるため、レイアウトでは
  /// その上限ぶんを確保しておかないと下端がオーバーフローする。
  double get bannerReserve =>
      math.max(50.0, (sizeHeight * 0.15).ceilToDouble());

  double buttonWidth([double widthRatio = 0.5]) {
    final ratioScale = widthRatio / 0.5;
    final width = contentWidth * 0.68 * ratioScale;
    return width.clamp(96.0, math.min(contentWidth, 320.0));
  }

  double buttonHeightFor([double heightRatio = 0.15]) {
    final ratioScale = heightRatio / 0.15;
    return (buttonHeight * ratioScale).clamp(42.0, 70.0);
  }

  double tableSizeFor(BoxConstraints constraints,
      {double topReserve = 0,
      double bottomReserve = 0,
      double maxWidthRatio = 1}) {
    final availableWidth = math.min(contentWidth, constraints.maxWidth) *
        maxWidthRatio.clamp(0.0, 1.0);
    final availableHeight = constraints.maxHeight - topReserve - bottomReserve;
    // 盤面は正方形。タブレットでは横幅の拡大に合わせて上限も引き上げ、
    // 広がったカラム幅と高さの許す範囲で盤面を大きく表示する。
    final maxTableSize = isTabletWidth ? 640.0 : 420.0;

    return math
        .min(math.min(availableWidth, availableHeight), maxTableSize)
        .clamp(180.0, maxTableSize);
  }
}
