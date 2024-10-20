# Calculator

A four-function calculator with a neumorphic keypad.

## States

|                                        |                                         |                                            |
| :------------------------------------: | :-------------------------------------: | :----------------------------------------: |
|  <img width="200" src="doc/idle.png">  | <img width="200" src="doc/typing.png">  | <img width="200" src="doc/expression.png"> |
|                  idle                  |            entering a number            |               an expression                |
| <img width="200" src="doc/result.png"> | <img width="200" src="doc/decimal.png"> |  <img width="200" src="doc/negative.png">  |
|                a result                | a quotient that does not divide evenly  |             a negative result              |
| <img width="200" src="doc/error.png">  |                                         |                                            |
|            division by zero            |                                         |                                            |

## Running it

```bash
flutter pub get
flutter run
```

The first run on the iOS simulator can fail with `Xcode build is missing
expected TARGET_BUILD_DIR build setting`. Run the same command again: the
Xcode build succeeds either way, and Flutter only reads the build settings in
time once they are cached.
