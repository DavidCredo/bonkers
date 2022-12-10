class BonItem {
  BonItem({required this.price, required this.title, this.payer});

  final double price;
  final String title;
  final String? payer;

  factory BonItem.fromJson(Map<String, dynamic> data) {
    final price = data["price"] as double;
    final title = data["title"] as String;
    final payer = data["payer"] as String?;

    return BonItem(price: price, title: title, payer: payer);
  }

  Map<String, dynamic> toJson() {
    return {
      'price': price,
      'title': title,
      if (payer != null) 'payer': payer,
    };
  }

  BonItem copyWith({double? price, String? title, String? payer}) {
    return BonItem(
        price: price ?? this.price,
        title: title ?? this.title,
        payer: payer ?? this.payer);
  }
}
