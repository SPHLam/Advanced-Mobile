import 'package:flutter/cupertino.dart';

class KnowledgeBase with ChangeNotifier {
  final List<String> _knowledgeBases = [
    "Document Assistant",
    "Travel Planner",
    "SnapSolver"
  ];

  List<String> get knowledgeBases => _knowledgeBases;

  void addKnowledgeBase(String newKnowledge) {
    _knowledgeBases.add(newKnowledge);
    notifyListeners();
  }
}
