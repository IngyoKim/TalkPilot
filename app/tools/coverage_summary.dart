import 'dart:io';

void main() async {
  final file = File('coverage/lcov.info');

  if (!await file.exists()) {
    print('❌ coverage/lcov.info 파일이 없습니다. 먼저 flutter test --coverage 실행하세요.');
    exit(1);
  }

  final lines = await file.readAsLines();
  final coverageData = <String, List<int>>{};
  String? currentFile;

  for (final line in lines) {
    if (line.startsWith('SF:')) {
      currentFile = line.substring(3).trim();
      coverageData[currentFile] = [];
    } else if (line.startsWith('DA:') && currentFile != null) {
      final parts = line.substring(3).split(',');
      final hit = int.tryParse(parts[1]) ?? 0;
      coverageData[currentFile]!.add(hit);
    }
  }

  int totalStatements = 0;
  int totalMissed = 0;

  print('${'Name'.padRight(40)} ${'Stmts'.padLeft(5)} ${'Miss'.padLeft(5)} ${'Cover'.padLeft(6)}');
  print('-' * 60);

  for (final entry in coverageData.entries) {
    final filePath = entry.key.replaceAll('\\', '/');
    final hits = entry.value;

    final total = hits.length;
    final missed = hits.where((h) => h == 0).length;
    final percent = total == 0 ? 100.0 : ((total - missed) / total * 100);

    totalStatements += total;
    totalMissed += missed;

    print('${filePath.padRight(40)} ${'$total'.padLeft(5)} ${'$missed'.padLeft(5)} ${percent.toStringAsFixed(1).padLeft(5)}%');
  }

  print('-' * 60);
  final totalPercent = totalStatements == 0
      ? 100.0
      : ((totalStatements - totalMissed) / totalStatements * 100);
  print('${'TOTAL'.padRight(40)} ${'$totalStatements'.padLeft(5)} ${'$totalMissed'.padLeft(5)} ${totalPercent.toStringAsFixed(1).padLeft(5)}%');
}
