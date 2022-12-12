import 'dart:io';
import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:touchable/touchable.dart';
import '../controller/bonItemsFilter.dart';
import '../controller/text_detector_painter.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class SplitBon extends StatefulWidget {
  const SplitBon({super.key, required this.pickedFile});
  final XFile pickedFile;

  @override
  State<SplitBon> createState() => _SplitBonState();
}

class _SplitBonState extends State<SplitBon> {
  final TextRecognizer _textRecognizer = TextRecognizer();
  bool _canProcess = true;
  bool _isBusy = false;
  List<TextLine>? _text;
  String? bonTitle;
  File? _strippedImage;
  Size? _imageSize;
  InputImageRotation? _imageRotation;
  double? _width;
  double? _height;

  @override
  void initState() {
    _processPickedFile(widget.pickedFile);
    super.initState();
  }

  @override
  void dispose() async {
    _canProcess = false;
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Wrap(
              children: const [Icon(Icons.receipt_long), Text(' Bonkers')]),
        ),
        body: SizedBox(
            height: _width != null && _height != null
                ? (MediaQuery.of(context).size.width / _width! * _height!)
                : MediaQuery.of(context).size.height,
            width: _width != null && _height != null
                ? (MediaQuery.of(context).size.height / _height! * _width!)
                : MediaQuery.of(context).size.width,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                if (_strippedImage != null) Image.file(_strippedImage!),
                if (_text != null &&
                    _imageSize != null &&
                    _imageRotation != null)
                  Consumer(builder: (_, WidgetRef ref, __) {
                    bool showOverlay =
                        ref.watch(visiblityNotifierProvider).showOverlay;
                    return Visibility(
                      visible: showOverlay,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainInteractivity: true,
                      maintainState: true,
                      child: CanvasTouchDetector(
                        builder: (context) => CustomPaint(
                            painter: TextRecognizerPainter(_text!, _imageSize!,
                                _imageRotation!, context, ref)),
                        gesturesToOverride: const [
                          GestureType.onTapDown,
                          GestureType.onTapUp,
                          GestureType.onLongPressStart,
                          GestureType.onLongPressEnd,
                          GestureType.onLongPressMoveUpdate
                        ],
                      ),
                    );
                  }),

                if (_text == null)
                  const Text(
                      'Leider konnte auf deinem Bild kein Text erkannt werden.') // TODO: schöneres Feedback und Möglichkeit direkt ein neues Bild aufzunehmen / zu wählen.,
              ],
            )));
  }

// TODO: Logik auslagern!
  Future _processPickedFile(XFile? pickedFile) async {
    final path = pickedFile?.path;
    final strippedPath = '${path}_compressed.jpg';
    if (path == null) {
      return;
    }

    await FlutterImageCompress.compressAndGetFile(path, strippedPath);

    setState(() {
      _strippedImage = File(strippedPath);
    });

    // image with exif data (needed for orientation information)
    final Uint8List bytes = await pickedFile!.readAsBytes();
    final exifData = await readExifFromBytes(bytes);

    // image with stripped exif data
    final Uint8List strippedBytes = await _strippedImage!.readAsBytes();
    final decodedImage = await decodeImageFromList(strippedBytes);
    final imageWidth = decodedImage.width.toDouble();
    final imageHeight = decodedImage.height.toDouble();

    getImageRotation() {
      final orientation = exifData['Image Orientation']!.printable;

      if (orientation == "Horizontal (normal)" && imageHeight < imageWidth) {
        return InputImageRotation.rotation0deg;
      } else if (orientation == "Rotated 180" && imageHeight < imageWidth) {
        return InputImageRotation.rotation180deg;
      } else if (orientation == "Rotated 90 CCW" && imageHeight > imageWidth) {
        return InputImageRotation.rotation270deg;
      } else if (orientation == "Rotated 90 CW" && imageHeight > imageWidth) {
        return InputImageRotation.rotation90deg;
      } else if (imageHeight < imageWidth) {
        return InputImageRotation.rotation0deg;
      } else if (imageHeight > imageWidth) {
        return InputImageRotation.rotation90deg;
      } else {
        return InputImageRotation.rotation90deg;
      } // if in doubt or square, the function still needs this information. In most cases its 90 degrees
    }

    final inputImage = InputImage.fromFilePath(strippedPath);

    _imageSize = Size(imageWidth, imageHeight);
    _imageRotation = getImageRotation();
    _width = imageWidth;
    _height = imageHeight;

    processImage(inputImage);
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    final recognizedText = await _textRecognizer.processImage(inputImage);
    bonTitle = recognizedText.blocks.first.lines.first.text;
    _text = itemsFilter(recognizedText);
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}

//TODO: in eigene Datei auslagern
class VisibilityNotifier extends ChangeNotifier {
  bool showOverlay = true;

  void changeVisiblity({bool? show}) {
    show != null ? showOverlay = show : showOverlay = !showOverlay;

    notifyListeners();
  }
}

final visiblityNotifierProvider =
    ChangeNotifierProvider((ref) => VisibilityNotifier());
