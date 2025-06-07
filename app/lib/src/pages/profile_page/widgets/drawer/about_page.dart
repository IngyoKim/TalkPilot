import 'package:flutter/material.dart';
import 'section_expansion_tile.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final List<bool> _isExpanded = List.generate(6, (_) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('About', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionExpansionTile(
            index: 0,
            title: 'TalkPilot 소개',
            content:
                '발표를 더 똑똑하게, 함께 준비하는 발표 도우미\n'
                '발표의 자율주행화를 목표로 하는 올인원 발표 연습 플랫폼입니다.\n'
                '현대오토에버 배리어프리 앱 개발 콘테스트 출품작입니다.',
            initiallyExpanded: _isExpanded[0],
          ),
          SectionExpansionTile(
            index: 1,
            title: '주요 기능',
            content:
                '• 발표 연습 기능\n'
                '  - Google Cloud STT API를 이용한 발표 연습 기능\n\n'
                '• 스케쥴 파악\n'
                '  - 스케쥴 페이지에서 한눈에 일정 확인 가능\n\n'
                '• 대본 및 프로젝트 관리\n'
                '  - 프로젝트별 대본 등록, 편집, 참여자 관리 가능\n'
                '  - 발표자별 발화 속도 측정 및 할당 구간 지정 기능 제공\n\n'
                '• 예상 발표 시간 계산\n'
                '  - 발화 속도와 대본 길이를 기반으로 예상 발표 시간 자동 산출\n'
                '  - 2인 이상의 발표자가 있는 경우도 처리 가능\n\n'
                '• 멀티 플랫폼 지원\n'
                '  - Flutter 기반 모바일 앱과 React + NestJS 기반 웹 클라이언트 제공\n'
                '  - 웹 클라이언트 주소: talkpilot.vercel.app',
            initiallyExpanded: _isExpanded[1],
          ),
          SectionExpansionTile(
            index: 2,
            title: '기술 스택',
            content:
                '모바일 앱: Flutter (Dart)\n'
                '웹 클라이언트: React (JavaScript)\n'
                '백엔드 서버: NestJS (TypeScript)\n'
                '인증: Firebase Authentication\n'
                'DB: Realtime Database\n'
                '음성 인식: Google Cloud STT',
            initiallyExpanded: _isExpanded[2],
          ),
          SectionExpansionTile(
            index: 3,
            title: '개발자 정보',
            content:
                '팀명: OmO\n'
                '팀장: 김인교 (https://github.com/IngyoKim)\n'
                '팀원: 김민규 (https://github.com/Asdfuxk)\n'
                '         전상민 (https://github.com/A-X-Y-S-T)',
            initiallyExpanded: _isExpanded[3],
          ),
          SectionExpansionTile(
            index: 4,
            title: '버전',
            content: 'v1.0.0',
            initiallyExpanded: _isExpanded[4],
          ),
          SectionExpansionTile(
            index: 5,
            title: '라이선스',
            content: 'MIT License © 2025 OmO Team',
            initiallyExpanded: _isExpanded[5],
          ),
        ],
      ),
    );
  }
}
