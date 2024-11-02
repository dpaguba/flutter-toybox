/// A three-by-three board and the rules of the game.
///
/// No Flutter import at all: everything here is covered by tests, and
/// minimax can churn through thousands of copies without touching widgets.
class Board {
  Board(this.cells);

  Board.empty() : cells = List.filled(9, "");

  final List<String> cells;

  static const List<List<int>> lines = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];

  bool canPlace(int index) => cells[index].isEmpty;

  void place(int index, String mark) {
    if (canPlace(index)) {
      cells[index] = mark;
    }
  }

  List<int>? get winningLine {
    for (final line in lines) {
      final String first = cells[line[0]];
      if (first.isNotEmpty &&
          first == cells[line[1]] &&
          first == cells[line[2]]) {
        return line;
      }
    }
    return null;
  }

  String? get winner {
    final line = winningLine;
    return line == null ? null : cells[line[0]];
  }

  bool get isFull => cells.every((cell) => cell.isNotEmpty);

  List<int> get emptyCells {
    final List<int> free = [];
    for (var i = 0; i < 9; i++) {
      if (cells[i].isEmpty) {
        free.add(i);
      }
    }
    return free;
  }

  Board copy() => Board(List<String>.from(cells));
}
