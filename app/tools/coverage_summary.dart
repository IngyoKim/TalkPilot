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

  const nameWidth = 60;
  const colWidth = 7;

  print('${'Name'.padRight(nameWidth)}'
      '${'Stmts'.padLeft(colWidth)}'
      '${'Miss'.padLeft(colWidth)}'
      '${'Cover'.padLeft(colWidth + 1)}');
  print('-' * (nameWidth + colWidth * 3 + 1));

  for (final entry in coverageData.entries) {
    final filePath = entry.key.replaceAll('\\', '/');
    final hits = entry.value;

    final total = hits.length;
    final missed = hits.where((h) => h == 0).length;
    final percent = total == 0 ? 100.0 : ((total - missed) / total * 100);

    totalStatements += total;
    totalMissed += missed;

    print('${filePath.padRight(nameWidth)}'
        '${'$total'.padLeft(colWidth)}'
        '${'$missed'.padLeft(colWidth)}'
        '${percent.toStringAsFixed(1).padLeft(colWidth)}%');
  }

  print('-' * (nameWidth + colWidth * 3 + 1));
  final totalPercent = totalStatements == 0
      ? 100.0
      : ((totalStatements - totalMissed) / totalStatements * 100);
  print('${'TOTAL'.padRight(nameWidth)}'
      '${'$totalStatements'.padLeft(colWidth)}'
      '${'$totalMissed'.padLeft(colWidth)}'
      '${totalPercent.toStringAsFixed(1).padLeft(colWidth)}%');
}
