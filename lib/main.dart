import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 📌 저장된 언어 불러오기를 위해 임포트 추가
import 'screens/main_screen.dart';
import 'utils/app_texts.dart'; // 📌 AppTexts 임포트 추가 (프로젝트 경로에 맞게 확인해주세요)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 📌 앱 실행 전 저장된 언어 설정 불러오기
  try {
    final prefs = await SharedPreferences.getInstance();
    String savedLang = prefs.getString('selected_language') ?? '한국어';
    await AppTexts.setLanguage(savedLang);
  } catch (e) {
    debugPrint('Failed to load saved language: $e');
  }

  // 📌 모바일 환경에서 애드몹 초기화 및 상태 로깅 추가
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    InitializationStatus status = await MobileAds.instance.initialize();
    status.adapterStatuses.forEach((key, value) {
      debugPrint('AdMob Adapter status: $key: ${value.state.name} (${value.description})');
    });
  }

  runApp(const fifteenPuzzleApp());
}

class fifteenPuzzleApp extends StatelessWidget {
  const fifteenPuzzleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magic Can Puzzle',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}