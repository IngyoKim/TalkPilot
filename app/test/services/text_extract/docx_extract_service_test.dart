import 'dart:io';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:archive/archive.dart';
import 'package:talk_pilot/src/utils/text_extract/docx_extract_service.dart';

void main() {
  late DocxExtractService docxExtractService;
  late Directory tempDir;

  setUp(() async {
    docxExtractService = DocxExtractService();
    tempDir = await Directory.systemTemp.createTemp('docx_test_');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  /// Helper → in-memory fake DOCX 생성 후 tempFile에 저장
  Future<File> createFakeDocxFile({required String documentXmlContent}) async {
    final archive = Archive();

    // word/document.xml 에 원하는 content 넣기
    final documentXmlBytes = utf8.encode(documentXmlContent);
    archive.addFile(ArchiveFile('word/document.xml', documentXmlBytes.length, documentXmlBytes));

    // ZIP 으로 인코딩
    final zipBytes = ZipEncoder().encode(archive)!;

    // temp 파일 저장
    final tempFile = File('${tempDir.path}/test.docx');
    await tempFile.writeAsBytes(zipBytes);

    return tempFile;
  }

  test('extracts simple text from DOCX', () async {
    final docxFile = await createFakeDocxFile(documentXmlContent: '''
      <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
        <w:body>
          <w:p><w:r><w:t>Hello world</w:t></w:r></w:p>
        </w:body>
      </w:document>
    ''');

    final result = await docxExtractService.extractTextFromDocx(docxFile);
    expect(result, contains('Hello world'));
  });

  test('returns empty string when document.xml has no w:t elements', () async {
    final docxFile = await createFakeDocxFile(documentXmlContent: '''
      <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
        <w:body>
          <w:p><w:r></w:r></w:p>
        </w:body>
      </w:document>
    ''');

    final result = await docxExtractService.extractTextFromDocx(docxFile);
    expect(result.trim(), '');
  });

  test('returns error message when document.xml is missing', () async {
    // word/document.xml 없이 빈 zip 만들기
    final archive = Archive();
    final zipBytes = ZipEncoder().encode(archive)!;
    final tempFile = File('${tempDir.path}/test_missing_document.docx');
    await tempFile.writeAsBytes(zipBytes);

    final result = await docxExtractService.extractTextFromDocx(tempFile);
    expect(result, contains('DOCX 텍스트 추출 실패'));
  });

  test('returns error message when document.xml is invalid XML', () async {
    final docxFile = await createFakeDocxFile(documentXmlContent: '<<<not-valid-xml>>>');

    final result = await docxExtractService.extractTextFromDocx(docxFile);
    expect(result, contains('DOCX 텍스트 추출 실패'));
  });
}
