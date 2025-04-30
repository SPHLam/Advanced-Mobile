import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:jarvis/views/Bot/page/edit_bot.dart';
import 'package:jarvis/views/Bot/page/public_bot.dart';
import 'package:jarvis/views/Bot/widgets/bot_card.dart';
import 'package:jarvis/views/HomeChat/home.dart';
import 'package:jarvis/models/bot_request.dart';
import 'package:jarvis/viewmodels/bot_view_model.dart';
import 'package:jarvis/models/bot.dart';
import 'package:jarvis/viewmodels/homechat_view_model.dart';
import 'package:provider/provider.dart';

class BotListWidget extends StatefulWidget {
  const BotListWidget({Key? key}) : super(key: key);

  @override
  _BotListWidgetState createState() => _BotListWidgetState();
}

class _BotListWidgetState extends State<BotListWidget> {
  bool isDeleting = false;
  final viewModel = BotViewModel();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<BotViewModel>();
      viewModel.fetchBots();
    });
    // final viewModel = context.read<BotViewModel>();
    // viewModel.fetchBots();

    // Lắng nghe sự kiện cuộn
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !viewModel.isLoadingMore) {
        viewModel.loadMoreBots();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BotViewModel>();
    final bots = viewModel.botList;

    print('✅ RESPONSE BOTS DATA IN BOT LIST: $bots');

    if (bots.total == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              'No bots found.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 5),
            Text(
              'Try adjusting your filters or search terms.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Stack(children: [
      ListView.builder(
        controller: _scrollController,
        itemCount: bots.data.length + (viewModel.hasNext ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < bots.data.length) {
            return Slidable(
              endActionPane: ActionPane(
                motion: const StretchMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) {
                      _openEditBotDialog(
                          context, bots.data[index], bots.data[index].id);
                    },
                    icon: Icons.edit,
                    backgroundColor: Colors.green,
                  ),
                  SlidableAction(
                    onPressed: (context) {
                      _removeBot(bots.data[index]);
                    },
                    icon: Icons.delete,
                    backgroundColor: Colors.red,
                  ),
                  SlidableAction(
                    onPressed: (context) {
                      _openPublishBotDialog(context);
                    },
                    icon: Icons.publish,
                    backgroundColor: Colors.blue,
                  ),
                ],
              ),
              child: InkWell(
                onTap: () async {
                  Provider.of<BotViewModel>(context, listen: false)
                      .isChatWithMyBot = true;
                  Provider.of<BotViewModel>(context, listen: false)
                      .currentChatBot = bots.data[index];
                  await Provider.of<BotViewModel>(context, listen: false)
                      .loadConversationHistory();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeChat()),
                  );

                  //viewModel.chatInHome(bots.data[index].id);
                },
                child: BotCard(
                  bot: bots.data[index],
                ),
              ),
            );
          } else if (viewModel.isLoadingMore) {
            // Hiển thị loading khi đang tải thêm
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          } else {
            return SizedBox.shrink(); // Không hiển thị gì
          }
        },
      ),
      if (isDeleting)
        Positioned.fill(
          child: Container(
            //color: Colors.black.withOpacity(0.5), // Lớp màu mờ
            child: Center(
              child: CircularProgressIndicator(color: Colors.blueGrey),
            ),
          ),
        ),
      if (viewModel.isLoading && bots.data.isEmpty)
        Center(child: CircularProgressIndicator()),
    ]);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _editBot(BotRequest newEditBot, String id) async {
    final viewModel = context.read<BotViewModel>();
    bool isUpdated = await viewModel.updateBot(newEditBot, id);
    if (isUpdated) {
      viewModel.fetchBots();
    } else {
      // Hiển thị thông báo lỗi nếu cập nhật bot không thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Update bot failed',
            style: TextStyle(color: Colors.white), // Màu chữ trắng
          ),
          backgroundColor: Colors.blue[600], // Màu nền xanh dương nhạt
        ),
      );
    }
  }

  Future<void> _removeBot(Bot bot) async {
    final viewModel = context.read<BotViewModel>();
    bool isDeleted = await viewModel.deleteBot(bot.id);
    if (isDeleted) {
      viewModel.fetchBots();
    } else {
      // Hiển thị thông báo lỗi nếu xóa bot không thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Update bot failed',
            style: TextStyle(color: Colors.white), // Màu chữ trắng
          ),
          backgroundColor: Colors.blue[600], // Màu nền xanh dương nhạt
        ),
      );
    }
  }

  void _openEditBotDialog(BuildContext context, Bot bot, String id) {
    Provider.of<BotViewModel>(context, listen: false).currentBot = bot;
    Provider.of<BotViewModel>(context, listen: false).getImportedKnowledge(id);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditBot(
          editBot: (bot) {
            _editBot(bot, id);
          },
          bot: bot.toBotRequest(),
        ),
      ),
    );
  }

  void _openPublishBotDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const PublicBot(),
    );
  }
}
