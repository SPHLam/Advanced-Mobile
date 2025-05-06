import 'package:flutter/material.dart';
import 'package:project_ai_chat/services/email_chat_service.dart';
import 'package:project_ai_chat/models/response/email_chat_response.dart';

class EmailChatViewModel extends ChangeNotifier {
  final EmailChatService emailChatService;
  List<String>? ideas;
  String? _emailReply;
  String? get emailReply => _emailReply;
  int? _remainingUsage;
  int? get remainingUsage => _remainingUsage;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  EmailChatViewModel() : emailChatService = EmailChatService();

  Future<List<String>> getEmailSuggestions({
    required String action,
    required String email,
    required String subject,
    required String sender,
    required String receiver,
    required String language,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final ideasSuggest = await emailChatService.suggestEmailIdeas(
        action: action,
        email: email,
        subject: subject,
        sender: sender,
        receiver: receiver,
        language: language,
      );
      ideas = ideasSuggest;
      print('Ý tưởng nhận được: $ideas');
      return ideasSuggest;
    } catch (e) {
      print('Lỗi khi lấy ý tưởng: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return [];
  }

  Future<EmailChatResponse> fetchEmailResponse({
    required String mainIdea,
    required String action,
    required String email,
    required String subject,
    required String sender,
    required String receiver,
    required String language,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await emailChatService.responseEmail(
        mainIdea: mainIdea,
        action: action,
        email: email,
        subject: subject,
        sender: sender,
        receiver: receiver,
        language: language,
      );
      _emailReply = response.email;
      _remainingUsage = response.remainingUsage;
      return response;
    } catch (e) {
      print('Lỗi khi lấy phản hồi email: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
