import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'game_screen.dart';
import 'fifteen_puzzle_screen.dart';
import 'tutorial_screen.dart';
import 'settings_screen.dart';
import 'record_screen.dart'; // 📌 P4: RecordScreen 임포트 추가
import '../widgets/ad_banner_widget.dart';
import '../utils/app_texts.dart'; // 📌 AppTexts 임포트 추가

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _appVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    _checkForUpdate();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
      });
    } catch (e) {
      debugPrint('Failed to get package info: $e');
    }
  }

  Future<void> _checkForUpdate() async {
    try {
      AppUpdateInfo info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        if (info.immediateUpdateAllowed) {
          await InAppUpdate.performImmediateUpdate();
        }
      }
    } catch (e) {
      debugPrint('Update check failed: $e');
    }
  }

  // 📌 우측 상단 지구본 아이콘을 눌렀을 때 실행되는 언어 선택 팝업
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF283593),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            '언어 / Language / 言語',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLangOption('한국어'),
              const Divider(color: Colors.white24),
              _buildLangOption('English'),
              const Divider(color: Colors.white24),
              _buildLangOption('日本語'),
            ],
          ),
        );
      },
    );
  }

  // 언어 선택 버튼 위젯
  Widget _buildLangOption(String langName) {
    bool isSelected = AppTexts.currentLang == langName;
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        minimumSize: const Size(double.infinity, 40),
      ),
      onPressed: () async {
        await AppTexts.setLanguage(langName); // 선택한 언어 저장
        setState(() {}); // MainScreen 갱신
        Navigator.pop(context); // 팝업 닫기
      },
      child: Text(
        langName,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.amber : Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // 📌 상단 왼쪽에 버전 표시 배치
        leadingWidth: 120,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Center(
            child: Text(
              'ver : $_appVersion',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        // 📌 상단 오른쪽에 지구본(언어 변경) 아이콘 배치
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            tooltip: 'Change Language',
            onPressed: _showLanguageDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/title.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  _buildMenuButton(
                    context,
                    title: AppTexts.get('gameStart'), // 📌 다국어 적용
                    color: const Color(0xFFFB923C),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GameScreen()),
                      );
                      setState(() {}); // 게임 화면에서 돌아왔을 때 언어 상태 갱신
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildMenuButton(
                    context,
                    title: AppTexts.get('fifteenPuzzle'),
                    color: const Color(0xFF9C27B0),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FifteenPuzzleScreen()),
                      );
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildMenuButton(
                    context,
                    title: AppTexts.get('recordView'), // 📌 다국어 적용
                    color: const Color(0xFFFBBF24),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RecordScreen()),
                      );
                      setState(() {});
                    },
                  ),
                  // const SizedBox(height: 16),
                  // _buildMenuButton(
                  //   context,
                  //   title: '게임 방법',
                  //   color: const Color(0xFF34D399),
                  //   onPressed: () => Navigator.push(
                  //     context,
                  //     MaterialPageRoute(builder: (_) => const TutorialScreen()),
                  //   ),
                  // ),
                  const SizedBox(height: 16),
                  _buildMenuButton(
                    context,
                    title: AppTexts.get('settings'), // 📌 다국어 적용
                    color: const Color(0xFF38BDF8),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                      setState(() {}); // 설정 화면에서 언어를 바꾸고 돌아왔을 때 반영
                    },
                  ),
                  const SizedBox(height: 24),
                  const AdBannerWidget(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
      BuildContext context, {
        required String title,
        required Color color,
        required VoidCallback onPressed,
      }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: Colors.black.withOpacity(0.2),
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}