import 'package:flutter/material.dart';
import 'package:jarvis/View/Bot/data/bots_data.dart';
import 'package:jarvis/View/Bot/page/edit_bot.dart';
import 'package:jarvis/View/Bot/page/new_bot.dart';
import 'package:jarvis/View/Bot/page/public_bot.dart';
import 'package:jarvis/View/Bot/widgets/bot_card.dart';
import 'package:jarvis/View/Bot/model/bot.dart';
import 'package:jarvis/View/HomeChat/home.dart';
import '../../../constants/colors.dart';

class BotScreen extends StatefulWidget {
  const BotScreen({super.key});

  @override
  State<BotScreen> createState() => _BotScreenState();
}

class _BotScreenState extends State<BotScreen> {
  final List<Bot> _listBots = bots;

  void _addBot(Bot newBot) {
    setState(() {
      _listBots.add(newBot);
    });
  }

  void _editBot(Bot newEditBot, int indexEditBox) {
    setState(() {
      _listBots[indexEditBox] = newEditBot;
    });
  }

  void _removeBot(Bot bot) {
    final botDeleteIndex = _listBots.indexOf(bot);
    setState(() {
      _listBots.remove(bot);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.grey[800],
        content: const Text("Bot has been Deleted!"),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.cyan,
          onPressed: () {
            setState(() {
              _listBots.insert(botDeleteIndex, bot);
            });
          },
        ),
      ),
    );
  }

  void _openAddBotDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => NewBot(
        addBot: (newBot) {
          _addBot(newBot);
        },
      ),
    );
  }

  void _openEditBotDialog(BuildContext context, Bot bot, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditBot(
          editBot: (bot) {
            _editBot(bot, index);
          },
          bot: bot,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Bots",
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
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                hintText: 'Search...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.cyan),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _listBots.isEmpty
                  ? const Center(
                child: Text(
                  "No bots available",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: _listBots.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeChat(),
                              ),
                            );
                          },
                          child: BotCard(bot: _listBots[index]),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15, right: 13),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  _openEditBotDialog(context, _listBots[index], index);
                                },
                                icon: const Icon(Icons.edit, size: 18),
                                color: Colors.green,
                              ),
                              const SizedBox(width: 6),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  _removeBot(_listBots[index]);
                                },
                                icon: const Icon(Icons.delete, size: 18),
                                color: Colors.red,
                              ),
                              const SizedBox(width: 6),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  _openPublishBotDialog(context);
                                },
                                icon: const Icon(Icons.publish, size: 19),
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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