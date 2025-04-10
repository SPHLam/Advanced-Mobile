import 'package:flutter/material.dart';
import 'package:jarvis/models/ai_logo.dart';
import 'package:jarvis/models/response/assistant_response.dart';
import 'package:jarvis/utils/exceptions/chat_exception.dart';
import 'package:jarvis/models/conversation_model.dart';
import 'package:jarvis/models/response/message_response.dart';
import 'package:jarvis/services/chat_service.dart';

class MessageModel extends ChangeNotifier {
  final List<Message> _messages = [];
  final List<Conversation> _conversations = [];
  final ChatService _chatService;
  String? _currentConversationId;
  int? _remainingUsage;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSending = false;

  MessageModel(this._chatService);

  String? _cursorConversation;
  bool _hasMoreConversation = true;
  bool _isFirstMessageSent = false;

  int? get remainingUsage => _remainingUsage;
  List<Message> get messages => _messages;
  List<Conversation> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSending => _isSending;
  bool get hasMoreConversation => _hasMoreConversation;

  Future<void> initializeChat(String assistantId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _messages.clear();
      _currentConversationId = null;
      _isFirstMessageSent = false;

      await updateRemainingUsage();

      notifyListeners();
    } catch (e) {
      print('❌ Error in initializing chat: $e');
      _errorMessage = e is ChatException ? e.message : 'Lỗi khởi tạo chat: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkCurrentConversation(String assistantId) async {
    if (conversations.isEmpty) {
      await initializeChat(assistantId);
    } else {
      await loadConversationHistory(assistantId, conversations.first.id);
    }
  }

  Future<void> createNewChat(String assistantId, String content) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _chatService.fetchAIChat(
        content: content,
        assistantId: assistantId,
      );

      print('✅ Create new chat response:');
      print('Message: ${response.message}');
      print('Remaining Usage: ${response.remainingUsage}');

      _messages.removeLast();
      _messages.add(Message(
        role: 'model',
        content: response.message,
        assistant: Assistant(
          id: assistantId,
          model: "dify",
          name: "AI Assistant",
        ),
        isErrored: false,
      ));

      _currentConversationId = response.conversationId;
      _remainingUsage = response.remainingUsage;
      notifyListeners();
    } catch (e) {
      print('❌ Error in creating new chat: $e');
      _messages.add(Message(
        role: 'model',
        content: e is ChatException ? e.message : 'Lỗi tạo chat mới: ${e.toString()}',
        assistant: Assistant(
          id: assistantId,
          model: "dify",
          name: "AI Assistant",
        ),
        isErrored: true,
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _removeHttpPrefix(String url) {
    return url.replaceAll(RegExp(r'^(https?:\/\/)?(www\.)?'), '');
  }

  Future<void> sendMessage(String content, AIItem assistant) async {
    try {
      _isSending = true;
      notifyListeners();

      _messages.add(Message(
        role: 'user',
        content: content,
        assistant: Assistant(
          id: assistant.id,
          model: "dify",
          name: assistant.name,
        ),
        isErrored: false,
      ));

      _messages.add(Message(
        role: 'model',
        content: '',
        assistant: Assistant(
          id: assistant.id,
          model: "dify",
          name: assistant.name,
        ),
        isErrored: false,
      ));
      notifyListeners();

      if (!_isFirstMessageSent) {
        await createNewChat(assistant.id, content);
        _isFirstMessageSent = true;
        await fetchAllConversations(assistant.id, "dify");
        notifyListeners();
        return;
      }

      final response = await _chatService.sendMessage(
        content: content,
        assistantId: assistant.id,
        conversationId: _currentConversationId,
        previousMessages: _messages,
      );

      String processedMessage = response.message;
      final RegExp pattern = RegExp(r'(\d+\.\s+)([^-\n]+)-\s*(https?:\/\/[^\n]+)\n([^\n]+)');
      processedMessage = processedMessage.replaceAllMapped(pattern, (match) {
        final number = match[1];
        final name = match[2];
        final url = _removeHttpPrefix(match[3]!);
        final desc = match[4];
        return '''$number$name- $url
  • $desc

''';
      });

      _messages.removeLast();
      _messages.add(Message(
        role: 'model',
        content: processedMessage,
        assistant: Assistant(
          id: assistant.id,
          model: "dify",
          name: assistant.name,
        ),
        isErrored: false,
      ));

      _currentConversationId = response.conversationId;
      _remainingUsage = response.remainingUsage;
    } catch (e) {
      _messages.removeLast();
      _messages.add(Message(
        role: 'model',
        content: e is ChatException
            ? (e.statusCode == 500
            ? 'Lỗi máy chủ. Vui lòng thử lại sau.'
            : e.message)
            : 'Lỗi gửi tin nhắn: ${e.toString()}',
        assistant: Assistant(
          id: assistant.id,
          model: "dify",
          name: assistant.name,
        ),
        isErrored: true,
      ));
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllConversations(String assistantId, String assistantModel,
      {bool isLoadMore = false}) async {
    if (isLoadMore && !_hasMoreConversation) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (!isLoadMore) {
      _cursorConversation = null;
      _hasMoreConversation = true;
    }

    final response = await _chatService.getAllConversations(
        assistantId, assistantModel, _cursorConversation);

    if (response.success && response.data != null) {
      if (!isLoadMore) _conversations.clear();
      _conversations.addAll(
        (response.data['items'] as List<dynamic>)
            .map((item) => Conversation.fromJson(item)),
      );
      _cursorConversation = response.data['cursor'];
      _hasMoreConversation = response.data['has_more'];
    } else {
      _errorMessage = response.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadConversationHistory(String assistantId, String conversationId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _chatService.fetchConversationHistory(
        conversationId: conversationId,
        assistantId: assistantId,
      );

      _messages.clear();
      _currentConversationId = conversationId;

      for (var message in response.items) {
        _messages.add(Message(
          role: 'user',
          content: message.query,
          assistant: Assistant(
            id: assistantId,
            model: "dify",
            name: "AI Assistant",
          ),
          isErrored: false,
        ));
        _messages.add(Message(
          role: 'model',
          content: message.answer,
          assistant: Assistant(
            id: assistantId,
            model: "dify",
            name: "AI Assistant",
          ),
          isErrored: false,
        ));
      }
    } catch (e) {
      print('❌ Error loading conversation history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearMessage() {
    _messages.clear();
    _isFirstMessageSent = false;
    notifyListeners();
  }

  Future<void> updateRemainingUsage() async {
    try {
      final tokenUsageResponse = await _chatService.fetchTokenUsage();
      if (tokenUsageResponse.availableTokens >= 0) {
        _remainingUsage = tokenUsageResponse.availableTokens;
        print('✅ Token usage fetched: $_remainingUsage');
      } else {
        _errorMessage = 'Invalid token quantity';
      }
      notifyListeners();
    } catch (e) {
      print('❌ Error fetching token usage: $e');
      _errorMessage = e is ChatException ? e.message : 'Update token error';
      notifyListeners();
    }
  }
}