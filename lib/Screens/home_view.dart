import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<String>? dataset;

  @override
  void initState() {
    // Hier soll die Datenbankabfrage geschehen und der loakle Datensatz gefüllt werden
    dataset = [
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
      "Eintrag 12"
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('BONkers'),
        ),
        body: ListView(
          children: dataset!.map((e) {
            return Container(
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.all(15),
              child: Text(e),
            );
          }).toList(),
        ));
  }
}
