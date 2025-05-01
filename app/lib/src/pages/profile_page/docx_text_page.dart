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
        actions: [
          IconButton(
            onPressed: pickAndExtractDocxText,
            icon: const Icon(Icons.upload_file),
            tooltip: '파일 업로드',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : extractedText.isEmpty
                ? const Center(
                  child: Text(
                    '위쪽 업로드 아이콘을 눌러 파일을 업로드해주세요.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
                : SingleChildScrollView(
                  child: Text(
                    extractedText,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
      ),
    );
  }
}
