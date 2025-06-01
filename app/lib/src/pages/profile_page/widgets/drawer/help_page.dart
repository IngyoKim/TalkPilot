import 'package:flutter/material.dart';
import 'section_expansion_tile.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final List<bool> _isExpanded = List.generate(5, (_) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Help', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionExpansionTile(
            index: 0,
            title: '점수 채점 기준',
            content: '총점(100점)\n대본 정확도: 20점\n평균 CPM 상태: 25점\n속도 일관성: 25점\n발표 시간: 30점',
            initiallyExpanded: _isExpanded[0],
          ),
          SectionExpansionTile(
            index: 1,
            title: '프로젝트 추가 방법',
            content: '프로젝트 탭의 우측 상단 \'+\' 아이콘을 통해 추가할 수 있습니다.\n프로젝트 생성은 제목과 설명을 입력하여 프로젝트를 생성할 수 있습니다.\n프로젝트 참여는 프로젝트 ID를 입력하여 다른 유저의 발표에 참여할 수 있습니다.',
            initiallyExpanded: _isExpanded[1],
          ),
          SectionExpansionTile(
            index: 2,
            title: '역할에 따른 권한',
            content: 'Member: 발표 자료 열람, 발표 흐름 확인, 연습 기능 사용\nEditor: 발표 자료 편집, 발표 자료 추가 및 삭제, Member 권한 포함\nOwner: 사용자 역할 변경 및 관리, 사용자 추가 및 삭제, 발표 전체 설정 관리, Editor 권한 포함',
            initiallyExpanded: _isExpanded[2],
          ),
          SectionExpansionTile(
            index: 3,
            title: '정확도에 대한 정의',
            content: '인식된 대본 조각 중 실제로 맞게 인식된 부분의 비율',
            initiallyExpanded: _isExpanded[3],
          ),
          SectionExpansionTile(
            index: 4,
            title: '진행도에 대한 정의',
            content: '대본에서 마지막으로 인식된 부분까지의 비율',
            initiallyExpanded: _isExpanded[4],
          ),
        ],
      ),
    );
  }
}
