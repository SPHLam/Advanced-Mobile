import 'package:flutter/cupertino.dart';

import '../models/ai_logo.dart';

class AIChatList extends ChangeNotifier {
  List<AIItem> aiItems = [
    AIItem(
      id: 'gpt-4o-mini',
      name: 'GPT-4o mini',
      logoPath: 'assets/logo/gpt-4o-mini.png',
      price: '1',
    ),
    AIItem(
      id: 'gpt-4o',
      name: 'GPT-4o',
      logoPath: 'assets/logo/gpt-4o.png',
      price: '5',
    ),
    AIItem(
      id: 'gemini-1.5-flash-latest',
      name: 'Gemini 1.5 Flash',
      logoPath: 'assets/logo/gemini-1.5-flash.png',
      price: '1',
    ),
    AIItem(
      id: 'gemini-1.5-pro-latest',
      name: 'Gemini 1.5 Pro',
      logoPath: 'assets/logo/gemini-1.5-pro.png',
      price: '5',
    ),
    AIItem(
      id: 'claude-3-haiku-20240307',
      name: 'Claude 3 Haiku',
      logoPath: 'assets/logo/claude-3-haiku.png',
      price: '1',
    ),
    AIItem(
      id: 'claude-3-sonnet-20240229',
      name: 'Claude 3 Sonnet',
      logoPath: 'assets/logo/claude-3-sonnet.png',
      price: '3',
    ),
    AIItem(
      id: 'deepseek',
      name: 'Deepseek Chat',
      logoPath: 'assets/logo/deepseek.png',
      price: '1',
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
