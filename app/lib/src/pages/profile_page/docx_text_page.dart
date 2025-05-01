import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:talk_pilot/src/services/text_extract/docx_extract_service.dart';

class DocxTextPage extends StatefulWidget {
  const DocxTextPage({super.key});

  @override
  State<DocxTextPage> createState() => _DocxTextPageState();
}

class _DocxTextPageState extends State<DocxTextPage> {
  String extractedText = '';
  bool isLoading = false;

  Future<void> pickAndExtractDocxText() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['docx'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final service = DocxExtractService();

      setState(() => isLoading = true);

      final text = await service.extractTextFromDocx(file);

      setState(() {
        extractedText = text;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DOCX 텍스트 추출', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: pickAndExtractDocxText,
              child: const Text('DOCX 파일 선택 및 텍스트 추출'),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    extractedText.isNotEmpty ? extractedText : '아직 추출된 텍스트가 없습니다.',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
