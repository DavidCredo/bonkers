import 'package:bonkers/models/bon_list.dart';
import 'package:bonkers/views/helpers/bon_list_widget.dart';
import 'package:bonkers/views/split_bon.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/bon.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<String>? dataset;
  ImagePicker? _imagePicker;

  @override
  void initState() {
    _imagePicker = ImagePicker();
    // Hier soll die Datenbankabfrage geschehen und der loakle Datensatz gefüllt werden.
    // TODO: Jeder einzelne Eintrag soll später anklickbar sein und auf das entsprechende split_bon view zeigen.
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
          const BonListWidget(),
          Stack(fit: StackFit.expand, children: [
            Positioned(
                left: 40,
                bottom: 40,
                child: ElevatedButton(
                  child: const Text('From Gallery'),
                  onPressed: () => _getImage(ImageSource.gallery),
                )),
            Positioned(
                right: 40,
                bottom: 40,
                child: ElevatedButton(
                  child: const Text('Take a picture'),
                  onPressed: () => _getImage(ImageSource.camera),
                ))
          ])
        ]));
  }

  Future _getImage(ImageSource source) async {
    final pickedFile = await _imagePicker?.pickImage(
        source: source, requestFullMetadata: false);
    if (pickedFile != null) {
      navigate(pickedFile);
    }
    setState(() {});
  }

  navigate(result) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => SplitBon(pickedFile: result)));
  }
}
