import 'package:flutter/material.dart';

class WorkPage extends StatefulWidget {
  const WorkPage({super.key});

  @override
  State<WorkPage> createState() => _WorkPageState();
}

class _WorkPageState extends State<WorkPage> {
  List<String> workItems = [];

  void _addNewItem(String title) {
    setState(() {
      // 최신순으로 위에 추가
      workItems.insert(0, title);
    });
  }

  void _showAddDialog() {
    String newTitle = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('작업 제목 입력'),
          content: TextField(
            autofocus: true,
            onChanged: (value) {
              newTitle = value;
            },
            decoration: const InputDecoration(
              hintText: '예: 보고서 작성',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 닫기
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                if (newTitle.trim().isNotEmpty) {
                  _addNewItem(newTitle.trim());
                }
                Navigator.pop(context);
              },
              child: const Text('추가'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('작업'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              debugPrint('설정 클릭');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // + 추가 버튼
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _showAddDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('추가'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 작업 리스트
          Expanded(
            child: workItems.isEmpty
                ? const Center(child: Text('추가된 작업이 없습니다.'))
                : ListView.builder(
                    itemCount: workItems.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            workItems[index],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
