import 'dart:ui';
import 'dart:ui' as ui;
import 'package:bonkers/views/split_bon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'coordinates_translator.dart';
import 'package:touchable/touchable.dart';

class TextRecognizerPainter extends CustomPainter {
  TextRecognizerPainter(this.recognizedText, this.absoluteImageSize,
      this.rotation, this.context, this.ref);

  final RecognizedText recognizedText;
  final Size absoluteImageSize;
  final InputImageRotation rotation;
  final BuildContext context; // context from CanvasTouchDetector
  final WidgetRef ref;

  @override
  void paint(Canvas canvas, Size size) {
    var touchyCanvas = TouchyCanvas(context, canvas);

    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color.fromARGB(255, 255, 255, 255);

    final Paint noPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color.fromARGB(0, 255, 255, 255);

    Future<void> showOverlayFallback() async {
      await Future.delayed(const Duration(seconds: 1));
      return ref.read(visiblityNotifierProvider).changeVisiblity(show: true);
    }

    touchyCanvas.drawRect(
        Rect.fromLTRB(0, 0, MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height),
        noPaint, onTapDown: (details) {
      ref.read(visiblityNotifierProvider).changeVisiblity(show: false);
    }, onTapUp: (details) {
      ref.read(visiblityNotifierProvider).changeVisiblity(show: true);
    }, onLongPressMoveUpdate: (details) {
      showOverlayFallback();
    }, onLongPressEnd: (details) {
      ref.read(visiblityNotifierProvider).changeVisiblity();
    });

    for (final textBlock in recognizedText.blocks) {
      final left = translateX(
          textBlock.boundingBox.left, rotation, size, absoluteImageSize);
      final top = translateY(
          textBlock.boundingBox.top, rotation, size, absoluteImageSize);
      final right = translateX(
          textBlock.boundingBox.right, rotation, size, absoluteImageSize);
      final bottom = translateY(
          textBlock.boundingBox.bottom, rotation, size, absoluteImageSize);

      final blockWidth = right - left;
      final blockHeight = bottom - top;
      final textLength = textBlock.text.length;
      final blockLines = textBlock.lines.length;

      getLongestLine() {
        if (blockLines <= 1) {
          return textLength;
        } else {
          int maxLenght = 0;

          for (var line in textBlock.lines) {
            if (line.text.length > maxLenght) {
              maxLenght = line.text.length;
            }
          }

          return maxLenght;
        }
      }

      getCharacterSize() {
        double width;
        double height;

        width = blockWidth / getLongestLine();
        height = blockHeight / blockLines;

        return [width, height];
      }

      fitFontSize() {
        double fontSize;

        fontSize = getCharacterSize()[1] *
            0.73; // accounts for whitespace in fontfamily

        return fontSize;
      }

      final ParagraphBuilder builder = ParagraphBuilder(
        ParagraphStyle(
            textAlign: TextAlign.left,
            fontSize: fitFontSize(),
            height: 1.2,
            fontFamily: "Fira Sans Extra Condensed",
            textDirection: TextDirection.ltr),
      );
      builder
          .pushStyle(ui.TextStyle(color: const Color.fromARGB(255, 0, 0, 0)));
      builder.addText(textBlock.text);
      builder.pop();

      touchyCanvas.drawRect(Rect.fromLTRB(left, top, right, bottom), paint,
          onTapDown: (tapDetail) {
        // TODO: unsauber, wird auch bei longpress aufgerufen
        print(textBlock.text);
      }, onLongPressStart: (tapDetail) {
        print("longpress");
      });

      canvas.drawParagraph(
        builder.build()
          ..layout(ParagraphConstraints(
            width: blockWidth,
          )),
        Offset(left, top),
      );
    }
  }

  @override
  bool shouldRepaint(TextRecognizerPainter oldDelegate) {
    return false;
  }
}
