import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:talk_pilot/src/services/database/project_service.dart';
import 'package:talk_pilot/src/services/text_extract/docx_extract_service.dart';
import 'package:talk_pilot/src/services/text_extract/txt_extract_service.dart';

Future<void> pickAndExtractScriptText({
  required String projectId,
  required void Function(bool) setLoading,
  required void Function(String message) showMessage,
  required Future<bool?> Function(String title, String content) confirmDialog,
}) async {
  final confirmedFileType = await confirmDialog(
    '파일 업로드 안내',
    'docx 또는 txt 파일만 업로드할 수 있어요. \n계속하시겠습니까?',
  );

  if (confirmedFileType != true) return;

  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['docx', 'txt'],
  );

  if (result == null || result.files.single.path == null) return;

  final file = File(result.files.single.path!);
  final filePath = file.path.toLowerCase();

  setLoading(true);

  String? extractedText;
  if (filePath.endsWith('.docx')) {
    extractedText = await DocxExtractService().extractTextFromDocx(file);
  } else if (filePath.endsWith('.txt')) {
    extractedText = await TxtExtractService().extractTextFromTxt(file);
  } else {
    showMessage('지원되지 않는 파일 형식입니다.');
    setLoading(false);
    return;
  }

  final project = await ProjectService().readProject(projectId);
  final hasScript = project?.script?.trim().isNotEmpty ?? false;

  if (hasScript) {
    final confirm = await confirmDialog(
      '덮어쓰기 확인',
      '현재 대본이 존재합니다.\n 이 내용을 덮어쓰시겠습니까?',
    );
    if (confirm != true) {
      setLoading(false);
      return;
    }
  }

  await ProjectService().updateProject(projectId, {'script': extractedText});
  showMessage('대본 필드에 텍스트가 반영되었습니다.');
  setLoading(false);
}
