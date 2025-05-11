import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:talk_pilot/src/services/stt/stt_service.dart';
import 'package:talk_pilot/src/services/practice/live_cpm_service.dart';
import 'package:talk_pilot/src/services/database/user_service.dart';
import 'package:talk_pilot/src/services/practice/script_progress_service.dart';

class PresentationPracticeController {
  final String projectId;
  final VoidCallback onUpdate;

  final SttService _sttService = SttService();
  final LiveCpmService _cpmService = LiveCpmService();
  final ScriptProgressService _progressService = ScriptProgressService();

  String recognizedText = '';
  bool isListening = false;
  double currentCpm = 0.0;
  String cpmStatus = '';
  double userCpm = 0.0;
  double scriptProgress = 0.0;

  List<String> get scriptChunks => _progressService.scriptChunks;

  PresentationPracticeController({
    required this.projectId,
    required this.onUpdate,
  });

  Future<void> initialize() async {
    _sttService.init();
    await _loadUserCpm();
    await _loadScript();
  }

  Future<void> _loadUserCpm() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userModel = await UserService().readUser(user.uid);
    if (userModel == null) return;

    userCpm = userModel.cpm ?? 200.0;
    onUpdate();
  }

  Future<void> _loadScript() async {
    await _progressService.loadScript(projectId);
    onUpdate();
  }

  void startListening() {
    _cpmService.start(
      userAverageCpm: userCpm,
      onCpmUpdate: (cpm, status) {
        currentCpm = cpm;
        cpmStatus = status;
        onUpdate();
      },
    );

    _sttService.startListening((text) {
      recognizedText = text;
      isListening = true;
      scriptProgress = _progressService.calculateProgressByLastMatch(text);
      _cpmService.updateRecognizedText(text);
      onUpdate();
    });
  }

  Future<void> stopListening() async {
    await _sttService.stopListening();
    _cpmService.stop();
    isListening = false;
    onUpdate();
  }

  void dispose() {
    _sttService.stopListening();
    _cpmService.stop();
  }

  bool isSimilar(String a, String b) => _progressService.isSimilar(a, b);
  List<String> splitText(String text) => _progressService.splitText(text);
}
