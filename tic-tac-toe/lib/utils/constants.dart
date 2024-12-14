import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color backgroundColor = Color.fromARGB(
  255,
  33,
  33,
  33,
);

const Color borderColor = Color.fromARGB(
  255,
  97,
  97,
  97,
);

final TextStyle customFontBlack = GoogleFonts.pressStart2p(
  textStyle: const TextStyle(
    color: Color.fromARGB(255, 0, 0, 0),
    letterSpacing: 3,
  ),
);

final TextStyle customFontWhite = GoogleFonts.pressStart2p(
  textStyle: const TextStyle(
    color: Colors.white,
    letterSpacing: 3,
    fontSize: 15,
  ),
);

/// The X mark as a seven-by-seven matrix. A one is a filled pixel.
const List<List<int>> markX = [
  [1, 0, 0, 0, 0, 0, 1],
  [0, 1, 0, 0, 0, 1, 0],
  [0, 0, 1, 0, 1, 0, 0],
  [0, 0, 0, 1, 0, 0, 0],
  [0, 0, 1, 0, 1, 0, 0],
  [0, 1, 0, 0, 0, 1, 0],
  [1, 0, 0, 0, 0, 0, 1],
];

/// The O mark as a seven-by-seven matrix.
const List<List<int>> markO = [
  [0, 1, 1, 1, 1, 1, 0],
  [1, 0, 0, 0, 0, 0, 1],
  [1, 0, 0, 0, 0, 0, 1],
  [1, 0, 0, 0, 0, 0, 1],
  [1, 0, 0, 0, 0, 0, 1],
  [1, 0, 0, 0, 0, 0, 1],
  [0, 1, 1, 1, 1, 1, 0],
];
