import 'package:calculator/screens/calc_screen.dart';
import 'package:calculator/domain/white_button.dart';
import 'package:calculator/global/color_constants.dart';

import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/black_button.dart';
import '../domain/pressed_black_button.dart';
import '../domain/pressed_white_button.dart';

class Calculator extends ConsumerStatefulWidget {
  const Calculator({Key? key}) : super(key: key);

  @override
  CalculatorState createState() => CalculatorState();
}

class CalculatorState extends ConsumerState<Calculator> {
  String first = "";
  String second = "";
  String operator = "";
  double? result;
  String errorText = "";

  /// Einmal gebaut statt bei jedem Aufruf von [format].
  static final RegExp _trailingZeros = RegExp(r"0+$");

  List<bool> buttonPressed = List<bool>.filled(20, false, growable: false);

  List<String> buttons = [
    "C",
    "±",
    "DEL",
    "÷",
    "7",
    "8",
    "9",
    "x",
    "4",
    "5",
    "6",
    "-",
    "1",
    "2",
    "3",
    "+",
    "00",
    "0",
    ".",
    "=",
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ColorConst.wBackground,
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                width: screenWidth - 40,
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: CalculatorScreen(
                    a: first,
                    b: second,
                    operator: operator,
                    result: displayResult()),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                ),
                children: buttons
                    .map(
                      (btn) => Center(
                        child: GridTile(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 0, bottom: 20, left: 10, right: 10),
                            child: AnimatedContainer(
                              duration: const Duration(
                                milliseconds: 200,
                              ),
                              child: isOperator(btn)
                                  ? (isPressed(btn)
                                      ? PressedBlackButton(
                                          buttonTapped: () {
                                            interactWithUI(btn);
                                          },
                                          textButton: btn,
                                        )
                                      : BlackButton(
                                          buttonTapped: () {
                                            interactWithUI(btn);
                                          },
                                          textButton: btn,
                                        ))
                                  : (isPressed(btn)
                                      ? PressedWhiteButton(
                                          buttonTapped: () {
                                            interactWithUI(btn);
                                          },
                                          textButton: btn,
                                        )
                                      : WhiteButton(
                                          buttonTapped: () {
                                            interactWithUI(btn);
                                          },
                                          textButton: btn,
                                        )),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool isOperator(String str) {
    return (str == "C" ||
        str == "DEL" ||
        str == "÷" ||
        str == "±" ||
        str == "x" ||
        str == "-" ||
        str == "+" ||
        str == "=");
  }

  bool isOperatorPressed() {
    return operator != "";
  }

  void changePressedValue(String str) {
    buttonPressed = List<bool>.filled(20, false, growable: false);
    int index = buttons.indexOf(str);
    buttonPressed[index] = true;
  }

  bool isPressed(String btn) {
    return buttonPressed[buttons.indexOf(btn)];
  }

  void clearAll() {
    first = "";
    second = "";
    operator = "";
    result = null;
    errorText = "";
  }

  /// Formatiert eine Zahl fuer die Anzeige.
  ///
  /// Ganze Werte verlieren das anhaengende ".0". Gebrochene werden auf zehn
  /// Nachkommastellen gekuerzt und um ihre Endnullen gebracht: die echte
  /// Division liefert Werte wie 0.3333333333333333, und die passen nicht in
  /// die Anzeige.
  String format(double value) {
    if (!value.isFinite) {
      return value.isNaN ? "NaN" : (value.isNegative ? "-inf" : "inf");
    }
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }
    String text = value.toStringAsFixed(10);
    text = text.replaceFirst(_trailingZeros, "");
    if (text.endsWith(".")) {
      text = text.substring(0, text.length - 1);
    }
    return text;
  }

  /// Nennt den Puffer, in den die naechste Ziffer geht.
  bool typingIntoSecond() {
    return isOperatorPressed() && first.isNotEmpty;
  }

  /// Sagt, ob gerade ein fertiges Ergebnis angezeigt wird.
  ///
  /// Die drei Tasten, die danach gedrueckt werden koennen, tun bewusst
  /// Verschiedenes: ein Operator rechnet mit dem Ergebnis weiter, eine Ziffer
  /// beginnt eine neue Zahl, und das Vorzeichen dreht das Ergebnis um. Geteilt
  /// wird nur die Frage, nicht die Antwort.
  bool get showingResult {
    return result != null &&
        first.isEmpty &&
        second.isEmpty &&
        operator.isEmpty;
  }

  void delete() {
    if (second.isNotEmpty) {
      second = second.substring(0, second.length - 1);
    } else if (operator.isNotEmpty) {
      operator = "";
    } else if (first.isNotEmpty) {
      first = first.substring(0, first.length - 1);
    } else if (result != null) {
      result = null;
    }
  }

  String changeSign(String str) {
    if (str.isEmpty || double.tryParse(str) == null) {
      return str;
    }
    if (str.startsWith("-")) {
      return str.substring(1);
    }
    return "-$str";
  }

  /// Rechnet einen Ausdruck aus, oder gibt null zurueck, wenn er unvollstaendig
  /// oder ungueltig ist. Die Division durch null wird als Fehler gemeldet und
  /// nicht als Ausnahme geworfen.
  double? evaluate(String left, String op, String right) {
    final double? a = double.tryParse(left);
    final double? b = double.tryParse(right);
    if (a == null || b == null) {
      return null;
    }
    switch (op) {
      case "÷":
        if (b == 0) {
          errorText = "Div by zero";
          return null;
        }
        return a / b;
      case "x":
        return a * b;
      case "+":
        return a + b;
      case "-":
        return a - b;
      default:
        return null;
    }
  }

  /// Rechnet und traegt die allgemeine Meldung nach, wenn [evaluate] keine
  /// eigene gesetzt hat.
  double? evaluateChecked(String left, String op, String right) {
    final double? value = evaluate(left, op, right);
    if (value == null && errorText.isEmpty) {
      errorText = "Invalid";
    }
    return value;
  }

  void calculate() {
    if (first.isEmpty || operator.isEmpty || second.isEmpty) {
      return;
    }
    final double? value = evaluateChecked(first, operator, second);
    if (value == null) {
      return;
    }
    clearAll();
    result = value;
  }

  String displayResult() {
    if (errorText.isNotEmpty) {
      return errorText;
    }
    if (result == null ||
        first.isNotEmpty ||
        second.isNotEmpty ||
        operator.isNotEmpty) {
      return "";
    }
    return format(result!);
  }

  void _checkLength() {
    if ((first.length + second.length + operator.length) >= 12) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Length of this expression is too long!"),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      clearAll();
                      buttonPressed =
                          List<bool>.filled(20, false, growable: false);
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Try Again",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  /// Haengt eine Ziffer oder ein Komma an den richtigen Puffer an.
  ///
  /// Ein zweites Komma in derselben Zahl wird verworfen, ebenso eine fuehrende
  /// Null vor einer weiteren Ziffer. Ohne diese beiden Pruefungen entstehen
  /// Zeichenketten wie "1..5" oder "005", die entweder beim Rechnen scheitern
  /// oder falsch aussehen.
  String append(String buffer, String btn) {
    if (btn == "." && buffer.contains(".")) {
      return buffer;
    }
    if (btn == ".") {
      return buffer.isEmpty ? "0." : buffer + btn;
    }
    if (buffer == "0") {
      return btn.replaceAll("0", "").isEmpty ? "0" : btn;
    }
    if (buffer.isEmpty && btn == "00") {
      return "0";
    }
    return buffer + btn;
  }

  /// Nimmt einen Operator entgegen.
  ///
  /// Steht schon ein vollstaendiger Ausdruck, so wird er zuerst ausgerechnet
  /// und sein Wert wird zum linken Operanden. Sonst ersetzt der neue Operator
  /// den alten. Ohne das Zusammenfalten kleben die naechsten Ziffern an den
  /// zweiten Operanden, und aus 2+3x4 wird 2x34.
  void applyOperator(String btn) {
    if (showingResult) {
      first = format(result!);
      result = null;
    }
    if (first.isNotEmpty && operator.isNotEmpty && second.isNotEmpty) {
      final double? value = evaluateChecked(first, operator, second);
      if (value == null) {
        return;
      }
      first = format(value);
      second = "";
    }
    if (first.isEmpty) {
      return;
    }
    operator = btn;
  }

  void interactWithUI(String btn) {
    setState(() {
      changePressedValue(btn);
      errorText = "";
      switch (btn) {
        case "C":
          clearAll();
          break;

        case "DEL":
          delete();
          break;

        case "±":
          if (second.isNotEmpty) {
            second = changeSign(second);
          } else if (first.isNotEmpty) {
            first = changeSign(first);
          } else if (showingResult) {
            result = -result!;
          }
          break;

        case "=":
          calculate();
          break;

        default:
          if (!isOperator(btn)) {
            if (showingResult) {
              result = null;
            }
            if (typingIntoSecond()) {
              second = append(second, btn);
            } else {
              first = append(first, btn);
            }
          } else {
            applyOperator(btn);
          }
          break;
      }
      _checkLength();
    });
  }
}
