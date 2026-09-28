import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart'; // 버전 정보를 위해 임포트
import 'package:shared_preferences/shared_preferences.dart'; // 📌 설정 저장을 위해 임포트
import 'package:url_launcher/url_launcher.dart'; // 웹링크 연결을 위해 임포트
import '../widgets/ad_banner_widget.dart'; // 📌 광고 위젯 임포트 경로에 맞춰 수정해 주세요
import '../utils/app_texts.dart'; // 📌 AppTexts 임포트 추가

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 설정 상태값
  bool _isSoundOn = true;
  bool _isBgmOn = true;
  String _selectedLang = AppTexts.currentLang; // 📌 현재 선택된 언어 상태

  // 버전 정보를 저장할 변수
  String _appVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    _loadSettings(); // 📌 화면 진입 시 저장된 설정 불러오기
    _initPackageInfo();
  }

  // 📌 SharedPreferences를 이용해 설정 불러오기
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isSoundOn = prefs.getBool('isSoundOn') ?? true;
      _isBgmOn = prefs.getBool('isBgmOn') ?? true;
      _selectedLang = prefs.getString('selected_language') ?? '한국어';
    });
  }

  // 📌 설정 변경 시 SharedPreferences에 저장하기
  Future<void> _saveSettings(bool soundOn, bool bgmOn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSoundOn', soundOn);
    await prefs.setBool('isBgmOn', bgmOn);
  }

  // 앱 버전 및 빌드 번호 가져오기
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

  // 개인정보처리방침 URL 여는 함수
  Future<void> _launchPrivacyPolicy() async {
    final Uri url = Uri.parse('https://hdevpolic.netlify.app/');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Could not launch URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 배경이 AppBar 영역 뒤까지 확장되도록 설정 (상태바까지 덮음)
      extendBodyBehindAppBar: true,
      // MainScreen과 동일한 배경 이미지 적용
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'), // 동일한 배경 이미지 사용
            fit: BoxFit.cover, // 화면에 꽉 차게 비율 유지하며 채우기
          ),
        ),
        child: Column(
          children: [
            // 커스텀 상단 영역 (배경 위에 반투명하게 겹침)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // 홈 화면으로 바로 이동하는 버튼
                    IconButton(
                      icon: const Icon(Icons.home, color: Colors.white),
                      onPressed: () {
                        // 현재 화면 위에 쌓인 모든 경로를 pop하여 루트(홈) 화면으로 이동
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      tooltip: AppTexts.get('homeTooltip'), // 📌 다국어 적용
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppTexts.get('settingsTitle'), // 📌 다국어 적용
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // 레이아웃 균형을 위한 빈 공간 (IconButton 크기와 동일)
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),

            // 기존 콘텐츠 영역 (중앙 배치)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),

                      // 설정 항목들을 감싸는 카드 컨테이너 (가독성 향상)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4), // 반투명 검은색 배경으로 텍스트 가독성 확보
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            // 📌 언어 변경 드롭다운 추가
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppTexts.get('selectLanguage'), // 📌 다국어 적용
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                DropdownButton<String>(
                                  value: _selectedLang,
                                  dropdownColor: const Color(0xFF283593),
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                  underline: Container(),
                                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                                  items: ['한국어', 'English', '日本語'].map((String lang) {
                                    return DropdownMenuItem<String>(
                                      value: lang,
                                      child: Text(lang),
                                    );
                                  }).toList(),
                                  onChanged: (String? newLang) async {
                                    if (newLang != null) {
                                      setState(() {
                                        _selectedLang = newLang;
                                      });
                                      await AppTexts.setLanguage(newLang); // 📌 언어 저장 및 변경
                                      setState(() {}); // 현재 화면 새로고침
                                    }
                                  },
                                ),
                              ],
                            ),
                            const Divider(color: Colors.white24, height: 24),
                            _buildSettingSwitch(
                              title: AppTexts.get('soundEffects'), // 📌 다국어 적용
                              value: _isSoundOn,
                              onChanged: (value) {
                                setState(() {
                                  _isSoundOn = value;
                                });
                                _saveSettings(_isSoundOn, _isBgmOn); // 📌 변경 즉시 저장
                              },
                            ),
                            const Divider(color: Colors.white24, height: 24),

                            // 개인정보처리방침 버튼 추가
                            SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                onPressed: _launchPrivacyPolicy,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  alignment: Alignment.centerLeft,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      AppTexts.get('privacyPolicy'), // 📌 다국어 적용
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white70,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),

            // 📌 배너 광고 영역을 버전 정보 위로 이동
            const SizedBox(
              height: 50,
              child: AdBannerWidget(),
            ),
            const SizedBox(height: 5),

            // 화면 최하단 버전 표시
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                'ver : $_appVersion',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 설정 스위치 항목을 만드는 헬퍼 위젯
  Widget _buildSettingSwitch({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF38BDF8), // MainScreen의 설정 버튼 블루 컬러와 통일감 부여
        ),
      ],
    );
  }
}