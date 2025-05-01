import 'package:flutter/material.dart';

class DocxTextPage extends StatelessWidget {
  const DocxTextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DOCX 텍스트 추출', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: Text(
          '여기에 DOCX 텍스트 추출 기능이 들어갑니다.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
