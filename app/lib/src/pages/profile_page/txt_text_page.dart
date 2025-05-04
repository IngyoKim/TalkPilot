import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:talk_pilot/src/services/text_extract/txt_extract_service.dart';

class TxtTextPage extends StatefulWidget {
  const TxtTextPage({super.key});

  @override
  State<TxtTextPage> createState() => _TxtTextPageState();
}

class _TxtTextPageState extends State<TxtTextPage> {
  String extractedText = '';
  bool isLoading = false;

  final TxtExtractService _service = TxtExtractService();

  Future<void> pickAndExtractTxtFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);

      setState(() => isLoading = true);

      final text = await _service.extractTextFromTxt(file);

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
        title: const Text('TXT 텍스트 추출', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            onPressed: pickAndExtractTxtFile,
            icon: const Icon(Icons.upload_file),
            tooltip: '파일 업로드',
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
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
