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
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 16,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                    decoration: BoxDecoration(
                      color: isEmpty ? Colors.grey[850] : const Color(0xFF007bff),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isEmpty
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: isEmpty
                        ? null
                        : Center(
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: cellSize * 0.35,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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