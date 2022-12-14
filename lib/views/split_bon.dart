import 'dart:io';
import 'package:bonkers/views/helpers/payer_list_widget.dart';
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
import '../controller/wrapper.dart';
import '../models/BonItemsToPaint.dart';
import '../models/bon.dart';
import '../models/bon_item.dart';
import '../services/bon_service.dart';

class SplitBon extends ConsumerStatefulWidget {
  const SplitBon({super.key, required this.pickedFile});
  final XFile pickedFile;

  @override
  ConsumerState<SplitBon> createState() => _SplitBonState();
}

class _SplitBonState extends ConsumerState<SplitBon> {
  final TextRecognizer _textRecognizer = TextRecognizer();
  TextRecognizerPainter? _painterInstance;
  bool _canProcess = true;
  bool _isBusy = false;
  bool _recognitionSuccessful = true;
  String? _bonTitle;
  List<BonItemsToPaint>? _bonItemsData;
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
          leadingWidth: 60,
          title: Wrap(
              children: const [Icon(Icons.receipt_long), Text(' Bonkers')]),
          centerTitle: true,
          leading: Builder(
              builder: ((context) => IconButton(
                    onPressed: (() {
                      Navigator.of(context).pop();
                    }),
                    icon: const Text(
                      "Zurück",
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ))),
          actions: [
            TextButton(
                onPressed: (() {
                  // create list of bon items (for database)
                  if (_painterInstance != null) {
                    final List<BonItem> bonItems = [];
                    for (final item in _painterInstance!.bonRects) {
                      // at this point, the value for key "price" must be a double, previous checks will handle
                      bonItems.add(BonItem(
                          price: double.parse(item.rectList["price"]!.content),
                          title: item.rectList["title"]!.content,
                          payer: item.payer));
                    }
                    final Bon newBon =
                        Bon.createBonFromScan(_bonTitle!, bonItems);
                    ref.read(bonServiceProvider).addBon(newBon);
                  }

                  Navigator.of(context).push(MaterialPageRoute(
                      builder: ((context) => const Wrapper())));
                }),
                child: const Text(
                  "Speichern",
                  style: TextStyle(color: Colors.white),
                ))
          ],
        ),
        body: Column(
          children: [
            SizedBox(
                // display the image in maximal display size while retaining the proportions
                height: _width != null && _height != null
                    ? (MediaQuery.of(context).size.width / _width! * _height!)
                    : MediaQuery.of(context).size.height,
                width: _width != null && _height != null
                    ? (MediaQuery.of(context).size.height / _height! * _width!)
                    : MediaQuery.of(context).size.width,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    if (_strippedImage != null)
                      Image.file(_strippedImage!)
                    else
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                    if (_bonItemsData != null &&
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
                                painter: _painterInstance =
                                    TextRecognizerPainter(
                                        _bonItemsData!,
                                        _imageSize!,
                                        _imageRotation!,
                                        context,
                                        ref)),
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
                    if (!_recognitionSuccessful)
                      const Text(
                          'Leider konnten auf deinem Bild keine Artikel eines Kassenbons erkannt werden. Versuche insbesondere darauf zu achten, dass der gesamte Bon auf deinem Bild zu sehen ist und Du dein Foto möglichst parallel und gerade zum Kassenbon schießt.')
                  ],
                )),
            const Flexible(
              child: PayerListWidget(),
            )
          ],
        ));
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
      final orientation = exifData['Image Orientation']?.printable ?? "no info";

      if (orientation == "Horizontal (normal)" && imageHeight < imageWidth) {
        return InputImageRotation.rotation0deg;
      } else if (orientation == "Rotated 180" && imageHeight < imageWidth) {
        return InputImageRotation.rotation180deg;
      } else if (orientation == "Rotated 90 CCW" && imageHeight > imageWidth) {
        return Platform.isIOS
            ? InputImageRotation.rotation270deg
            : InputImageRotation.rotation180deg;
      } else if (orientation == "Rotated 90 CW" && imageHeight > imageWidth) {
        return Platform.isIOS
            ? InputImageRotation.rotation90deg
            : InputImageRotation.rotation0deg;
      } else if (imageHeight < imageWidth) {
        return Platform.isIOS
            ? InputImageRotation.rotation0deg
            : InputImageRotation.rotation90deg;
      } else if (imageHeight > imageWidth) {
        return Platform.isIOS
            ? InputImageRotation.rotation90deg
            : InputImageRotation.rotation0deg;
      } else {
        // if in doubt or square, the function still needs this information. In most cases its 90 degrees
        return InputImageRotation.rotation90deg;
      }
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
    _bonTitle = recognizedText.blocks.first.lines.first.text;
    _bonItemsData = itemsFilter(recognizedText);
    if (_bonItemsData == null) _recognitionSuccessful = false;
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
