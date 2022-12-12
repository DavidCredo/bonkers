import 'package:bonkers/models/bon.dart';
import 'package:bonkers/models/bon_item.dart';
import 'package:bonkers/services/bon_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditBonItemDialog extends ConsumerStatefulWidget {
  final Bon? bon;
  final List<BonItem>? bonItems;
  final int index;
  const EditBonItemDialog(
      {super.key, this.bon, this.bonItems, required this.index});

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
    if (widget.bon != null) {
      _itemTitleController.text = widget.bon!.articles[widget.index].title;
      _itemPriceController.text =
          widget.bon!.articles[widget.index].price.toString();
    } else {
      _itemTitleController.text = widget.bonItems![widget.index].title;
      _itemPriceController.text =
          widget.bonItems![widget.index].price.toString();
    }
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
    late final Bon? bon;
    late final List<BonItem>? bonItems;
    if (widget.bon != null) {
      bon = widget.bon!;
    } else {
      bonItems = widget.bonItems;
    }
    final int index = widget.index;

    return AlertDialog(
      title: const Text(
        "Artikel bearbeiten",
        textAlign: TextAlign.center,
      ),
      content: Form(
        key: _formKey,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _itemTitleController,
                  decoration:
                      const InputDecoration(icon: Icon(Icons.description)),
                ),
              ),
            ),
            Expanded(
                flex: 1,
                child: TextFormField(
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
            if (widget.bon != null) {
              bonItemController.updateBonItemInDB(bon!, index,
                  _itemTitleController.text, _itemPriceController.text);
              Navigator.of(context).pop();
            } else {
              bonItemController.updateBonItemLocally(bonItems!, index,
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

  void updateBonItemInDB(
      Bon bon, int index, String userInputTitle, String userInputPrice) {
    final updatedBonItem = bon.articles[index].copyWith(
        price: double.tryParse(userInputPrice.replaceAll(',', '.')),
        title: userInputTitle);

    final newBon = bon.updateBonItem(bon, index, updatedBonItem);
    ref.read(bonServiceProvider).updateBon(newBon);
  }

  void updateBonItemLocally(List<BonItem> articles, int index,
      String userInputTitle, String userInputPrice) {
    final updatedBonItem = articles[index].copyWith(
        price: double.tryParse(userInputPrice.replaceAll(',', '.')),
        title: userInputTitle);
    articles[index] = updatedBonItem;
  }
}
