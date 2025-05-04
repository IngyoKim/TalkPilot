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
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('파일 업로드 안내'),
      content: const Text('docx 또는 txt 파일만 업로드할 수 있어요. \n계속하시겠습니까?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false), // 취소
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true), // 확인
          child: const Text('확인'),
        ),
      ],
    ),
  );

  // 사용자가 확인을 누르지 않았을 경우 리턴
  if (confirmed != true) return;

  // ✅ 이제 파일 선택 창 열기
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('지원되지 않는 파일 형식입니다.')),
      );
    }

    if (extractedText != null) {
      await ProjectService().updateProject(projectId, {
        'script': extractedText,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('대본 필드에 텍스트가 반영되었습니다.')),
      );
    }

    setLoading(false);
  }
}
