import 'package:calculator/global/color_constants.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PressedWhiteButton extends ConsumerWidget {
  final String textButton;
  final VoidCallback? buttonTapped;

  const PressedWhiteButton(
      {super.key, required this.textButton, this.buttonTapped});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: buttonTapped,
      child: Container(
        decoration: BoxDecoration(
          color: ColorConst.wBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: ColorConst.wInsetShadowTop,
              offset: Offset(4, 4),
              blurRadius: 15,
              spreadRadius: 1,
              inset: true,
            ),
            BoxShadow(
              color: ColorConst.wShadowTop,
              offset: Offset(-4, -4),
              blurRadius: 15,
              spreadRadius: 1,
              inset: true,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: Text(
              textButton,
              style: const TextStyle(
                color: ColorConst.bText,
                fontSize: 30,
                fontFamily: "Orbitron",
              ),
            ),
          ),
        ),
      ),
    );
  }
}
