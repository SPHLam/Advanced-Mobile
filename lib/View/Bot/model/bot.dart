class Bot {
  const Bot(
      {required this.name,
      required this.prompt,
      required this.team,
      required this.imageUrl,
      required this.isPublish,
      required this.listKnowledge});

  final String name;
  final String prompt;
  final String team;
  final String imageUrl;
  final bool isPublish;
  final List<String> listKnowledge;
}
