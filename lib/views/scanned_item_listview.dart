import 'package:flutter/material.dart';

class ItemsListPage extends StatefulWidget {
  final String? itemsString;
  const ItemsListPage({super.key, required this.itemsString});

  @override
  State<ItemsListPage> createState() => _ItemsListPageState();
}

class _ItemsListPageState extends State<ItemsListPage> {
  List<String>? dataset;

  @override
  void initState() {
    dataset = widget.itemsString!.split(' ');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Scanned Items'),
        ),
        body: ListView(
          children: dataset!.map((word) {
            return Container(
              margin: EdgeInsets.all(5),
              padding: EdgeInsets.all(15),
              child: Text(word),
            );
          }).toList(),
        ));
  }
}
