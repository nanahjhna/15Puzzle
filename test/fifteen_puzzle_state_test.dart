import 'package:flutter_test/flutter_test.dart';
import 'package:fifteenPuzzle/models/fifteen_puzzle_state.dart';

void main() {
  group('FifteenPuzzleState.moveTile 슬라이드 이동', () {
    test('같은 행 왼쪽에 있는 타일 탭 시 전체 행이 밀린다', () {
      final state = FifteenPuzzleState(gridSize: 4);
      state.init();
      // 초기 배치: 행3 = [13, 14, 15, 0], 빈칸 = 15(3행3열)
      // 3행0열(13) 탭 -> 행 전체가 오른쪽으로 밀림
      bool moved = state.moveTile(12);
      expect(moved, isTrue);
      expect(state.tiles.sublist(12, 16), [0, 13, 14, 15]);
      expect(state.emptyIndex, 12);
    });

    test('같은 행 오른쪽에 있는 타일 탭 시 전체 행이 밀린다', () {
      final state = FifteenPuzzleState(gridSize: 4);
      state.init();
      // 빈칸을 2행3열(11)로 이동
      state.moveTile(11);
      // 2행0열(9) 탭 -> 행 전체가 오른쪽으로 밀림
      bool moved = state.moveTile(8);
      expect(moved, isTrue);
      expect(state.tiles.sublist(8, 12), [0, 9, 10, 11]);
      expect(state.emptyIndex, 8);
    });

    test('같은 열에 있는 타일 탭 시 세로로 밀린다', () {
      final state = FifteenPuzzleState(gridSize: 4);
      state.init();
      // 1행3열(7) 탭 -> 3열 전체가 아래로 밀림
      bool moved = state.moveTile(7);
      expect(moved, isTrue);
      expect(state.tiles[3], 4);
      expect(state.tiles[7], 0);
      expect(state.tiles[11], 8);
      expect(state.tiles[15], 12);
      expect(state.emptyIndex, 7);
    });

    test('같은 행/열이 아닌 타일은 이동 불가', () {
      final state = FifteenPuzzleState(gridSize: 4);
      state.init();
      bool moved = state.moveTile(0); // 빈칸 15와 대각선 위치
      expect(moved, isFalse);
      expect(state.tiles, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 0]);
      expect(state.emptyIndex, 15);
    });

    test('빈칸 자신은 이동 불가', () {
      final state = FifteenPuzzleState(gridSize: 4);
      state.init();
      bool moved = state.moveTile(15);
      expect(moved, isFalse);
      expect(state.emptyIndex, 15);
    });
  });
}