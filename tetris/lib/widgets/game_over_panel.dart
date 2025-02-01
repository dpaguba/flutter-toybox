import 'package:flutter/material.dart';

import '../theme/chassis.dart';
import 'chassis_surface.dart';
import 'hard_key.dart';
import 'segment_readout.dart';

/// End-of-game summary: a solid chassis panel with readouts behind glass.
class GameOverPanel extends StatelessWidget {
  const GameOverPanel({
    super.key,
    required this.score,
    required this.lines,
    required this.level,
    required this.isRecord,
    required this.onRestart,
    required this.onQuit,
  });

  final int score;
  final int lines;
  final int level;

  /// Whether this score beat the previous record.
  final bool isRecord;

  final VoidCallback onRestart;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    final Chassis chassis = Chassis.of(context);
    return BrushedPanel(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("GAME OVER", style: nameplate(context)),
                if (isRecord) ...[
                  const SizedBox(height: 10),
                  Text(
                    "NEW RECORD",
                    style: chassisLabel(context, strong: true)
                        .copyWith(color: chassis.record),
                  ),
                ],
                const SizedBox(height: 30),
                SegmentReadout(
                  key: const ValueKey("over-score"),
                  label: "SCORE",
                  value: "$score",
                  factor: 1.7,
                ),
                const SizedBox(height: 20),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      SegmentReadout(
                        key: const ValueKey("over-lines"),
                        label: "LINES",
                        value: "$lines",
                        digits: 3,
                        factor: 0.85,
                      ),
                      const SizedBox(width: 26),
                      SegmentReadout(
                        key: const ValueKey("over-level"),
                        label: "LEVEL",
                        value: "$level",
                        digits: 2,
                        factor: 0.85,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 34),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      HardKey(
                        label: "PLAY AGAIN",
                        cap: Chassis.startCap,
                        onPressed: onRestart,
                      ),
                      const SizedBox(height: 14),
                      HardKey(label: "QUIT", onPressed: onQuit),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
