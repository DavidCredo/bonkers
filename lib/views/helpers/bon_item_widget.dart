import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/bon.dart';
import '../bon_detail_view.dart';

class AllBonsListTile extends StatelessWidget {
  const AllBonsListTile({super.key, required this.bon});
  final Bon bon;

  @override
  Widget build(BuildContext context) {
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
      ),
    );
  }
}
