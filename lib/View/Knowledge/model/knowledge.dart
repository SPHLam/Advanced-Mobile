class Knowledge {
  const Knowledge({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.listFiles,
    required this.listGGDrives,
    required this.listUrlWebsite,
    required this.listSlackFiles,
    required this.listConfluenceFiles,
  });

  final String name;
  final String description;
  final String imageUrl;
  final List<String> listFiles;
  final List<String> listGGDrives;
  final List<String> listUrlWebsite;
  final List<String> listSlackFiles;
  final List<String> listConfluenceFiles;
}
