import 'package:flutter/foundation.dart';
import 'package:jarvis/models/prompt_model.dart';
import 'package:jarvis/models/prompt_list.dart';
import '../services/prompt_service.dart';

class PromptListViewModel extends ChangeNotifier {
  final PromptService _service = PromptService();
  PromptList allPrompts = PromptList.empty();
  bool _isLoading = false;
  String? error;

  PromptRequest pr = PromptRequest(
      query: "",
      offset: 0,
      limit: 100,
      category: "",
      isFavorite: false,
      isPublic: true);

  bool get isLoading => _isLoading;
  bool get hasError => error != null;

  Future<PromptList> fetchAllPrompts() async {
    _isLoading = true;
    notifyListeners();
    allPrompts = await _service.fetchAllPrompts();
    _isLoading = false;
    notifyListeners();
    return allPrompts;
  }

  Future<PromptList> fetchPrompts({
    required String category,
    String query = '',
    bool isFavorite = false,
    required bool isPublic,
  }) async {
    _isLoading = true;
    notifyListeners();
    pr = pr.copyWith(
        category: category,
        query: query,
        isFavorite: isFavorite,
        isPublic: isPublic);
    if (kDebugMode) {
      print("-------------------->>>>>>> ${pr.category}");
    }
    var result = await _service.fetchPrompts(pr);
    pr = pr.copyWith(limit: result.total);
    result = await _service.fetchPrompts(pr);
    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<bool> toggleFavorite(String promptId, bool isFavorite) {
    return _service.toggleFavorite(promptId, isFavorite);
  }

  Future<bool> createPrompt(PromptRequest newPrompt) {
    return _service.createPrompt(newPrompt);
  }

  Future<bool> deletePrompt(String id) {
    return _service.deletePrompt(id);
  }

  Future<bool> updatePrompt(PromptRequest newPrompt, String promptId) {
    return _service.updatePrompt(newPrompt, promptId);
  }
}
