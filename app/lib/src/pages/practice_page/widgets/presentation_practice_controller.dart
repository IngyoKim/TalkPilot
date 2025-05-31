import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:talk_pilot/src/models/project_model.dart';
import 'package:talk_pilot/src/models/script_part_model.dart';
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
  String? currentSpeakerNickname;

  List<int> _charStartIndices = [];

  List<String> get scriptChunks => _progressService.scriptChunks;
  Duration get presentationDuration => _stopwatch.elapsed;
  Duration get expectedDuration =>
      Duration(seconds: _projectModel?.estimatedTime ?? 120);
  double get scriptAccuracy =>
      _progressService.calculateAccuracy(recognizedText);

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
    _charStartIndices =
        _buildWordCharStartIndices(script, _progressService.scriptChunks);

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

    _cpmService.start(
      userAverageCpm: userCpm,
      onCpmUpdate: (cpm, status) {
        currentCpm = cpm;
        cpmStatus = status;
        onUpdate();
      },
    );

    await _sttService.startListening((text) async {
      recognizedText = text;
      isListening = true;
      scriptProgress = _progressService.calculateProgressByLastMatch(text);

      await _updateCurrentSpeakerByProgress();

      _cpmService.updateRecognizedText(text);
      onUpdate();
    });

    isListening = true;
    onUpdate();
  }

  Future<void> _updateCurrentSpeakerByProgress() async {
    try {
      final parts = _projectModel?.scriptParts;
      if (parts == null || parts.isEmpty) {
        if (currentSpeakerNickname != null) {
          currentSpeakerNickname = null;
          onUpdate();
        }
        return;
      }

      final currentIndex = _currentCharIndex;

      final scriptParts = parts.map<ScriptPartModel>((e) => e).toList();

      ScriptPartModel? matchedPart;
      for (final part in scriptParts) {
        if (part.startIndex <= currentIndex && currentIndex <= part.endIndex) {
          matchedPart = part;
          break;
        }
      }

      matchedPart ??= scriptParts.last;

      final userModel = await UserService().readUser(matchedPart.uid);
      final nickname = userModel?.nickname ?? '발표자';
      final newUserCpm = userModel?.cpm ?? 200.0;

      if (currentSpeakerNickname != nickname) {
        currentSpeakerNickname = nickname;
        _cpmService.updateUserCpm(newUserCpm); // 발표자 기준으로 CPM 업데이트
        onUpdate();
      }
    } catch (e) {
      if (currentSpeakerNickname != '발표자') {
        currentSpeakerNickname = '발표자';
        onUpdate();
      }
    }
  }

  Future<void> stopListening() async {
    _stopwatch.stop();
    await _sttService.stopListening();
    _cpmService.stop();
    isListening = false;
    onUpdate();
  }

  Future<void> dispose() async {
    await _sttService.dispose();
    _cpmService.stop();
  }

  bool isSimilar(String a, String b) => _progressService.isSimilar(a, b);

  List<String> splitText(String text) => _progressService.splitText(text);
}
