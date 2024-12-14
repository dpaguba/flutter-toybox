import 'package:flutter/material.dart';

import '../models/player.dart';
import '../storage/names_store.dart';
import '../utils/constants.dart';
import '../widgets/back_link.dart';
import '../widgets/pixel_button.dart';
import 'game.dart';

/// Choosing the mode, names, and difficulty before a game.
class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final NamesStore _store = NamesStore();
  final TextEditingController _left = TextEditingController();
  final TextEditingController _right = TextEditingController();
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
        _left.text = names[0];
        _right.text = names[1];
        _loaded = true;
      });
    });
  }

  @override
  void dispose() {
    _left.dispose();
    _right.dispose();
    super.dispose();
  }

  Widget _field(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        maxLength: 12,
        textCapitalization: TextCapitalization.characters,
        style: customFontWhite.copyWith(fontSize: 12),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: customFontWhite.copyWith(fontSize: 10),
          counterText: "",
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _toggleButton(
    String text,
    bool active,
    VoidCallback onTap, {
    Key? key,
    double fontSize = 10,
    double verticalPadding = 14,
  }) {
    return Expanded(
      child: GestureDetector(
        key: key,
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          color: active ? Colors.white : backgroundColor,
          child: Center(
            child: Text(
              text,
              style: active
                  ? customFontBlack.copyWith(fontSize: fontSize)
                  : customFontWhite.copyWith(fontSize: fontSize),
            ),
          ),
        ),
      ),
    );
  }

  void _start() {
    final String leftName =
        _left.text.trim().isEmpty ? defaultLeftName : _left.text.trim();
    final String rightName =
        _right.text.trim().isEmpty ? defaultRightName : _right.text.trim();
    _store.save(leftName, rightName);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GamePage(
          left: Player(name: leftName, mark: "X"),
          right: _againstBot
              ? Player(
                  name: botName,
                  mark: "O",
                  isBot: true,
                  difficulty: _difficulty,
                )
              : Player(name: rightName, mark: "O"),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(backgroundColor: backgroundColor);
    }
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: BackLink(onTap: () => Navigator.pop(context)),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "SETUP",
                      textAlign: TextAlign.center,
                      style: customFontWhite.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        _toggleButton(
                          "2 PLAYERS",
                          !_againstBot,
                          () => setState(() => _againstBot = false),
                          key: const ValueKey('mode-two'),
                        ),
                        _toggleButton(
                          "VS COMPUTER",
                          _againstBot,
                          () => setState(() => _againstBot = true),
                          key: const ValueKey('mode-bot'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _field(_left, "PLAYER X"),
                    if (!_againstBot) _field(_right, "PLAYER O"),
                    if (_againstBot) ...[
                      const SizedBox(height: 24),
                      Text(
                        "DIFFICULTY",
                        textAlign: TextAlign.center,
                        style: customFontWhite.copyWith(fontSize: 10),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _toggleButton(
                            "EASY",
                            _difficulty == Difficulty.easy,
                            () => setState(() => _difficulty = Difficulty.easy),
                            fontSize: 9,
                            verticalPadding: 12,
                          ),
                          _toggleButton(
                            "MEDIUM",
                            _difficulty == Difficulty.medium,
                            () =>
                                setState(() => _difficulty = Difficulty.medium),
                            fontSize: 9,
                            verticalPadding: 12,
                          ),
                          _toggleButton(
                            "HARD",
                            _difficulty == Difficulty.hard,
                            () => setState(() => _difficulty = Difficulty.hard),
                            fontSize: 9,
                            verticalPadding: 12,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            PixelButton(label: "START", onTap: _start),
          ],
        ),
      ),
    );
  }
}
