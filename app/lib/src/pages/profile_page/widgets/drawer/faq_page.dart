import 'package:flutter/material.dart';
import 'section_expansion_tile.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  final List<bool> _isExpanded = List.generate(4, (_) => false);

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
