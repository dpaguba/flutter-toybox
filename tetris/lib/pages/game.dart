import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../logic/game_engine.dart';
import '../models/tetromino.dart';
import '../storage/score_store.dart';
import '../theme/chassis.dart';
import '../widgets/chassis_surface.dart';
import '../widgets/game_over_panel.dart';
import '../widgets/hard_key.dart';
import '../widgets/key_deck.dart';
import '../widgets/key_glyph.dart';
import '../widgets/pattern_bank.dart';
import '../widgets/pause_overlay.dart';
import '../widgets/playfield_view.dart';
import '../widgets/segment_readout.dart';
import '../widgets/tempo_strip.dart';

/// The working face of the machine: readouts, tempo strip, well, banks, and keys.
class GamePage extends StatefulWidget {
  const GamePage({super.key, this.engine});

  /// A ready-made engine instead of a new one.
  ///
  /// Needed by tests, so they can play a known-in-advance sequence of pieces:
  /// a normal game always creates its own engine with a shuffled bag.
  final GameEngine? engine;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  late final GameEngine _engine = widget.engine ?? GameEngine();
  final ScoreStore _store = ScoreStore();

  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;
  bool _isRecord = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _engine.start();
    _ticker = createTicker(_onTick);
    _syncTicker();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final int delta = (elapsed - _lastTick).inMilliseconds;
    _lastTick = elapsed;
    if (delta <= 0 || _engine.status != GameStatus.running) {
      return;
    }
    final String before = _snapshot();
    _engine.update(delta);
    if (_snapshot() != before) {
      setState(() {});
    }
    _afterMove();
  }

  /// Keeps the clock running only while pieces are actually falling.
  ///
  /// While paused and after game over, no one needs frames, and a test
  /// would otherwise wait for silence that would never come.
  void _syncTicker() {
    final bool shouldRun = _engine.status == GameStatus.running;
    if (shouldRun && !_ticker.isActive) {
      _lastTick = Duration.zero;
      _ticker.start();
    } else if (!shouldRun && _ticker.isActive) {
      _ticker.stop();
    }
  }

  void _afterMove() {
    _syncTicker();
    if (_engine.status == GameStatus.over) {
      _finish();
    }
  }

  String _snapshot() {
    final piece = _engine.current;
    return "${_engine.status}|${_engine.score}|${_engine.lines}|"
        "${piece?.type}|${piece?.rotation}|${piece?.x}|${piece?.y}";
  }

  void _act(VoidCallback action) {
    if (_engine.status != GameStatus.running) {
      return;
    }
    setState(action);
    _afterMove();
  }

  Future<void> _finish() async {
    if (_saved) {
      return;
    }
    _saved = true;
    _syncTicker();
    final bool record = await _store.save(_engine.score);
    if (!mounted) {
      return;
    }
    setState(() => _isRecord = record);
  }

  void _restart() {
    setState(() {
      _saved = false;
      _isRecord = false;
      _engine.start();
    });
    _syncTicker();
  }

  void _pause() {
    setState(_engine.pause);
    _syncTicker();
  }

  void _resume() {
    setState(_engine.resume);
    _syncTicker();
  }

  void _quit() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BrushedPanel(
        child: BoundedTextScale(
          child: SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                  child: Column(
                    children: [
                      _readouts(),
                      const SizedBox(height: 12),
                      TempoStrip(
                        stepMs: _engine.gravityMs,
                        running: _engine.status == GameStatus.running,
                        level: _engine.level,
                      ),
                      const SizedBox(height: 10),
                      Expanded(child: _wellAndBanks()),
                      const SizedBox(height: 14),
                      KeyDeck(
                        canHold: _engine.canHold,
                        onLeft: () => _act(_engine.moveLeft),
                        onRight: () => _act(_engine.moveRight),
                        onRotate: () =>
                            _act(() => _engine.rotate(clockwise: true)),
                        onSoftDrop: () => _act(_engine.softDrop),
                        onHardDrop: () => _act(_engine.hardDrop),
                        onHold: () => _act(_engine.hold),
                      ),
                    ],
                  ),
                ),
                if (_engine.status == GameStatus.paused)
                  PauseOverlay(onResume: _resume, onQuit: _quit),
                if (_engine.status == GameStatus.over)
                  GameOverPanel(
                    score: _engine.score,
                    lines: _engine.lines,
                    level: _engine.level,
                    isRecord: _isRecord,
                    onRestart: _restart,
                    onQuit: _quit,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The instrument glass: score in large digits, level and lines beside it.
  ///
  /// The glass is a single piece, so at very large text sizes it shrinks as
  /// a whole rather than spreading out into a wrapped line.
  Widget _readouts() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SegmentReadout(
                  key: const ValueKey("stat-score"),
                  label: "SCORE",
                  value: "${_engine.score}",
                  factor: 1.6,
                ),
                const SizedBox(width: 26),
                SegmentReadout(
                  key: const ValueKey("stat-level"),
                  label: "LEVEL",
                  value: "${_engine.level}",
                  digits: 2,
                  factor: 0.8,
                ),
                const SizedBox(width: 16),
                SegmentReadout(
                  key: const ValueKey("stat-lines"),
                  label: "LINES",
                  value: "${_engine.lines}",
                  digits: 3,
                  factor: 0.8,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        HardKey(
          key: const ValueKey("control-pause"),
          mark: KeyMark.pause,
          compact: true,
          onPressed: _pause,
        ),
      ],
    );
  }

  /// The well and banks, measured against whatever room is left on screen.
  ///
  /// Bank width is derived from height, not from a fixed number: otherwise
  /// on a short screen the fourth window simply would not fit.
  Widget _wellAndBanks() {
    return LayoutBuilder(
      builder: (context, limits) {
        final double window =
            (limits.maxHeight - _labelHeight(context) * 2 - _bankGaps) / 4;
        final double inner =
            (window - PatternBank.windowPadding * 2) * PatternBank.windowAspect;
        final double bankWidth = (inner + PatternBank.windowPadding * 2)
            .clamp(40.0, 100.0)
            .toDouble();
        final double wellWidth = math.min(
          limits.maxWidth - bankWidth - 12,
          limits.maxHeight * _engine.field.columns / _engine.field.rows,
        );
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: SizedBox(
                  width: math.max(0, wellWidth),
                  child: AspectRatio(
                    aspectRatio: _engine.field.columns / _engine.field.rows,
                    child: PlayfieldView(
                      field: _engine.field,
                      current: _engine.current,
                      ghost: _engine.ghost,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(width: bankWidth, child: _banks()),
          ],
        );
      },
    );
  }

  /// Gaps between the four bank windows and after the last of them.
  static const double _bankGaps = 14 + 6 * 3;

  /// The exact height of the stenciled label above a window.
  double _labelHeight(BuildContext context) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: "HOLD", style: chassisLabel(context)),
      textDirection: TextDirection.ltr,
      textScaleFactor: MediaQuery.textScaleFactorOf(context),
    )..layout();
    return painter.height + PatternBank.labelGap;
  }

  Widget _banks() {
    final List<TetrominoType> next = _engine.next;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PatternBank(
          key: const ValueKey("preview-hold"),
          label: "HOLD",
          type: _engine.held,
          dimmed: !_engine.canHold,
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < next.length; i++) ...[
          PatternBank(
            key: ValueKey("preview-next-$i"),
            label: i == 0 ? "NEXT" : null,
            type: next[i],
          ),
          const SizedBox(height: 6),
        ],
      ],
    );
  }
}
