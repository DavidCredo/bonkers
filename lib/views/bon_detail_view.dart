import 'package:bonkers/views/helpers/bon_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../models/bon.dart';
import '../models/bon_item.dart';

class BonDetailView extends StatefulWidget {
  final Bon bon;
  const BonDetailView({super.key, required this.bon});

  @override
  State<BonDetailView> createState() => _BonDetailViewState();
}

class _BonDetailViewState extends State<BonDetailView> {
  @override
  Widget build(BuildContext context) {
    final Bon bon = widget.bon;
    return Scaffold(
      appBar: AppBar(title: Text(bon.title)),
      body: Column(
        children: <Widget>[
          Flexible(
            flex: 4,
            child: ListView.builder(
                itemCount: bon.articles.length,
                itemBuilder: ((context, index) => ListTile(
                      title: Text(bon.articles[index].title),
                      subtitle: Text("Preis: " +
                          bon.articles[index].price.toString() +
                          "€"),
                    ))),
          ),
          Expanded(
              child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            children: <Widget>[
              Container(
                width: 75,
                child: const CircleAvatar(
                  backgroundColor: Colors.black,
                  maxRadius: 50,
                  child: Text("AH"),
                ),
              ),
              const CircleAvatar(
                backgroundColor: Colors.black,
                maxRadius: 50,
                child: Text("AH"),
              ),
              const CircleAvatar(
                backgroundColor: Colors.black,
                maxRadius: 50,
                child: Text("AH"),
              )
            ],
          ))
        ],
      ),
    );
  }
}
