import 'package:flutter/material.dart';
import 'package:jarvis/views/Bot/data/bots_data.dart';
import 'package:jarvis/views/Bot/page/edit_bot.dart';
import 'package:jarvis/views/Bot/page/new_bot.dart';
import 'package:jarvis/views/Bot/page/public_bot.dart';
import 'package:jarvis/views/Bot/widgets/bot_card.dart';
import 'package:jarvis/views/Bot/model/bot.dart';
import '../../../constants/colors.dart';

class BotScreen extends StatefulWidget {
  const BotScreen({super.key});

  @override
  State<BotScreen> createState() => _BotScreenState();
}

class _BotScreenState extends State<BotScreen> {
  final List<Bot> _listBots = bots;
  List<Bot> _filteredBots = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredBots = List.from(_listBots);
    _searchController.addListener(_filterBots);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterBots() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredBots = List.from(_listBots);
      } else {
        _filteredBots = _listBots.where((bot) {
          return bot.name.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _addBot(Bot newBot) {
    setState(() {
      _listBots.add(newBot);
      _filterBots();
    });
  }

  void _editBot(Bot newEditBot, int indexEditBox) {
    setState(() {
      _listBots[indexEditBox] = newEditBot;
      _filterBots();
    });
  }

  void _removeBot(Bot bot) {
    final botDeleteIndex = _listBots.indexOf(bot);
    setState(() {
      _listBots.remove(bot);
      _filterBots();
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
              _filterBots();
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
              controller: _searchController,
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
              child: _filteredBots.isEmpty
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
                itemCount: _filteredBots.length,
                itemBuilder: (context, index) {
                  return BotCard(
                    bot: _filteredBots[index],
                    onEdit: () => _openEditBotDialog(
                        context, _filteredBots[index], _listBots.indexOf(_filteredBots[index])),
                    onDelete: () => _removeBot(_filteredBots[index]),
                    onPublish: () => _openPublishBotDialog(context),
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

class Listviews {
}