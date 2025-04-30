class AIItem {
  final String name;
  final String logoPath;
  final String id;

  AIItem({
    required this.name,
    required this.logoPath,
    required this.id,
  });

  factory AIItem.fromJson(Map<String, dynamic> json) {
    return AIItem(
      name: json['name'] ?? '',
      logoPath: json['logoPath'] ?? '',
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'logoPath': logoPath,
      'id': id,
    };
  }

  AIItem copyWith({
    String? name,
    String? logoPath,
    String? id,
  }) {
    return AIItem(
      name: name ?? this.name,
      logoPath: logoPath ?? this.logoPath,
      id: id ?? this.id,
    );
  }
}
