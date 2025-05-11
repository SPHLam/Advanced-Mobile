import 'package:flutter/material.dart';
import 'package:project_ai_chat/core/Widget/chat_widget.dart';
import 'package:project_ai_chat/viewmodels/bot_view_model.dart';
import 'package:provider/provider.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({Key? key}) : super(key: key);

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  void _handleRefreshChat() {
    // Thực hiện logic xóa dữ liệu hoặc làm mới chat
    // Provider.of<BotViewModel>(context, listen: false).updateAiBotWithThreadPlayGround();
    Provider.of<BotViewModel>(context, listen: false).loadConversationHistory();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Thread has been refreshed!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lấy tên bot từ Provider
    final botName = context.read<BotViewModel>().currentBot.assistantName;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => {
            Provider.of<BotViewModel>(context, listen: false).isPreview = false,
            Provider.of<BotViewModel>(context, listen: false).loadConversationHistory(),
            Navigator.pop(context)
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Expanded(
              child: Text(
                'Preview',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: _handleRefreshChat,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: Text(
            botName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: ChatWidget(isPreview: true),
        ),
      ),
    );
  }
}