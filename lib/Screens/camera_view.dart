import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:image_picker/image_picker.dart';

class InputView extends StatefulWidget {
  const InputView(
      {Key? key,
      required this.title,
      required this.customPaint,
      this.text,
      required this.onImage})
      : super(key: key);

  final String title;
  final CustomPaint? customPaint;
  final String? text;
  final Function(InputImage inputImage) onImage;

  @override
  _InputViewState createState() => _InputViewState();
}

class _InputViewState extends State<InputView> {
  File? _image;
  String? _path;
  ImagePicker? _imagePicker;

  @override
  void initState() {
    super.initState();
    _imagePicker = ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _galleryBody(),
    );
  }

  Widget _galleryBody() {
    return ListView(shrinkWrap: true, children: [
      // Hier wird das Bild angezeigt, wenn eines ausgewählt wurde
      // _image != null
      //     ? SizedBox(
      //         height: 400,
      //         width: 400,
      //         child: Stack(
      //           fit: StackFit.expand,
      //           children: <Widget>[
      //             Image.file(_image!),
      //             if (widget.customPaint != null) widget.customPaint!,
      //           ],
      //         ),
      //       )
      //     :
      const Icon(
        Icons.receipt_long,
        size: 200,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          child: const Text('From Gallery'),
          onPressed: () => _getImage(ImageSource.gallery),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          child: const Text('Take a picture'),
          onPressed: () => _getImage(ImageSource.camera),
        ),
      ),
      if (_image != null)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(widget.text ?? ''),
        ),
    ]);
  }

  Future _getImage(ImageSource source) async {
    setState(() {
      _image = null;
      _path = null;
    });
    final pickedFile = await _imagePicker?.pickImage(
        source: source, requestFullMetadata: false);
    if (pickedFile != null) {
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
    widget.onImage(inputImage);
  }
}
