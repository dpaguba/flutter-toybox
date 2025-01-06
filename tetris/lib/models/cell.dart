/// A grid cell: column `x` and row `y`.
///
/// Rows are counted top to bottom, so row zero is the top of the field. A
/// cell compares by value so sets of cells can be compared directly in
/// tests.
class Cell {
  const Cell(this.x, this.y);

  final int x;
  final int y;

  /// The same cell, shifted by `dx` columns and `dy` rows.
  Cell shifted(int dx, int dy) => Cell(x + dx, y + dy);

  @override
  bool operator ==(Object other) =>
      other is Cell && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => "($x, $y)";
}
