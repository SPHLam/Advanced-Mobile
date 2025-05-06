import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:project_ai_chat/models/response/my_aibot_message_response.dart';
import 'package:project_ai_chat/utils/exceptions/chat_exception.dart';
import 'package:project_ai_chat/viewmodels/bot_view_model.dart';
import 'package:project_ai_chat/viewmodels/auth_view_model.dart';


import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';


class ChatWidget extends StatefulWidget {
  final bool isPreview;

  const ChatWidget({Key? key, this.isPreview = false}) : super(key: key);

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();

    //Provider.of<BotViewModel>(context, listen: false).isPreview = widget.isPreview;

    //Lắng nghe ô nhập dữ liệu
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.isNotEmpty;
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    });
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   Provider.of<BotViewModel>(context, listen: false).isPreview = widget.isPreview;
  // }

  @override
  Widget build(BuildContext context) {
    final messageModel = context.watch<BotViewModel>();
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: messageModel.myAiBotMessages.length,
            itemBuilder: (context, index) {
              final message = messageModel.myAiBotMessages[index];
              return _buildMessage(message);
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromARGB(255, 238, 240, 243),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.5),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _controller,
                      maxLines: null,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        hintText: 'Enter your message...',
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.grey, width: 1),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.5),
                            width: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _hasText ? _sendMessage : null,
              style: IconButton.styleFrom(
                foregroundColor: _hasText ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
      ],
    );
  }

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    try {
      Provider.of<BotViewModel>(context, listen: false)
          .askAssistant(_controller.text.isEmpty ? '' : _controller.text);
      _controller.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is ChatException ? e.message : 'Có lỗi xảy ra khi gửi tin nhắn',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildMessage(MyAiBotMessage message) {
    bool isUser = message.role == 'user';
    bool isError = message.isErrored ?? false;

    // Lấy thông tin từ BotViewModel
    final botViewModel = Provider.of<BotViewModel>(context, listen: false);
    // Lấy thông tin người dùng từ AuthViewModel
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    // Username và avatar
    final String username = authViewModel.user?.username ?? 'User';
    final String firstLetter = username.isNotEmpty ? username[0].toUpperCase() : '';

    // Tên assistant
    final String assistantName = botViewModel.currentChatBot.assistantName;

    Future<void> _launchURL(String url) async {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot open URL: $url')),
        );
      }
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                isUser ? Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: Center(
                    child: Text(
                      firstLetter,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
                : ClipOval(child: Image.asset(
                    'assets/logo/default-bot.png',
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover,
                  )
                ),
                const SizedBox(width: 8),
                // Tên
                Text(
                  isUser ? username : assistantName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isError ? Colors.red : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Nội dung tin nhắn
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: isError
                    ? Colors.red[100]
                    : (isUser ? Colors.blue[100] : Colors.grey[200]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Consumer<BotViewModel>(
                builder: (context, messageModel, child) {
                  // Hiển thị loading nếu là tin nhắn model rỗng và đang trong trạng thái gửi
                  if (!isUser && message.content.isEmpty && messageModel.isSending) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Loading...',
                          style: TextStyle(
                            color: isError ? Colors.red : Colors.black,
                          ),
                        ),
                      ],
                    );
                  }

                  // Sử dụng Markdown widget cho tin nhắn model
                  return Column(
                    children: [
                      isUser
                          ? Text(
                        message.content,
                        style: TextStyle(
                          color: isError ? Colors.red : Colors.black,
                        ),
                      )
                          : MarkdownBody(
                        data: message.content,
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(
                            color: isError ? Colors.red : Colors.black,
                          ),
                          a: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          listBullet: TextStyle(
                            color: isError ? Colors.red : Colors.black,
                          ),
                        ),
                        selectable: true,
                        onTapLink: (text, href, title) {
                          if (href != null) {
                            _launchURL(href);
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
