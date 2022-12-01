import 'package:bonkers/controller/database.dart';
import 'package:bonkers/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PayerListWidget extends ConsumerStatefulWidget {
  const PayerListWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PayerListWidgetState();
}

class _PayerListWidgetState extends ConsumerState<PayerListWidget> {
  String? selectedPayer;
  @override
  Widget build(BuildContext context) {
    final userDocReference = ref.watch(userCollectionProvider);
    return userDocReference.when(
        data: (user) => ListView.builder(
            scrollDirection: Axis.horizontal,
            itemBuilder: ((context, index) {
              if (index == user.payers!.length) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MaterialButton(
                      color: Colors.green,
                      textColor: Colors.white,
                      shape: const CircleBorder(
                          side: BorderSide(
                              width: 1,
                              color: Colors.green,
                              style: BorderStyle.solid)),
                      onPressed: (() {}),
                      child: const Icon(Icons.add)),
                );
              }
              return Padding(
                padding: const EdgeInsets.all(4),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: MaterialButton(
                      color: Colors.green,
                      textColor: Colors.white,
                      shape: const CircleBorder(
                          side: BorderSide(
                              width: 1,
                              color: Colors.blue,
                              style: BorderStyle.solid)),
                      onPressed: (() {
                        ref
                            .read(payerNotifierProvider)
                            .updatePayer(user.payers![index]);
                        print(ref.read(payerNotifierProvider).selectedPayer);
                      }),
                      child: Text(user.payers![index])),
                ),
              );
            }),
            itemCount: user.payers!.length + 1),
        error: (e, stackTrace) => Center(
              child: Text(e.toString()),
            ),
        loading: (() => const Center(
              child: CircularProgressIndicator(),
            )));
  }
}
