import 'package:flutter/material.dart';

import '../theme/chassis.dart';
import 'chassis_surface.dart';
import 'hard_key.dart';

/// Pause shutter: an opaque chassis panel slid over the well.
///
/// The panel is opaque because it is metal, not glass: while the clock is
/// stopped, the field is hidden and the next move cannot be peeked at.
class PauseOverlay extends StatelessWidget {
  const PauseOverlay({
    super.key,
    required this.onResume,
    required this.onQuit,
  });

  final VoidCallback onResume;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    return BrushedPanel(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("PAUSED", style: nameplate(context)),
                const SizedBox(height: 34),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 260),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      HardKey(
                        label: "RESUME",
                        cap: Chassis.startCap,
                        onPressed: onResume,
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
