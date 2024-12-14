import 'package:flutter/material.dart';

import 'pixel_mark.dart';

class _GridPainter extends CustomPainter {
  _GridPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double horizontalStep = size.width / 3;
    final double verticalStep = size.height / 3;
    final double thickness = size.shortestSide / 3 / 8;
    final paint = Paint()
      ..color = color
      ..isAntiAlias = false;
    for (var i = 1; i < 3; i++) {
      canvas.drawRect(
        Rect.fromLTWH(horizontalStep * i - thickness / 2, 0, thickness, size.height),
        paint,
      );
      canvas.drawRect(
        Rect.fromLTWH(0, verticalStep * i - thickness / 2, size.width, thickness),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.color != color;
}

class _AppearingMark extends StatefulWidget {
  const _AppearingMark({required this.mark, required this.color});

  final String mark;
  final Color color;

  @override
  State<_AppearingMark> createState() => _AppearingMarkState();
}

class _AppearingMarkState extends State<_AppearingMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
      child: PixelMark(mark: widget.mark, color: widget.color),
    );
  }
}

/// A three-by-three board with a pixel grid and pixel marks.
class PixelBoard extends StatelessWidget {
  const PixelBoard({
    super.key,
    required this.cells,
    required this.onTap,
    this.winningLine,
    this.enabled = true,
  });

  final List<String> cells;
  final void Function(int index) onTap;
  final List<int>? winningLine;

  /// When false, cells do not respond to taps: for example, while the bot is thinking.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _GridPainter(Colors.white70)),
          ),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 9,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemBuilder: (context, index) {
              final bool inLine =
                  winningLine != null && winningLine!.contains(index);
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  key: ValueKey('cell-$index'),
                  onTap: enabled ? () => onTap(index) : null,
                  splashColor: Colors.white24,
                  child: cells[index].isEmpty
                      ? const SizedBox.expand()
                      : Padding(
                          key: ValueKey('mark-$index-${cells[index]}'),
                          padding: const EdgeInsets.all(8),
                          child: _AppearingMark(
                            mark: cells[index],
                            color: inLine ? Colors.amber : Colors.white,
                          ),
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
