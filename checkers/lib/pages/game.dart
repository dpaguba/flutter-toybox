import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../ai/bot.dart';
import '../logic/move_generator.dart';
import '../logic/rules.dart';
import '../models/board.dart';
import '../models/move.dart';
import '../models/piece.dart';
import '../models/player.dart';
import '../utils/sheet.dart';
import '../widgets/back_slab.dart';
import '../widgets/checker_board.dart';
import '../widgets/turn_slab.dart';
import 'result.dart';

/// How long the computer "thinks" before a move.
///
/// The pause is not just for show: it gives time for the frame with the
/// player's own move to finish drawing, so the search does not eat that
/// frame along with its own.
const Duration botPause = Duration(milliseconds: 450);

/// How much room is left for the two slabs once the board takes all it
/// can.
///
/// The band grows together with the system text size, so at the largest
/// size it is the board, not the player's name, that gives way.
const double slabBand = 170;

/// The game screen: two slabs with names, and the board at full bleed
/// between them.
class GamePage extends StatefulWidget {
  const GamePage({
    super.key,
    required this.light,
    required this.dark,
    this.startBoard,
    this.startTurn = Side.light,
  });

  /// The player playing light.
  final Player light;

  /// The player playing dark.
  final Player dark;

  /// The position the game starts from. The starting position by
  /// default.
  final Board? startBoard;

  /// Who moves first.
  final Side startTurn;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final Random _random = Random();
  late Board _board;
  late Side _turn;
  late List<Move> _legal;
  int? _origin;
  int? _barred;
  List<Move> _active = const [];
  int _step = 0;
  int _lightTook = 0;
  int _darkTook = 0;
  Set<int> _trail = const {};
  bool _botThinking = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _reset();
    _botMoveIfNeeded();
  }

  /// Returns the game to the starting position.
  void _reset() {
    _board = widget.startBoard?.copy() ?? Board.initial();
    _turn = widget.startTurn;
    _legal = legalMoves(_board, _turn);
    _origin = null;
    _barred = null;
    _active = const [];
    _step = 0;
    _lightTook = 0;
    _darkTook = 0;
    _trail = const {};
    _botThinking = false;
    _finished = false;
  }

  /// The player playing side [side].
  Player _playerOf(Side side) =>
      side == Side.light ? widget.light : widget.dark;

  /// The position shown on screen.
  ///
  /// In the middle of a chain the piece already stands on the
  /// intermediate square, while the captured pieces are still on the
  /// board: under the rules they are removed only once the chain ends.
  Board get _shownBoard {
    if (_origin == null || _step == 0) {
      return _board;
    }
    final Board shown = _board.copy();
    final Piece piece = shown.at(_origin!)!;
    shown.squares[_origin!] = null;
    shown.squares[_active.first.path[_step - 1]] = piece;
    return shown;
  }

  /// The square the piece is currently moving from.
  int? get _cursor => _step == 0 ? _origin : _active.first.path[_step - 1];

  /// The squares the next step is allowed to land on.
  Set<int> get _destinations => _origin == null
      ? const {}
      : _active.map((move) => move.path[_step]).toSet();

  /// Pieces already captured in the unfinished chain.
  Set<int> get _doomed =>
      _step == 0 ? const {} : _active.first.captured.take(_step).toSet();

  /// Which pieces the proposed next step would remove.
  Set<int> get _victims => _origin == null
      ? const {}
      : _active
          .where((move) => move.captured.length > _step)
          .map((move) => move.captured[_step])
          .toSet();

  /// The pieces that have something to move.
  ///
  /// Once a piece has been picked, only that piece is left: the page
  /// speaks about one move, not all of them at once. Empty in the middle
  /// of a chain and during the bot's move.
  Set<int> get _movable {
    if (_finished || _botThinking || _step > 0 || _playerOf(_turn).isBot) {
      return const {};
    }
    if (_origin != null) {
      return {_origin!};
    }
    return _legal.map((move) => move.from).toSet();
  }

  /// Whether the side to move is compelled to capture.
  bool get _mustCapture => _legal.isNotEmpty && _legal.first.isCapture;

  /// How many pieces the longest of the currently allowed captures takes.
  int get _mostTaken => _legal.isEmpty ? 0 : _legal.first.captureCount;

  /// What the rules say to whoever's turn it is.
  String get _claim {
    if (_botThinking) {
      return "THINKING";
    }
    return _mustCapture ? "MUST TAKE $_mostTaken" : "TO MOVE";
  }

  /// A tap on a square: either picking a piece or the chain's next step.
  void _tapped(int square) {
    if (_finished || _botThinking || _playerOf(_turn).isBot) {
      return;
    }
    if (_origin != null && _destinations.contains(square)) {
      _advance(square);
      return;
    }
    if (_step > 0) {
      return;
    }
    final List<Move> moves =
        _legal.where((move) => move.from == square).toList();
    final Piece? piece = _board.at(square);
    setState(() {
      _origin = moves.isEmpty ? null : square;
      _active = moves.isEmpty ? const [] : moves;
      _barred =
          moves.isEmpty && piece != null && piece.side == _turn ? square : null;
    });
  }

  /// Takes one step of the move and finishes it if there are no steps
  /// left.
  void _advance(int square) {
    final List<Move> next =
        _active.where((move) => move.path[_step] == square).toList();
    if (next.isEmpty) {
      return;
    }
    final int step = _step + 1;
    if (next.first.path.length == step) {
      _commit(next.first);
      return;
    }
    setState(() {
      _active = next;
      _step = step;
      _barred = null;
    });
  }

  /// Records a finished move and passes the turn.
  void _commit(Move move) {
    final Side mover = _turn;
    setState(() {
      _board = applyMove(_board, move);
      if (mover == Side.light) {
        _lightTook += move.captureCount;
      } else {
        _darkTook += move.captureCount;
      }
      _trail = {move.from, move.to};
      _origin = null;
      _barred = null;
      _active = const [];
      _step = 0;
      _turn = opponentOf(mover);
      _legal = legalMoves(_board, _turn);
    });
    final Side? champion = winnerOf(_board, _turn);
    if (champion != null) {
      setState(() => _finished = true);
      _showResult(champion);
      return;
    }
    _botMoveIfNeeded();
  }

  /// Schedules the computer's move, if it is its turn.
  void _botMoveIfNeeded() {
    final Player next = _playerOf(_turn);
    if (_finished || !next.isBot) {
      return;
    }
    final Board scheduledBoard = _board;
    final Side scheduledSide = _turn;
    setState(() => _botThinking = true);
    Future.delayed(botPause, () {
      if (!mounted) {
        return;
      }
      final bool stillValid = !_finished &&
          identical(_board, scheduledBoard) &&
          _turn == scheduledSide;
      if (!stillValid) {
        setState(() => _botThinking = false);
        return;
      }
      final Move move = chooseMove(
        _board,
        scheduledSide,
        next.difficulty ?? Difficulty.medium,
        _random,
      );
      setState(() => _botThinking = false);
      _commit(move);
    });
  }

  /// Shows the result page and carries out what was chosen there.
  Future<void> _showResult(Side champion) async {
    final ResultChoice? choice = await Navigator.of(context).push<ResultChoice>(
      CupertinoPageRoute<ResultChoice>(
        fullscreenDialog: true,
        builder: (context) => ResultPage(
          winner: _playerOf(champion).name,
          lightName: widget.light.name,
          darkName: widget.dark.name,
          lightTook: _lightTook,
          darkTook: _darkTook,
        ),
      ),
    );
    if (!mounted) {
      return;
    }
    if (choice == ResultChoice.again) {
      setState(_reset);
      _botMoveIfNeeded();
      return;
    }
    if (choice == ResultChoice.menu) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Sheet sheet = Sheet.of(context);
    final bool lightTurn = !_finished && _turn == Side.light;
    final bool darkTurn = !_finished && _turn == Side.dark;
    return Scaffold(
      backgroundColor: sheet.ground,
      appBar: CupertinoNavigationBar(
        backgroundColor: sheet.ground,
        leading: const BackSlab(previous: "PLAYERS"),
        automaticallyImplyLeading: false,
        border: Border(
          bottom: BorderSide(color: sheet.mark, width: heavyRule / 2),
        ),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double slabFloor =
                slabBand * MediaQuery.textScaleFactorOf(context);
            final double side = max(
              0,
              min(
                constraints.maxWidth,
                constraints.maxHeight - 2 * heavyRule - slabFloor,
              ),
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: TurnSlab(
                    name: widget.dark.name,
                    claim: _claim,
                    took: _darkTook,
                    active: darkTurn,
                    compulsory: _mustCapture,
                    inverted: !widget.dark.isBot,
                  ),
                ),
                Container(height: heavyRule, color: sheet.mark),
                Center(
                  child: SizedBox(
                    width: side,
                    height: side,
                    child: CheckerBoard(
                      board: _shownBoard,
                      onTap: _tapped,
                      origin: _cursor,
                      destinations: _destinations,
                      movable: _movable,
                      doomed: _doomed,
                      victims: _victims,
                      trail: _trail,
                      barred: _barred,
                      enabled: !_finished && !_botThinking,
                    ),
                  ),
                ),
                Container(height: heavyRule, color: sheet.mark),
                Expanded(
                  child: TurnSlab(
                    name: widget.light.name,
                    claim: _claim,
                    took: _lightTook,
                    active: lightTurn,
                    compulsory: _mustCapture,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
