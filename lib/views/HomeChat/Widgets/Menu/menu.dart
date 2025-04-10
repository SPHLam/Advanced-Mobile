import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jarvis/views/Knowledge/page/knowledge_screen.dart';
import 'package:jarvis/models/ai_logo.dart';
import 'package:jarvis/view_models/auth_view_model.dart';
import 'package:provider/provider.dart';
import '../../../../view_models/homechat_view_model.dart';
import '../../../Login/login_screen.dart';
import '../../../UpgradeAccount/upgrade_account.dart';
import '../../../../view_models/ai_chat_list_view_model.dart';
import 'package:jarvis/constants/colors.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<StatefulWidget> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  int _selectedIndex = -1;
  late final AIChatList aiChatList;
  late AIItem currentAI;
  late ScrollController _scrollController;

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
  }

  String _formatTimestamp(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  Future<void> _logout() async {
    // Logic logout từ code cũ
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
          icon: Icons.book_outlined,
          title: "Knowledge Management",
          index: 1,
          color: Colors.indigo,
        ),
        _buildMenuItemCard(
          icon: Icons.workspace_premium,
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
              const Expanded(
                child: Text(
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
                icon: const Icon(Icons.search, color: Colors.black54),
                onPressed: () {},
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

            return ListView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: messageModel.conversations.length +
                  (messageModel.hasMoreConversation ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messageModel.conversations.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final conversation = messageModel.conversations[index];
                return _buildConversationItem(
                    conversation, index, messageModel);
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
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const KnowledgeScreen()),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UpgradeAccount()),
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

  Widget _buildConversationItem(
      dynamic conversation, int index, MessageModel messageModel) {
    String previewText = conversation.title.isNotEmpty
        ? conversation.title.substring(
            0, conversation.title.length > 30 ? 30 : conversation.title.length)
        : "Empty conversation";
    if (previewText.length == 30) previewText += "...";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        elevation: 0,
        color: Colors.grey[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: Colors.black,
            child: Text(
              "${index + 1}",
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(
            "Conversation ${index + 1}",
            style: const TextStyle(fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              "$previewText\n${_formatTimestamp(conversation.createdAt)}",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.red[300], size: 20),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Delete Conversation"),
                  content: const Text(
                      "Are you sure you want to delete this conversation?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    // TextButton(
                    //   onPressed: () {
                    //     messageModel.deleteConversation(index);
                    //     Navigator.pop(context);
                    //   },
                    //   child: const Text("Delete",
                    //       style: TextStyle(color: Colors.red)),
                    // ),
                  ],
                ),
              );
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          onTap: () async {
            await Provider.of<MessageModel>(context, listen: false)
                .loadConversationHistory(currentAI.id, conversation.id);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
