import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:math';

// filter for all blocks, which represent the collection of items of the shopping receipt

List<TextLine>? itemsFilter(RecognizedText? recognizedText) {
  if (recognizedText == null) return null;

  List<TextLine> allLines = [];
  List<TextLine> treatedLines = [];
  List<TextLine> sortedLines = [];

  // get textlines from recognized blocks
  for (final block in recognizedText.blocks) {
    allLines.addAll(block.lines);
  }

  // we only want the items (sort and short the selection)
  allLines
      .sort((a, b) => (a.boundingBox.bottom - b.boundingBox.bottom).floor());
  int startPos = allLines
      .indexWhere((element) => (element.text.toLowerCase().contains('eur')));
  int endPos = allLines.lastIndexWhere((element) =>
      (element.text.toLowerCase().contains('summe') ||
          element.text.toLowerCase().contains('zu zahlen')));

  sortedLines = allLines.sublist(startPos + 1, endPos);

  // now filter out amounts and unit prices
  for (final textLine in sortedLines) {
    String treatCandidate(String candidate) {
      return candidate
          .replaceAll(RegExp('[lIi!]'), '1')
          .replaceAll(RegExp(','), '.')
          .replaceAll(RegExp('O'), '0')
          .replaceAll(RegExp('[A-Za-z]'), '')
          .replaceAll(RegExp(' 1'), '');
    }

    int? parseInt(String candidate) {
      return int.tryParse(treatCandidate(candidate));
    }

    double? parseDouble(String candidate) {
      return double.tryParse(treatCandidate(candidate));
    }

    bool isName(String text) {
      return RegExp('[A-Za-z]{3}').hasMatch(text);
    }

    bool isAmount(String text) {
      return parseDouble(text) != null;
    }

    bool isItemCount(String text) {
      return parseInt(text) != null;
    }

    if (isName(textLine.text)) {
      treatedLines.add(textLine);
    } else if (isItemCount(textLine.text)) {
      // is discarded and must be tested first, since any int can be converted to a double.
      continue;
    } else if (isAmount(textLine.text)) {
      // TODO: keine Einzelpreise     max(double.tryParse(textLine.text) ?? 0.0, currentAmount ?? 0.0)
      treatedLines.add(TextLine(
          text: treatCandidate(textLine.text),
          elements: textLine.elements,
          boundingBox: textLine.boundingBox,
          recognizedLanguages: textLine.recognizedLanguages,
          cornerPoints: textLine.cornerPoints));
    }
  }

  return treatedLines;
}
