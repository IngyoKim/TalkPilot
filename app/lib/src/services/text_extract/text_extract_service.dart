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
