import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jarvis/constants/colors.dart';
import 'package:jarvis/models/ai_logo.dart';
import 'package:jarvis/views/Knowledge/page/knowledge_screen.dart';
import 'package:jarvis/viewmodels/bot_view_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jarvis/constants/text_strings.dart';
import 'package:jarvis/viewmodels/homechat_view_model.dart';
import 'package:jarvis/viewmodels/aichat_list_view_model.dart';
import 'package:jarvis/viewmodels/auth_view_model.dart';
import 'package:jarvis/views/Login/login_screen.dart';

class Menu extends StatefulWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  int _selectedIndex = -1;
  late final AIChatList aiChatList;
  late AIItem currentAI;
  late ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    aiChatList = Provider.of<AIChatList>(context, listen: false);
    currentAI = aiChatList.selectedAIItem;

    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          Provider.of<MessageModel>(context, listen: false)
              .fetchAllConversations(currentAI.id, 'dify', isLoadMore: true);
        }
      });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  String _formatTimestamp(String timestamp) {
    final DateTime dateTime = DateTime.parse(timestamp);
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  Future<void> _logout() async {
    await Provider.of<AuthViewModel>(context, listen: false).logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
              decoration: BoxDecoration(
                color: primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Image.asset("assets/logoAI.png", height: 48),
                      ),
                      const SizedBox(width: 16),
                      const Flexible(
                        child: Text(
                          "JarvisCopi",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _logout,
                    icon:
                        const Icon(Icons.logout, size: 18, color: Colors.white),
                    label: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 16),
                  _buildMainMenuSection(),
                  const Divider(height: 32),
                  _buildConversationsSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainMenuSection() {
    return Column(
      children: [
        _buildMenuItemCard(
          icon: Icons.play_lesson,
          title: "Knowledge Bases",
          index: 1,
          color: Colors.indigo,
        ),
        _buildMenuItemCard(
          icon: Icons.verified_sharp,
          title: "Upgrade Version",
          index: 2,
          color: Colors.amber[700]!,
        ),
      ],
    );
  }

  Widget _buildConversationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: _isSearching
                    ? TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _isSearching = false;
                              });
                            },
                          ),
                        ),
                        autofocus: true,
                      )
                    : const Text(
                        'All Conversations',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
              IconButton(
                icon: Icon(_isSearching ? Icons.search_off : Icons.search,
                    color: Colors.black54),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                    }
                  });
                },
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
            ],
          ),
        ),
        Consumer<MessageModel>(
          builder: (context, messageModel, child) {
            if (messageModel.isLoading && messageModel.conversations.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (messageModel.errorMessage != null &&
                messageModel.conversations.isEmpty) {
              return Center(
                child: Text(
                  messageModel.errorMessage ?? 'Server error, please try again',
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            }

            final filteredConversations = _searchQuery.isEmpty
                ? messageModel.conversations
                : messageModel.conversations
                    .where((conversation) => conversation.title
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                    .toList();

            return ListView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredConversations.length +
                  (messageModel.hasMoreConversation && _searchQuery.isEmpty
                      ? 1
                      : 0),
              itemBuilder: (context, index) {
                if (index == filteredConversations.length &&
                    _searchQuery.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final conversation = filteredConversations[index];
                String previewText = conversation.title.isNotEmpty
                    ? conversation.title.substring(
                        0,
                        conversation.title.length > 30
                            ? 30
                            : conversation.title.length)
                    : "Empty conversation";
                if (previewText.length == 30) previewText += "...";

                return ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        previewText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimestamp(conversation.createdAt),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  onTap: () async {
                    await Provider.of<MessageModel>(context, listen: false)
                        .loadConversationHistory(currentAI.id, conversation.id);
                    Provider.of<BotViewModel>(context, listen: false)
                        .isChatWithMyBot = false;
                    Navigator.pop(context);
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuItemCard({
    required IconData icon,
    required String title,
    required int index,
    required Color color,
  }) {
    final isSelected = index == _selectedIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: isSelected ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: () async {
            setState(() {
              _selectedIndex = index;
            });
            if (index == 2) {
              final Uri url = Uri.parse(linkUpgrade);
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cannot open link!')),
                );
              }
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const KnowledgeScreen()),
              );
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
