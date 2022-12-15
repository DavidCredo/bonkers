import 'package:bonkers/controller/database.dart';
import 'package:bonkers/models/payer.dart';
import 'package:bonkers/models/user.dart';
import 'package:bonkers/views/helpers/payer_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeletePayerDialog extends ConsumerWidget {
  const DeletePayerDialog({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userCollectionProvider).value;
    final selectedPayer = ref.watch(payerNotifierProvider).selectedPayer.name;
    final PayerDialogController dialogController =
        PayerDialogController(ref: ref);

    return AlertDialog(
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [Text("Willst du $selectedPayer von der Liste löschen?")],
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
              dialogController.removePayer(user!, index);
              Navigator.of(context).pop();
              ref
                  .read(payerNotifierProvider)
                  .updatePayer(Payer(color: Colors.black, name: "Niemand"));
            },
            child: const Text(
              "Löschen",
              style: TextStyle(color: Colors.red),
            ))
      ],
    );
  }
}
