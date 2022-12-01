import 'dart:io';
import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:touchable/touchable.dart';
import '../controller/text_detector_painter.dart';

class SplitBon extends ConsumerStatefulWidget {
  const SplitBon({super.key, required this.pickedFile});
  final XFile pickedFile;

  @override
  ConsumerState<SplitBon> createState() => _SplitBonState();
}

class _SplitBonState extends ConsumerState<SplitBon> {
  final TextRecognizer _textRecognizer = TextRecognizer();
  bool _canProcess = true;
  bool _isBusy = false;
  RecognizedText? _text;
  File? _image;
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
    bool showOverlay = ref.watch(visiblityNotifierProvider).showOverlay;
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
                Image.file(_image!),
                if (_text != null &&
                    _imageSize != null &&
                    _imageRotation != null)
                  Visibility(
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
                        GestureType.onLongPressEnd
                      ],
                    ),
                  ),

                if (_text == null)
                  const Text(
                      'Leider konnte auf deinem Bild kein Text erkannt werden.') // TODO: schöneres Feedback und Möglichkeit direkt ein neues Bild aufzunehmen / zu wählen.,
              ],
            )));
  }

  Future _processPickedFile(XFile? pickedFile) async {
    final path = pickedFile?.path;
    if (path == null) {
      return;
    }
    setState(() {
      _image = File(path);
    });

    final Uint8List bytes = await pickedFile!.readAsBytes();
    final decodedImage = await decodeImageFromList(bytes);
    final exifData = await readExifFromBytes(bytes);
    final imageWidth = decodedImage.width.toDouble();
    final imageHeight = decodedImage.height.toDouble();

    getImageRotation() {
      print({exifData['Image Orientation'], imageWidth, imageHeight});
      // Exif data (pre smartphone standard) is based on horizontal (0 deg) images (most digicam pictures), the code is based vertically (0 deg, most smartphone pictures)
      final orientation = exifData['Image Orientation']!.printable;

      if (orientation == "Horizontal (normal)" && imageHeight < imageWidth) {
        print("1"); // works with live photos
        return InputImageRotation.rotation90deg;
      } else if (orientation == "Rotated 180" && imageHeight < imageWidth) {
        print("2"); // doesnt work
        return InputImageRotation.rotation270deg;
      } else if (orientation == "Rotated 90 CCW" && imageHeight > imageWidth) {
        print("3"); // doesnt work
        return InputImageRotation.rotation180deg;
      } else if (orientation == "Rotated 90 CW" && imageHeight > imageWidth) {
        print("4"); // doesnt work
        return InputImageRotation.rotation0deg;
      } else {
        print("5");
        return InputImageRotation.rotation0deg; // works with gallery photots
      } // if in doubt, the function still needs this information. In most cases its 0 degrees
    }

    final inputImage = InputImage.fromFilePath(path);

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
    _text = recognizedText;
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}

class VisibilityNotifier extends ChangeNotifier {
  bool showOverlay = true;

  void changeVisiblity({bool? show}) {
    show != null ? showOverlay = show : showOverlay = !showOverlay;

    notifyListeners();
  }
}

final visiblityNotifierProvider =
    ChangeNotifierProvider((ref) => VisibilityNotifier());
