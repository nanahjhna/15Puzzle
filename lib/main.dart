import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/main_screen.dart';
import 'utils/app_texts.dart'; // 📌 AppTexts 임포트 추가 (프로젝트 경로에 맞게 확인해주세요)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 📌 앱 실행 전 저장된 언어 설정 불러오기
  try {
    await AppTexts.loadLanguage();
  } catch (e) {
    debugPrint('Failed to load saved language: $e');
  }

  // 📌 모바일 환경에서 애드몹 초기화 및 상태 로깅 추가
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    // 📌 RequestConfiguration은 반드시 initialize()보다 먼저 설정해야 적용됩니다.
    // 테스트 디바이스 ID는 빌드 시점에 주입합니다.
    //   flutter run --dart-define=ADMOB_TEST_DEVICE_IDS=4492C32A190B5A1EE24DCB8D74BA5C8F
    const String rawTestDeviceIds = String.fromEnvironment('ADMOB_TEST_DEVICE_IDS');
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        testDeviceIds: rawTestDeviceIds.isEmpty
            ? const <String>[]
            : rawTestDeviceIds.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      ),
    );

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
      title: '15Puzzle',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}