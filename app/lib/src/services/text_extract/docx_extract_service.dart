import 'dart:io';
import 'dart:convert';
import 'package:archive/archive_io.dart';
import 'package:xml/xml.dart';

class DocxExtractService {
  /// DOCX 파일에서 텍스트 추출
  Future<String> extractTextFromDocx(File file) async {
    try {
      final bytes = await file.readAsBytes();

      /// .docx는 ZIP 파일
      final archive = ZipDecoder().decodeBytes(bytes);

      /// document.xml 파일 찾기 (본문 내용이 들어 있음)
      final xmlFile = archive.files.firstWhere(
        (f) => f.name == 'word/document.xml',
        orElse: () => throw Exception('word/document.xml not found in DOCX'),
      );

      final xmlContent = utf8.decode(xmlFile.content as List<int>);
      final document = XmlDocument.parse(xmlContent);

      /// 실제 텍스트는 <w:t> 태그에 들어 있음
      final textElements = document.findAllElements('w:t');
      final extracted = textElements.map((e) => e.text).join(' ');

      return extracted;
    } catch (e) {
      return 'DOCX 텍스트 추출 실패: $e';
    }
  }
}
