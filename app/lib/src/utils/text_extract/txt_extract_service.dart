import 'dart:io';

class TxtExtractService {
  /// TXT 파일에서 텍스트 추출
  Future<String> extractTextFromTxt(File file) async {
    try {
      final text = await file.readAsString();
      return text;
    } catch (e) {
      return 'TXT 텍스트 추출 실패: $e';
    }
  }
}
