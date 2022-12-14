import 'package:bonkers/models/bon.dart';
import 'package:bonkers/models/bon_item.dart';
import 'package:bonkers/services/bon_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditBonItemDialog extends ConsumerStatefulWidget {
  final Bon bon;
  final int index;
  const EditBonItemDialog({super.key, required this.bon, required this.index});

  @override
  ConsumerState<EditBonItemDialog> createState() => _EditBonItemDialogState();
}

class _EditBonItemDialogState extends ConsumerState<EditBonItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _itemTitleController = TextEditingController();
  final _itemPriceController = TextEditingController();
  late final BonItemController bonItemController;

  @override
  void initState() {
    super.initState();
    _itemTitleController.text = widget.bon.articles[widget.index].title;
    _itemPriceController.text =
        widget.bon.articles[widget.index].price.toString();
    bonItemController = BonItemController(ref: ref);
  }

  @override
  void dispose() {
    super.dispose();
    _itemPriceController.dispose();
    _itemTitleController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bon = widget.bon;
    final int index = widget.index;

    return AlertDialog(
      title: const Text(
        "Artikel bearbeiten",
        textAlign: TextAlign.center,
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Diese Feld darf nicht leer sein.";
                    } else {
                      return null;
                    }
                  },
                  controller: _itemTitleController,
                  decoration:
                      const InputDecoration(icon: Icon(Icons.description)),
                ),
              ),
            ),
            Flexible(
                flex: 1,
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Dieses Feld darf nicht leer sein.";
                    } else if (double.tryParse(value) == null) {
                      return "Bitte gib eine Zahl ein.";
                    } else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.number,
                  controller: _itemPriceController,
                  decoration: const InputDecoration(icon: Icon(Icons.euro)),
                )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: (() {
            Navigator.of(context).pop();
          }),
          child: const Text("Zurück"),
        ),
        TextButton(
          onPressed: (() {
            if (_formKey.currentState!.validate()) {
              bonItemController.updateBonItem(bon, index,
                  _itemTitleController.text, _itemPriceController.text);
              Navigator.of(context).pop();
            }
          }),
          child: const Text("Speichern"),
        ),
      ],
    );
  }
}

class BonItemController {
  BonItemController({required this.ref});
  final WidgetRef ref;

  void updateBonItem(
      Bon bon, int index, String userInputTitle, String userInputPrice) {
    final updatedBonItem = bon.articles[index].copyWith(
        price: double.tryParse(userInputPrice.replaceAll(',', '.')),
        title: userInputTitle);

    final newBon = bon.updateBonItem(bon, index, updatedBonItem);
    ref.read(bonServiceProvider).updateBon(newBon);
  }
}
