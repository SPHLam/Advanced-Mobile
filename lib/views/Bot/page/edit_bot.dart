import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jarvis/views/Bot/model/bot.dart';
import 'package:jarvis/views/Bot/page/new_bot_knowledge.dart';
import 'package:jarvis/constants/colors.dart';

class EditBot extends StatefulWidget {
  const EditBot({super.key, required this.editBot, required this.bot});
  final void Function(Bot newBot) editBot;
  final Bot bot;

  @override
  State<EditBot> createState() => _EditBotState(); // Sửa tên state
}

class _EditBotState extends State<EditBot> {
  final _formKey = GlobalKey<FormState>();
  List<String> _arrKnowledge = [];
  int _accessOption = 1;
  String _enteredName = "";
  String _enteredPrompt = "";
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _enteredName = widget.bot.name;
    _enteredPrompt = widget.bot.prompt;
    _accessOption = widget.bot.isPublish ? 1 : 2;
    _arrKnowledge = List.from(widget.bot.listKnowledge);

    if (!widget.bot.imageUrl.startsWith('assets/') && !widget.bot.imageUrl.startsWith('http')) {
      _selectedImagePath = widget.bot.imageUrl;
    }
  }

  void _openAddKnowledgeDialog(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => NewBotKnowledge(arrKnowledgeAdded: _arrKnowledge),
    );

    if (result != null) {
      setState(() {
        _arrKnowledge.add(result);
      });
    }
  }

  void _handleDeleteKnowledge(String name) {
    setState(() {
      _arrKnowledge.remove(name);
    });
  }

  void _handleEditKnowledge(String oldName) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => NewBotKnowledge(arrKnowledgeAdded: _arrKnowledge),
    );

    if (result != null) {
      setState(() {
        final index = _arrKnowledge.indexOf(oldName);
        if (index != -1) {
          _arrKnowledge[index] = result;
        }
      });
    }
  }

  void _saveBot() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.editBot(
        Bot(
          name: _enteredName,
          prompt: _enteredPrompt,
          team: widget.bot.team,
          imageUrl: _selectedImagePath ?? widget.bot.imageUrl,
          isPublish: _accessOption == 1,
          listKnowledge: _arrKnowledge,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _openGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImagePath = image.path;
      });
    }
  }

  ImageProvider<Object> _getImageProvider(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return NetworkImage(imageUrl);
    } else if (imageUrl.startsWith('assets/')) {
      return AssetImage(imageUrl);
    } else {
      return FileImage(File(imageUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: const Text(
          "Edit Bot",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Basic Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: GestureDetector(
                              onTap: _openGallery,
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: _selectedImagePath != null
                                    ? FileImage(File(_selectedImagePath!))
                                    : _getImageProvider(widget.bot.imageUrl),
                                child: _selectedImagePath == null && widget.bot.imageUrl.isEmpty
                                    ? const Icon(Icons.add, size: 32, color: Colors.white)
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: _enteredName,
                            decoration: InputDecoration(
                              labelText: 'Name',
                              hintText: 'Enter bot name',
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
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
                          const SizedBox(height: 12),
                          TextFormField(
                            initialValue: _enteredPrompt,
                            maxLines: 4,
                            decoration: InputDecoration(
                              labelText: 'Prompt',
                              hintText: 'Enter prompt content...',
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a prompt';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredPrompt = value!;
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<int>(
                            value: _accessOption,
                            items: const [
                              DropdownMenuItem(
                                value: 1,
                                child: Text('Public'),
                              ),
                              DropdownMenuItem(
                                value: 2,
                                child: Text('Private'),
                              ),
                            ],
                            onChanged: (int? newValue) {
                              setState(() {
                                _accessOption = newValue!;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Access',
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Knowledge Base',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._arrKnowledge.map(
                                (knowledge) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: ListTile(
                                leading: const Icon(Icons.book, color: Colors.blue),
                                title: Text(
                                  knowledge,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.green),
                                      onPressed: () => _handleEditKnowledge(knowledge),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _handleDeleteKnowledge(knowledge),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => _openAddKnowledgeDialog(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Knowledge'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[50],
                              foregroundColor: Colors.blue[700],
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveBot,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}