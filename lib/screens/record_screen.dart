import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/ad_banner_widget.dart';
import '../utils/app_texts.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({Key? key}) : super(key: key);

  @override
  _RecordScreenState createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  _ModeRecord? _record4;
  _ModeRecord? _record5;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    // 📌 4x4 / 5x5 모드별 기록을 각각 로드
    final record4 = _ModeRecord(4);
    final record5 = _ModeRecord(5);
    await Future.wait([record4.load(), record5.load()]);
    if (!mounted) return;
    setState(() {
      _record4 = record4;
      _record5 = record5;
      _isLoading = false;
    });
  }

  // 📌 다국어가 반영된 시간 포맷 함수 (AppTexts 활용)
  String _formatTime(int? milliseconds) {
    if (milliseconds == null) return '--:--.--';
    int totalSeconds = milliseconds ~/ 1000;
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    int centiseconds = (milliseconds % 1000) ~/ 10;

    return minutes > 0
        ? AppTexts.formatTimeMinSec(minutes, seconds, centiseconds)
        : AppTexts.formatTimeSec(seconds, centiseconds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.home, color: Colors.white),
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      tooltip: AppTexts.get('homeTooltip'), // 📌 다국어 적용
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppTexts.get('recordScreenTitle'), // 📌 다국어 적용
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // 균형을 위한 빈 공간
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.amber),
                      )
                    : DefaultTabController(
                        length: 2,
                        child: Column(
                          children: [
                            // 📌 4x4 / 5x5 모드 선택 탭
                            Container(
                              height: 48,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 36.0,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TabBar(
                                dividerColor: Colors.transparent,
                                indicator: BoxDecoration(
                                  color: const Color(0xFF9C27B0),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelColor: Colors.white,
                                unselectedLabelColor: Colors.white70,
                                labelStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                tabs: const [
                                  Tab(text: '4 X 4'),
                                  Tab(text: '5 X 5'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  _buildRecordContent(_record4!),
                                  _buildRecordContent(_record5!),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 50, child: AdBannerWidget()),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordContent(_ModeRecord record) {
    // 📌 누적 플레이 시간 단위 계산 (분 단위)
    double totalMinutes = record.totalTimeMs / 1000 / 60;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTopRecordsCard(record),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: AppTexts.get('totalPlays'), // 📌 다국어 적용
                  value:
                      '${record.totalPlays} ${AppTexts.get('playsUnit')}', // 📌 다국어 적용
                  icon: Icons.play_arrow_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: AppTexts.get('totalTime'), // 📌 다국어 적용
                  value:
                      '${totalMinutes.toStringAsFixed(1)} ${AppTexts.get('minutesUnit')}', // 📌 다국어 적용
                  icon: Icons.history,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            title: AppTexts.get('averageTime'), // 📌 다국어 적용
            value: _formatTime(record.averageMs),
            icon: Icons.functions,
          ),
        ],
      ),
    );
  }

  Widget _buildTopRecordsCard(_ModeRecord record) {
    const rankIcons = [Icons.looks_one, Icons.looks_two, Icons.looks_3];
    const rankColors = [Colors.amber, Colors.white70, Color(0xFFCD7F32)];
    final rankLabels = [
      AppTexts.get('firstPlace'),
      AppTexts.get('secondPlace'),
      AppTexts.get('thirdPlace'),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 26),
              const SizedBox(width: 8),
              Text(
                AppTexts.get('topRecords'),
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < 3; index++) ...[
            if (index > 0) const Divider(color: Colors.white24, height: 16),
            Row(
              children: [
                Icon(rankIcons[index], color: rankColors[index], size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    rankLabels[index],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  _formatTime(
                    index < record.topTimesMs.length
                        ? record.topTimesMs[index]
                        : null,
                  ),
                  style: TextStyle(
                    color: rankColors[index],
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.white70),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// 📌 모드별(4x4 / 5x5) 기록 데이터를 로드하는 헬퍼 클래스
class _ModeRecord {
  final int gridSize;
  int? bestTimeMs;
  List<int> topTimesMs = [];
  int totalPlays = 0;
  int totalTimeMs = 0;

  _ModeRecord(this.gridSize);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    bestTimeMs = prefs.getInt('fifteenBestTimeMilliseconds_$gridSize');
    topTimesMs =
        (prefs.getStringList('fifteenTopTimesMilliseconds_$gridSize') ?? [])
            .map(int.tryParse)
            .whereType<int>()
            .toList()
          ..sort();
    if (topTimesMs.isEmpty && bestTimeMs != null) {
      topTimesMs = [bestTimeMs!];
    }
    topTimesMs = topTimesMs.take(3).toList();
    totalPlays = prefs.getInt('fifteenTotalPlays_$gridSize') ?? 0;
    totalTimeMs = prefs.getInt('fifteenTotalTimeElapsed_$gridSize') ?? 0;
  }

  int? get averageMs {
    if (totalPlays == 0 || totalTimeMs == 0) return null;
    return (totalTimeMs / totalPlays).round();
  }
}
