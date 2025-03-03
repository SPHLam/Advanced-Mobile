import 'package:flutter/cupertino.dart';

import '../View/HomeChat/model/ai-logo-list.dart';


class AIChatList extends ChangeNotifier {
  List<AIItem> aiItems = [
    AIItem(
      name: 'Claude',
      logoPath: 'assets/logo/claude.png',
      path: 'path/to/claude',
      tokenCount: 90,
    ),
    AIItem(
      name: 'GitHub Copilot',
      logoPath: 'assets/logo/github-copilot.png',
      path: 'path/to/github-copilot',
      tokenCount: 90,
    ),
    AIItem(
      name: 'ChatGPT',
      logoPath: 'assets/logo/chatgpt.png',
      path: 'path/to/chatgpt',
      tokenCount: 50,
    ),
    AIItem(
      name: 'Deepseek',
      logoPath: 'assets/logo/deepseek.png',
      path: 'path/to/deepseek',
      tokenCount: 40,
    ),
    AIItem(
      name: 'Gemini',
      logoPath: 'assets/logo/gemini.png',
      path: 'path/to/gemini',
      tokenCount: 30,
    ),
  ];


  void addAIItem(AIItem newAIItem) {
    aiItems.add(newAIItem);
    notifyListeners();
  }
}