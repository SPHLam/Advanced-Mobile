import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_ai_chat/models/bot.dart';
import 'package:project_ai_chat/models/bot_request.dart';
import 'package:project_ai_chat/models/knowledge.dart';
import 'package:project_ai_chat/models/response/my_aibot_message_response.dart';
import 'package:project_ai_chat/services/bot_service.dart';
import 'package:project_ai_chat/services/chat_service.dart';
import 'package:project_ai_chat/utils/exceptions/chat_exception.dart';
import '../models/bot_list.dart';

class BotViewModel extends ChangeNotifier {
  final BotService _service = BotService();
  final ChatService _chatService = ChatService();
  BotList _botList = BotList.empty();

////  Chat with My AI-BOT

  bool _isChatWithMyBot = false;
  final List<MyAiBotMessage> _myAiBotMessages = [];
  Bot _currentBot = Bot.empty();
  Bot _currentChatBot = Bot.empty();
  String _currentOpenAiThreadId = "";
  bool _isSending = false;
  List<Knowledge> _knowledgeList = [];
  bool _isPreview = false;
  int _remainingUsage = 50;

  bool get isChatWithMyBot => _isChatWithMyBot;
  int get remainingUsage => _remainingUsage;
  List<MyAiBotMessage> get myAiBotMessages => _myAiBotMessages;
  Bot get currentBot => _currentBot;
  Bot get currentChatBot => _currentChatBot;
  bool get isSending => _isSending;
  List<Knowledge> get knowledgeList => _knowledgeList;
  bool get isPreview => _isPreview;

  set isChatWithMyBot(bool value) {
    _isChatWithMyBot = value;
    notifyListeners();
  }

  set currentBot(Bot bot) {
    _currentBot = bot;
    notifyListeners();
  }

  set currentChatBot(Bot bot) {
    _currentChatBot = bot;
    notifyListeners();
  }

  set isPreview(bool value) {
    _isPreview = value;
    notifyListeners();
  }

  /////

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? error;

  // Thông tin phân trang
  int _limit = 10;
  int _offset = 0;
  bool _hasNext = true;

  String _query = '';
  bool _isCreated = false;

  BotList get botList => _botList;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasError => error != null;
  bool get hasNext => _hasNext;
  String get query => _query;
  bool get isCreated => _isCreated;

  set query(String value) {
    if (_query != value) {
      _query = value;
      fetchBots();
      notifyListeners();
    }
  }

  BotRequest botRequest = BotRequest(
    assistantName: 'My AI Assistant',
    instructions: 'Help users solve problems.',
    description: 'A test bot for demonstration.',
  );

  Future<bool> fetchBots() async {
    if (_isLoading) return false;

    _isLoading = true;

    _offset = 0; // Reset lại offset
    _botList = BotList.empty(); // Xóa dữ liệu cũ
    _hasNext = true;

    print('✅ Dô view model rồi nề');

    notifyListeners();

    print('✅ Qua notify rồi');

    try {
      final result = await _service.fetchBots(
          query: _query, limit: _limit, offset: _offset);

      print('✅ Lấy result rồi: $result');
      // Cập nhật danh sách và trạng thái phân trang
      _botList = result;
      print('✅ RESPONSE BOTS DATA IN BOT VIEW MODEL: $_botList');
      _hasNext = result.hasNext;
      _offset += _limit;
    } catch (e) {
      error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return true;
  }

  Future<void> loadMoreBots() async {
    if (_isLoadingMore || !_hasNext) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _service.fetchBots(
          query: _query, limit: _limit, offset: _offset);

      // Cập nhật danh sách và trạng thái phân trang
      _botList.data.addAll(result.data);
      _hasNext = result.hasNext;
      _offset += _limit;
    } catch (e) {
      error = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<bool> createBot(BotRequest newBot) {
    return _service.createBot(newBot);
  }

  Future<bool> deleteBot(String id) {
    return _service.deleteBot(id);
  }

  Future<bool> updateBot(BotRequest newBot, String id) {
    return _service.updateBot(newBot, id);
  }

  String _removeHttpPrefix(String url) {
    return url.replaceAll(RegExp(r'^(https?:\/\/)?(www\.)?'), '');
  }

  Future<void> askAssistant(String message, {List<String>? files}) async {
    try {
      _isSending = true;

      // Thêm tin nhắn của user
      _myAiBotMessages.add(MyAiBotMessage(
        role: 'user',
        content: message,
        files: files,
        isErrored: false,
      ));

      // Thêm tin nhắn tạm thời cho model (để hiển thị loading)
      _myAiBotMessages.add(MyAiBotMessage(
        role: 'model',
        content: '', // Nội dung rỗng
        isErrored: false,
      ));
      notifyListeners();

      String processedMessage;
      if (_isPreview) {
        // _currentOpenAiThreadId = _currentBot.openAiThreadIdPlay;
        processedMessage = await _service.askAssistant(_currentBot.id, message);
      } else {
        // _currentOpenAiThreadId = await _service.getThread(_currentChatBot.id);
        final response = await _chatService.sendMessage(
          content: message,
          files: files,
          assistantId: _currentChatBot.id,
          model: "knowledge-base",
        );
        processedMessage = response.message;
        _remainingUsage = response.remainingUsage;
      }

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

      _myAiBotMessages.removeLast(); // Xóa tin nhắn tạm
      _myAiBotMessages.add(MyAiBotMessage(
        role: 'model',
        content: processedMessage,
        isErrored: false,
      ));
    } catch (e) {
      // Xử lý lỗi: thay thế tin nhắn tạm bằng tin nhắn lỗi
      _myAiBotMessages.removeLast(); // Xóa tin nhắn tạm

      if (e is ChatException) {
        _myAiBotMessages.add(MyAiBotMessage(
          role: 'model',
          content: e.statusCode == 500
              ? 'Internal server error when sending message'
              : e.message,
          isErrored: true,
        ));
      } else {
        _myAiBotMessages.add(MyAiBotMessage(
          role: 'model',
          content: 'Unknown error when sending message: ${e.toString()}',
          isErrored: true,
        ));
      }
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> loadConversationHistory() async {
    try {
      _isLoading = true;
      notifyListeners();
      // if (_isPreview) {
      //   _currentOpenAiThreadId = _currentBot.openAiThreadIdPlay;
      // } else {
      //   _currentOpenAiThreadId = await _service.getThread(_currentChatBot.id);
      // }
      // List<MyAiBotMessage>? response =
      //     await _service.retrieveMessageOfThread(_currentOpenAiThreadId);

      _myAiBotMessages.clear(); // Xóa tin nhn cũ trước khi thêm lịch sử mới

      // if (response != null) {
      //   // Xử lý messages nhận được
      //   for (int i = response.length - 1; i >= 0; i--) {
      //     var message = response[i];
      //     _myAiBotMessages.add(MyAiBotMessage(
      //       role: message.role,
      //       content: message.content,
      //       isErrored: false,
      //     ));
      //   }
      // }
    } catch (e) {
      print('❌ Error loading conversation history: $e');
      // Xử lý lỗi tương tự như các method khác
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> importKnowledge(String knowledgeId) async {
    bool response =
        await _service.importKnowledgeToAiBot(currentBot.id, knowledgeId);
    if (response) {
      getImportedKnowledge(currentBot.id);
      return true;
    }
    return false;
  }

  Future<void> getImportedKnowledge(String assistantId) async {
    final response = await _service.getImportedKnowledge(assistantId);
    _knowledgeList = response;
    notifyListeners();
  }

  Future<bool> removeKnowledge(String knowledgeId) async {
    bool response =
        await _service.removeKnowledgeFromAiBot(currentBot.id, knowledgeId);
    if (response) {
      getImportedKnowledge(currentBot.id);
      return true;
    }
    return false;
  }

  // Future<bool> updateAiBotWithThreadPlayGround() async {
  //   Bot response =
  //       await _service.updateAiBotWithThreadPlayGround(currentBot.id);
  //   if (response.id != '') {
  //     currentBot = response;
  //     _myAiBotMessages.clear();
  //     notifyListeners();
  //     return true;
  //   }
  //   return false;
  // }

  Future<bool> publishToSlack(String assistantId, String botToken, String clientId, String clientSecret, String signingSecret) async {
    _isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _service.publishToSlack(assistantId, botToken, clientId, clientSecret, signingSecret);
      if (response.success) {
        await Clipboard.setData(ClipboardData(text: response.data['redirect']));
        return true;
      } else {
        error = response.message;
        return false;
      }
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> publishToTelegram(String assistantId, String botToken) async {
    _isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _service.publishToTelegram(assistantId, botToken);
      if (response.success) {
        await Clipboard.setData(ClipboardData(text: response.data['redirect']));
        return true;
      } else {
        error = response.message;
        return false;
      }
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> publishToMessenger(String assistantId, String botToken, String pageId, String appSecret) async {
    _isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _service.publishToMessenger(assistantId, botToken, pageId, appSecret);
      if (response.success) {
        await Clipboard.setData(ClipboardData(text: response.data['redirect']));
        return true;
      } else {
        error = response.message;
        return false;
      }
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
