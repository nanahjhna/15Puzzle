import 'dart:math';

class FifteenPuzzleState {
  List<int> tiles = [];
  int emptyIndex = 15;
  bool isSuccess = false;

  FifteenPuzzleState() {
    init();
  }

  void init() {
    tiles = List.generate(15, (i) => i + 1);
    tiles.add(0);
    emptyIndex = 15;
    isSuccess = false;
  }

  void shuffle() {
    final random = Random();
    do {
      for (int i = tiles.length - 1; i > 0; i--) {
        int j = random.nextInt(i + 1);
        int temp = tiles[i];
        tiles[i] = tiles[j];
        tiles[j] = temp;
      }
      emptyIndex = tiles.indexOf(0);
      checkSuccess();
    } while (!isSolvable() || isWon());
  }

  bool isSolvable() {
    int inversions = 0;
    int emptyRow = 0;

    for (int i = 0; i < tiles.length; i++) {
      if (tiles[i] == 0) {
        emptyRow = i ~/ 4;
        continue;
      }
      for (int j = i + 1; j < tiles.length; j++) {
        if (tiles[j] != 0 && tiles[i] > tiles[j]) {
          inversions++;
        }
      }
    }
    if (emptyRow % 2 == 0) {
      return inversions % 2 != 0;
    } else {
      return inversions % 2 == 0;
    }
  }

  bool moveTile(int clickedIndex) {
    if (clickedIndex < 0 || clickedIndex >= tiles.length) return false;
    if (tiles[clickedIndex] == 0) return false;

    int clickedRow = clickedIndex ~/ 4;
    int clickedCol = clickedIndex % 4;
    int emptyRow = emptyIndex ~/ 4;
    int emptyCol = emptyIndex % 4;

    bool isAdjacent = (clickedRow - emptyRow).abs() + (clickedCol - emptyCol).abs() == 1;

    if (isAdjacent) {
      int temp = tiles[emptyIndex];
      tiles[emptyIndex] = tiles[clickedIndex];
      tiles[clickedIndex] = temp;
      emptyIndex = clickedIndex;
      checkSuccess();
      return true;
    }
    return false;
  }

  bool isWon() {
    for (int i = 0; i < 15; i++) {
      if (tiles[i] != i + 1) return false;
    }
    return tiles[15] == 0;
  }

  void checkSuccess() {
    isSuccess = isWon();
  }

  String getTileLabel(int index) {
    int value = tiles[index];
    if (value == 0) return '';
    return value.toString();
  }

  bool isEmpty(int index) {
    return tiles[index] == 0;
  }
}