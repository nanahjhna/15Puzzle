import 'package:flutter/material.dart';
import '../widgets/ad_banner_widget.dart'; // 📌 광고 위젯 임포트 경로에 맞춰 수정해 주세요

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({Key? key}) : super(key: key);

  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  // 🗑️ 내용이 없으므로 PageController 및 데이터 리스트가 필요 없습니다.
  // final PageController _pageController = PageController();
  // int _currentPage = 0;
  // final List<Map<String, String>> _tutorialData = [...]

  @override
  void dispose() {
    // _pageController.dispose(); // 컨트롤러도 함께 제거
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        // 배경 이미지가 SafeArea까지 확장되도록 Container 설정
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
              // 1. 커스텀 상단 영역 (홈 버튼 + 타이틀) - 유지
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.home, color: Colors.white),
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      tooltip: '홈으로 이동',
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '게임 방법',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    // 레이아웃 균형을 위한 빈 공간
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // --------------------------------------------------
              // 🗑️ 2. 기존 PageView 영역 전체 삭제 (내용 없는 빈 페이지)
              // --------------------------------------------------
              const Expanded(
                child: Center(
                  child: Text(
                    '준비 중입니다.', // 원하신다면 임시 문구를 넣거나 비워두세요.
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              ),
              // --------------------------------------------------

              // 3. 화면 하단 배너 광고 영역 추가 - 유지
              const SizedBox(
                height: 50,
                child: AdBannerWidget(),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}