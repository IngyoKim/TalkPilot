import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talk_pilot/src/utils/project/script_comparison_view.dart';

void main() {
  group('ScriptComparisonView', () {
    testWidgets('renders correctly with matched words bold and colored', (WidgetTester tester) async {
      final scriptChunks = ['Hello', 'world', 'this', 'is', 'a', 'test', 'script'];
      final recognizedText = 'Hello world this is';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScriptComparisonView(
              scriptChunks: scriptChunks,
              recognizedText: recognizedText,
              splitText: (text) => text.split(' '),
            ),
          ),
        ),
      );

      final richTextFinder = find.byType(RichText);
      expect(richTextFinder, findsOneWidget);

      final RichText richText = tester.widget(richTextFinder);
      final TextSpan span = richText.text as TextSpan;
      final List<InlineSpan> children = span.children!;

      expect(children.length, scriptChunks.length);

      for (int i = 0; i < scriptChunks.length; i++) {
        final TextSpan textSpan = children[i] as TextSpan;
        final String word = scriptChunks[i];

        expect(textSpan.text, '$word ');

        if (['Hello', 'world', 'this', 'is'].contains(word)) {
          expect(textSpan.style?.fontWeight, FontWeight.bold);
          expect(textSpan.style?.color, Colors.deepPurple);
        } else {
          expect(textSpan.style?.fontWeight, FontWeight.normal);
          expect(textSpan.style?.color, Colors.black);
        }
      }
    });

    testWidgets('renders empty Text when scriptChunks is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScriptComparisonView(
              scriptChunks: [],
              recognizedText: 'Hello world',
              splitText: (text) => text.split(' '),
            ),
          ),
        ),
      );

      expect(find.text(''), findsOneWidget);
    });
  });
}
