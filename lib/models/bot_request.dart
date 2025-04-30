class BotRequest {
  final String assistantName;
  final String? instructions;
  final String? description;

  BotRequest({
    required this.assistantName,
    this.instructions,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'assistantName': assistantName,
      if (instructions != null) 'instructions': instructions,
      if (description != null) 'description': description,
    };
  }
}
