import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/fifteen_puzzle_state.dart';
import '../utils/app_texts.dart'; // 📌 AppTexts 임포트 추가

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
  // 📌 슬라이드 사운드는 한 번 플레이마다 연속으로 울리므로 저지연 전용 플레이어를 분리한다
  final AudioPlayer _slidePlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    _slidePlayer.dispose();
    super.dispose();
  }

  Future<void> playStartSound() async {
    if (!widget.isSoundOn) return;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/start.mp3'));
    } catch (e) {
      debugPrint("시작 사운드 재생 실패: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTexts.get('soundPlayError'))), // 📌 다국어 적용
        );
      }
    }
  }

  Future<void> playClearSound() async {
    if (!widget.isSoundOn) return;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/clear.mp3'));
    } catch (e) {
      debugPrint("클리어 사운드 재생 실패: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTexts.get('soundPlayError'))), // 📌 다국어 적용
        );
      }
    }
  }

  Future<void> _playSlideSound() async {
    if (!widget.isSoundOn) return;
    try {
      await _slidePlayer.stop();
      // 📌 lowLatency 모드는 SoundPool을 써서 연속 재생 시 지연과 끊김이 줄어든다
      await _slidePlayer.play(
        AssetSource('sounds/slide.mp3'),
        mode: PlayerMode.lowLatency,
      );
    } catch (e) {
      debugPrint("슬라이드 사운드 재생 실패: $e");
      // 슬라이드 사운드는 너무 자주 발생하므로 SnackBar를 띄우지 않음
    }
  }

  @override
  Widget build(BuildContext context) {
    // 📌 puzzleState에서 현재 그리드 크기(4 또는 5) 가져오기
    int gridSize = widget.puzzleState.gridSize;

    return LayoutBuilder(
      builder: (context, constraints) {
        // 📌 컨테이너 패딩(12*2)과 내부 패딩(4*2)을 뺀 폭이 실제 보드 폭이다.
        // 간격까지 제외해 계산한 셀 크기는 GridView가 강제하므로 글자 크기 계산에만 쓴다.
        final double boardWidth = constraints.maxWidth - 32;
        final double totalSpacing = (gridSize - 1) * 6.0;
        final double cellSize = (boardWidth - totalSpacing) / gridSize;

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
                color: Colors.black.withValues(alpha: 0.4),
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
                          color: Colors.black.withValues(alpha: 0.25),
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
                          fontSize: (cellSize * (gridSize == 5 ? 0.45 : 0.38)).clamp(12.0, 32.0).toDouble(),
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