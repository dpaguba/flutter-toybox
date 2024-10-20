import 'package:calculator/global/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calculator/screens/calculator.dart';

void main(List<String> args) {
  runApp(const MyApp());
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: "Orbitron"),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Calculator",
            style: TextStyle(color: ColorConst.bText),
          ),
          backgroundColor: ColorConst.wBackground,
          elevation: 0,
        ),
        body: const Calculator(),
      ),
    );
  }
}
