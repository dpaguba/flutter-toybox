import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// The "back" link in the top-left corner of the game screen.
class BackLink extends StatelessWidget {
  const BackLink({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            "< MAIN MENU",
            style: customFontWhite.copyWith(fontSize: 10),
          ),
        ),
      ),
    );
  }
}
