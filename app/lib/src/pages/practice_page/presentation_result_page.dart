import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talk_pilot/src/components/bottom_bar.dart';
import 'package:talk_pilot/src/models/cpm_record_model.dart';
import 'package:talk_pilot/src/pages/practice_page/widgets/result_summary.dart';
import 'package:talk_pilot/src/pages/practice_page/widgets/speaker_cpm_result.dart';
import 'package:talk_pilot/src/provider/user_provider.dart';
import 'package:talk_pilot/src/services/database/cpm_history_service.dart';
import 'package:talk_pilot/src/services/database/user_service.dart';

class PresentationResultPage extends StatefulWidget {
  final double scriptAccuracy;
  final double actualCpm;
  final double userCpm;
  final String cpmStatus;
  final Duration actualDuration;
  final Duration expectedDuration;
  final List<SpeakerCpmResult> speakerResults;

  const PresentationResultPage({
    super.key,
    required this.scriptAccuracy,
    required this.actualCpm,
    required this.userCpm,
    required this.cpmStatus,
    required this.actualDuration,
    required this.expectedDuration,
    required this.speakerResults,
  });

  @override
  State<PresentationResultPage> createState() => _PresentationResultPageState();
}

class _PresentationResultPageState extends State<PresentationResultPage> {
  @override
  void initState() {
    super.initState();
    _saveCpmRecord();
  }

  Future<void> _saveCpmRecord() async {
    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.currentUser;
    if (currentUser == null) return;

    final userService = UserService();
    final now = DateTime.now();

    for (final speaker in widget.speakerResults) {
      final record = CpmRecordModel(cpm: speaker.actualCpm, timestamp: now);
      await userService.addCpmRecord(speaker.uid, record);

      if (speaker.uid == currentUser.uid) {
        await userService.updateAverageCpm(speaker.uid);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('최종 결과'),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ResultSummary(
                scriptAccuracy: widget.scriptAccuracy,
                actualCpm: widget.actualCpm,
                userCpm: widget.userCpm,
                cpmStatus: widget.cpmStatus,
                actualDuration: widget.actualDuration,
                expectedDuration: widget.expectedDuration,
                speakerResults: widget.speakerResults,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const BottomBar()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('메인 화면으로 이동'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
