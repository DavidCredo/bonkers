import 'package:bonkers/controller/text_detector_painter.dart';
import 'package:bonkers/models/BonItemsToPaint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditLocalBonItemDialog extends ConsumerStatefulWidget {
  const EditLocalBonItemDialog({super.key, required this.bonItem});
  final BonItemsToPaint bonItem;

  @override
  ConsumerState<EditLocalBonItemDialog> createState() =>
      _EditLocalBonItemDialogState();
}

class _EditLocalBonItemDialogState
    extends ConsumerState<EditLocalBonItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _itemTitleController = TextEditingController();
  final _itemPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _itemTitleController.text = widget.bonItem.rectList["title"]!.content;
    _itemPriceController.text = widget.bonItem.rectList["price"]!.content;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Artikel bearbeiten",
        textAlign: TextAlign.center,
      ),
      content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Diese Feld darf nicht leer sein.";
                        } else {
                          return null;
                        }
                      },
                      controller: _itemTitleController,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.description),
                      ),
                    ),
                  )),
              Flexible(
                  child: Padding(
                padding: const EdgeInsets.all(8),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Dieses Feld darf nicht leer sein.";
                    } else if (double.tryParse(value) == null) {
                      return "Bitte gib eine Zahl ein.";
                    } else {
                      return null;
                    }
                  },
                  controller: _itemPriceController,
                  decoration: const InputDecoration(icon: Icon(Icons.euro)),
                ),
              ))
            ],
          )),
      actions: [
        TextButton(
            onPressed: (() {
              Navigator.of(context).pop();
            }),
            child: const Text("Abbrechen")),
        TextButton(
            onPressed: (() {
              widget.bonItem.rectList["title"]!.content =
                  _itemTitleController.text;
              widget.bonItem.rectList["price"]!.content =
                  _itemPriceController.text;
              ref.read(shouldRepaintProvider).triggerRepaint();
              Navigator.of(context).pop();
            }),
            child: const Text("Speichern"))
      ],
    );
  }
}
