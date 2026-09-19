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
    return LayoutBuilder(
      builder: (context, constraints) {
        double boardSize = constraints.maxWidth;
        double cellSize = (boardSize - 30) / 4;
        if (cellSize > 80) cellSize = 80;

        return Container(
          padding: const EdgeInsets.all(12),
          // [우드 보드 프레임 디자인] 이미지의 따뜻하고 고급스러운 나무 판자 느낌을 주는 그라데이션 및 입체감
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
              itemCount: 16,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
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
                    // [개별 타일 디자인] 나무 블록이 볼록하게 솟아 있는 입체적인 질감과 그림자 표현
                    decoration: BoxDecoration(
                      color: isEmpty ? Colors.transparent : null,
                      borderRadius: BorderRadius.circular(12),
                      gradient: isEmpty
                          ? null
                          : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFFF4E0), // 타일 상단 밝은 크림우드 톤
                          Color(0xFFE5BE9B), // 타일 하단 따뜻한 우드 톤
                        ],
                      ),
                      boxShadow: isEmpty
                          ? null
                          : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 4,
                          offset: const Offset(0, 3), // 블록 아래로 떨어지는 입체 음영
                        ),
                      ],
                    ),
                    child: isEmpty
                        ? Container(
                      // [빈칸 디자인] 이미처럼 빈 공간은 나무 판자 안쪽이 파인 듯한 짙은 우드톤 음영 처리
                      decoration: BoxDecoration(
                        color: const Color(0xFF9E5C22),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    )
                        : Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: cellSize * 0.38,
                          fontWeight: FontWeight.w900,
                          // [숫자 디자인] 나무 블록과 대비되어 또렷하게 보이는 짙은 갈색 텍스트
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