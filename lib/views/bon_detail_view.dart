import 'package:bonkers/models/user.dart';
import 'package:bonkers/views/helpers/bon_item_widget.dart';
import 'package:bonkers/views/helpers/payer_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
  bool didChangePayer = false;
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
    final sumInEuros =
        NumberFormat.currency(locale: 'eu', symbol: "€").format(sum);
    final selectedPayer = ref.read(payerNotifierProvider).selectedPayer;
    return Scaffold(
      appBar: AppBar(title: Text(bon.title)),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: ListView.builder(
                itemCount: bonItems.length + 1,
                itemBuilder: ((context, index) {
                  if (index == bonItems.length) {
                    return Text(
                      "Summe: $sumInEuros",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    );
                  } else {
                    return ListTile(
                        trailing: Text(bonItems[index].payer ?? "Niemand"),
                        title: Text(bonItems[index].title),
                        // Number format is used to format the items price in euros
                        subtitle: Text("Preis: " +
                            NumberFormat.currency(locale: 'eu', symbol: "€")
                                .format(bonItems[index].price)),
                        onTap: () {
                          bonItems[index].setPayer(selectedPayer);
                          didChangePayer = true;
                          setState(() {});
                        });
                  }
                })),
          ),
          if (didChangePayer)
            ElevatedButton(
              onPressed: () {
                didChangePayer = false;
                setState(() {});
              },
              child: Text("Save"),
            ),
          const Expanded(
            flex: 1,
            child: PayerListWidget(),
          )
        ],
      ),
    );
  }
}
