import 'package:flutter_test/flutter_test.dart';
import 'package:tetris/logic/rotation.dart';
import 'package:tetris/models/cell.dart';
import 'package:tetris/models/piece.dart';
import 'package:tetris/models/playfield.dart';
import 'package:tetris/models/tetromino.dart';

void main() {
  test('on a clean field, rotation does not shift the piece', () {
    final field = Playfield();
    const piece = Piece(type: TetrominoType.t, rotation: 0, x: 4, y: 5);
    final turned = RotationSystem.rotate(
      piece: piece,
      field: field,
      clockwise: true,
    );
    expect(turned, isNotNull);
    expect(turned!.rotation, 1);
    expect(turned.x, 4);
    expect(turned.y, 5);
  });

  test('four rotations return the piece to the same position', () {
    final field = Playfield();
    for (final type in TetrominoType.values) {
      Piece piece = Piece(type: type, rotation: 0, x: 4, y: 8);
      for (var i = 0; i < 4; i++) {
        final next = RotationSystem.rotate(
          piece: piece,
          field: field,
          clockwise: true,
        );
        expect(next, isNotNull, reason: "$type");
        piece = next!;
      }
      expect(piece.rotation, 0, reason: "$type");
      expect(piece.x, 4, reason: "$type");
      expect(piece.y, 8, reason: "$type");
    }
  });

  test('T is pushed away from the left wall', () {
    final field = Playfield();
    const piece = Piece(type: TetrominoType.t, rotation: 1, x: -1, y: 4);
    expect(field.fits(piece), isTrue);

    final turned = RotationSystem.rotate(
      piece: piece,
      field: field,
      clockwise: false,
    );
    expect(turned, isNotNull);
    expect(turned!.rotation, 0);
    expect(turned.x, 0);
    expect(turned.y, 4);
    expect(field.fits(turned), isTrue);
  });

  test('T is pushed away from the right wall', () {
    final field = Playfield();
    const piece = Piece(type: TetrominoType.t, rotation: 3, x: 8, y: 4);
    expect(field.fits(piece), isTrue);

    final turned = RotationSystem.rotate(
      piece: piece,
      field: field,
      clockwise: true,
    );
    expect(turned, isNotNull);
    expect(turned!.rotation, 0);
    expect(turned.x, 7);
    expect(turned.y, 4);
    expect(field.fits(turned), isTrue);
  });

  test('I is pushed away from the left wall by two cells', () {
    final field = Playfield();
    const piece = Piece(type: TetrominoType.i, rotation: 1, x: -2, y: 0);
    expect(piece.cells.toSet(), {
      const Cell(0, 0),
      const Cell(0, 1),
      const Cell(0, 2),
      const Cell(0, 3),
    });

    final turned = RotationSystem.rotate(
      piece: piece,
      field: field,
      clockwise: true,
    );
    expect(turned, isNotNull);
    expect(turned!.rotation, 2);
    expect(turned.x, 0);
    expect(turned.y, 0);
  });

  test('I is pushed away from the right wall', () {
    final field = Playfield();
    const piece = Piece(type: TetrominoType.i, rotation: 1, x: 7, y: 0);
    expect(piece.cells.every((cell) => cell.x == 9), isTrue);

    final turned = RotationSystem.rotate(
      piece: piece,
      field: field,
      clockwise: false,
    );
    expect(turned, isNotNull);
    expect(turned!.rotation, 0);
    expect(turned.x, 6);
  });

  test('T is pushed away from a placed piece', () {
    final field = Playfield();
    field.setAt(4, 1, TetrominoType.z);
    const piece = Piece(type: TetrominoType.t, rotation: 1, x: 4, y: 0);
    expect(field.fits(piece), isTrue);

    final turned = RotationSystem.rotate(
      piece: piece,
      field: field,
      clockwise: false,
    );
    expect(turned, isNotNull);
    expect(turned!.rotation, 0);
    expect(turned.x, 5);
    expect(turned.y, 0);
    expect(field.fits(turned), isTrue);
  });

  test('a wedged piece does not rotate', () {
    final field = Playfield();
    for (var y = 0; y < field.rows; y++) {
      for (var x = 0; x < field.columns; x++) {
        field.setAt(x, y, TetrominoType.o);
      }
    }
    for (var y = 0; y < 3; y++) {
      field.setAt(0, y, null);
    }
    const piece = Piece(type: TetrominoType.i, rotation: 1, x: -2, y: 0);
    expect(
      RotationSystem.rotate(piece: piece, field: field, clockwise: true),
      isNull,
    );
  });

  test('each transition has five kicks, the first one is zero', () {
    for (final type in TetrominoType.values) {
      for (var from = 0; from < 4; from++) {
        for (final to in [(from + 1) % 4, (from + 3) % 4]) {
          final kicks = RotationSystem.kicks(type, from, to);
          expect(kicks.length, 5, reason: "$type $from -> $to");
          expect(kicks.first, const Cell(0, 0), reason: "$type $from -> $to");
        }
      }
    }
  });

  test('a transition skipping a position is not supported', () {
    expect(
      () => RotationSystem.kicks(TetrominoType.t, 0, 2),
      throwsArgumentError,
    );
    expect(
      () => RotationSystem.kicks(TetrominoType.t, 0, 0),
      throwsArgumentError,
    );
  });

  test('I goes around a placed piece by becoming vertical', () {
    final field = Playfield();
    field.setAt(2, 3, TetrominoType.o);
    const piece = Piece(type: TetrominoType.i, rotation: 0, x: 0, y: 0);
    expect(field.fits(piece), isTrue);

    final turned = RotationSystem.rotate(
      piece: piece,
      field: field,
      clockwise: true,
    );
    expect(turned, isNotNull);
    expect(turned!.rotation, 1);
    expect(turned.x, -2);
    expect(turned.cells.every((cell) => cell.x == 0), isTrue);
  });

  test('I shifts to the right when the left side is also cramped', () {
    final field = Playfield();
    field.setAt(2, 3, TetrominoType.o);
    field.setAt(0, 3, TetrominoType.o);
    const piece = Piece(type: TetrominoType.i, rotation: 0, x: 0, y: 0);

    final turned = RotationSystem.rotate(
      piece: piece,
      field: field,
      clockwise: true,
    );
    expect(turned, isNotNull);
    expect(turned!.x, 1);
    expect(turned.cells.every((cell) => cell.x == 3), isTrue);
  });

  test('reverse kicks are the same kicks with the opposite sign', () {
    for (final type in TetrominoType.values) {
      for (var from = 0; from < 4; from++) {
        final int to = (from + 1) % 4;
        final forward = RotationSystem.kicks(type, from, to);
        final back = RotationSystem.kicks(type, to, from);
        for (var i = 0; i < forward.length; i++) {
          expect(
            back[i],
            Cell(-forward[i].x, -forward[i].y),
            reason: "$type $from -> $to, kick $i",
          );
        }
      }
    }
  });
}
