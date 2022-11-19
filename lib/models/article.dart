class Article {
  Article({required this.price, required this.title, this.payer});

  final double price;
  final String title;
  final String? payer;

  factory Article.fromJson(Map<String, dynamic> data) {
    final price = data["price"] as double;
    final title = data["title"] as String;
    final payer = data["payer"] as String?;

    return Article(price: price, title: title, payer: payer);
  }

  Map<String, dynamic> toJson() {
    return {
      'price': price,
      'title': title,
      if (payer != null) 'payer': payer,
    };
  }
}
