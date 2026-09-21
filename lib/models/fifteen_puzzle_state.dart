import 'dart:math';

class FifteenPuzzleState {
  final int gridSize; // 📌 4 또는 5 크기 저장
  List<int> tiles = [];
  int emptyIndex = 15;
  bool isSuccess = false;

  FifteenPuzzleState({this.gridSize = 4}) {
    init();
  }

  void init() {
    int totalTiles = gridSize * gridSize;
    tiles = List.generate(totalTiles - 1, (i) => i + 1);
    tiles.add(0);
    emptyIndex = totalTiles - 1;
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
    int totalTiles = gridSize * gridSize;
    int emptyRowFromBottom = 0;

    for (int i = 0; i < totalTiles; i++) {
      if (tiles[i] == 0) {
        // 바닥에서부터의 행 번호 (1부터 시작)
        emptyRowFromBottom = gridSize - (i ~/ gridSize);
        continue;
      }
      for (int j = i + 1; j < totalTiles; j++) {
        if (tiles[j] != 0 && tiles[i] > tiles[j]) {
          inversions++;
        }
      }
    }

    // 📌 격자 크기가 홀수(5x5 등)인지 짝수(4x4 등)인지에 따른 풀이 가능 여부 판정
    if (gridSize % 2 != 0) {
      // 홀수 그리드: 인버전스가 짝수여야 풀 수 있음
      return inversions % 2 == 0;
    } else {
      // 짝수 그리드: 빈칸의 위치(바닥 기준)와 인버전스 홀짝 조합에 따라 결정
      if (emptyRowFromBottom % 2 != 0) {
        return inversions % 2 == 0;
      } else {
        return inversions % 2 != 0;
      }
    }
  }

  bool moveTile(int clickedIndex) {
    if (clickedIndex < 0 || clickedIndex >= tiles.length) return false;
    if (tiles[clickedIndex] == 0) return false;

    int clickedRow = clickedIndex ~/ gridSize;
    int clickedCol = clickedIndex % gridSize;
    int emptyRow = emptyIndex ~/ gridSize;
    int emptyCol = emptyIndex % gridSize;

    // 📌 빈칸과 같은 행 또는 같은 열에 있는 타일만 이동 가능 (원거리 탭 시 슬라이드)
    bool sameRow = clickedRow == emptyRow;
    bool sameCol = clickedCol == emptyCol;
    if (!sameRow && !sameCol) return false;

    // 빈칸에서 클릭한 타일 쪽으로 향하는 방향 오프셋
    int step;
    if (sameRow) {
      step = clickedCol > emptyCol ? 1 : -1;
    } else {
      step = clickedRow > emptyRow ? gridSize : -gridSize;
    }

    // 빈칸부터 클릭한 타일까지의 타일들을 빈칸 방향으로 한 칸씩 민다
    for (int i = emptyIndex; i != clickedIndex; i += step) {
      tiles[i] = tiles[i + step];
    }
    tiles[clickedIndex] = 0;
    emptyIndex = clickedIndex;

    checkSuccess();
    return true;
  }

  bool isWon() {
    int totalTiles = gridSize * gridSize;
    for (int i = 0; i < totalTiles - 1; i++) {
      if (tiles[i] != i + 1) return false;
    }
    return tiles[totalTiles - 1] == 0;
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