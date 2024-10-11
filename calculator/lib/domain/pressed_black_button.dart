import 'package:calculator/global/color_constants.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PressedBlackButton extends ConsumerWidget {
  final String textButton;
  final VoidCallback? buttonTapped;

  const PressedBlackButton({
    super.key,
    required this.textButton,
    this.buttonTapped,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: buttonTapped,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
              color: ColorConst.bBackground,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                    color: ColorConst.bShadowTop,
                    offset: Offset(-6, -6),
                    blurRadius: 15,
                    spreadRadius: 1,
                    inset: true),
                BoxShadow(
                    color: ColorConst.bShadowBottom,
                    offset: Offset(6, 6),
                    blurRadius: 15,
                    spreadRadius: 1,
                    inset: true),
              ]),
          child: Center(
            child: Text(
              textButton,
              style: const TextStyle(
                color: ColorConst.wText,
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
