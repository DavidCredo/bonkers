import 'package:bonkers/controller/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BonListWidget extends ConsumerWidget {
  const BonListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bonList = ref.watch(userBonsCollectionProvider);
    return bonList.when(
        data: (bons) => ListView.builder(
            itemCount: bons.length,
            itemBuilder: ((context, index) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(bons[index].title),
                    subtitle: Text(
                      bons[index].createdAt.toDate().toString(),
                    ),
                  ),
                ))),
        error: (e, st) => Center(
              child: Text(e.toString()),
            ),
        loading: (() => const Center(
              child: CircularProgressIndicator(),
            )));
  }
}
