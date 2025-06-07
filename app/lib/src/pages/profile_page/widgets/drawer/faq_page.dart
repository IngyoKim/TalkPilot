import 'package:flutter/material.dart';
import 'section_expansion_tile.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  final List<bool> _isExpanded = List.generate(10, (_) => false);

  final List<Map<String, String>> _faqItems = [
    {
      'question': '버그등과 관련해서 개발자에게 어떻게 연락하나요?',
      'answer': 'a58276976@gmail.com 또는 010-5802-5827을 통해 연락할 수 있습니다.'
    },
    {
      'question': '앱 업데이트는 어떻게 확인하나요?',
      'answer': '앱 스토어 또는 구글 플레이 스토어에서 업데이트 알림을 받거나, 앱 내 공지사항을 확인하세요.'
    },
    {
      'question': '사용자 데이터는 어떻게 보호되나요?',
      'answer': '모든 사용자 데이터는 Firebase Authentication 및 Realtime Database를 통해 안전하게 관리됩니다.'
    },
    {
      'question': '정확도가 낮게 나오는데 정상인가요?',
      'answer': 'TalkPilot은 Google Cloud Stt 서비스를 이용하여 발표 진행 및 정확도를 측정합니다.\nSTT자체의 한계점과 띄어쓰기, 맞춤법에 의해서 정확도가 낮게 측정될 수 있습니다.\n평균적으로 70%정도의 정확도가 나오며, 맞춤법 검사기, 띄어쓰기 보정기 등을 통하여 대본을 보정하면 더욱 높은 정확도를 얻을 수 있습니다.'
    },
    {
      'question': 'CPM값이 이상해졌어요.',
      'answer': 'CPM은 맨 처음에 한 번 측정, 그 이후로는 발표 연습을 끝낼때마다 계산됩니다.\n이 값이 이상한 경우에는 프로필 페이지의 발표 기록 보기 탭에서 관리할 수 있습니다.\n평균에서 많이 벗어난 값을 삭제하거나 전체 초기화가 가능합니다.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('FAQ', style: TextStyle(color: Colors.white)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _faqItems.length,
        itemBuilder: (context, index) {
          final item = _faqItems[index];
          return SectionExpansionTile(
            index: index,
            title: item['question'] ?? '',
            content: item['answer'] ?? '',
            initiallyExpanded: _isExpanded[index],
          );
        },
      ),
    );
  }
}
