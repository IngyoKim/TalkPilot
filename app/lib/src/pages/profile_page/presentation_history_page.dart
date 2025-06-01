import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talk_pilot/src/models/cpm_record_model.dart';
import 'package:talk_pilot/src/services/database/cpm_history_service.dart';
import 'package:talk_pilot/src/services/database/user_service.dart';

class PresentationHistoryPage extends StatefulWidget {
  const PresentationHistoryPage({super.key});

  @override
  State<PresentationHistoryPage> createState() => _PresentationHistoryPageState();
}

class _PresentationHistoryPageState extends State<PresentationHistoryPage> {
  final _userService = UserService();
  late Future<List<CpmRecordModel>> _cpmHistoryFuture;

  @override
  void initState() {
    super.initState();
    _loadCpmHistory();
  }

  void _loadCpmHistory() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _cpmHistoryFuture = _userService.getCpmHistory(uid);
    } else {
      _cpmHistoryFuture = Future.value([]);
    }
  }

  Future<void> _clearCpmHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('기록 초기화'),
        content: const Text('모든 발표 기록을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await _userService.clearCpmHistory(uid);
        setState(() {
          _cpmHistoryFuture = Future.value([]);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('발표 기록이 삭제되었습니다')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('발표 기록 확인', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: '발표 기록 초기화',
            onPressed: _clearCpmHistory,
          ),
        ],
      ),
      body: FutureBuilder<List<CpmRecordModel>>(
        future: _cpmHistoryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('데이터를 불러오는 데 실패했습니다.'));
          }
          final records = snapshot.data ?? [];
          if (records.isEmpty) {
            return const Center(child: Text('CPM 기록이 없습니다.'));
          }

          records.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          return ListView.separated(
            itemCount: records.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final record = records[index];
              return ListTile(
                leading: const Icon(Icons.speed),
                title: Text('${record.cpm.toStringAsFixed(2)} CPM'),
                subtitle: Text(
                  '${record.timestamp.toLocal()}'.split('.').first,
                  style: const TextStyle(fontSize: 12),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
