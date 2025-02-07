import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:holobooth_ui/holobooth_ui.dart';

extension HoloboothWidgetTester on WidgetTester {
  void setDisplaySize(Size size) {
    binding.window.physicalSizeTestValue = size;
    binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(() {
      binding.window.clearPhysicalSizeTestValue();
      binding.window.clearDevicePixelRatioTestValue();
    });
  }

  void setLandscapeDisplaySize() {
    setDisplaySize(const Size(HoloboothBreakpoints.large, 1000));
  }

  void setPortraitDisplaySize() {
    setDisplaySize(const Size(HoloboothBreakpoints.small, 1000));
  }
}
