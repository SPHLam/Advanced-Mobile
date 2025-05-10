import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:project_ai_chat/viewmodels/emailchat_view_model.dart';
import 'package:project_ai_chat/views/Account/pages/account_screen.dart';
import 'package:project_ai_chat/views/Bot/page/bot_screen.dart';
import 'package:project_ai_chat/core/Widget/chat_widget.dart';
import 'package:project_ai_chat/utils/exceptions/chat_exception.dart';
import 'package:project_ai_chat/viewmodels/auth_view_model.dart';
import 'package:project_ai_chat/viewmodels/bot_view_model.dart';
import 'package:project_ai_chat/viewmodels/knowledge_base_view_model.dart';
import 'package:project_ai_chat/viewmodels/prompt_list_view_model.dart';
import 'package:project_ai_chat/services/iap_service.dart';
import '../../core/Widget/dropdown_button.dart';
import '../../models/prompt.dart';
import '../../utils/helpers/ads/ads_helper.dart';
import '../../viewmodels/aichat_list_view_model.dart';
import '../../viewmodels/homechat_view_model.dart';
import 'package:provider/provider.dart';
import '../EmailChat/email.dart';
import '../Prompt/prompt_screen.dart';
import '../Prompt/widgets/prompt_details.dart';
import 'Widgets/bottom_navigation.dart';
import 'Widgets/menu.dart';
import '../../models/ai_logo.dart';
import 'package:screenshot/screenshot.dart';
import 'Widgets/build_message.dart';
import 'Widgets/input_message.dart';

class HomeChat extends StatefulWidget {
  const HomeChat({super.key});

  @override
  State<HomeChat> createState() => _HomeChatState();
}

class _HomeChatState extends State<HomeChat> {
  InterstitialAd? _interstitialAd;
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final ScreenshotController _screenshotController = ScreenshotController();
  final FocusNode _focusNode = FocusNode();

  bool _isOpenDeviceWidget = false;
  bool _hasText = false;
  bool _showSlash = false;
  int _selectedBottomItemIndex = 0;
  List<String>? _files;
  late List<AIItem> _listAIItem;
  late String _selectedAIItem;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();

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
      _loadConversation();
      _loadAllPrompt();
    });

    final aiChatList = Provider.of<AIChatList>(context, listen: false);
    _listAIItem = aiChatList.aiItems;
    _selectedAIItem = aiChatList.selectedAIItem.name;

    Provider.of<HomeChatViewModel>(context, listen: false).updateRemainingUsage();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<KnowledgeBaseViewModel>(context, listen: false)
          .fetchAllKnowledgeBases(isLoadMore: false);
    });
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          setState(() {
            _interstitialAd = ad;
          });
          _interstitialAd?.show();
          _interstitialAd?.fullScreenContentCallback =
              FullScreenContentCallback(
                onAdDismissedFullScreenContent: (InterstitialAd ad) {
                  ad.dispose();
                  print("Interstitial Ad dismissed.");
                },
                onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
                  ad.dispose();
                  print("Failed to show Interstitial Ad: ${error.message}");
                },
              );
        },
        onAdFailedToLoad: (error) {
          print('Interstitial ad failed to load: $error');
        },
      ),
    );
  }

  Future<void> _loadUserInfo() async {
    try {
      await Provider.of<AuthViewModel>(context, listen: false).fetchUserInfo();
    } catch (e) {
      return;
    }
  }

  Future<void> _loadConversation() async {
    final aiItem =
    _listAIItem.firstWhere((aiItem) => aiItem.name == _selectedAIItem);
    try {
      Provider.of<HomeChatViewModel>(context, listen: false)
          .fetchAllConversations(aiItem.id, 'dify')
          .then((_) async {
        await Provider.of<HomeChatViewModel>(context, listen: false)
            .checkCurrentConversation(aiItem.id);
      });
    } catch (e) {
      return;
    }
  }

  Future<void> _loadAllPrompt() async {
    try {
      Provider.of<PromptListViewModel>(context, listen: false)
          .fetchAllPrompts()
          .then((_) {
        Provider.of<PromptListViewModel>(context, listen: false).allPrompts;
      });
    } catch (e) {
      return;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(() {});
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _onTappedBottomItem(int index) {
    setState(() {
      _selectedBottomItemIndex = index;
    });
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PromptScreen()),
      ).then((result) {
        if (result != null && result is String && result.contains('Respond in')) {
          setState(() {
            _controller.text = result.replaceFirst('Respond in: ', '');
            _sendMessage();
          });
        }
        _loadAllPrompt();
      });
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BotScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EmailComposer()),
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
    if (_files == null && _controller.text.isEmpty) return;

    try {
      final aiItem =
      _listAIItem.firstWhere((aiItem) => aiItem.name == _selectedAIItem);

      await Provider.of<HomeChatViewModel>(context, listen: false).sendMessage(
        _controller.text.isEmpty ? '' : _controller.text,
        aiItem,
        files: _files ?? [],
      );

      _controller.clear();
      setState(() {
        _files = null;
      });
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

  void _updateSelectedAIItem(String newValue) {
    setState(() {
      _selectedAIItem = newValue;
      AIItem aiItem = _listAIItem.firstWhere((aiItem) => aiItem.name == newValue);

      Provider.of<AIChatList>(context, listen: false).setSelectedAIItem(aiItem);

      _listAIItem.removeWhere((aiItem) => aiItem.name == newValue);
      _listAIItem.insert(0, aiItem);
    });
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
      promptId: prompt.id,
      itemTitle: prompt.title,
      content: prompt.content,
      category: prompt.category,
      description: prompt.description,
      language: prompt.language,
      isPublic: prompt.isPublic,
      isFavorite: prompt.isFavorite,
    ).then((result) {
      if (result != null) {
        if (result['action'] == 'send') {
          setState(() {
            _controller.text = result['content'];
            _sendMessage();
          });
        } else if (result['action'] == 'update') {
          _loadAllPrompt();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final botModel = context.watch<BotViewModel>();
    final emailModel = context.watch<EmailChatViewModel>();
    return Screenshot(
      controller: _screenshotController,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const Menu(),
        body: Consumer2<HomeChatViewModel, IAPManager>(
          builder: (context, messageModel, iapManager, child) {
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
                        !botModel.isChatWithMyBot
                            ? AIDropdown(
                          listAIItems: _listAIItem,
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              _updateSelectedAIItem(newValue);
                            }
                          },
                        )
                            : Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color:
                              const Color.fromARGB(255, 238, 240, 243),
                            ),
                            height: 30,
                            padding:
                            const EdgeInsets.symmetric(horizontal: 10),
                            child: Center(
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      botModel.currentChatBot.assistantName,
                                      style: const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  const Row(children: [
                                    Icon(
                                      Icons.flash_on,
                                      color: Colors.orange,
                                      size: 16,
                                    ),
                                    Text(
                                      '5',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ])
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 238, 240, 243),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.flash_on,
                                color: Colors.orange,
                                size: 20,
                              ),
                              messageModel.maxTokens == 99999 &&
                                  messageModel.maxTokens != null
                                  ? const Text(
                                "Unlimited",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.orange,
                                ),
                              )
                                  : Text(
                                '${[
                                  messageModel.remainingUsage,
                                  botModel.remainingUsage,
                                  emailModel.remainingUsage ?? 99999
                                ].reduce((a, b) => a < b ? a : b)}',
                                style: const TextStyle(
                                    color:
                                    Color.fromRGBO(119, 117, 117, 1.0)),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            Provider.of<HomeChatViewModel>(context, listen: false)
                                .clearMessage();
                            botModel.isChatWithMyBot = false;
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
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 10, bottom: 10, right: 10),
                            child: !botModel.isChatWithMyBot ? Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    iapManager.isPro ? 'PRO User' : 'Free User',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: iapManager.isPro
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    itemCount: messageModel.messages.length,
                                    itemBuilder: (context, index) {
                                      final message =
                                      messageModel.messages[index];
                                      return BuildMessage(message: message);
                                    },
                                  )
                                ),
                                if (_showSlash)
                                  Consumer<PromptListViewModel>(
                                    builder: (context, promptList, child) {
                                      if (promptList.isLoading) {
                                        return const CircularProgressIndicator();
                                      } else if (promptList.hasError) {
                                        return Text(
                                            'Error occur: ${promptList.error}');
                                      } else {
                                        return Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Container(
                                            width:
                                            MediaQuery.of(context).size.width /
                                                3 *
                                                2,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: const Color.fromARGB(
                                                    255, 158, 198, 232),
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                              BorderRadius.circular(20.0),
                                            ),
                                            constraints: BoxConstraints(
                                              maxHeight: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                                  3,
                                            ),
                                            child: ListView.builder(
                                              itemCount: promptList
                                                  .allPrompts.items.length,
                                              itemBuilder: (context, index) {
                                                return ListTile(
                                                  title: Text(promptList
                                                      .allPrompts
                                                      .items[index]
                                                      .title),
                                                  onTap: () {
                                                    _controller.text = "";
                                                    _showSlash = false;
                                                    _openPromptDetailsDialog(
                                                        context,
                                                        promptList.allPrompts
                                                            .items[index]);
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                InputWidget(
                                  focusNode: _focusNode,
                                  controller: _controller,
                                  onTextChanged: _onTextChanged,
                                  sendMessage: _sendMessage,
                                  isOpenDeviceWidget: _isOpenDeviceWidget,
                                  toggleDeviceVisibility: _toggleDeviceVisibility,
                                  hasText: _hasText,
                                  updateImagePaths: (paths) {
                                    setState(() {
                                      _files = paths;
                                    });
                                  },
                                  screenshotController: _screenshotController,
                                ),
                                const SizedBox(height: 5),
                              ],
                            ) : ChatWidget(),
                          ),
                        ),
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
      ),
    );
  }
}