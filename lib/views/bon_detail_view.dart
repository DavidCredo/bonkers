import 'package:bonkers/models/user.dart';
import 'package:bonkers/views/helpers/bon_item_widget.dart';
import 'package:bonkers/views/helpers/payer_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/bon.dart';
import '../models/bon_item.dart';

class BonDetailView extends ConsumerStatefulWidget {
  final Bon bon;
  const BonDetailView({super.key, required this.bon});

  @override
  ConsumerState<BonDetailView> createState() => _BonDetailViewState();
}

class _BonDetailViewState extends ConsumerState<BonDetailView> {
  double? sum;
  @override
  void initState() {
    super.initState();
    sum = widget.bon.articles
        .map((article) => article.price)
        .reduce((value, element) => value + element);
  }

  @override
  Widget build(BuildContext context) {
    final Bon bon = widget.bon;
    final bonItems = bon.articles;
    return Scaffold(
      appBar: AppBar(title: Text(bon.title)),
      body: Column(
        children: <Widget>[
          Flexible(
            flex: 4,
            child: ListView.builder(
                itemCount: bonItems.length,
                itemBuilder: ((context, index) => ListTile(
                    trailing: Text(bonItems[index].payer ?? "Niemand"),
                    title: Text(bonItems[index].title),
                    subtitle: Text(
                        "Preis: " + bonItems[index].price.toString() + "€"),
                    onTap: () {
                      bonItems[index].setPayer(
                          ref.read(payerNotifierProvider).selectedPayer);
                      setState(() {});
                    }))),
          ),
          Expanded(
              flex: 4,
              child: Text(
                "Summe: " + sum.toString() + "€",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              )),
          const Expanded(
            flex: 2,
            child: PayerListWidget(),
          )
        ],
      ),
    );
  }
}
