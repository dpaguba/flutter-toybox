import 'package:flutter/material.dart';

import '../models/tetromino.dart';

/// The key color for each of the seven pieces.
///
/// The colors are flat, like paint on a tool's keys: no glow, no
/// gradients. All seven read clearly against the dark bottom of the well
/// and are never confused with each other even at a glance.
const Map<TetrominoType, Color> pieceColors = {
  TetrominoType.i: Color(0xFF3FC6DC),
  TetrominoType.o: Color(0xFFF2C11B),
  TetrominoType.t: Color(0xFFB36FE0),
  TetrominoType.s: Color(0xFF5CC463),
  TetrominoType.z: Color(0xFFF0574E),
  TetrominoType.j: Color(0xFF5A8CE8),
  TetrominoType.l: Color(0xFFEE8A2B),
};

/// The color of piece `type`.
///
/// Raises:
///   ArgumentError: if no color is set for the piece.
Color colorOf(TetrominoType type) {
  final Color? color = pieceColors[type];
  if (color == null) {
    throw ArgumentError.value(type, "type", "No color set for the piece");
  }
  return color;
}
