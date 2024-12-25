# Tic Tac Toe

A pixel-art tic-tac-toe. Two players share the phone or one of them plays the
computer, both sides pick a nickname, and a match runs until someone has won
three rounds.

## Screens

|                                             |                                              |
| :-----------------------------------------: | :------------------------------------------- |
| <img width="200" src="doc/01-intro.png">    | the title screen                             |
| <img width="200" src="doc/02-setup.png">    | two players, each with a nickname             |
| <img width="200" src="doc/03-computer.png"> | against the computer, at one of three levels  |
| <img width="200" src="doc/04-game.png">     | a round under way, the side to move in gold   |
| <img width="200" src="doc/05-round.png">    | a round won, the winning line lit up          |
| <img width="200" src="doc/06-match.png">    | the match decided, with every round listed    |

## Playing it

Easy answers at random, medium takes a win or blocks one, hard searches the
whole game and deviates only now and then, which is the only way to beat it.
The loser of a round opens the next one. Nicknames are kept between launches.

## Running it

```bash
flutter pub get
flutter run
```
