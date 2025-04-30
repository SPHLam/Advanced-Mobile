class Knowledge {
  Knowledge({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.id,
    this.listUnits = const [],
  });

  final String name;
  final String description;
  final String imageUrl;
  final String id;
  List<Unit> listUnits;

  factory Knowledge.fromJson(Map<String, dynamic> json) {
    return Knowledge(
      name: json['knowledgeName'] ?? '',
      id: json['id'] ?? '',
      description: json['description'] ?? '',
      imageUrl: "assets/images/open-book.png",
    );
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'title': title,
  //     'id': id,
  //     'createdAt': createdAt,
  //   };
  // }
}

class Unit {
  final String unitName;
  final String unitId;
  final String unitType;
  bool isActived;

  Unit({
    required this.unitName,
    required this.unitId,
    required this.unitType,
    required this.isActived,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      unitId: json['id'],
      unitName: json['name'],
      unitType: json['type'],
      isActived: json['status'] as bool
    );
  }
}
