import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart'; // 📌 스토어 연결을 위해 추가
import 'fifteen_puzzle_screen.dart';
import 'settings_screen.dart';
import 'record_screen.dart'; // 📌 P4: RecordScreen 임포트 추가
import '../widgets/ad_banner_widget.dart';
import '../utils/app_texts.dart'; // 📌 AppTexts 임포트 추가

// 📌 홍보 앱 목록 (팝업에서 스토어로 연결됩니다)
// 여기에 { 이름, 패키지명 }만 추가하면 팝업에 자동 반영됩니다.
const List<_PromoApp> _promoApps = [
  _PromoApp(name: 'Magic Can Puzzle', packageName: 'com.han.puzzle'),
];

class _PromoApp {
  final String name;
  final String packageName;

  const _PromoApp({required this.name, required this.packageName});
}

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

  // 📌 [다른 앱 구경하기] 버튼을 눌렀을 때 실행되는 홍보 팝업
  void _showPromoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF283593),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            AppTexts.get('moreAppsTitle'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppTexts.get('moreAppsMessage'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 16),
              // 📌 홍보 앱 목록을 스토어 버튼으로 표시
              for (final app in _promoApps) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B1FA2),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // 팝업 닫기
                      _launchStore(app.packageName);
                    },
                    icon: const Icon(Icons.storefront, size: 20),
                    label: Text(app.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        );
      },
    );
  }

  // 📌 구글 플레이스토어 연결 (market:// 시도 후 실패 시 https 폴백)
  Future<void> _launchStore(String packageName) async {
    final marketUri = Uri.parse('market://details?id=$packageName');
    final httpsUri = Uri.parse('https://play.google.com/store/apps/details?id=$packageName');
    try {
      if (await canLaunchUrl(marketUri)) {
        await launchUrl(marketUri, mode: LaunchMode.externalApplication);
        return;
      }
      if (await canLaunchUrl(httpsUri)) {
        await launchUrl(httpsUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Store launch failed: $e');
    }
  }

  // 📌 게임 시작 시 4x4 또는 5x5를 선택할 수 있는 팝업
  void _showGridSizeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF283593),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            '게임 모드 선택\nSelect Game Mode',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C27B0),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  Navigator.pop(context); // 팝업 닫기
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FifteenPuzzleScreen(gridSize: 4), // 4x4 전달
                    ),
                  );
                  setState(() {});
                },
                child: const Text('4 X 4', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B1FA2),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  Navigator.pop(context); // 팝업 닫기
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FifteenPuzzleScreen(gridSize: 5), // 5x5 전달
                    ),
                  );
                  setState(() {});
                },
                child: const Text('5 X 5', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
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
                    title: AppTexts.get('fifteenPuzzle'),
                    color: const Color(0xFF9C27B0),
                    onPressed: _showGridSizeDialog, // 📌 팝업 호출 함수로 연결
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
                  const SizedBox(height: 16),
                  _buildMenuButton(
                    context,
                    title: AppTexts.get('moreApps'), // 📌 다국어 적용
                    color: const Color(0xFF14B8A6),
                    onPressed: _showPromoDialog,
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