import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:super_editor/super_editor.dart';
import 'package:super_editor_markdown/super_editor_markdown.dart';

import '../../test_tools_goldens.dart';

void main() {
  group("SuperEditor > text entry > composing region >", () {
    testGoldensOnAndroid("is underlined in paragraph", _showsUnderlineInParagraph);
    testGoldensOnAndroid("is underlined in list item", _showsUnderlineInListItem);
    testGoldensOnAndroid("is underlined in task", _showsUnderlineInTask);

    testGoldensOniOS("is underlined in paragraph", _showsUnderlineInParagraph);
    testGoldensOniOS("is underlined in list item", _showsUnderlineInListItem);
    testGoldensOniOS("is underlined in task", _showsUnderlineInTask);

    testGoldensOnMac("is underlined in paragraph", _showsUnderlineInParagraph);
    testGoldensOnMac("is underlined in list item", _showsUnderlineInListItem);
    testGoldensOnMac("is underlined in task", _showsUnderlineInTask);
  });

  group("SuperEditor > text entry > composing region >", () {
    testGoldensOnWindows("shows nothing in paragraph", _showsNothingInParagraph);
    testGoldensOnWindows("shows nothing in list item", _showsNothingInListItem);
    testGoldensOnWindows("shows nothing in task", _showsNothingInTask);

    testGoldensOnLinux("shows nothing in paragraph", _showsNothingInParagraph);
    testGoldensOnLinux("shows nothing in list item", _showsNothingInListItem);
    testGoldensOnLinux("shows nothing in task", _showsNothingInTask);
  });
}

Future<void> _showsUnderlineInParagraph(WidgetTester tester) async {
  final (editor, document) = await _pumpScaffold(tester, _paragraphMarkdown);

  _simulateComposingRegion(tester, editor, document);

  // Ensure the composing region is underlined.
  await screenMatchesGolden(
      tester, "super-editor_text-entry_composing-region-shows-underline_paragraph_${defaultTargetPlatform.name}_1");

  _clearComposingRegion(tester, editor, document);

  // Ensure the underline disappeared now that the composing region is null.
  await screenMatchesGolden(
      tester, "super-editor_text-entry_composing-region-shows-underline_paragraph_${defaultTargetPlatform.name}_2");
}

Future<void> _showsNothingInParagraph(WidgetTester tester) async {
  final (editor, document) = await _pumpScaffold(tester, _paragraphMarkdown);

  _simulateComposingRegion(tester, editor, document);

  // Ensure the composing region is underlined.
  await screenMatchesGolden(
      tester, "super-editor_text-entry_composing-region-showing-nothing_paragraph_${defaultTargetPlatform.name}");
}

Future<void> _showsUnderlineInListItem(WidgetTester tester) async {
  final (editor, document) = await _pumpScaffold(tester, _listItemMarkdown);

  _simulateComposingRegion(tester, editor, document);

  // Ensure the composing region is underlined.
  await screenMatchesGolden(
      tester, "super-editor_text-entry_composing-region-shows-underline_list-item_${defaultTargetPlatform.name}_1");

  _clearComposingRegion(tester, editor, document);

  // Ensure the underline disappeared now that the composing region is null.
  await screenMatchesGolden(
      tester, "super-editor_text-entry_composing-region-shows-underline_list-item_${defaultTargetPlatform.name}_2");
}

Future<void> _showsNothingInListItem(WidgetTester tester) async {
  final (editor, document) = await _pumpScaffold(tester, _listItemMarkdown);

  _simulateComposingRegion(tester, editor, document);

  // Ensure the composing region is underlined.
  await screenMatchesGolden(
      tester, "super-editor_text-entry_composing-region-shows-nothing_list-item_${defaultTargetPlatform.name}");
}

Future<void> _showsUnderlineInTask(WidgetTester tester) async {
  final (editor, document) = await _pumpScaffold(tester, _taskMarkdown);

  _simulateComposingRegion(tester, editor, document);

  // Ensure the composing region is underlined.
  await screenMatchesGolden(
      tester, "super-editor_text-entry_composing-region-shows-underline_task_${defaultTargetPlatform.name}_1");

  _clearComposingRegion(tester, editor, document);

  // Ensure the underline disappeared now that the composing region is null.
  await screenMatchesGolden(
      tester, "super-editor_text-entry_composing-region-shows-underline_task_${defaultTargetPlatform.name}_2");
}

Future<void> _showsNothingInTask(WidgetTester tester) async {
  final (editor, document) = await _pumpScaffold(tester, _taskMarkdown);

  _simulateComposingRegion(tester, editor, document);

  // Ensure the composing region is underlined.
  await screenMatchesGolden(
      tester, "super-editor_text-entry_composing-region-shows-nothing_task_${defaultTargetPlatform.name}");
}

Future<(Editor, Document)> _pumpScaffold(WidgetTester tester, String contentMarkdown) async {
  // TODO: Whenever we're able to create a TaskComponentBuilder without passing the Editor, refactor
  //       this setup to look like a normal SuperEditor test.
  final document = deserializeMarkdownToDocument(contentMarkdown);
  final composer = MutableDocumentComposer();
  final editor = createDefaultDocumentEditor(document: document, composer: composer);

  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: SuperEditor(
        editor: editor,
        document: document,
        composer: composer,
        componentBuilders: [
          TaskComponentBuilder(editor),
          ...defaultComponentBuilders,
        ],
        stylesheet: _stylesheet,
      ),
    ),
  ));

  return (editor, document);
}

Future<void> _simulateComposingRegion(WidgetTester tester, Editor editor, Document document) async {
  final nodeId = document.nodes.first.id;
  editor.execute([
    ChangeSelectionRequest(
      DocumentSelection.collapsed(
        position: DocumentPosition(
          nodeId: nodeId,
          nodePosition: const TextNodePosition(offset: 23),
        ),
      ),
      SelectionChangeType.placeCaret,
      SelectionReason.userInteraction,
    ),
    ChangeComposingRegionRequest(
      DocumentRange(
        start: DocumentPosition(
          nodeId: nodeId,
          nodePosition: const TextNodePosition(offset: 22),
        ),
        end: DocumentPosition(
          nodeId: nodeId,
          nodePosition: const TextNodePosition(offset: 23),
        ),
      ),
    ),
  ]);
  await tester.pumpAndSettle();
}

Future<void> _clearComposingRegion(WidgetTester tester, Editor editor, Document document) async {
  final nodeId = document.nodes.first.id;
  editor.execute([
    ChangeSelectionRequest(
      DocumentSelection.collapsed(
        position: DocumentPosition(
          nodeId: nodeId,
          nodePosition: const TextNodePosition(offset: 23),
        ),
      ),
      SelectionChangeType.placeCaret,
      SelectionReason.userInteraction,
    ),
    ChangeComposingRegionRequest(null),
  ]);
  await tester.pump();
}

const _paragraphMarkdown = "Typing with composing a";
const _listItemMarkdown = " * Typing with composing a";
const _taskMarkdown = "- [ ] Typing with composing a";

/// A [StyleSheet] which applies the Roboto font for all nodes.
///
/// This is needed to use real font glyphs in the golden tests.
final _stylesheet = defaultStylesheet.copyWith(
  addRulesAfter: [
    StyleRule(BlockSelector.all, (doc, node) {
      return {
        Styles.textStyle: const TextStyle(
          fontFamily: 'Roboto',
        ),
      };
    })
  ],
);
