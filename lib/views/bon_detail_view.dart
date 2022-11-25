import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../models/bon_item.dart';

class BonDetailView extends StatefulWidget {
  final List<BonItem> items;
  const BonDetailView({super.key, required this.items});

  @override
  State<BonDetailView> createState() => _BonDetailViewState();
}

class _BonDetailViewState extends State<BonDetailView> {
  @override
  Widget build(BuildContext context) {
    final List<BonItem> items = widget.items;
    return Scaffold(
      appBar: AppBar(title: const Text("Artikel")),
      body: Stack(
        children: <Widget>[
          ListView.builder(
              itemCount: items.length,
              itemBuilder: ((context, index) => ListTile(
                    title: Text(items[index].title),
                    subtitle:
                        Text("Preis: " + items[index].price.toString() + "€"),
                  ))),
          
        ],
      ),
    );
  }
}
