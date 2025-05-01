enum Language {
  English('English'),
  Japanese('Japanese'),
  Spanish('Spanish'),
  German('German'),
  French('French');

  final String label; // Dùng để hiển thị trên UI
  const Language(this.label);
  String get value => this.toString().split('.').last;
}

enum Category {
  other('Other'),
  business('Business'),
  marketing('Marketing'),
  seo('SEO'),
  writing('Writing'),
  coding('Coding'),
  career('Career'),
  chatbot('Chatbot'),
  education('Education'),
  fun('Fun'),
  productivity('Productivity');

  final String label; // Dùng để hiển thị trên UI
  const Category(this.label);
  String get value =>
      this.toString().split('.').last; // Giá trị lưu trữ lowercase
}
