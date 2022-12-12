import 'dart:ui';

class Payer {
  Payer({required this.color, required this.name});

  final String name;
  final Color color;

  factory Payer.fromJson(Map<String, dynamic> data) {
    final name = data["name"] as String;
    final colorData = data["color"] as int;
    final color = Color(colorData);

    return Payer(color: color, name: name);
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "color": color.value,
    };
  }
}
