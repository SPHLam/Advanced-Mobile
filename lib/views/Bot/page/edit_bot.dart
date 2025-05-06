import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_ai_chat/views/Bot/page/preview_bot.dart';
import 'package:project_ai_chat/models/bot_request.dart';
import 'package:project_ai_chat/viewmodels/bot_view_model.dart';
import 'package:project_ai_chat/viewmodels/knowledge_base_view_model.dart';
import 'package:project_ai_chat/views/Bot/page/new_bot_knowledge.dart';
import 'package:project_ai_chat/models/knowledge.dart';
import 'package:provider/provider.dart';

class EditBot extends StatefulWidget {
  const EditBot({super.key, required this.editBot, required this.bot});
  final void Function(BotRequest newBot) editBot;
  final BotRequest bot;

  @override
  State<EditBot> createState() => _NewBotState();
}

class _NewBotState extends State<EditBot> {
  final _formKey = GlobalKey<FormState>();
  List<String> _arrKnowledge = [];

  //TextFormField
  String _enteredName = "";
  String _enteredPrompt = "";
  String _enteredDescription = "";

  void _openAddKnowledgeDialog(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => NewBotKnowledge(),
    );

    if (result != null) {
      //Show add success
    }
  }

  void _handleDeleteKnowledge(String knowledgeId) {
    Provider.of<BotViewModel>(context, listen: false)
        .removeKnowledge(knowledgeId);
  }

  @override
  void initState() {
    super.initState();
    _enteredName = widget.bot.assistantName;
    _enteredPrompt = widget.bot.instructions!;
    _enteredDescription = widget.bot.description!;
  }

  void _saveBot() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // information edit bot
      widget.editBot(BotRequest(
        assistantName: _enteredName,
        instructions: _enteredPrompt,
        description: _enteredDescription,
      ));
      Navigator.pop(context);
    }
  }

  Future<void> _previewBot() async {
    Provider.of<BotViewModel>(context, listen: false).isPreview = true;
    await Provider.of<BotViewModel>(context, listen: false)
        .loadConversationHistory();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PreviewScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Edit Bot",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        // controller: nameController,
                        initialValue: _enteredName,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          hintText: 'Enter a AI Bot\'s Name...',
                          suffixIcon: Icon(Icons.edit),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enteredName = value!;
                        },
                      ),
                      const Text(
                        'Example: Professional Translator | Writing Expert | Code Assistant',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        initialValue: _enteredDescription,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Enter a description...',
                          suffixIcon: Icon(Icons.description),
                        ),
                        onSaved: (value) {
                          _enteredDescription = value ?? "";
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        initialValue: _enteredPrompt,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Prompt',
                          hintText: 'Enter a AI Bot\'s Prompt Content...',
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (value) {
                          _enteredPrompt = value ?? "";
                        },
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Example: You are an experienced translator with skills in multiple languages worldwide.',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Nút Save với ElevatedButton có gradient
                          Expanded(
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.blue, Colors.lightBlueAccent],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ElevatedButton(
                                onPressed: _saveBot,
                                style: ElevatedButton.styleFrom(
                                  //padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: Colors
                                      .transparent, // Quan trọng để giữ gradient
                                  shadowColor:
                                      Colors.transparent, // Loại bỏ bóng
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                ),
                                child: const Text(
                                  "Save",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16), // Khoảng cách giữa hai nút
                          // Nút Preview với OutlineButton
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: OutlinedButton(
                                onPressed: _previewBot,
                                style: OutlinedButton.styleFrom(
                                  //padding: const EdgeInsets.symmetric(vertical: 16),
                                  side: const BorderSide(
                                      color: Colors.blue, width: 1),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                ),
                                child: const Text(
                                  "Preview",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text("Imported Knowledge"),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Consumer<BotViewModel>(
                            builder: (context, botViewModel, child) {
                              return Column(
                                children: botViewModel.knowledgeList
                                    .map(
                                      (knowledge) => Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Image.network(
                                                'assets/images/open-book.png',
                                                width: 30,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return const Icon(Icons
                                                      .storage); // Hiển thị icon lỗi nếu không load được hình
                                                },
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  knowledge.name,
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.delete),
                                                    iconSize: 20,
                                                    color: Colors.red,
                                                    onPressed: () {
                                                      _handleDeleteKnowledge(
                                                          knowledge.id);
                                                    },
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              );
                            },
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          OutlinedButton(
                            onPressed: () {
                              _openAddKnowledgeDialog(context);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  width: 1, color: Colors.blue),
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize
                                  .min, // Đảm bảo nút không chiếm toàn bộ chiều ngang
                              children: [
                                Icon(
                                  Icons.add,
                                  color: Colors.blue,
                                ),
                                SizedBox(
                                    width: 8), // Khoảng cách giữa icon và text
                                Text(
                                  'Add Knowledge',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));

    //   actions: [
    //   ],
    // );
  }
}
