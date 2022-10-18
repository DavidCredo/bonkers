import 'package:flutter/material.dart';

class ItemsListPage extends StatefulWidget {
  final String itemsString;
  const ItemsListPage({super.key, required this.itemsString});

  @override
  State<ItemsListPage> createState() => _ItemsListPageState();
}

class _ItemsListPageState extends State<ItemsListPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanned Items'),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return _listItem(index);
        },
      ),
    );
  }

  Widget _listItem(int index) {
    return Card(
      child: ListTile(title: Text("Item")),
    );
  }
}
