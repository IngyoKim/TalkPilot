import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:talk_pilot/src/services/database/project_service.dart';
import 'package:talk_pilot/src/services/text_extract/docx_extract_service.dart';
import 'package:talk_pilot/src/services/text_extract/txt_extract_service.dart';

Future<void> pickAndExtractScriptText({
  required BuildContext context,
  required String projectId,
  required void Function(bool) setLoading,
}) async {
  final confirmedFileType = await showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('파일 업로드 안내'),
          content: const Text('docx 또는 txt 파일만 업로드할 수 있어요. 계속하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('확인'),
            ),
          ],
        ),
  );

  if (confirmedFileType != true) return;

  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['docx', 'txt'],
  );

  if (result != null && result.files.single.path != null) {
    final file = File(result.files.single.path!);
    final filePath = file.path.toLowerCase();

    setLoading(true);

    String? extractedText;

    if (filePath.endsWith('.docx')) {
      extractedText = await DocxExtractService().extractTextFromDocx(file);
    } else if (filePath.endsWith('.txt')) {
      extractedText = await TxtExtractService().extractTextFromTxt(file);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('지원되지 않는 파일 형식입니다.')));
      setLoading(false);
      return;
    }

    final currentProject = await ProjectService().readProject(projectId);
    final hasScript = currentProject?.script?.trim().isNotEmpty == true;

    if (hasScript) {
      final confirmedOverwrite = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('덮어쓰기 확인'),
              content: const Text('현재 대본이 존재합니다. 이 내용을 덮어쓰시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('확인'),
                ),
              ],
            ),
      );

      if (confirmedOverwrite != true) {
        setLoading(false);
        return;
      }
    }

    await ProjectService().updateProject(projectId, {'script': extractedText});

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('대본 필드에 텍스트가 반영되었습니다.')));

    setLoading(false);
  }
}
