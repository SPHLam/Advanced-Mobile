class AIItem {
  final String id;
  final String name;
  final String logoPath;
  final String price;

  AIItem({
    required this.id,
    required this.name,
    required this.logoPath,
    required this.price,
  });

  factory AIItem.fromJson(Map<String, dynamic> json) {
    return AIItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      logoPath: json['logoPath'] ?? '',
      price: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logoPath': logoPath,
      'price': price,
    };
  }

  AIItem copyWith({
    String? id,
    String? name,
    String? logoPath,
    String? price,
  }) {
    return AIItem(
      id: id ?? this.id,
      name: name ?? this.name,
      logoPath: logoPath ?? this.logoPath,
      price: price ?? this.price,
    );
  }
}
