import 'package:calculator/global/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BlackButton extends ConsumerWidget {
  final String textButton;
  final VoidCallback? buttonTapped;

  const BlackButton({
    super.key,
    required this.textButton,
    this.buttonTapped,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: buttonTapped,
      child: Container(
        decoration: BoxDecoration(
            color: ColorConst.bBackground,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: ColorConst.bShadowBottom,
                offset: Offset(4, 4),
                blurRadius: 15,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: ColorConst.wText,
                offset: Offset(-4, -4),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
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
