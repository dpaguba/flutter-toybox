import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// Both players' names and scores.
///
/// Each half gets exactly half the width via [Expanded], and the name is
/// clipped to a single line with an ellipsis. The old panel laid out two
/// thirty-pixel [Padding] widgets in a [Row] with no width constraint, which
/// let it run off the edge on a narrow screen.
class ScorePanel extends StatelessWidget {
  const ScorePanel({
    super.key,
    required this.leftName,
    required this.rightName,
    required this.leftScore,
    required this.rightScore,
    required this.activeIsLeft,
  });

  final String leftName;
  final String rightName;
  final int leftScore;
  final int rightScore;
  final bool activeIsLeft;

  Widget _side(String name, int score, bool active) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: customFontWhite.copyWith(
              fontSize: 12,
              color: active ? Colors.amber : Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            score.toString(),
            style: customFontWhite.copyWith(fontSize: 18),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          _side(leftName, leftScore, activeIsLeft),
          _side(rightName, rightScore, !activeIsLeft),
        ],
      ),
    );
  }
}
