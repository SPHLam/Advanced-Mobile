import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:project_ai_chat/views/HomeChat/Widgets/input_message.dart';
import 'package:project_ai_chat/views/Prompt/widgets/prompt_details.dart';
import 'package:project_ai_chat/models/response/my_aibot_message_response.dart';
import 'package:project_ai_chat/utils/exceptions/chat_exception.dart';
import 'package:project_ai_chat/viewmodels/bot_view_model.dart';
import 'package:project_ai_chat/viewmodels/auth_view_model.dart';
import 'package:project_ai_chat/viewmodels/prompt_list_view_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:screenshot/screenshot.dart';
import '../../models/prompt.dart';

class ChatWidget extends StatefulWidget {
  final bool isPreview;
  const ChatWidget({super.key, this.isPreview = false});
  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final _scrollController = ScrollController();
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _screenshotController = ScreenshotController();
  var _hasText = false;
  var _showSlash = false;
  var _isOpenDeviceWidget = false;
  List<String>? _files;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() => _hasText = _controller.text.isNotEmpty));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PromptListViewModel>().fetchAllPrompts();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged(String input) => setState(() {
    _hasText = input.isNotEmpty;
    _showSlash = input.startsWith('/');
  });

  void _openPromptDetailsDialog(BuildContext context, Prompt prompt) {
    PromptDetails.show(context, promptId: prompt.id, itemTitle: prompt.title, content: prompt.content, category: prompt.category, description: prompt.description, language: prompt.language, isPublic: prompt.isPublic, isFavorite: prompt.isFavorite).then((result) {
      if (result == null) return;
      if (result['action'] == 'send') {
        setState(() {
          _controller.text = result['content'];
          _sendMessage(result['content'], null);
          _showSlash = false;
        });
      } else if (result['action'] == 'update') {
        context.read<PromptListViewModel>().fetchAllPrompts();
      }
    });
  }

  Future<void> _sendMessage(String content, List<String>? files) async {
    try {
      await context.read<BotViewModel>().askAssistant(content, files: files);
      _controller.clear();
      setState(() => _files = null);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e is ChatException ? e.message : 'Error occurred when sending the message.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cannot open URL: $url')));
    }
  }

  Widget _buildMessage(MyAiBotMessage message) {
    final isUser = message.role == 'user';
    final isError = message.isErrored ?? false;
    final botViewModel = context.read<BotViewModel>();
    final authViewModel = context.read<AuthViewModel>();
    final username = authViewModel.user?.username ?? 'User';
    final firstLetter = username.isNotEmpty ? username[0].toUpperCase() : '';
    final assistantName = botViewModel.currentChatBot.assistantName;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                isUser
                    ? CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.blue,
                  child: Text(firstLetter, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
                    : const CircleAvatar(
                  radius: 15,
                  backgroundImage: AssetImage('assets/logo/default-bot.png'),
                ),
                const SizedBox(width: 8),
                Text(isUser ? username : assistantName, style: TextStyle(fontWeight: FontWeight.bold, color: isError ? Colors.red : Colors.black)),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isError ? Colors.red[100] : isUser ? Colors.blue[100] : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Consumer<BotViewModel>(
                builder: (context, messageModel, _) => !isUser && message.content.isEmpty && messageModel.isSending
                    ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.blue))),
                    SizedBox(width: 8),
                    Text('Loading...'),
                  ],
                )
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isUser && message.files?.isNotEmpty == true) ...[
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: message.files!.map((path) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(File(path), width: 100, height: 100, fit: BoxFit.cover),
                            ),
                          )).toList(),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    isUser
                        ? Text(message.content, style: TextStyle(color: isError ? Colors.red : Colors.black))
                        : MarkdownBody(
                      data: message.content,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(color: isError ? Colors.red : Colors.black),
                        a: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                        listBullet: TextStyle(color: isError ? Colors.red : Colors.black),
                      ),
                      selectable: true,
                      onTapLink: (text, href, title) => href != null ? _launchURL(href) : null,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Consumer<BotViewModel>(
            builder: (context, messageModel, _) => ListView.builder(
              controller: _scrollController,
              itemCount: messageModel.myAiBotMessages.length,
              itemBuilder: (context, index) => _buildMessage(messageModel.myAiBotMessages[index]),
            ),
          ),
        ),
        if (_showSlash && !widget.isPreview)
          Consumer<PromptListViewModel>(
            builder: (context, promptList, _) => promptList.isLoading
            ? const CircularProgressIndicator()
            : promptList.hasError
              ? Text('Error occur: ${promptList.error}')
              : Container(
                width: MediaQuery.of(context).size.width * 2 / 3,
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF9EC6E8)),
                  borderRadius: BorderRadius.circular(20),
                ),
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 3),
                child: ListView.builder(
                  itemCount: promptList.allPrompts.items.length,
                  itemBuilder: (context, index) {
                    final prompt = promptList.allPrompts.items[index];
                    return ListTile(
                      title: Text(prompt.title),
                      onTap: () {
                        _controller.clear();
                        _showSlash = false;
                        _openPromptDetailsDialog(context, prompt);
                      },
                    );
                  },
                ),
              ),
          ),
        if (widget.isPreview)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: null,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    hintText: 'Enter your message...',
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFFEEF0F3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.5), width: 0.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.5), width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.blue, width: 0.5),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _hasText ? () => _sendMessage(_controller.text, null) : null,
                color: _hasText ? Colors.black : Colors.grey,
              ),
            ],
          )
        else
          InputWidget(
            controller: _controller,
            focusNode: _focusNode,
            isOpenDeviceWidget: _isOpenDeviceWidget,
            toggleDeviceVisibility: () => setState(() => _isOpenDeviceWidget = !_isOpenDeviceWidget),
            sendMessage: _sendMessage,
            onTextChanged: _onTextChanged,
            hasText: _hasText,
            updateImagePaths: (paths) => setState(() => _files = paths),
            screenshotController: _screenshotController,
          ),
        const SizedBox(height: 5),
      ],
    );
  }
}