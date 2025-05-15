import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/services/stt/stt_service.dart';
import 'package:talk_pilot/src/services/project/live_cpm_service.dart';
import 'package:talk_pilot/src/services/database/user_service.dart';
import 'package:talk_pilot/src/services/project/script_progress_service.dart';
import 'package:talk_pilot/src/services/database/project_service.dart';

class PresentationPracticeController {
  final String projectId;
  final VoidCallback onUpdate;

  final SttService _sttService = SttService();
  final LiveCpmService _cpmService = LiveCpmService();
  final ScriptProgressService _progressService = ScriptProgressService();
  final ProjectService _projectService = ProjectService();
  final Stopwatch _stopwatch = Stopwatch();

  String recognizedText = '';
  bool isListening = false;
  bool hasUpdatedCpm = false;
  double currentCpm = 0.0;
  String cpmStatus = '적당함';
  double userCpm = 0.0;
  double scriptProgress = 0.0;

  ProjectModel? _projectModel;

  List<String> get scriptChunks => _progressService.scriptChunks;
  Duration get presentationDuration => _stopwatch.elapsed;
  Duration get expectedDuration => Duration(seconds: _projectModel?.estimatedTime ?? 120);
  double get scriptAccuracy => _progressService.calculateAccuracy(recognizedText);

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
    _projectModel = await _projectService.readProject(projectId);
    await _progressService.loadScript(projectId);
    onUpdate();
  }

  void startListening() {
    _stopwatch.reset();
    _stopwatch.start();

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
    _stopwatch.stop();
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
