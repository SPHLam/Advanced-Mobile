import 'package:flutter/cupertino.dart';

import '../models/ai_logo.dart';

class AIChatList extends ChangeNotifier {
  List<AIItem> aiItems = [
    AIItem(
      name: 'GPT-4o mini',
      logoPath: 'assets/logo/gpt-4o-mini.png',
      id: 'gpt-4o-mini',
    ),
    AIItem(
      name: 'GPT-4o',
      logoPath: 'assets/logo/gpt-4o.png',
      id: 'gpt-4o',
    ),
    AIItem(
      name: 'Gemini 1.5 Flash',
      logoPath: 'assets/logo/gemini-1.5-flash.png',
      id: 'gemini-1.5-flash',
    ),
    AIItem(
      name: 'Gemini 1.5 Pro',
      logoPath: 'assets/logo/gemini-1.5-pro.png',
      id: 'gemini-1.5-pro',
    ),
    AIItem(
      name: 'Claude 3 Haiku',
      logoPath: 'assets/logo/claude-3-haiku.png',
      id: 'claude-3-haiku',
    ),
    AIItem(
      name: 'Claude 3 Sonnet',
      logoPath: 'assets/logo/claude-3-sonnet.png',
      id: 'claude-3-sonnet',
    ),
    AIItem(
      name: 'Deepseek Chat',
      logoPath: 'assets/logo/deepseek.png',
      id: 'deepseek',
    ),
  ];

  late AIItem _selectedAIItem;
  int tokenCount = 30;

  AIChatList() {
    _selectedAIItem = aiItems.first;
  }

  AIItem get selectedAIItem => _selectedAIItem;

  void setSelectedAIItem(AIItem item) {
    _selectedAIItem = item;
    notifyListeners();
  }

  void addAIItem(AIItem newAIItem) {
    aiItems.add(newAIItem);
    notifyListeners();
  }

  AIItem? getAIItemById(String id) {
    try {
      return aiItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  AIItem? getAIItemByName(String name) {
    try {
      return aiItems.firstWhere((item) => item.name == name);
    } catch (e) {
      return null;
    }
  }
}