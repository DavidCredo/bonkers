import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class BonItemWidget extends StatelessWidget {
  const BonItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return (Row(
      children: [
        Expanded(
          child: Text("Title"),
        ),
        Expanded(
          child: Text("price"),
        ),
        Icon(Icons.attach_money)
      ],
    ));
  }
}
