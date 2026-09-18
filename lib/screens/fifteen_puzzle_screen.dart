import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fifteen_puzzle_state.dart';
import '../widgets/fifteen_puzzle_board.dart';
import '../widgets/ad_banner_widget.dart';
import '../utils/app_texts.dart';
import 'record_screen.dart';

class FifteenPuzzleScreen extends StatefulWidget {
  const FifteenPuzzleScreen({Key? key}) : super(key: key);

  @override
  _FifteenPuzzleScreenState createState() => _FifteenPuzzleScreenState();
}

class _FifteenPuzzleScreenState extends State<FifteenPuzzleScreen> {
  final GlobalKey<FifteenPuzzleBoardState> _boardKey =
      GlobalKey<FifteenPuzzleBoardState>();
  final FifteenPuzzleState _puzzleState = FifteenPuzzleState();

  Timer? _gameTimer;
  Timer? _countdownTimer;
  final Stopwatch _stopwatch = Stopwatch();
  int _millisecondsElapsed = 0;
  bool _isPlaying = false;
  bool _isCountdownActive = false;
  int _countdownValue = 3;

  bool _isSoundOn = true;
  bool _isBgmOn = true;

  int? _bestMilliseconds;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadBestTime();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showStartPopup();
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _countdownTimer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _isSoundOn = prefs.getBool('isSoundOn') ?? true;
    });
  }

  Future<void> _loadBestTime() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bestMilliseconds = prefs.getInt('fifteenBestTimeMilliseconds');
    });
  }

  Future<void> _saveBestTime(int timeInMs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fifteenBestTimeMilliseconds', timeInMs);
    setState(() {
      _bestMilliseconds = timeInMs;
    });
  }

  Future<void> _updateGameStats(int timeInMs) async {
    final prefs = await SharedPreferences.getInstance();
    int currentPlays = prefs.getInt('fifteenTotalPlays') ?? 0;
    int currentTimeMs = prefs.getInt('fifteenTotalTimeElapsed') ?? 0;
    await prefs.setInt('fifteenTotalPlays', currentPlays + 1);
    await prefs.setInt('fifteenTotalTimeElapsed', currentTimeMs + timeInMs);
  }

  void _showStartPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            backgroundColor: const Color(0xFF283593),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              AppTexts.get('fifteenPuzzle'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            content: Text(
              AppTexts.get('fifteenReadyMessage'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              Column(
                children: [
                  GestureDetector(
                    onTapDown: (_) {
                      Navigator.pop(context);
                      setState(() {
                        _millisecondsElapsed = 0;
                        _puzzleState.shuffle();
                      });
                      _startCountdown();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        AppTexts.get('gameStart'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white70),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10)
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RecordScreen()),
                        );
                      },
                      icon: const Icon(Icons.emoji_events, color: Colors.amber),
                      label: Text(AppTexts.get('recordView'), style: const TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _isCountdownActive = true;
      _countdownValue = 3;
      _isPlaying = false;
      _millisecondsElapsed = 0;
    });

    _boardKey.currentState?.playStartSound();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdownValue > 1) {
        setState(() {
          _countdownValue--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isCountdownActive = false;
          _isPlaying = true;
          _stopwatch.reset();
          _stopwatch.start();
        });
        _startTimer();
      }
    });
  }

  void _startTimer() {
    if (!_isPlaying) return;
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _millisecondsElapsed = _stopwatch.elapsedMilliseconds;
      });
    });
  }

  void _checkSuccess() async {
    if (_puzzleState.isSuccess && _isPlaying) {
      _gameTimer?.cancel();
      _stopwatch.stop();
      _isPlaying = false;

      _boardKey.currentState?.playClearSound();

      bool isNewRecord = false;
      if (_bestMilliseconds == null || _millisecondsElapsed < _bestMilliseconds!) {
        await _saveBestTime(_millisecondsElapsed);
        isNewRecord = true;
      }
      await _updateGameStats(_millisecondsElapsed);

      _showSuccessPopup(isNewRecord);
    }
  }

  void _showSuccessPopup(bool isNewRecord) {
    int totalSeconds = _millisecondsElapsed ~/ 1000;
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    int centiseconds = (_millisecondsElapsed % 1000) ~/ 10;

    String timeStr = minutes > 0
        ? AppTexts.formatTimeMinSec(minutes, seconds, centiseconds)
        : AppTexts.formatTimeSec(seconds, centiseconds);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF283593),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            children: [
              if (isNewRecord)
                Text(
                  AppTexts.get('fifteenNewRecord'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.amber, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              Text(
                AppTexts.get('fifteenSuccess'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.greenAccent, fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${AppTexts.get('elapsedTime')}: $timeStr',
                  style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.home, color: Colors.white),
                    label: Text(AppTexts.get('fifteenHome'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _millisecondsElapsed = 0;
                        _puzzleState.shuffle();
                      });
                      _startCountdown();
                    },
                    child: Text(AppTexts.get('fifteenPlayAgain'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showSettingsDialog(BuildContext context) {
    if (_isPlaying) {
      _gameTimer?.cancel();
      _stopwatch.stop();
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF283593),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                AppTexts.get('settingsTitle'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.home, color: Colors.white, size: 22),
                            const SizedBox(width: 10),
                            Text(
                              AppTexts.get('goToMain'),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                          style: IconButton.styleFrom(backgroundColor: Colors.white12, padding: const EdgeInsets.all(8)),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white24, height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.refresh, color: Colors.amber, size: 22),
                            const SizedBox(width: 10),
                            Text(
                              AppTexts.get('restartGame'),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              _millisecondsElapsed = 0;
                              _puzzleState.shuffle();
                              _startCountdown();
                            });
                          },
                          icon: const Icon(Icons.play_arrow, color: Colors.black, size: 18),
                          style: IconButton.styleFrom(backgroundColor: Colors.amber, padding: const EdgeInsets.all(8)),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white24, height: 30),
                    _buildSettingSwitch(
                      title: AppTexts.get('soundEffects'),
                      value: _isSoundOn,
                      onChanged: (value) {
                        setDialogState(() { _isSoundOn = value; });
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppTexts.get('close'), style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      if (_isPlaying) {
        _stopwatch.start();
        _startTimer();
      }
    });
  }

  Widget _buildSettingSwitch({required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        Switch(value: value, onChanged: onChanged, activeColor: Colors.amber),
      ],
    );
  }

  String _formatTime() {
    int totalSeconds = _millisecondsElapsed ~/ 1000;
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    int centiseconds = (_millisecondsElapsed % 1000) ~/ 10;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${centiseconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B4CCA),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.timer, color: Color(0xFFFFD700), size: 28),
                          const SizedBox(width: 6),
                          Text(
                            _formatTime(),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white, size: 28),
                        onPressed: () => _showSettingsDialog(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 350, maxHeight: 350),
                        decoration: BoxDecoration(
                          color: const Color(0xFF283593),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Stack(
                              children: [
                                FifteenPuzzleBoard(
                                  key: _boardKey,
                                  puzzleState: _puzzleState,
                                  isSoundOn: _isSoundOn,
                                  onUpdate: () {
                                    setState(() {});
                                    _checkSuccess();
                                  },
                                ),
                                if (!_isPlaying)
                                  const AbsorbPointer(absorbing: true, child: SizedBox.expand()),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const SizedBox(height: 50, child: AdBannerWidget()),
                  const SizedBox(height: 5),
                ],
              ),
            ),
            if (_isCountdownActive)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Text(
                    '$_countdownValue',
                    style: const TextStyle(fontSize: 100, fontWeight: FontWeight.bold, color: Colors.amber),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}