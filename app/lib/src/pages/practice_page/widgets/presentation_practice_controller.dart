import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/models/script_part_model.dart';
import 'package:talk_pilot/src/pages/practice_page/widgets/speaker_cpm_result.dart';
import 'package:talk_pilot/src/services/stt/stt_service.dart';
import 'package:talk_pilot/src/services/project/live_cpm_service.dart';
import 'package:talk_pilot/src/services/database/user_service.dart';
import 'package:talk_pilot/src/services/project/script_progress_service.dart';
import 'package:talk_pilot/src/services/database/project_service.dart';

class PresentationPracticeController {
  final String projectId;
  final VoidCallback onUpdate;

  final Map<String, SpeakerCpmResult> _speakerCpmResults = {};
  final Map<String, LiveCpmService> _cpmServices = {};

  final SttService _sttService = SttService();
  final ScriptProgressService _progressService = ScriptProgressService();
  final ProjectService _projectService = ProjectService();
  final Stopwatch _stopwatch = Stopwatch();

  String recognizedText = '';
  bool isListening = false;
  bool hasUpdatedCpm = false;
  double userCpm = 0.0;
  double scriptProgress = 0.0;

  ProjectModel? _projectModel;
  String? currentSpeakerNickname;
  String? currentSpeakerUid;

  List<int> _charStartIndices = [];

  List<String> get scriptChunks => _progressService.scriptChunks;
  Duration get presentationDuration => _stopwatch.elapsed;
  Duration get expectedDuration =>
      Duration(seconds: _projectModel?.estimatedTime ?? 120);
  double get scriptAccuracy =>
      _progressService.calculateAccuracy(recognizedText);

  double get currentCpm {
    final active = currentSpeakerUid;
    if (active == null) return 0;
    final service = _cpmServices[active];
    return service?.currentCpm ?? 0;
  }

  String get cpmStatus {
    final active = currentSpeakerUid;
    if (active == null) return '적당함';
    return _speakerCpmResults[active]?.cpmStatus ?? '적당함';
  }

  double get userCpmForCurrentSpeaker {
    final active = currentSpeakerUid;
    if (active == null) return userCpm;
    return _speakerCpmResults[active]?.userCpm ?? userCpm;
  }

  List<SpeakerCpmResult> get speakerResults =>
      _speakerCpmResults.values.toList();

  PresentationPracticeController({
    required this.projectId,
    required this.onUpdate,
  });

  Future<void> initialize() async {
    await _sttService.init();
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

    final script = _projectModel?.script ?? '';
    _charStartIndices = _buildWordCharStartIndices(
      script,
      _progressService.scriptChunks,
    );

    onUpdate();
  }

  List<int> _buildWordCharStartIndices(String script, List<String> chunks) {
    final List<int> charIndices = [];
    int cursor = 0;
    for (final word in chunks) {
      final index = script.indexOf(word, cursor);
      if (index == -1) {
        charIndices.add(cursor);
      } else {
        charIndices.add(index);
        cursor = index + word.length;
      }
    }
    return charIndices;
  }

  int get _currentCharIndex {
    final wordIndex =
        (_progressService.scriptChunks.length * scriptProgress).floor();
    if (_charStartIndices.isEmpty) return 0;
    if (wordIndex >= _charStartIndices.length) return _charStartIndices.last;
    return _charStartIndices[wordIndex];
  }

  Future<void> startListening() async {
    _stopwatch.reset();
    _stopwatch.start();

    await _sttService.startListening((text) async {
      recognizedText = text;
      isListening = true;
      scriptProgress = _progressService.calculateProgressByLastMatch(text);

      await _updateCurrentSpeakerByProgress();

      final active = currentSpeakerUid;
      if (active != null && _cpmServices.containsKey(active)) {
        _cpmServices[active]!.updateRecognizedText(text);
      }

      onUpdate();
    });

    isListening = true;
    onUpdate();
  }

  Future<void> _updateCurrentSpeakerByProgress() async {
    final parts = _projectModel?.scriptParts;
    if (parts == null || parts.isEmpty) return;

    final currentIndex = _currentCharIndex;
    ScriptPartModel? matchedPart;

    for (final part in parts) {
      if (part.startIndex <= currentIndex && currentIndex <= part.endIndex) {
        matchedPart = part;
        break;
      }
    }

    matchedPart ??= parts.last;

    final userModel = await UserService().readUser(matchedPart.uid);
    final uid = userModel?.uid;
    final nickname = userModel?.nickname ?? '발표자';
    final targetCpm = userModel?.cpm ?? 200.0;

    if (uid == null || currentSpeakerUid == uid) return;

    currentSpeakerUid = uid;
    currentSpeakerNickname = nickname;

    _speakerCpmResults.putIfAbsent(
      uid,
      () => SpeakerCpmResult(
        uid: uid,
        nickname: nickname,
        actualCpm: 0,
        userCpm: targetCpm,
        cpmStatus: '적당함',
      ),
    );

    _cpmServices[uid]?.stop();
    _cpmServices[uid] =
        LiveCpmService()..start(
          userAverageCpm: targetCpm,
          onCpmUpdate: (cpm, status) {
            final result = _speakerCpmResults[uid];
            if (result != null) {
              result.actualCpm = cpm;
              result.cpmStatus = status;
            }
            onUpdate();
          },
        );

    onUpdate();
  }

  Future<void> stopListening() async {
    _stopwatch.stop();
    await _sttService.stopListening();
    for (final service in _cpmServices.values) {
      service.stop();
    }
    isListening = false;
    onUpdate();
  }

  Future<void> dispose() async {
    await _sttService.dispose();
    for (final service in _cpmServices.values) {
      service.stop();
    }
  }

  bool isSimilar(String a, String b) => _progressService.isSimilar(a, b);
  List<String> splitText(String text) => _progressService.splitText(text);
}
