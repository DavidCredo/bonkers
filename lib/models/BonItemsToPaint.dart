import 'dart:ui';

class BonItemsToPaint {
  BonItemsToPaint(this.rectList, this.color, this.payer);

  final Map<String, RectInfo> rectList;
  Color color; // changes accoring to the ownership (payer)
  String? payer; // to be set by the user
}

class RectInfo {
  RectInfo(this.left, this.top, this.right, this.bottom, this.content);
  final double left;
  final double top;
  final double right;
  final double bottom;
  String content; // to be manipulated (corrected) by the user
}
