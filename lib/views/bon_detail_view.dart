import 'package:bonkers/views/bon_view.dart';
import 'package:bonkers/views/helpers/payer_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/bon.dart';

class BonDetailView extends ConsumerStatefulWidget {
  final Bon bon;
  const BonDetailView({super.key, required this.bon});

  @override
  ConsumerState<BonDetailView> createState() => _BonDetailViewState();
}

class _BonDetailViewState extends ConsumerState<BonDetailView> {
  bool didChangePayer = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Bon bon = widget.bon;

//TODO: Check if BonItem List scrolls and PayerList doesnt!
    return Scaffold(
      appBar: AppBar(title: Text(bon.title)),
      body: Column(
        children: <Widget>[
          Expanded(flex: 3, child: SingleBonListView(bonId: bon.uid)),
          const Expanded(
            flex: 1,
            child: PayerListWidget(),
          )
        ],
      ),
    );
  }
}
