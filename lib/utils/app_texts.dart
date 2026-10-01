import 'package:shared_preferences/shared_preferences.dart';

class AppTexts {
  static String _currentLang = '한국어';

  // 📌 저장된 언어 불러오기 (앱이 켜질 때 호출)
  static Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLang = prefs.getString('selected_language') ?? '한국어';
  }

  // 📌 언어 변경 및 저장하기
  static Future<void> setLanguage(String lang) async {
    _currentLang = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', lang);
  }

  static String get currentLang => _currentLang;

  // 📌 화면별 텍스트 데이터 맵 (다른 화면의 텍스트도 여기에 계속 추가하면 됩니다)
  static final Map<String, Map<String, String>> _texts = {
    '한국어': {
      'gameStart': '게임 시작',
      'recordView': '기록 보기',
      'settings': '설정',
      'gameMethod': '게임 방법',
      'elapsedTime': '소요 시간',
      'settingsTitle': '⚙️ 설정',
      'goToMain': '메인으로 이동',
      'restartGame': '게임 다시하기',
      'soundEffects': '효과음',
      'close': '닫기',
      // 📌 RecordScreen & SettingsScreen 추가 키값
      'homeTooltip': '홈으로 이동',
      'recordScreenTitle': '🏆 게임 기록',
      'bestRecord': '최고 기록',
      'topRecords': '상위 기록',
      'firstPlace': '1위',
      'secondPlace': '2위',
      'thirdPlace': '3위',
      'totalPlays': '플레이 횟수',
      'playsUnit': '회',
      'totalTime': '누적 플레이 시간',
      'minutesUnit': '분',
      'averageTime': '평균 클리어 타임',
      'privacyPolicy': '개인정보처리방침',
      // 📌 퍼즐 추가 키값
      'fifteenPuzzle': '게임 시작하기',
      'fifteenReadyMessage': '번호를 순서대로 배치하세요.',
      'fifteenNewRecord': '👑 신기록!',
      'fifteenSuccess': '🎉 퍼즐 클리어!',
      'fifteenPlayAgain': '다시 하기',
      'fifteenHome': '홈으로',
      // 📌 홍보 / 다른 앱 구경하기 키 추가
      'moreApps': '다른 앱 구경하기',
      'moreAppsTitle': '다른 앱들도 구경해 보세요!',
      'moreAppsMessage': '아래 앱을 눌러 스토어에서 확인해 보세요.',
      // 📌 언어 선택 / 게임 모드 / 오류 메시지 추가 키값
      'selectLanguage': '언어 선택',
      'gameModeSelect': '게임 모드 선택',
      'changeLanguageTooltip': '언어 변경',
      'soundPlayError': '사운드 재생 중 오류가 발생했습니다.',
      // 📌 인앱 업데이트 안내 키값
      'updateAvailableTitle': '업데이트 가능',
      'updateAvailableMessage': '새로운 버전이 배포되었습니다. 지금 업데이트할까요?',
      'updateNow': '지금 업데이트',
      'updateLater': '나중에',
    },
    'English': {
      'gameStart': 'Start Game',
      'recordView': 'View Records',
      'settings': 'Settings',
      'gameMethod': 'How to Play',
      'elapsedTime': 'Time',
      'settingsTitle': '⚙️ Settings',
      'goToMain': 'Go to Main',
      'restartGame': 'Restart Game',
      'soundEffects': 'Sound Effects',
      'close': 'Close',
      // 📌 RecordScreen & SettingsScreen 추가 키값
      'homeTooltip': 'Go to Home',
      'recordScreenTitle': '🏆 Game Records',
      'bestRecord': 'Best Record',
      'topRecords': 'Top Records',
      'firstPlace': '1st',
      'secondPlace': '2nd',
      'thirdPlace': '3rd',
      'totalPlays': 'Total Plays',
      'playsUnit': 'times',
      'totalTime': 'Total Time',
      'minutesUnit': 'min',
      'averageTime': 'Average Time',
      'privacyPolicy': 'Privacy Policy',
      'fifteenPuzzle': 'Game Start',
      'fifteenReadyMessage': 'Arrange the numbers in order.',
      'fifteenNewRecord': '👑 New Record!',
      'fifteenSuccess': '🎉 15 Puzzle Cleared!',
      'fifteenPlayAgain': 'Play Again',
      'fifteenHome': 'Home',
      // 📌 홍보 / 다른 앱 구경하기 키 추가
      'moreApps': 'More Apps',
      'moreAppsTitle': 'Check Out My Other Apps!',
      'moreAppsMessage': 'Tap an app below to check it out in the store.',
      // 📌 언어 선택 / 게임 모드 / 오류 메시지 추가 키값
      'selectLanguage': 'Select Language',
      'gameModeSelect': 'Select Game Mode',
      'changeLanguageTooltip': 'Change Language',
      'soundPlayError': 'An error occurred while playing the sound.',
      // 📌 인앱 업데이트 안내 키값
      'updateAvailableTitle': 'Update Available',
      'updateAvailableMessage': 'A new version has been released. Update now?',
      'updateNow': 'Update Now',
      'updateLater': 'Later',
    },
    '日本語': {
      'gameStart': 'ゲーム開始',
      'recordView': '記録を見る',
      'settings': '設定',
      'gameMethod': '遊び方',
      'elapsedTime': '所要時間',
      'settingsTitle': '⚙️ 設定',
      'goToMain': 'メインへ移動',
      'restartGame': 'ゲームやり直し',
      'soundEffects': '効果音',
      'close': '閉じる',
      // 📌 RecordScreen & SettingsScreen 추가 키값
      'homeTooltip': 'ホームへ移動',
      'recordScreenTitle': '🏆 ゲーム記録',
      'bestRecord': '最高記録',
      'topRecords': 'トップ記録',
      'firstPlace': '1位',
      'secondPlace': '2位',
      'thirdPlace': '3位',
      'totalPlays': 'プレイ回数',
      'playsUnit': '回',
      'totalTime': '累計プレイ時間',
      'minutesUnit': '分',
      'averageTime': '平均クリアタイム',
      'privacyPolicy': 'プライバシーポリシー',
      'fifteenPuzzle': 'ゲームスタート',
      'fifteenReadyMessage': '番号を順番に並べてください。',
      'fifteenNewRecord': '👑 新記録！',
      'fifteenSuccess': '🎉 15パズルクリア！',
      'fifteenPlayAgain': 'もう一度',
      'fifteenHome': 'ホームへ',
      // 📌 홍보 / 다른 앱 구경하기 키 추가
      'moreApps': '他のアプリを見る',
      'moreAppsTitle': '他のアプリもチェック！',
      'moreAppsMessage': '下のアプリをタップしてストアで確認できます。',
      // 📌 언어 선택 / 게임 모드 / 오류 메시지 추가 키값
      'selectLanguage': '言語を選択',
      'gameModeSelect': 'ゲームモード選択',
      'changeLanguageTooltip': '言語を変更',
      'soundPlayError': 'サウンドの再生中にエラーが発生しました。',
      // 📌 인앱 업데이트 안내 키값
      'updateAvailableTitle': 'アップデートがあります',
      'updateAvailableMessage': '新しいバージョンが公開されました。今すぐ更新しますか？',
      'updateNow': '今すぐ更新',
      'updateLater': '後で',
    },
  };

  // 📌 텍스트를 가져오는 함수
  static String get(String key) {
    return _texts[_currentLang]?[key] ?? _texts['한국어']?[key] ?? key;
  }

  // 📌 라벨과 값을 합쳐서 표시 (예: 소요 시간: 12.34초)
  // 3개 언어 모두 반콜론 + 공백이 표준이라 구분자는 고정입니다.
  static String pair(String key, String value) {
    return '${get(key)}: $value';
  }

  // 📌 초 단위 시간 포맷 (예: 12.34초 / 12.34s / 12.34秒)
  static String formatTimeSec(int seconds, int centiseconds) {
    String csStr = centiseconds.toString().padLeft(2, '0');
    if (_currentLang == 'English') {
      return '$seconds.$csStr s';
    } else if (_currentLang == '日本語') {
      return '$seconds.$csStr秒';
    } else {
      return '$seconds.$csStr초';
    }
  }

  // 📌 분/초 단위 시간 포맷 (예: 1분 12.34초 / 1m 12.34s / 1分 12.34秒)
  static String formatTimeMinSec(int minutes, int seconds, int centiseconds) {
    String csStr = centiseconds.toString().padLeft(2, '0');
    if (_currentLang == 'English') {
      return '$minutes m $seconds.$csStr s';
    } else if (_currentLang == '日本語') {
      return '$minutes分 $seconds.$csStr秒';
    } else {
      return '$minutes분 $seconds.$csStr초';
    }
  }
}
