import 'package:calculator/global/color_constants.dart';

import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalculatorScreen extends ConsumerWidget {
  final String a;
  final String b;
  final String operator;
  final String result;

  const CalculatorScreen(
      {super.key,
      required this.a,
      required this.b,
      required this.operator,
      required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: ColorConst.wInsetShadowTop,
              offset: Offset(4, 4),
              blurRadius: 15,
              spreadRadius: 1,
              inset: true,
            ),
            BoxShadow(
              color: ColorConst.wText,
              offset: Offset(-4, -4),
              blurRadius: 15,
              spreadRadius: 1,
              inset: true,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    a,
                    style: const TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  Text(
                    operator,
                    style: const TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  Text(
                    b,
                    style: const TextStyle(
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              child: Text(
                result,
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
