import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/piece.dart';
import '../models/player.dart';
import '../storage/names_store.dart';
import '../utils/sheet.dart';
import '../widgets/back_slab.dart';
import '../widgets/checker_piece.dart';
import '../widgets/slab_button.dart';
import '../widgets/standing_head.dart';
import 'game.dart';

/// Choosing the mode, names, and difficulty before a game.
class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final NamesStore _store = NamesStore();
  final TextEditingController _light = TextEditingController();
  final TextEditingController _dark = TextEditingController();
  bool _againstBot = false;
  Difficulty _difficulty = Difficulty.medium;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _store.load().then((names) {
      if (!mounted) {
        return;
      }
      setState(() {
        _light.text = names[0];
        _dark.text = names[1];
        _loaded = true;
      });
    });
  }

  @override
  void dispose() {
    _light.dispose();
    _dark.dispose();
    super.dispose();
  }

  /// The label of a single switch segment.
  Widget _segment(String text, {required bool chosen, required Key key}) {
    final Sheet sheet = Sheet.of(context);
    return KeyedSubtree(
      key: key,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            maxLines: 1,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: chosen ? sheet.onAccent : sheet.quiet,
                ),
          ),
        ),
      ),
    );
  }

  /// A switch whose word never grows past its segment's width.
  Widget _switchboard(Widget control) {
    final MediaQueryData media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        textScaleFactor: min(media.textScaleFactor, segmentScaleCap),
      ),
      child: control,
    );
  }

  /// The game mode switch.
  Widget _mode() {
    final Sheet sheet = Sheet.of(context);
    return _switchboard(
      CupertinoSlidingSegmentedControl<bool>(
        groupValue: _againstBot,
        backgroundColor: sheet.mark.withOpacity(0.10),
        thumbColor: sheet.accent,
        onValueChanged: (value) => setState(() => _againstBot = value ?? false),
        children: {
          false: _segment(
            "TWO PLAYERS",
            chosen: !_againstBot,
            key: const ValueKey('mode-two'),
          ),
          true: _segment(
            "VS COMPUTER",
            chosen: _againstBot,
            key: const ValueKey('mode-bot'),
          ),
        },
      ),
    );
  }

  /// The computer difficulty switch.
  Widget _level() {
    final Sheet sheet = Sheet.of(context);
    return _switchboard(
      CupertinoSlidingSegmentedControl<Difficulty>(
        groupValue: _difficulty,
        backgroundColor: sheet.mark.withOpacity(0.10),
        thumbColor: sheet.accent,
        onValueChanged: (value) =>
            setState(() => _difficulty = value ?? Difficulty.medium),
        children: {
          for (final level in Difficulty.values)
            level: _segment(
              level.name.toUpperCase(),
              chosen: _difficulty == level,
              key: ValueKey('level-${level.name}'),
            ),
        },
      ),
    );
  }

  /// A player's name field, with a label and that player's own piece
  /// above it.
  Widget _field(TextEditingController controller, String label, Side side) {
    final Sheet sheet = Sheet.of(context);
    final TextTheme type = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CheckerPiece(piece: Piece(side: side)),
              ),
              const SizedBox(width: 8),
              Flexible(child: Text(label, style: type.labelSmall)),
            ],
          ),
          TextField(
            controller: controller,
            maxLength: 12,
            textCapitalization: TextCapitalization.characters,
            style: type.displaySmall,
            decoration: InputDecoration(
              counterText: "",
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: sheet.mark, width: hairRule),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: sheet.accent, width: heavyRule / 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the players from what was entered and opens the board.
  void _start() {
    final String lightName =
        _light.text.trim().isEmpty ? defaultLightName : _light.text.trim();
    final String darkName =
        _dark.text.trim().isEmpty ? defaultDarkName : _dark.text.trim();
    _store.save(lightName, darkName);
    Navigator.push(
      context,
      CupertinoPageRoute<void>(
        builder: (context) => GamePage(
          light: Player(name: lightName, side: Side.light),
          dark: _againstBot
              ? Player(
                  name: botName,
                  side: Side.dark,
                  isBot: true,
                  difficulty: _difficulty,
                )
              : Player(name: darkName, side: Side.dark),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Sheet sheet = Sheet.of(context);
    final TextTheme type = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: sheet.ground,
      appBar: CupertinoNavigationBar(
        backgroundColor: sheet.ground,
        leading: const BackSlab(previous: "DRAUGHTS"),
        automaticallyImplyLeading: false,
        border: Border(
          bottom: BorderSide(color: sheet.mark, width: heavyRule / 2),
        ),
      ),
      body: !_loaded
          ? const SizedBox.shrink()
          : SafeArea(
              top: false,
              bottom: false,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const StandingHead(text: "PLAYERS"),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(pageMargin),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        _mode(),
                                        _field(
                                          _light,
                                          "LIGHT PIECES",
                                          Side.light,
                                        ),
                                        if (!_againstBot)
                                          _field(
                                            _dark,
                                            "DARK PIECES",
                                            Side.dark,
                                          ),
                                        if (_againstBot) ...[
                                          const SizedBox(height: 26),
                                          Text(
                                            "COMPUTER LEVEL",
                                            style: type.labelSmall,
                                          ),
                                          const SizedBox(height: 8),
                                          _level(),
                                          const SizedBox(height: 14),
                                          Text(
                                            "The computer plays the dark "
                                            "pieces and moves second.",
                                            style: type.bodyMedium,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SlabButton(
                          label: "START",
                          footer: true,
                          onTap: _start,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
