import 'package:flutter/material.dart';
import 'package:jarvis/models/ai_logo.dart';
import 'package:jarvis/models/response/assistant_response.dart';
import 'package:jarvis/models/response/chat_response.dart';
import 'package:jarvis/utils/exceptions/chat_exception.dart';
import 'package:jarvis/models/conversation_model.dart';
import 'package:jarvis/models/response/message_response.dart';
import 'package:jarvis/services/chat_service.dart';

class MessageModel extends ChangeNotifier {
  final List<Message> _messages = [];
  final List<Conversation> _conversations = [];
  final ChatService _chatService;
  String? _currentConversationId;
  int _remainingUsage = 30;
  int? _maxTokens;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSending = false;
  MessageModel(this._chatService);

  // load more conversations
  String? _cursorConversation;
  bool _hasMoreConversation = true;

  // Thêm biến để theo dõi trạng thái gửi tin nhắn đầu tiên
  bool _isFirstMessageSent = false;

  int get remainingUsage => _remainingUsage;
  int? get maxTokens => _maxTokens;
  List<Message> get messages => _messages;
  List<Conversation> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSending => _isSending;

  // load more conversations
  bool get hasMoreConversation => _hasMoreConversation;

  //Định nghĩa cho tối đa tokens
  final int unlimitedTokens = 99999;

  Future<void> initializeChat(String assistantId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _messages.clear();
      _currentConversationId = null;

      final response = await _chatService.fetchAIChat(
        content: "Hi",
        assistantId: assistantId,
      );

      print('✅ Initial chat response:');
      print('Message: ${response.message}');
      print('Remaining Usage: ${response.remainingUsage}');

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
      _isFirstMessageSent = true;
      notifyListeners();
    } catch (e) {
      print('❌ Error in initializing chat:');
      if (e is ChatException) {
        print('Status: ${e.statusCode}');
        print('Message: ${e.message}');
      } else {
        print('Unexpected error: $e');
      }

      _messages.add(Message(
        role: 'model',
        content: e is ChatException
            ? e.message
            : 'Lỗi không xác định khi khởi tạo chat: ${e.toString()}',
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

  Future<void> checkCurrentConversation(String assistantId) async {
    if (conversations.isEmpty)
      initializeChat(assistantId);
    else {
      loadConversationHistory(assistantId, conversations.first.id);
    }
  }

  Future<void> createNewChat(String assistantId, String content) async {
    try {
      _isLoading = true;
      notifyListeners();

      _currentConversationId = null;

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
      print('❌ Error in initializing chat:');
      if (e is ChatException) {
        print('Status: ${e.statusCode}');
        print('Message: ${e.message}');
      } else {
        print('Unexpected error: $e');
      }

      _messages.add(Message(
        role: 'model',
        content: e is ChatException
            ? e.message
            : 'Lỗi không xác định khi khởi tạo chat: ${e.toString()}',
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

  Future<void> sendMessage(String content, AIItem assistant,
      {List<String>? imagePaths}) async {
    try {
      _isSending = true;

      // Nếu đây là tin nhắn đầu tiên, gọi createNewChat
      if (!_isFirstMessageSent) {
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
          content: '', // Nội dung rỗng
          assistant: Assistant(
            id: assistant.id,
            model: "dify",
            name: assistant.name,
          ),
          isErrored: false,
        ));
        await createNewChat(assistant.id, content);
        fetchAllConversations(assistant.id, "dify");
        notifyListeners();
        _isFirstMessageSent = true; // Đánh dấu đã gửi tin nhắn đầu tiên
        return; // Kết thúc phương thức
      }

      // Thêm tin nhắn của user
      _messages.add(Message(
        role: 'user',
        content: content,
        imagePaths: imagePaths,
        assistant: Assistant(
          id: assistant.id,
          model: "dify",
          name: assistant.name,
        ),
        isErrored: false,
      ));

      // Thêm tin nhắn tạm thời cho model (để hiển thị loading)
      _messages.add(Message(
        role: 'model',
        content: '', // Nội dung rỗng
        assistant: Assistant(
          id: assistant.id,
          model: "dify",
          name: assistant.name,
        ),
        isErrored: false,
      ));
      notifyListeners();
      ChatResponse response;
      // Gửi tin nhắn hoặc hình ảnh
      if (imagePaths != null && imagePaths.isNotEmpty) {
        response = await _chatService.sendImageMessages(
          content: content,
          imagePaths: imagePaths,
          assistantId: assistant.id,
          conversationId: _currentConversationId,
          previousMessages: _messages,
        );
      } else {
        response = await _chatService.sendMessage(
          content: content,
          assistantId: assistant.id,
          conversationId: _currentConversationId,
          previousMessages: _messages,
        );
      }
      // Xử lý response.message để thêm bullet points và format markdown
      String processedMessage = response.message;

      // Xử lý pattern dạng "1. Tên - URL\nMô tả"
      final RegExp pattern =
          RegExp(r'(\d+\.\s+)([^-\n]+)-\s*(https?:\/\/[^\n]+)\n([^\n]+)');
      processedMessage = processedMessage.replaceAllMapped(pattern, (match) {
        final number = match[1]; // Số thứ tự (1.)
        final name = match[2]; // Tên website
        final url = _removeHttpPrefix(match[3]!); // URL
        final desc = match[4]; // Mô tả

        return '''$number$name- $url • $desc''';
      });

      _messages.removeLast(); // Xóa tin nhắn tạm
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
      // Xử lý lỗi: thay thế tin nhắn tạm bằng tin nhắn lỗi
      _messages.removeLast(); // Xóa tin nhắn tạm

      if (e is ChatException) {
        _messages.add(Message(
          role: 'model',
          content: e.statusCode == 500
              ? 'Internal server error when sending message'
              : e.message,
          assistant: Assistant(
            id: assistant.id,
            model: "dify",
            name: "AI Assistant",
          ),
          isErrored: true,
        ));
      } else {
        _messages.add(Message(
          role: 'model',
          content: 'Unknown error when sending message: ${e.toString()}',
          assistant: Assistant(
            id: assistant.id,
            model: "dify",
            name: "AI Assistant",
          ),
          isErrored: true,
        ));
      }
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllConversations(String assistantId, String assistantModel,
      {bool isLoadMore = false}) async {
    if (isLoadMore && _hasMoreConversation == false) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (isLoadMore == false) {
      _cursorConversation = null;
      _hasMoreConversation = true;
    }

    final response = await _chatService.getAllConversations(
        assistantId, assistantModel, _cursorConversation);

    if (response.success && response.data != null) {
      if (isLoadMore == false) {
        _conversations.clear();
      }
      _conversations.addAll(
        (response.data['items'] as List<dynamic>)
            .map((item) => Conversation.fromJson(item)),
      );
      _cursorConversation = response.data['cursor'];
      _hasMoreConversation = response.data['has_more'];
      _isLoading = false;
      notifyListeners();
    } else {
      _isLoading = false;
      _errorMessage = response.message;
      notifyListeners();
      // logout();
      // throw response;
    }
  }

  Future<void> loadConversationHistory(
      String assistantId, String conversationId,
      {bool? isClearMessage}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _chatService.fetchConversationHistory(
        conversationId: conversationId,
        assistantId: assistantId,
      );
      if (isClearMessage == true || isClearMessage == null) {
        _messages.clear();
      }
      // Xóa tin nhắn cũ trước khi thêm lịch sử mới
      _currentConversationId =
          conversationId; // Cập nhật ID cuộc hội thoại hiện tại

      // Xử lý messages nhận được
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
      // Xử lý lỗi tương tự như các method khác
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Xóa đoạn chat khi chọn new chat
  void clearMessage() {
    _messages.clear(); // Xóa tất cả tin nhắn
    _isFirstMessageSent = false; // Đặt lại trạng thái gửi tin nhắn đầu tiên
    notifyListeners(); // Cập nhật giao diện
  }

  Future<void> updateRemainingUsage() async {
    try {
      final tokenUsageResponse = await _chatService.fetchTokenUsage();
      if (tokenUsageResponse.unlimited) {
        _maxTokens = unlimitedTokens;
        return;
      } else {
        _remainingUsage = tokenUsageResponse.availableTokens;
        _maxTokens = null;
        print('✅ Token usage fetched successfully: $_remainingUsage');
      }
      notifyListeners();
    } catch (e) {
      print('❌ Error fetching token usage: $e');
      if (e is ChatException) {
        //_errorMessage = e.message;
        notifyListeners();
      }
    }
  }
}
