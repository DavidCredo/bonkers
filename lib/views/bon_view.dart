import 'package:bonkers/models/bon.dart';
import 'package:bonkers/models/user.dart';
import 'package:bonkers/services/bon_service.dart';
import 'package:bonkers/views/helpers/edit_bon_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/bon_item.dart';

class SingleBonListView extends ConsumerWidget {
  const SingleBonListView({super.key, required this.bonId});
  final String bonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bon = ref.watch(bonStreamProvider(bonId));
    return bon.when(
        data: (bonData) => ListView.builder(
            itemCount: bonData.articles.length + 1,
            itemBuilder: ((context, index) {
              if (index == bonData.articles.length) {
                return Center(
                  child: Text(
                    "Summe: " + Bon.getSumInEuros(bonData),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                );
              }
              return BonItemTile(
                bonItem: bonData.articles[index],
                bonId: bonId,
                index: index,
              );
            })),
        error: ((error, stackTrace) => Center(child: Text(error.toString()))),
        loading: (() => const Center(
              child: CircularProgressIndicator(),
            )));
  }
}

class BonItemTile extends ConsumerStatefulWidget {
  const BonItemTile(
      {super.key,
      required this.bonItem,
      required this.bonId,
      required this.index});
  final String bonId;
  final BonItem bonItem;
  final int index;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BonItemTileState();
}

class _BonItemTileState extends ConsumerState<BonItemTile> {
  @override
  Widget build(BuildContext context) {
    final bonItem = widget.bonItem;
    final selectedPayer = ref.watch(payerNotifierProvider).selectedPayer;
    final bon = ref.watch(bonStreamProvider(widget.bonId)).value;

    return ListTile(
      title: Text(bonItem.title),
      subtitle: Text("Preis: " +
          NumberFormat.currency(locale: 'eu', symbol: '€')
              .format(bonItem.price)),
      trailing: Text(bonItem.payer ?? "Niemand"),
      onTap: () {
        final newBonItem = bonItem.copyWith(payer: selectedPayer.name);
        final newBon = bon!.updateBonItem(bon, widget.index, newBonItem);
        ref.read(bonServiceProvider).updateBon(newBon);
      },
      onLongPress: () {
        showDialog(
            context: context,
            builder: ((context) =>
                EditBonItemDialog(bon: bon!, index: widget.index)));
      },
    );
  }
}
