import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/fifteen_puzzle_state.dart';

class FifteenPuzzleBoard extends StatefulWidget {
  final FifteenPuzzleState puzzleState;
  final VoidCallback onUpdate;
  final bool isSoundOn;

  const FifteenPuzzleBoard({
    Key? key,
    required this.puzzleState,
    required this.onUpdate,
    required this.isSoundOn,
  }) : super(key: key);

  @override
  FifteenPuzzleBoardState createState() => FifteenPuzzleBoardState();
}

class FifteenPuzzleBoardState extends State<FifteenPuzzleBoard> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> playStartSound() async {
    if (!widget.isSoundOn) return;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/start.mp3'));
    } catch (e) {
      debugPrint("시작 사운드 재생 실패: $e");
    }
  }

  Future<void> playClearSound() async {
    if (!widget.isSoundOn) return;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/clear.mp3'));
    } catch (e) {
      debugPrint("클리어 사운드 재생 실패: $e");
    }
  }

  Future<void> _playSlideSound() async {
    if (!widget.isSoundOn) return;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/slide.mp3'));
    } catch (e) {
      debugPrint("슬라이드 사운드 재생 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // 📌 puzzleState에서 현재 그리드 크기(4 또는 5) 가져오기
    int gridSize = widget.puzzleState.gridSize;

    return LayoutBuilder(
      builder: (context, constraints) {
        double boardSize = constraints.maxWidth;
        // 📌 그리드 크기에 맞춰 셀 크기 및 간격 계산 (5x5일 경우 간격을 조금 더 좁게 조절 가능)
        double totalSpacing = (gridSize - 1) * 6.0;
        double cellSize = (boardSize - 30 - totalSpacing) / gridSize;
        if (cellSize > (gridSize == 5 ? 65 : 80)) {
          cellSize = gridSize == 5 ? 65 : 80;
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE2A76F), // 밝은 나무톤 (하이라이트)
                Color(0xFFB87333), // 진한 나무톤 (음영)
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: gridSize * gridSize, // 📌 4x4는 16, 5x5는 25
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize, // 📌 동적 크기 적용
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemBuilder: (context, index) {
                bool isEmpty = widget.puzzleState.isEmpty(index);
                String label = widget.puzzleState.getTileLabel(index);

                return GestureDetector(
                  onTap: isEmpty
                      ? null
                      : () {
                    bool moved = widget.puzzleState.moveTile(index);
                    if (moved) {
                      _playSlideSound();
                      widget.onUpdate();
                    }
                  },
                  child: Container(
                    width: cellSize,
                    height: cellSize,
                    decoration: BoxDecoration(
                      color: isEmpty ? Colors.transparent : null,
                      borderRadius: BorderRadius.circular(gridSize == 5 ? 8 : 12),
                      gradient: isEmpty
                          ? null
                          : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFFF4E0),
                          Color(0xFFE5BE9B),
                        ],
                      ),
                      boxShadow: isEmpty
                          ? null
                          : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 4,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: isEmpty
                        ? Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF9E5C22),
                        borderRadius: BorderRadius.circular(gridSize == 5 ? 8 : 12),
                      ),
                    )
                        : Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          // 📌 5x5일 때는 칸이 더 촘촘하므로 글자 크기를 살짝 줄임
                          fontSize: cellSize * (gridSize == 5 ? 0.45 : 0.38),
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF4A2E18),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}