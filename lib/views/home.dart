import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'Painters/text_detector_painter.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<String>? dataset;
  File? _image;
  String? _path;
  ImagePicker? _imagePicker;
  final TextRecognizer _textRecognizer = TextRecognizer();
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;

  @override
  void dispose() async {
    _canProcess = false;
    _textRecognizer.close();
    super.dispose();
  }

  @override
  void initState() {
    _imagePicker = ImagePicker();
    // Hier soll die Datenbankabfrage geschehen und der loakle Datensatz gefüllt werden
    dataset = [
      "Eintrag 0",
      "Eintrag 1",
      "Eintrag 2",
      "Eintrag 3",
      "Eintrag 4",
      "Eintrag 5",
      "Eintrag 6",
      "Eintrag 7",
      "Eintrag 8",
      "Eintrag 9",
      "Eintrag 10",
      "Eintrag 11",
      "Eintrag 12",
      "Eintrag 13",
      "Eintrag 14"
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Wrap(
              children: const [Icon(Icons.receipt_long), Text(' Bonkers')]),
        ),
        body: Stack(children: <Widget>[
          ListView(
            children: dataset!.map((e) {
              return Container(
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.all(15),
                child: Text(e),
              );
            }).toList(),
          ),
          Stack(fit: StackFit.expand, children: [
            Positioned(
                left: 40,
                bottom: 20,
                child: ElevatedButton(
                  child: const Text('From Gallery'),
                  onPressed: () => _getImage(ImageSource.gallery),
                )),
            Positioned(
                right: 40,
                bottom: 20,
                child: ElevatedButton(
                  child: const Text('Take a picture'),
                  onPressed: () => _getImage(ImageSource.camera),
                ))
          ])
        ]));
  }

  Future _getImage(ImageSource source) async {
    setState(() {
      _image = null;
      _path = null;
    });
    final pickedFile = await _imagePicker?.pickImage(
        source: source, requestFullMetadata: false);
    if (pickedFile != null) {
      // TODO: go to view where one can split the bill, get back from there with or without saveing (options on top: save | cancel)
      _processPickedFile(pickedFile);
    }
    setState(() {});
  }

  Future _processPickedFile(XFile? pickedFile) async {
    final path = pickedFile?.path;
    if (path == null) {
      return;
    }
    setState(() {
      _image = File(path);
    });
    _path = path;
    final inputImage = InputImage.fromFilePath(path);
    processImage(inputImage);
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final recognizedText = await _textRecognizer.processImage(inputImage);
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = TextRecognizerPainter(
          recognizedText,
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      _customPaint = CustomPaint(painter: painter);
    } else {
      _text = recognizedText.text;
      // TODO: set _customPaint to draw boundingRect on top of image
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
