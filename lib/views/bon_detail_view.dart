import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../models/bon_item.dart';

class BonDetailView extends StatefulWidget {
  const BonDetailView({super.key});

  @override
  State<BonDetailView> createState() => _BonDetailViewState();
}

class _BonDetailViewState extends State<BonDetailView> {

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemBuilder: ((context, index) => const Padding(
              padding: EdgeInsets.all(8.0),
            )));
  }
}
