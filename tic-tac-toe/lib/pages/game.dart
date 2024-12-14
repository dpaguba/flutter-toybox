import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tic_tac_toe/utils/constants.dart';
import '../ai/bot.dart';
import '../models/board.dart';
import '../models/match.dart';
import '../models/player.dart';
import '../widgets/back_link.dart';
import '../widgets/pixel_board.dart';
import '../widgets/score_panel.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key, required this.left, required this.right});

  final Player left;
  final Player right;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final Match match = Match(left: widget.left, right: widget.right);
  Board board = Board.empty();
  late String turnMark = match.startingMark;
  int moves = 0;
  bool _botThinking = false;

  /// Plays move [mark] on cell [index] and, if the round has not ended,
  /// passes the turn and schedules a bot move if needed.
  void _applyMove(int index, String mark) {
    setState(() {
      board.place(index, mark);
      moves++;
      final String? champion = board.winner;
      if (champion != null || board.isFull) {
        match.recordRound(champion, moves);
        _showRoundDialog(champion);
      } else {
        turnMark =
            turnMark == widget.left.mark ? widget.right.mark : widget.left.mark;
        _botMoveIfNeeded();
      }
    });
  }

  /// Schedules the bot's move after a short delay, if it is the bot's turn.
  ///
  /// The board and mark the move is being computed for are captured up
  /// front: if either changes while the timer is waiting, the delayed
  /// callback cancels itself instead of playing a stale mark onto a board
  /// that has since moved on.
  void _botMoveIfNeeded() {
    final Player next =
        turnMark == widget.left.mark ? widget.left : widget.right;
    if (!next.isBot || match.isOver || board.winner != null || board.isFull) {
      return;
    }
    final Board scheduledBoard = board;
    final String scheduledMark = next.mark;
    setState(() {
      _botThinking = true;
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) {
        return;
      }
      final bool stillValid = !match.isOver &&
          identical(board, scheduledBoard) &&
          board.winner == null &&
          !board.isFull &&
          turnMark == scheduledMark;
      if (!stillValid) {
        setState(() {
          _botThinking = false;
        });
        return;
      }
      final int move =
          chooseMove(board, scheduledMark, next.difficulty!, Random());
      setState(() {
        _botThinking = false;
      });
      _applyMove(move, scheduledMark);
    });
  }

  void _tapped(int index) {
    if (_botThinking || match.isOver || !board.canPlace(index)) {
      return;
    }
    final Player mover =
        turnMark == widget.left.mark ? widget.left : widget.right;
    if (mover.isBot) {
      return;
    }
    _applyMove(index, turnMark);
  }

  void _startNextRound() {
    setState(() {
      board = Board.empty();
      moves = 0;
      turnMark = match.startingMark;
      _botThinking = false;
    });
    _botMoveIfNeeded();
  }

  String _nameOf(String mark) =>
      mark == widget.left.mark ? widget.left.name : widget.right.name;

  void _showRoundDialog(String? winnerMark) {
    final bool finished = match.isOver;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            finished
                ? "MATCH OVER"
                : (winnerMark == null
                    ? "DRAW"
                    : "${_nameOf(winnerMark)} WINS ROUND"),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: customFontBlack.copyWith(fontSize: 12),
          ),
          content: finished
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${match.champion!.name} TAKES THE MATCH",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: customFontBlack.copyWith(fontSize: 10),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "${match.leftScore} : ${match.rightScore}",
                      style: customFontBlack.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    for (var i = 0; i < match.history.length; i++)
                      Text(
                        "R${i + 1}  "
                        "${match.history[i].winnerMark == null ? 'DRAW' : _nameOf(match.history[i].winnerMark!)}"
                        "  ${match.history[i].moves} MOVES",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: customFontBlack.copyWith(fontSize: 8, height: 1.8),
                      ),
                  ],
                )
              : Text(
                  "${match.leftScore} : ${match.rightScore}",
                  style: customFontBlack.copyWith(fontSize: 14),
                ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (finished) {
                  Navigator.of(context).pop();
                } else {
                  _startNextRound();
                }
              },
              child: Text(
                finished ? "DONE" : "NEXT ROUND",
                style: customFontBlack.copyWith(fontSize: 10),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: BackLink(
                onTap: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
            ),
            ScorePanel(
              leftName: widget.left.name,
              rightName: widget.right.name,
              leftScore: match.leftScore,
              rightScore: match.rightScore,
              activeIsLeft: turnMark == widget.left.mark,
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Center(
                  child: PixelBoard(
                    cells: board.cells,
                    onTap: _tapped,
                    winningLine: board.winningLine,
                    enabled: !_botThinking,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                match.isOver
                    ? "MATCH OVER"
                    : "ROUND ${match.round}   ${_nameOf(turnMark)} TO MOVE",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: customFontWhite.copyWith(fontSize: 9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
