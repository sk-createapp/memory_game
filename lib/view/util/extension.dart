import 'package:flutter/material.dart';

extension DispSize on BuildContext {
  double get sizeWidth => MediaQuery.of(this).size.width;
  double get sizeHeight => MediaQuery.of(this).size.height;

  double widthByRatio(double ratio) {
    return MediaQuery.of(this).size.width * ratio;
  }

  double heightByRatio(double ratio) {
    return MediaQuery.of(this).size.height * ratio;
  }
}
