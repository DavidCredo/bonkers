import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'coordinates_translator.dart';

class TextRecognizerPainter extends CustomPainter {
  TextRecognizerPainter(
      this.recognizedText, this.absoluteImageSize, this.rotation);

  final RecognizedText recognizedText;
  final Size absoluteImageSize;
  final InputImageRotation rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Color.fromARGB(255, 89, 175, 255);

    final Paint background = Paint()
      ..color = Color.fromARGB(187, 255, 253, 253);

    for (final textBlock in recognizedText.blocks) {
      final ParagraphBuilder builder = ParagraphBuilder(
        ParagraphStyle(
            textAlign: TextAlign.left,
            fontSize: 10, // TODO: automate
            textDirection: TextDirection.ltr),
      );
      builder.pushStyle(ui.TextStyle(
          color: Color.fromARGB(255, 0, 0, 0), background: background));
      builder.addText(textBlock.text);
      builder.pop();

      final left = translateX(
          textBlock.boundingBox.left, rotation, size, absoluteImageSize);
      final top = translateY(
          textBlock.boundingBox.top, rotation, size, absoluteImageSize);
      final right = translateX(
          textBlock.boundingBox.right, rotation, size, absoluteImageSize);
      final bottom = translateY(
          textBlock.boundingBox.bottom, rotation, size, absoluteImageSize);

      canvas.drawRect(
        Rect.fromLTRB(left, top, right, bottom),
        paint,
      );

      canvas.drawParagraph(
        builder.build()
          ..layout(ParagraphConstraints(
            width: right - left,
          )),
        Offset(left, top),
      );
    }
  }

  @override
  bool shouldRepaint(TextRecognizerPainter oldDelegate) {
    return oldDelegate.recognizedText != recognizedText;
  }
}
