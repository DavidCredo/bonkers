class BonItem {
  BonItem({required this.price, required this.title, this.payer});

  double price;
  String title;
  String? payer;

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
}
