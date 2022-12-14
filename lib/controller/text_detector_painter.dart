import 'dart:ui';
import 'dart:ui' as ui;
import 'package:bonkers/models/bon_item.dart';
import 'package:bonkers/models/user.dart';
import 'package:bonkers/views/helpers/edit_bon_item_widget.dart';
import 'package:bonkers/views/split_bon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/BonItemsToPaint.dart';
import 'coordinates_translator.dart';
import 'package:touchable/touchable.dart';

class TextRecognizerPainter extends CustomPainter {
  TextRecognizerPainter(this.bonRects, this.absoluteImageSize, this.rotation,
      this.context, this.ref);

  final List<BonItemsToPaint> bonRects;
  final Size absoluteImageSize;
  final InputImageRotation rotation;
  final BuildContext context; // context from CanvasTouchDetector
  final WidgetRef ref;
  Map<double, BonItem> entries = {};

  @override
  void paint(Canvas canvas, Size size) {
    var touchyCanvas = TouchyCanvas(context, canvas);

    Future<void> showOverlayFallback() async {
      await Future.delayed(const Duration(seconds: 1));
      return ref.read(visiblityNotifierProvider).changeVisiblity(show: true);
    }

    // tap anywhere to hide the overlay during tap (following boxes and touchListeners will be on top)
    touchyCanvas.drawRect(
        Rect.fromLTRB(0, 0, MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height),
        Paint()
          ..color = const Color(0x00000000)
          ..style = PaintingStyle.fill, onTapDown: (details) {
      ref.read(visiblityNotifierProvider).changeVisiblity(show: false);
    }, onTapUp: (details) {
      ref.read(visiblityNotifierProvider).changeVisiblity(show: true);
    }, onLongPressMoveUpdate: (details) {
      showOverlayFallback();
    }, onLongPressEnd: (details) {
      ref.read(visiblityNotifierProvider).changeVisiblity();
    });

    // paint individual rectangles
    for (final item in bonRects) {
      // translate values to canvas
      item.rectList.forEach((key, value) {
        final left = translateX(value.left, rotation, size, absoluteImageSize);
        final top = translateY(value.top, rotation, size, absoluteImageSize);
        final right =
            translateX(value.right, rotation, size, absoluteImageSize);
        final bottom =
            translateY(value.bottom, rotation, size, absoluteImageSize);

        final ParagraphBuilder builder = ParagraphBuilder(
          ParagraphStyle(
              textAlign: TextAlign.left,
              fontSize: (bottom - top) *
                  0.73, // accounts for whitespace in fontfamily,
              height: 1.2,
              fontFamily: "Fira Sans Extra Condensed",
              textDirection: TextDirection.ltr),
        );
        builder
            .pushStyle(ui.TextStyle(color: const Color.fromARGB(255, 0, 0, 0)));
        builder.addText(value.content);
        builder.pop();

        touchyCanvas.drawRect(
            Rect.fromLTRB(left, top, right, bottom),
            Paint()
              ..color = item.color
              ..style = PaintingStyle.fill, onTapDown: (tapDetail) {
          if (item.payer == null ||
              item.payer !=
                  ref.read(payerNotifierProvider).selectedPayer.name) {
            item.payer = ref.read(payerNotifierProvider).selectedPayer.name;
            item.color = ref.read(payerNotifierProvider).selectedPayer.color;
          } else {
            item.payer = null;
            item.color = const Color.fromARGB(255, 255, 255, 255);
          }
          ref.read(shouldRepaintProvider).triggerRepaint();
        }, onLongPressStart: (tapDetail) {
          // TODO: unsauber, onTap wird auch bei longpress aufgerufen
          // showDialog(
          //   context: context,
          //   builder: (context) => EditBonItemDialog(bon: bonArticles, index: 2),
          // );
        });

        canvas.drawParagraph(
          builder.build()
            ..layout(ParagraphConstraints(
              width: right - left,
            )),
          Offset(left, top),
        );

        // draw invisble rect, which is connected to a listener that is activated whenever the rectBons-Object might change to then trigger a repaint
        canvas.drawRect(
            const Rect.fromLTRB(0, 0, 0, 0),
            Paint()
              ..color = ref.watch(shouldRepaintProvider).color
              ..style = PaintingStyle.fill);
      });
    }

    // create list of bon items (for database)
    // TODO:erst beim Klick auf Speichern ausführen -> jedes bonRects-Objekt durchgehen und bei den "rectList"s die values "title" und "price" nehmen, dessen "content"s bilden den Kassenbon
    // TODO: in Splitbon auslagern, sofern sich der painter und Splitbon tatsächlich dieselbe Instanz von bonRects teilen.

    // final Bon newBon = Bon.createBonFromScan(bonTitle, bonArticles);
    // bonServiceProvider.addBon(newBon);
  }

  @override
  bool shouldRepaint(TextRecognizerPainter oldDelegate) {
    return true;
  }
}

class shouldRepaintNotifier extends ChangeNotifier {
  Color color = const Color(0x00000000);

  void triggerRepaint() {
    notifyListeners();
  }
}

final shouldRepaintProvider =
    ChangeNotifierProvider<shouldRepaintNotifier>((ref) {
  return shouldRepaintNotifier();
});
