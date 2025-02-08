import 'package:flutter/material.dart';

import 'pages/intro.dart';
import 'theme/chassis.dart';

void main() {
  runApp(const TetrisApp());
}

/// The app's root.
class TetrisApp extends StatelessWidget {
  const TetrisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _finish(Brightness.light),
      darkTheme: _finish(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const IntroPage(),
    );
  }

  /// Finish matched to the light the machine is viewed under.
  static ThemeData _finish(Brightness brightness) {
    final Chassis chassis =
        brightness == Brightness.dark ? Chassis.night : Chassis.day;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorSchemeSeed: Chassis.ledOn,
      scaffoldBackgroundColor: chassis.metalLow,
    );
  }
}
