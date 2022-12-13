import 'dart:ui';
import 'dart:ui' as ui;
import 'package:bonkers/models/bon_item.dart';
import 'package:bonkers/models/user.dart';
import 'package:bonkers/views/helpers/edit_bon_item_widget.dart';
import 'package:bonkers/views/split_bon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'coordinates_translator.dart';
import 'package:touchable/touchable.dart';

class TextRecognizerPainter extends CustomPainter {
  TextRecognizerPainter(this.recognizedText, this.absoluteImageSize,
      this.rotation, this.context, this.ref);

  final List<TextLine> recognizedText;
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

    // tap anywhere to hide the overlay during tap (following boxes and touchListeners will be on top)
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

    Map<double, BonItem> entries = {};
    List<BonItem> bonArticles = [];

    String? itemTitle;
    double? itemPrice;

    for (final textLine in recognizedText) {
      // create bon items for database

      bool isTitle(String text) {
        return RegExp('[A-Za-z]{3}').hasMatch(text);
      }

      bool isPrice(String text) {
        return double.tryParse(text) != null;
      }

      if (isTitle(textLine.text)) {
        itemTitle = textLine.text;
      } else if (isPrice(textLine.text)) {
        itemPrice = double.tryParse(textLine.text);
      }

      if (itemTitle != null && itemPrice != null) {
        entries[translateY(textLine.boundingBox.center.dy, rotation, size,
            absoluteImageSize)] = BonItem(price: itemPrice, title: itemTitle);
        itemTitle = null;
        itemPrice = null;
      }

      // paint bon items for interaction:
      final left = translateX(
          textLine.boundingBox.left, rotation, size, absoluteImageSize);
      final top = translateY(
          textLine.boundingBox.top, rotation, size, absoluteImageSize);
      final right = translateX(
          textLine.boundingBox.right, rotation, size, absoluteImageSize);
      final bottom = translateY(
          textLine.boundingBox.bottom, rotation, size, absoluteImageSize);

      final ParagraphBuilder builder = ParagraphBuilder(
        ParagraphStyle(
            textAlign: TextAlign.left,
            fontSize:
                (bottom - top) * 0.73, // accounts for whitespace in fontfamily,
            height: 1.2,
            fontFamily: "Fira Sans Extra Condensed",
            textDirection: TextDirection.ltr),
      );
      builder
          .pushStyle(ui.TextStyle(color: const Color.fromARGB(255, 0, 0, 0)));
      builder.addText(textLine.text);
      builder.pop();

      touchyCanvas.drawRect(Rect.fromLTRB(left, top, right, bottom), paint,
          onTapDown: (tapDetail) {
        entries.forEach((key, value) {
          if (key < bottom && key > top) {
            print({value.title, value.price});

            if (value.payer == null) {
              // value.payer = ref.read(payerNotifierProvider).selectedPayer.name;
              // paint.color = ref.read(payerNotifierProvider).selectedPayer.color;
              paint.color = const Color.fromARGB(255, 166, 12, 12);
            } else {
              value.payer = null;
              paint.color = const Color.fromARGB(255, 255, 255, 255);
            }
          }
        });
      }, onLongPressStart: (tapDetail) {
        // TODO: unsauber, onTap wird auch bei longpress aufgerufen
        showDialog(
          context: context,
          builder: (context) => EditBonItemDialog(bon: bonArticles, index: 2),
        );
      });

      canvas.drawParagraph(
        builder.build()
          ..layout(ParagraphConstraints(
            width: right - left,
          )),
        Offset(left, top),
      );
    }

    entries.forEach((key, value) => bonArticles.add(value));
    // bonArticles.forEach((element) {
    //   print(element.toJson());
    // });

    // final Bon newBon = Bon.createBonFromScan(bonTitle, bonArticles);
    // bonServiceProvider.addBon(newBon);
  }

  @override
  bool shouldRepaint(TextRecognizerPainter oldDelegate) {
    return oldDelegate.recognizedText != recognizedText;
  }
}
