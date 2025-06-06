import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_ai_chat/constants/colors.dart';
import 'package:project_ai_chat/models/ai_logo.dart';
import 'package:project_ai_chat/views/Knowledge/page/knowledge_screen.dart';
import 'package:project_ai_chat/viewmodels/bot_view_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:project_ai_chat/constants/text_strings.dart';
import 'package:project_ai_chat/viewmodels/homechat_view_model.dart';
import 'package:project_ai_chat/viewmodels/aichat_list_view_model.dart';
import 'package:project_ai_chat/viewmodels/auth_view_model.dart';
import 'package:project_ai_chat/views/Login/login_screen.dart';
import 'package:project_ai_chat/core/Widget/delete_confirm_dialog.dart';
import 'package:project_ai_chat/services/iap_service.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  int _selectedIndex = -1;
  late AIChatList aiChatList;
  late AIItem currentAI;
  late ScrollController _scrollController;
  final _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    aiChatList = Provider.of<AIChatList>(context, listen: false);
    currentAI = aiChatList.selectedAIItem;
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.atEdge &&
            _scrollController.position.pixels != 0) {
          Provider.of<HomeChatViewModel>(context, listen: false)
              .fetchAllConversations(currentAI.id, 'dify', isLoadMore: true);
        }
      });
    _searchController.addListener(() => setState(() {}));
  }

  String _formatTimestamp(String timestamp) =>
      DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(timestamp));

  Future<void> _logout() async {
    await Provider.of<AuthViewModel>(context, listen: false).logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
      );
    }
  }

  void _showDeleteDialog(String conversationId, String title) {
    if (_isDialogOpen) return;
    setState(() => _isDialogOpen = true);
    showDialog(
      context: context,
      builder: (_) => DeleteConfirmationDialog(
        title: 'Delete Conversation',
        message: 'Are you sure you want to delete this conversation?',
        onConfirm: () => _deleteConversation(conversationId),
      ),
    ).then((_) => setState(() => _isDialogOpen = false));
  }

  void _showRenameDialog(String diaryId, String currentName) {
    if (_isDialogOpen) return;
    setState(() => _isDialogOpen = true);
    showDialog(
      context: context,
      builder: (_) => RenameDialog(
        diaryId: diaryId,
        currentName: currentName,
        onRename: _renameConversation,
      ),
    ).then((_) => setState(() => _isDialogOpen = false));
  }

  Future<void> _deleteConversation(String conversationId) async {
    try {
      await Provider.of<HomeChatViewModel>(context, listen: false)
          .deleteConversationHistory(
          conversationId: conversationId, assistantId: currentAI.id);
      if (mounted)
        _showSnackBar('Conversation deleted successfully', Colors.green);
    } catch (e) {
      if (mounted)
        _showSnackBar('Failed to delete conversation: $e', Colors.red);
    }
  }

  Future<void> _renameConversation(String conversationId, String title) async {
    try {
      await Provider.of<HomeChatViewModel>(context, listen: false)
          .updateConversationTitle(
          conversationId: conversationId,
          assistantId: currentAI.id,
          title: title);
      if (mounted)
        _showSnackBar('Conversation renamed successfully', Colors.green);
    } catch (e) {
      if (mounted)
        _showSnackBar('Failed to rename conversation: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Future<void> _showDialog({
    required String title,
    required IconData icon,
    required Color? iconColor,
    required String message,
    required String confirmText,
    required Color? confirmColor,
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 300, maxWidth: 400),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 48),
              const SizedBox(height: 16),
              Text(title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(message,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel',
                        style:
                        TextStyle(fontSize: 16, color: Colors.grey[600])),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: Text(confirmText,
                        style:
                        const TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _purchaseProUpgrade() async {
    try {
      final iapManager = Provider.of<IAPManager>(context, listen: false);
      if (iapManager.canPurchase) {
        await iapManager.buyProUpgrade();
      } else {
        _showSnackBar('PRO subscription is still active', Colors.grey);
      }
    } catch (e) {
      _showSnackBar('Purchase error: $e', Colors.red);
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
            _buildHeader(),
            Expanded(
              child: Column(
                children: [
                  _buildMainMenuSection(),
                  const Divider(height: 32),
                  Expanded(child: _buildConversationsSection()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
      decoration: BoxDecoration(
        color: primaryColor,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2))
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
                        offset: const Offset(0, 2))
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
                      fontSize: 26),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, size: 18, color: Colors.white),
            label: const Text("Logout"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainMenuSection() {
    return Consumer<IAPManager>(
      builder: (context, iapManager, _) {
        return Column(
          children: [
            _buildMenuItemCard(
              icon: Icons.play_lesson,
              title: "Knowledge Bases",
              index: 1,
              color: Colors.indigo,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const KnowledgeScreen())),
            ),
            _buildMenuItemCard(
              icon: Icons.verified_sharp,
              title: "Upgrade Version",
              index: 2,
              color: Colors.amber[700]!,
              onTap: () async {
                final url = Uri.parse(linkUpgrade);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  _showSnackBar('Cannot open link!', Colors.red);
                }
              },
            ),
            _buildMenuItemCard(
              icon: Icons.payment,
              title: "In-app Purchase",
              index: 3,
              color: Colors.green,
              onTap: iapManager.canPurchase ? _purchaseProUpgrade : () {},
              isEnabled: iapManager.canPurchase,
            ),
          ],
        );
      },
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
                        borderRadius: BorderRadius.circular(12)),
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
                    : const Text('All Conversations',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                icon: Icon(_isSearching ? Icons.search_off : Icons.search,
                    color: Colors.black54),
                onPressed: () => setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) _searchController.clear();
                }),
              ),
            ],
          ),
        ),
        Expanded(
          child: Consumer<HomeChatViewModel>(
            builder: (context, model, _) {
              if (model.isLoading && model.conversations.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (model.errorMessage != null && model.conversations.isEmpty) {
                return Center(
                    child: Text(model.errorMessage ?? 'Server error',
                        style:
                        const TextStyle(color: Colors.red, fontSize: 16)));
              }

              final conversations = _searchController.text.isEmpty
                  ? model.conversations
                  : model.conversations
                  .where((c) => c.title
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()))
                  .toList();

              return ListView.builder(
                controller: _scrollController,
                itemCount: conversations.length +
                    (model.hasMoreConversation && _searchController.text.isEmpty
                        ? 1
                        : 0),
                itemBuilder: (context, index) {
                  if (index == conversations.length &&
                      _searchController.text.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final conversation = conversations[index];
                  final title = conversation.title.trim();

                  return Card(
                    margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                await Provider.of<HomeChatViewModel>(context,
                                    listen: false)
                                    .loadConversationHistory(
                                    currentAI.id, conversation.id);
                                Provider.of<BotViewModel>(context,
                                    listen: false)
                                    .isChatWithMyBot = false;
                                Navigator.pop(context);
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(_formatTimestamp(conversation.createdAt),
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.green),
                            onPressed: () => _showRenameDialog(
                                conversation.id, conversation.title ?? ''),
                            tooltip: 'Rename',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteDialog(
                                conversation.id, conversation.title ?? ''),
                            tooltip: 'Delete',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItemCard({
    required IconData icon,
    required String title,
    required int index,
    required Color color,
    required VoidCallback onTap,
    bool isEnabled = true,
  }) {
    final isSelected = index == _selectedIndex;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: isSelected ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
              color: isSelected ? color : Colors.transparent, width: 2),
        ),
        child: InkWell(
          onTap: isEnabled
              ? () {
            setState(() => _selectedIndex = index);
            onTap();
          }
              : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: color.withOpacity(isEnabled ? 0.1 : 0.05),
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, color: isEnabled ? color : Colors.grey),
                ),
                const SizedBox(width: 16),
                Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                          fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 16,
                          color: isEnabled ? null : Colors.grey),
                    )),
                Icon(Icons.chevron_right,
                    color: isEnabled ? Colors.grey[400] : Colors.grey[200],
                    size: 20),
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

class RenameDialog extends StatefulWidget {
  final String diaryId;
  final String currentName;
  final Future<void> Function(String, String) onRename;

  const RenameDialog({
    super.key,
    required this.diaryId,
    required this.currentName,
    required this.onRename,
  });

  @override
  State<RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<RenameDialog> {
  late final TextEditingController _renameController;
  String _title = '';

  @override
  void initState() {
    super.initState();
    _renameController = TextEditingController(text: widget.currentName);
    _title = widget.currentName;
  }

  @override
  void dispose() {
    _renameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 250),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Rename Conversation',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: _renameController,
                decoration: InputDecoration(
                  hintText: 'Enter new name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.indigo)),
                ),
                autofocus: true,
                onChanged: (value) => setState(() => _title = value),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel',
                        style:
                        TextStyle(fontSize: 16, color: Colors.grey[600])),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_title.trim().isNotEmpty) {
                        Navigator.pop(context);
                        await widget.onRename(widget.diaryId, _title.trim());
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                              Text('Conversation name cannot be empty'),
                              backgroundColor: Colors.red),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Save',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}