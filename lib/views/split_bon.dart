import 'dart:io';
import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../controller/text_detector_painter.dart';

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
  CustomPaint? _customPaint;
  String? _text;
  File? _image;
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
                Image.file(_image!),
                if (_customPaint != null) _customPaint!,
                if (_text == '' || _text == null)
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
        print("1");
        return InputImageRotation.rotation90deg;
      } else if (orientation == "Rotated 180" && imageHeight < imageWidth) {
        print("2");
        return InputImageRotation.rotation270deg;
      } else if (orientation == "Rotated 90 CCW" && imageHeight > imageWidth) {
        print("3");
        return InputImageRotation.rotation180deg;
      } else if (orientation == "Rotated 90 CW" && imageHeight > imageWidth) {
        print("4");
        return InputImageRotation.rotation0deg;
      } else {
        print("5");
        return InputImageRotation.rotation0deg;
      } // if in doubt, the function still needs this information. In most cases its 0 degrees
    }

    final inputImage = InputImage.fromFilePath(path);
    final imageSize = Size(imageWidth, imageHeight);
    final rotation = getImageRotation();
    _width = imageWidth;
    _height = imageHeight;

    processImage(inputImage, imageSize, rotation);
  }

  Future<void> processImage(InputImage inputImage, Size imageSize,
      InputImageRotation imageRotation) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    final recognizedText = await _textRecognizer.processImage(inputImage);
    final painter =
        TextRecognizerPainter(recognizedText, imageSize, imageRotation);
    _customPaint = CustomPaint(painter: painter);
    _text = recognizedText.text;
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
