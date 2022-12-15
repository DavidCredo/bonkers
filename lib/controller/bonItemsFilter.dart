import 'dart:ui';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../models/BonItemsToPaint.dart';

List<BonItemsToPaint>? itemsFilter(RecognizedText? recognizedText) {
  if (recognizedText == null) return null;

  // --- filter for all blocks, which represent the collection of items of the shopping receipt ---

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
  int startPos = allLines.indexWhere((element) =>
      (element.text.toLowerCase() == "eur" ||
          element.text.toLowerCase().contains('kasse')));
  int endPos = allLines.indexWhere((element) =>
      (element.text.toLowerCase() == "total" ||
          element.text.toLowerCase() == "summe" ||
          element.text.toLowerCase() == "zu zahlen"));

  if (startPos != -1 && endPos != -1) {
    sortedLines = allLines.sublist(startPos + 1, endPos - 1);
  } else {
    return null;
  }

  // now filter out amounts and unit prices
  for (final textLine in sortedLines) {
    // resolve common errors from TextRecognizer and clean up
    String treatPrice(String candidate) {
      return candidate
          .replaceAll(RegExp('[lIi!]'), '1')
          .replaceAll(RegExp(','), '.')
          .replaceAll(RegExp('O'), '0')
          .replaceAll(RegExp('[A-Za-z]'), '')
          .replaceAll(RegExp(' '), '');
    }

    // resolve common errors from TextRecognizer
    String treatItem(String text) {
      String manipulatedText = text.replaceAll(RegExp('\\['), 'l');
      if (!text.toLowerCase().contains("eur")) {
        text
            .replaceAll(RegExp('0'), 'O')
            .replaceAll(RegExp('1'), 'l')
            .replaceAll(RegExp('[2-9]'), '');
      }

      return manipulatedText;
    }

    int? parseInt(String candidate) {
      return int.tryParse(treatPrice(candidate));
    }

    double? parseDouble(String candidate) {
      return double.tryParse(treatPrice(candidate));
    }

    bool isTitle(String text) {
      return RegExp('[A-Za-z]{3}').hasMatch(text);
    }

    bool isPrice(String text) {
      return parseDouble(text) != null;
    }

    bool isItemCount(String text) {
      return parseInt(text) != null;
    }

    if (isTitle(textLine.text)) {
      if (!textLine.text.toLowerCase().contains(" x") &&
          !textLine.text.toLowerCase().contains("stk") &&
          !textLine.text.toLowerCase().contains("pfand") &&
          !textLine.text.toLowerCase().contains("rabatt")) {
        treatedLines.add(TextLine(
            text: treatItem(textLine.text),
            elements: textLine.elements,
            boundingBox: textLine.boundingBox,
            recognizedLanguages: textLine.recognizedLanguages,
            cornerPoints: textLine.cornerPoints));
      }
    } else if (isItemCount(textLine.text)) {
      // is discarded and must be tested first, since any int can be converted to a double.
      continue;
    } else if (isPrice(textLine.text)) {
      // filter for unit counts
      if (!textLine.text.toLowerCase().contains(" x") &&
          !textLine.text.toLowerCase().contains("*") &&
          !textLine.text.toLowerCase().contains("-")) {
        treatedLines.add(TextLine(
            text: treatPrice(textLine.text),
            elements: textLine.elements,
            boundingBox: textLine.boundingBox,
            recognizedLanguages: textLine.recognizedLanguages,
            cornerPoints: textLine.cornerPoints));
      }
    }
  }

  // --- generate pairs of title and price, also include information for the painter ---

  List<BonItemsToPaint> rects = [];
  RectInfo? itemTitle;
  RectInfo? itemPrice;
  Color defaultColor = const Color.fromARGB(255, 255, 255, 255);

  for (final textLine in treatedLines) {
    // create list of rectangles (for controlled painting)

    bool isTitle(String text) {
      return RegExp('[A-Za-z]{3}').hasMatch(text);
    }

    bool isPrice(String text) {
      return double.tryParse(text) != null;
    }

    if (isTitle(textLine.text)) {
      itemTitle = RectInfo(
          textLine.boundingBox.left,
          textLine.boundingBox.top,
          textLine.boundingBox.right,
          textLine.boundingBox.bottom,
          textLine.text);
    } else if (isPrice(textLine.text)) {
      itemPrice = RectInfo(
          textLine.boundingBox.left,
          textLine.boundingBox.top,
          textLine.boundingBox.right,
          textLine.boundingBox.bottom,
          textLine.text);
    }

    if (itemTitle != null && itemPrice != null) {
      rects.add(BonItemsToPaint(
          {"title": itemTitle, "price": itemPrice}, defaultColor, null));
      itemTitle = null;
      itemPrice = null;
    }
  }

  return rects;
}
