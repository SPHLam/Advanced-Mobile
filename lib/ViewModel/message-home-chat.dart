import 'package:flutter/material.dart';

class MessageModel with ChangeNotifier {
  List<Map<String, String>> _messages = [];
  final List<List<Map<String, String>>> _savedConversations = [];
  int? _currentConversationIndex;

  List<Map<String, String>> get messages => _messages;
  List<List<Map<String, String>>> get savedConversations => _savedConversations;

  void addMessage(Map<String, String> message) {
    if (_currentConversationIndex == null) {
      _savedConversations.add([]);
      _currentConversationIndex = _savedConversations.length - 1;
    }
    _messages.add(message);
    _savedConversations[_currentConversationIndex!] = List.from(_messages);
    notifyListeners();
  }

  void saveConversation() {
    if (_messages.isNotEmpty) {
      if (_currentConversationIndex != null) {
        _savedConversations[_currentConversationIndex!] = List.from(_messages);
      } else {
        _savedConversations.add(List.from(_messages));
      }
      _messages.clear();
      _currentConversationIndex = null;

      notifyListeners();
    }
  }

  void setConversation(List<Map<String, String>> conversation, int index) {
    _messages = List.from(conversation);
    _currentConversationIndex = index;
    notifyListeners();
  }

  void deleteConversation(int index) {
    if (_currentConversationIndex != null) {
      if (_currentConversationIndex == index) {
        _messages = [];
        _currentConversationIndex = null;
      } else if (_currentConversationIndex! > index) {
        _currentConversationIndex = _currentConversationIndex! - 1;
      }
    }

    _savedConversations.removeAt(index);
    notifyListeners();
  }
}