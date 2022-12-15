import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/bon.dart';
import '../../controller/bon_service.dart';
import '../bon_detail_view.dart';

class AllBonsListTile extends ConsumerWidget {
  const AllBonsListTile({super.key, required this.bon});
  final Bon bon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime timestampAsDateTime = bon.createdAt.toDate();
    final String formattedTime =
        DateFormat("dd.MM.yyyy").format(timestampAsDateTime).toString();
    final sum = Bon.getSumInEuros(bon);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(bon.title),
        subtitle: Text("Hinzugefügt am: $formattedTime"),
        trailing: Text("Summe: $sum"),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return BonDetailView(bon: bon);
          }));
        },
        onLongPress: () => showDialog(
            context: context,
            builder: ((context) => AlertDialog(
                  content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text("Willst du diesen Bon wirklich löschen?")
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                        onPressed: (() {
                          Navigator.of(context).pop();
                        }),
                        child: const Text("Zurück")),
                    TextButton(
                        onPressed: () {
                          ref.read(bonServiceProvider).deleteBon(bon);
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "Löschen",
                          style: TextStyle(color: Colors.red),
                        ))
                  ],
                ))),
      ),
    );
  }
}
