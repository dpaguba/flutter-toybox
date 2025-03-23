import 'package:flutter/material.dart';

import 'pages/intro.dart';
import 'utils/sheet.dart';

/// Entry point.
void main() {
  runApp(const CheckersApp());
}

/// The app's root.
class CheckersApp extends StatelessWidget {
  const CheckersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: pressTheme(Brightness.light),
      darkTheme: pressTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const IntroPage(),
    );
  }
}
