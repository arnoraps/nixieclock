import 'package:flutter/widgets.dart';
import 'package:flutter_clock_helper/customizer.dart';
import 'package:flutter_clock_helper/model.dart';

import 'nixie_clock.dart';

void main() {
  // Start the clock
  runApp(ClockCustomizer((ClockModel model) => NixieClock(model)));
}