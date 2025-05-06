import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_ai_chat/views/Bot/page/new_bot.dart';
import 'package:project_ai_chat/views/Bot/widgets/bot_list.dart';
import 'package:provider/provider.dart';
import '../../../constants/colors.dart';
import '../../../models/bot_request.dart';
import '../../../viewmodels/bot_view_model.dart';

class BotScreen extends StatefulWidget {
  const BotScreen({super.key});

  @override
  State<BotScreen> createState() => _BotScreenState();
}

class _BotScreenState extends State<BotScreen> {
  final viewModel = BotViewModel();
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  Future<void> _addBot(BotRequest newBot) async {
    final viewModel = context.read<BotViewModel>();
    bool isCreated = await viewModel.createBot(newBot);
    if (isCreated) {
      viewModel.fetchBots();

    } else {
      // Hiển thị thông báo lỗi nếu tạo bot không thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Create bot failed',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue[600],
        ),
      );
    }
  }


  void _openAddBotDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => NewBot(
              addBot: (newBot) {
                _addBot(newBot);
              },
            ));
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BotViewModel>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Bots',
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _openAddBotDialog(context);
            },
            icon: const Icon(Icons.add),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onChanged: (value) {
                viewModel.query = value; // Gửi query qua callback
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade200,
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                hintText: 'Search...',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.blue, width: 1),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: BotListWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
