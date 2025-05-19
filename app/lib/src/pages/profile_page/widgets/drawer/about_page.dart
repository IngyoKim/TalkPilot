import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('About', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildSection(
              title: 'TalkPilot 소개',
              content:
                  '발표를 더 똑똑하게, 함께 준비하는 발표 도우미\n'
                  '발표의 자율주행화를 목표로 하는 올인원 발표 연습 플랫폼입니다.\n'
                  '현대오토에버 배리어프리 앱 개발 콘테스트 출품작입니다.',
              emphasized: 'TalkPilot 소개',
            ),
            _buildSection(
              title: '주요 기능',
              content:
                  '• 실시간 음성 인식 (Speech-to-Text)\n'
                  '  - Google Cloud STT API를 이용하여 음성 인식 지원\n\n'
                  '• 대본 및 프로젝트 관리\n'
                  '  - 프로젝트별 대본 등록, 편집, 참여자 관리 가능\n'
                  '  - 발표자별 발화 속도 측정 및 할당 구간 지정 기능 제공\n\n'
                  '• 예상 발표 시간 계산\n'
                  '  - 발화 속도와 대본 길이를 기반으로 예상 발표 시간 자동 산출\n'
                  '  - 2인 이상의 발표자가 있는 경우도 처리 가능\n\n'
                  '• 사용자 인증 및 권한 관리\n'
                  '  - Google 및 Kakao 계정 로그인 지원\n\n'
                  '• 멀티 플랫폼 지원\n'
                  '  - Flutter 기반 모바일 앱과 React + NestJS 기반 웹 클라이언트 제공',
            ),
            _buildSection(
              title: '기술 스택',
              content:
                  '모바일 앱: Flutter (Dart)\n'
                  '웹 클라이언트: React (JavaScript)\n'
                  '백엔드 서버: NestJS (TypeScript)\n'
                  '인증: Firebase Authentication\n'
                  'DB: Realtime Database\n'
                  '음성 인식: Google Cloud STT',
            ),
            _buildSection(
              title: '라이선스',
              content: 'MIT License © 2025 OmO Team',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    String? emphasized,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 3,
            width: 60,
            color: Colors.deepPurple,
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }
}
