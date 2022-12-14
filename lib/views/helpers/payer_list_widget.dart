import 'package:bonkers/controller/auth.dart';
import 'package:bonkers/controller/database.dart';
import 'package:bonkers/models/bon_item.dart';
import 'package:bonkers/models/payer.dart';
import 'package:bonkers/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'delete_payer_dialog_widget.dart';

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
              if (index == user.payers!.length || user.payers == null) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MaterialButton(
                      color: Colors.green,
                      textColor: Colors.white,
                      shape: const CircleBorder(
                          side: BorderSide(
                              color: Colors.green, style: BorderStyle.solid)),
                      onPressed: (() {
                        showDialog(
                            context: context,
                            builder: ((BuildContext context) {
                              return const AddPayerDialog();
                            }));
                      }),
                      child: const Icon(Icons.add)),
                );
              }
              return Padding(
                padding: const EdgeInsets.all(4),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: MaterialButton(
                      color: user.payers![index].color,
                      textColor: Colors.white,
                      shape: CircleBorder(
                          side: BorderSide(
                              width: 1,
                              color: user.payers![index].color,
                              style: BorderStyle.solid)),
                      onPressed: (() {
                        ref
                            .read(payerNotifierProvider)
                            .updatePayer(user.payers![index]);
                      }),
                      onLongPress: () {
                        showGeneralDialog(
                          context: context,
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  DeletePayerDialog(index: index),
                        );
                      },
                      child: Text(user.payers![index].name)),
                ),
              );
            }),
            itemCount: user.payers!.length + 1),
        error: (error, stackTrace) => Center(
              child: Text(error.toString()),
            ),
        loading: (() => const Center(
              child: CircularProgressIndicator(),
            )));
  }
}

class AddPayerDialog extends ConsumerStatefulWidget {
  const AddPayerDialog({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddPayerDialogState();
}

class _AddPayerDialogState extends ConsumerState<AddPayerDialog> {
  final TextEditingController newUserController = TextEditingController();
  late final PayerDialogController dialogController;
  late Color selectedColor;

  @override
  void initState() {
    super.initState();

    selectedColor = ref.read(selectedColorProvider).selectedColor;
    dialogController = PayerDialogController(ref: ref);
  }

  @override
  void dispose() {
    super.dispose();
    newUserController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Neuen Teilnehmer hinzufügen"),
      content: Padding(
        padding: const EdgeInsets.all(8),
        child: Form(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: newUserController,
              decoration: const InputDecoration(
                  labelText: "Name", icon: Icon(Icons.account_box)),
            ),
            Flexible(
              flex: 1,
              child: MaterialColorPicker(
                  allowShades: false,
                  onMainColorChange: (color) {
                    ref
                        .read(selectedColorProvider)
                        .changeColor(color!.withOpacity(1));
                    selectedColor = color.withOpacity(1);
                  }),
            )
          ],
        )),
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              "Zurück",
              style: TextStyle(color: Colors.redAccent),
            )),
        TextButton(
            onPressed: () {
              final user = ref.read(userCollectionProvider).value;
              dialogController.addPayer(
                  user!, newUserController.text, selectedColor);
              Navigator.of(context).pop();
            },
            child: const Text("Hinuzufügen"))
      ],
    );
  }
}

class PayerDialogController {
  PayerDialogController({required this.ref});
  final WidgetRef ref;

  void removePayer(AuthenticatedUser user, int index) {
    final newPayerList = user.payers!;
    newPayerList.remove(user.payers![index]);
    final updatedUser = user.copyWith(payers: newPayerList);
    ref.read(databaseProvider).updatePayerList(updatedUser);
  }

  void addPayer(AuthenticatedUser user, String newUserName, Color color) {
    final newPayer = Payer(color: color, name: newUserName);
    final newPayerList = user.payers!;
    newPayerList.add(newPayer);
    final updatedUser = user.copyWith(payers: newPayerList);
    ref.read(databaseProvider).updatePayerList(updatedUser);
  }
}

class SelectedColorNotifier extends ChangeNotifier {
  Color selectedColor = Color.fromARGB(100, 100, 100, 100);

  void changeColor(Color newColor) {
    selectedColor = newColor;
    notifyListeners();
  }
}

final selectedColorProvider = ChangeNotifierProvider((ref) {
  return SelectedColorNotifier();
});
