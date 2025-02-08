import 'package:flutter/material.dart';

import '../storage/score_store.dart';
import '../theme/chassis.dart';
import '../widgets/chassis_surface.dart';
import '../widgets/hard_key.dart';
import '../widgets/segment_readout.dart';
import 'game.dart';

/// The machine's front panel: nameplate, high score, and start key.
///
/// The tempo strip is deliberately absent here. The lamp shows how fast a
/// piece is falling, and until a game session has started, nothing is
/// falling: the strip would just be running for nothing. It appears on the
/// game screen once it has something to say.
class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final ScoreStore _store = ScoreStore();
  int _best = 0;

  @override
  void initState() {
    super.initState();
    _loadBest();
  }

  Future<void> _loadBest() async {
    final int best = await _store.load();
    if (!mounted) {
      return;
    }
    setState(() => _best = best);
  }

  Future<void> _play() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const GamePage()),
    );
    await _loadBest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BrushedPanel(
        child: BoundedTextScale(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 5),
                  Text(
                    "TETRIS",
                    key: const ValueKey("intro-title"),
                    style: nameplate(context, factor: 1.5),
                  ),
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SegmentReadout(
                      label: "BEST",
                      value: "$_best",
                      factor: 2.2,
                    ),
                  ),
                  const SizedBox(height: 34),
                  HardKey(
                    key: const ValueKey("intro-start"),
                    label: "START",
                    cap: Chassis.startCap,
                    onPressed: _play,
                  ),
                  const Spacer(flex: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
