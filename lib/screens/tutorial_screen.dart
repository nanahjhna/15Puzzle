import 'package:flutter/material.dart';
import '../widgets/ad_banner_widget.dart'; // 📌 광고 위젯 임포트 경로에 맞춰 수정해 주세요

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({Key? key}) : super(key: key);

  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  // PageView의 현재 페이지 상태를 관리하는 컨트롤러
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // 튜토리얼 데이터 리스트 (제목, 설명, 이미지 경로)
  final List<Map<String, String>> _tutorialData = [
    {
      'title': '1. 게임 목표',
      'text': '세로 줄(Column)의 공 색상을 모두 동일하게 맞추면 승리합니다!',
      'image': 'assets/images/tutorial_goal.png' // 생성된 이미지 경로
    },
    {
      'title': '2. 실린더 회전',
      'text': '각 행을 좌우로 드래그하거나 화살표 버튼을 눌러 회전시킬 수 있습니다.',
      'image': 'assets/images/tutorial_rotate.png' // 생성된 이미지 경로
    },
    {
      'title': '3. 구슬 이동',
      'text': '빈칸(Empty)과 인접한 구슬을 탭하면 빈칸으로 이동합니다.',
      'image': 'assets/images/tutorial_tap.png' // 생성된 이미지 경로
    },
  ];

  @override
  void dispose() {
    _pageController.dispose(); // 컨트롤러 해제
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
              // 1. 커스텀 상단 영역 (홈 버튼 + 타이틀)
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



              // 📌 3. 화면 하단 배너 광고 영역 추가
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