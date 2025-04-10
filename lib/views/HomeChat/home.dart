import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jarvis/views/Account/account_screen.dart';
import 'package:jarvis/views/Bot/page/bot_screen.dart';
import 'package:jarvis/utils/exceptions/chat_exception.dart';
import 'package:jarvis/models/response/message_response.dart';
import 'package:jarvis/view_models/auth_view_model.dart';
import 'package:jarvis/view_models/prompt_list_view_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:jarvis/core/Widget/dropdown_button.dart';
import 'package:jarvis/view_models/ai_chat_list_view_model.dart';
import 'package:jarvis/view_models/homechat_view_model.dart';
import '../../models/prompt.dart';
import '../EmailChat/email.dart';
import '../Prompt/prompt_screen.dart';
import '../Prompt/widgets/prompt_details.dart';
import 'Widgets/BottomNavigatorBarCustom/custom-bottom-navigator-bar.dart';
import 'Widgets/Menu/menu.dart';
import '../../models/ai_logo.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeChat extends StatefulWidget {
  const HomeChat({super.key});

  @override
  State<HomeChat> createState() => _HomeChatState();
}

class _HomeChatState extends State<HomeChat> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isOpenDeviceWidget = false;
  int _selectedBottomItemIndex = 0;
  String? _selectedImagePath;
  late List<AIItem> _listAIItem;
  late String selectedAIItem;
  bool _hasText = false;
  bool _showSlash = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.isNotEmpty;
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    });
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _isOpenDeviceWidget = false;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserInfo();
    });

    final aiChatList = Provider.of<AIChatList>(context, listen: false);
    _listAIItem = aiChatList.aiItems;
    selectedAIItem = aiChatList.selectedAIItem.name;

    final aiItem = _listAIItem.firstWhere((aiItem) => aiItem.name == selectedAIItem);
    Provider.of<MessageModel>(context, listen: false)
        .fetchAllConversations(aiItem.id, 'dify')
        .then((_) async {
      await Provider.of<MessageModel>(context, listen: false)
          .checkCurrentConversation(aiItem.id);
    });
    Provider.of<MessageModel>(context, listen: false).updateRemainingUsage();
    _refreshPrompts();
  }

  Future<void> _loadUserInfo() async {
    try {
      await Provider.of<AuthViewModel>(context, listen: false).fetchUserInfo();
    } catch (e) {
      if (kDebugMode) print('Error loading user info: $e');
    }
  }

  Future<void> _refreshPrompts() async {
    await Provider.of<PromptListViewModel>(context, listen: false)
        .fetchAllPrompts();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTappedBottomItem(int index) {
    setState(() {
      _selectedBottomItemIndex = index;
    });
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PromptScreen()),
      ).then((_) {
        _refreshPrompts();
      });
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BotScreen()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AccountScreen()),
      );
    }
  }

  void _toggleDeviceVisibility() {
    setState(() {
      _isOpenDeviceWidget = !_isOpenDeviceWidget;
    });
  }

  void _sendMessage() async {
    if (_controller.text.isEmpty && _selectedImagePath == null) return;

    try {
      final aiItem = _listAIItem.firstWhere((aiItem) => aiItem.name == selectedAIItem);
      await Provider.of<MessageModel>(context, listen: false).sendMessage(
        _controller.text,
        aiItem,
      );
      _controller.clear();
      if (_selectedImagePath != null) {
        setState(() {
          _selectedImagePath = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is ChatException ? e.message : 'An error occurred while sending the message',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateSelectedAIItem(String newValue) {
    setState(() {
      selectedAIItem = newValue;
      AIItem aiItem = _listAIItem.firstWhere((aiItem) => aiItem.name == newValue);
      Provider.of<AIChatList>(context, listen: false).setSelectedAIItem(aiItem);
      _listAIItem.removeWhere((aiItem) => aiItem.name == newValue);
      _listAIItem.insert(0, aiItem);
    });
  }

  Widget _buildMessage(Message message) {
    bool isUser = message.role == 'user';
    bool isError = message.isErrored ?? false;

    Future<void> launchURL(String url) async {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot open link: $url')),
        );
      }
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isError
              ? Colors.red[100]
              : (isUser ? Colors.blue[100] : Colors.grey[300]),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Consumer<MessageModel>(builder: (context, messageModel, child) {
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
                  'Processing...',
                  style: TextStyle(
                    color: isError ? Colors.red : Colors.black,
                  ),
                ),
              ],
            );
          }
          return isUser
              ? Text(
            message.content,
            style: TextStyle(color: isError ? Colors.red : Colors.black),
          )
              : MarkdownBody(
            data: message.content,
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(color: isError ? Colors.red : Colors.black),
              a: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              listBullet: TextStyle(color: isError ? Colors.red : Colors.black),
            ),
            selectable: true,
            onTapLink: (text, href, title) {
              if (href != null) {
                launchURL(href);
              }
            },
          );
        }),
      ),
    );
  }

  Future<void> _openGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImagePath = image.path;
        _isOpenDeviceWidget = false;
      });
    }
  }

  Future<void> _openCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedImagePath = image.path;
        _isOpenDeviceWidget = false;
      });
    }
  }

  void _onTextChanged(String input) {
    if (input.isNotEmpty) {
      _showSlash = input.startsWith('/');
    } else {
      _showSlash = false;
    }
  }

  void _openPromptDetailsDialog(BuildContext context, Prompt prompt) {
    PromptDetails.show(
      context,
      itemTitle: prompt.title,
      content: prompt.content,
      category: prompt.category,
      description: prompt.description,
      isPublic: prompt.isPublic,
      isFavorite: prompt.isFavorite,
    ).then((result) {
      if (result != null) {
        if (result.contains('Respond in')) {
          _controller.text = result;
          _sendMessage();
        } else {
          _refreshPrompts();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const Menu(),
      body: Consumer<MessageModel>(
        builder: (context, messageModel, child) {
          return Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () {
                          _scaffoldKey.currentState?.openDrawer();
                        },
                        icon: const Icon(Icons.menu),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.flash_on,
                              color: Colors.orangeAccent,
                            ),
                            Text(
                              '${messageModel.remainingUsage ?? 0}',
                              style: const TextStyle(
                                color: Color.fromRGBO(119, 117, 117, 1.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          Provider.of<MessageModel>(context, listen: false)
                              .clearMessage();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    if (_isOpenDeviceWidget) {
                      _toggleDeviceVisibility();
                    }
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: messageModel.messages.length,
                          itemBuilder: (context, index) {
                            final message = messageModel.messages[index];
                            return _buildMessage(message);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 140,
                              child: AIDropdown(
                                listAIItems: _listAIItem,
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    _updateSelectedAIItem(newValue);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_showSlash)
                        Consumer<PromptListViewModel>(
                          builder: (context, promptList, child) {
                            if (promptList.isLoading) {
                              return const CircularProgressIndicator();
                            } else if (promptList.hasError) {
                              return Text('Có lỗi xảy ra: ${promptList.error}');
                            } else {
                              return Padding(
                                padding: const EdgeInsets.all(5),
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 3 * 2,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color.fromARGB(255, 158, 198, 232),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  constraints: BoxConstraints(
                                      maxHeight: MediaQuery.of(context).size.height / 3),
                                  child: ListView.builder(
                                    itemCount: promptList.allPrompts.items.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        title: Text(promptList.allPrompts.items[index].title),
                                        onTap: () {
                                          _controller.text = "";
                                          _showSlash = false;
                                          _openPromptDetailsDialog(
                                              context, promptList.allPrompts.items[index]);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: _isOpenDeviceWidget
                                ? const Icon(Icons.arrow_back_ios_new)
                                : const Icon(Icons.arrow_forward_ios),
                            onPressed: _toggleDeviceVisibility,
                          ),
                          if (_isOpenDeviceWidget) ...[
                            IconButton(
                              icon: const Icon(Icons.camera_alt),
                              onPressed: _openCamera,
                            ),
                            IconButton(
                              icon: const Icon(Icons.image_rounded),
                              onPressed: _openGallery,
                            ),
                            IconButton(
                              icon: const Icon(Icons.email),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => EmailComposer()),
                                );
                              },
                            ),
                          ],
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey, width: 1),
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.grey[200],
                              ),
                              child: Stack(
                                alignment: Alignment.centerLeft,
                                children: [
                                  TextField(
                                    focusNode: _focusNode,
                                    controller: _controller,
                                    onChanged: _onTextChanged,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.only(left: 10, right: 10),
                                      hintText: (_selectedImagePath == null)
                                          ? 'Enter your message...'
                                          : null,
                                      border: InputBorder.none,
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(50),
                                        borderSide: const BorderSide(color: Colors.grey, width: 1),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(50),
                                        borderSide: const BorderSide(color: Colors.black, width: 1),
                                      ),
                                    ),
                                  ),
                                  if (_selectedImagePath != null)
                                    Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey.withOpacity(0.5),
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.1),
                                              spreadRadius: 1,
                                              blurRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.file(
                                                File(_selectedImagePath!),
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Positioned(
                                              top: -15,
                                              right: -15,
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.close,
                                                  size: 20,
                                                  color: Colors.black54,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _selectedImagePath = null;
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: _hasText || _selectedImagePath != null ? _sendMessage : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedBottomItemIndex,
        onTap: _onTappedBottomItem,
      ),
    );
  }
}