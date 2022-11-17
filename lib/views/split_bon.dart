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
        body: ListView(shrinkWrap: true, children: [
          SizedBox(
            height: 400,
            width: 400,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Image.file(_image!),
                if (_customPaint != null) _customPaint!,
              ],
            ),
          ),
          Text(_text ??
              'Leider konnte auf deinem Bild kein Text erkannt werden.')
        ]));
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

    getImageRotation() {
      var width = exifData['EXIF ExifImageWidth'];
      var height = exifData['EXIF ExifImageLength'];
      print(exifData);

      switch (exifData['Image Orientation']!.printable) {
        case "Horizontal (normal)":
          return InputImageRotation.rotation0deg;
        case "Rotated 180":
          return InputImageRotation.rotation180deg;
        case "Rotated 90° CCW":
          return InputImageRotation.rotation270deg;
        case "Rotated 90 CW":
          return InputImageRotation.rotation90deg;
        default:
          return InputImageRotation
              .rotation0deg; // if in doubt, the function still needs this information. in most cases its 0 degrees
      }
    }

    final inputImage = InputImage.fromFilePath(path);
    final imageSize =
        Size(decodedImage.height.toDouble(), decodedImage.width.toDouble());
    final rotation = getImageRotation();

    processImage(inputImage, imageSize, rotation);
  }

  Future<void> processImage(InputImage inputImage, Size imageSize,
      InputImageRotation imageRotation) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final recognizedText = await _textRecognizer.processImage(inputImage);
    final painter =
        TextRecognizerPainter(recognizedText, imageSize, imageRotation);
    _customPaint = CustomPaint(painter: painter);
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
