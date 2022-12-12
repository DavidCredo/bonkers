import 'package:bonkers/services/bon_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bon_item_widget.dart';

class AllBonsOverviewList extends ConsumerWidget {
  const AllBonsOverviewList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bonList = ref.watch(bonListStreamProvider);
    return bonList.when(
        data: (bons) => ListView.builder(
            itemCount: bons.length,
            itemBuilder: ((context, index) => AllBonsListTile(
                  bon: bons[index],
                ))),
        error: (e, stackTrace) => Center(
              child: Text(e.toString()),
            ),
        loading: (() => const Center(
              child: CircularProgressIndicator(),
            )));
  }
}
