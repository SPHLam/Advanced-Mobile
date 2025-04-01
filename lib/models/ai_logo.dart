class AIItem {
  final String name;
  final String logoPath;
  final String id;

  AIItem({
    required this.id,
    required this.name,
    required this.logoPath,
  });

  factory AIItem.fromJson(Map<String, dynamic> json) {
    return AIItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      logoPath: json['logoPath'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logoPath': logoPath,
    };
  }

  AIItem copyWith({
    String? id,
    String? name,
    String? logoPath,
  }) {
    return AIItem(
      name: name ?? this.name,
      logoPath: logoPath ?? this.logoPath,
      id: id ?? this.id,
    );
  }
}
