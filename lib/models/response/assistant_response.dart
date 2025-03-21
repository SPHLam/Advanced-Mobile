class Assistant {
  final String id;
  final String model;
  final String name;

  Assistant({
    required this.id,
    required this.model,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'model': model,
        'name': name,
      };

  factory Assistant.fromJson(Map<String, dynamic> json) => Assistant(
        id: json['id'],
        model: json['model'],
        name: json['name'],
      );
} 