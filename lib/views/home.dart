import 'package:bonkers/controller/auth.dart';
import 'package:bonkers/views/helpers/bon_list_widget.dart';
import 'package:bonkers/views/split_bon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/bon.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  List<String>? dataset;
  ImagePicker? _imagePicker;

  @override
  void initState() {
    _imagePicker = ImagePicker();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkModeEnabled =
        ref.watch(themeNotifierProvider).isDarkModeEnabled;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: ((() {
                ref.read(themeNotifierProvider).toggleTheme();
              })),
              icon:
                  Icon(isDarkModeEnabled ? Icons.dark_mode : Icons.light_mode)),
          IconButton(
              onPressed: () async {
                await ref.read(firebaseAuthProvider).signOut();
              },
              icon: const Icon(Icons.logout)),
        ],
        title:
            Wrap(children: const [Icon(Icons.receipt_long), Text(' Bonkers')]),
      ),
      body: Stack(children: <Widget>[
        const AllBonsOverviewList(),
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
      ]),
    );
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

class ThemeNotifier extends ChangeNotifier {
  bool isDarkModeEnabled = false;

  void toggleTheme() {
    isDarkModeEnabled = !isDarkModeEnabled;
    notifyListeners();
  }
}

final themeNotifierProvider = ChangeNotifierProvider<ThemeNotifier>((ref) {
  return ThemeNotifier();
});
