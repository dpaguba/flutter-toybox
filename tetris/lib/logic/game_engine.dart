import '../models/piece.dart';
import '../models/playfield.dart';
import '../models/tetromino.dart';
import 'bag.dart';
import 'rotation.dart';
import 'scoring.dart';

/// Status of a game session.
enum GameStatus {
  /// The game has not started yet.
  ready,

  /// Pieces are falling, controls are active.
  running,

  /// Paused: time is stopped, controls do nothing.
  paused,

  /// The top of the field is filled, the game session has ended.
  over,
}

/// Rules of a game session: falling, controls, scoring, and game over.
///
/// The engine holds all the state and draws nothing. Time comes in from
/// outside through [update], so a test can run a whole game session without
/// timers or widgets.
class GameEngine {
  GameEngine({PieceSource? source, Playfield? field})
      : _source = source ?? SevenBag(),
        field = field ?? Playfield();

  /// How many pieces the preview shows.
  static const int previewCount = 3;

  /// How long a piece keeps moving after landing, in milliseconds.
  static const int lockDelayMs = 500;

  /// How many times a move can postpone locking before it happens by force.
  static const int maxLockResets = 15;

  final PieceSource _source;

  /// The field with pieces already placed.
  final Playfield field;

  Piece? _current;
  TetrominoType? _held;
  bool _holdUsed = false;
  int _score = 0;
  int _lines = 0;
  int _level = 1;
  GameStatus _status = GameStatus.ready;
  int _fallTimer = 0;
  int _lockTimer = 0;
  int _lockResets = 0;

  /// The piece currently falling, or `null` outside a game.
  Piece? get current => _current;

  /// The next three pieces in order of appearance.
  List<TetrominoType> get next => _source.peek(previewCount);

  /// The held piece, or `null` if nothing is held.
  TetrominoType? get held => _held;

  /// Whether a piece can be held right now.
  bool get canHold => _status == GameStatus.running && !_holdUsed;

  int get score => _score;

  int get lines => _lines;

  int get level => _level;

  GameStatus get status => _status;

  /// The pause between falling steps at the current level.
  int get gravityMs => Scoring.gravityForLevel(_level);

  /// Where the piece would land if dropped right now.
  Piece? get ghost {
    final Piece? piece = _current;
    if (piece == null) {
      return null;
    }
    Piece result = piece;
    while (field.fits(result.moved(0, 1))) {
      result = result.moved(0, 1);
    }
    return result;
  }

  /// Starts a new game session on a clean field.
  void start() {
    field.reset();
    _held = null;
    _holdUsed = false;
    _score = 0;
    _lines = 0;
    _level = 1;
    _fallTimer = 0;
    _status = GameStatus.running;
    _takeNextPiece();
  }

  /// Stops time until [resume] is called.
  void pause() {
    if (_status == GameStatus.running) {
      _status = GameStatus.paused;
    }
  }

  /// Resumes the game from pause.
  void resume() {
    if (_status == GameStatus.paused) {
      _status = GameStatus.running;
    }
  }

  /// Shifts the piece one cell to the left and reports whether it succeeded.
  bool moveLeft() => _shift(-1);

  /// Shifts the piece one cell to the right and reports whether it succeeded.
  bool moveRight() => _shift(1);

  /// Rotates the piece a quarter turn and reports whether it succeeded.
  bool rotate({required bool clockwise}) {
    final Piece? piece = _playablePiece();
    if (piece == null) {
      return false;
    }
    final Piece? turned = RotationSystem.rotate(
      piece: piece,
      field: field,
      clockwise: clockwise,
    );
    if (turned == null) {
      return false;
    }
    _current = turned;
    _delayLock();
    return true;
  }

  /// Lowers the piece by one cell and adds a point.
  bool softDrop() {
    final Piece? piece = _playablePiece();
    if (piece == null) {
      return false;
    }
    final Piece lower = piece.moved(0, 1);
    if (!field.fits(lower)) {
      return false;
    }
    _current = lower;
    _score += Scoring.softDropScore(1);
    _fallTimer = 0;
    return true;
  }

  /// Drops the piece all the way down, locks it, and returns the distance
  /// traveled.
  int hardDrop() {
    final Piece? piece = _playablePiece();
    if (piece == null) {
      return 0;
    }
    final Piece landed = ghost!;
    final int distance = landed.y - piece.y;
    _current = landed;
    _score += Scoring.hardDropScore(distance);
    _lockCurrent();
    return distance;
  }

  /// Swaps the current piece with the held one and reports whether it
  /// succeeded.
  ///
  /// This can only be done once per drop, otherwise a piece could be
  /// swapped back and forth endlessly.
  bool hold() {
    final Piece? piece = _playablePiece();
    if (piece == null || _holdUsed) {
      return false;
    }
    final TetrominoType? previous = _held;
    _held = piece.type;
    _holdUsed = true;
    if (previous == null) {
      _takeNextPiece();
    } else {
      _placeNewPiece(Piece.spawn(previous));
    }
    return true;
  }

  /// Advances the game by `deltaMs` milliseconds.
  void update(int deltaMs) {
    if (_status != GameStatus.running || _current == null) {
      return;
    }
    if (field.fits(_current!.moved(0, 1))) {
      _lockTimer = 0;
      _fallTimer += deltaMs;
      while (_fallTimer >= gravityMs && field.fits(_current!.moved(0, 1))) {
        _fallTimer -= gravityMs;
        _current = _current!.moved(0, 1);
      }
      return;
    }
    _lockTimer += deltaMs;
    if (_lockTimer >= lockDelayMs) {
      _lockCurrent();
    }
  }

  Piece? _playablePiece() =>
      _status == GameStatus.running ? _current : null;

  bool _shift(int dx) {
    final Piece? piece = _playablePiece();
    if (piece == null) {
      return false;
    }
    final Piece moved = piece.moved(dx, 0);
    if (!field.fits(moved)) {
      return false;
    }
    _current = moved;
    _delayLock();
    return true;
  }

  void _delayLock() {
    if (_lockResets >= maxLockResets) {
      return;
    }
    if (_lockTimer > 0) {
      _lockResets++;
    }
    _lockTimer = 0;
  }

  void _lockCurrent() {
    field.lock(_current!);
    final int cleared = field.clearFullRows();
    if (cleared > 0) {
      _score += Scoring.lineScore(cleared, _level);
      _lines += cleared;
      _level = Scoring.levelForLines(_lines);
    }
    _holdUsed = false;
    _takeNextPiece();
  }

  void _takeNextPiece() {
    _placeNewPiece(Piece.spawn(_source.next()));
  }

  void _placeNewPiece(Piece piece) {
    _fallTimer = 0;
    _lockTimer = 0;
    _lockResets = 0;
    if (!field.fits(piece)) {
      _current = null;
      _status = GameStatus.over;
      return;
    }
    _current = piece;
  }
}
