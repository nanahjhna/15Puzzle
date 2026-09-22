import 'package:flutter_test/flutter_test.dart';
import 'package:fifteenPuzzle/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // 빌드 및 앱 실행 확인
    await tester.pumpWidget(const fifteenPuzzleApp());

    // 메인 화면의 메뉴 버튼 텍스트가 잘 표시되는지 확인 (기본 언어: 한국어)
    expect(find.text('게임 시작하기'), findsOneWidget);
    expect(find.text('기록 보기'), findsOneWidget);
    expect(find.text('설정'), findsOneWidget);
    expect(find.text('다른 앱 구경하기'), findsOneWidget);
  });
}