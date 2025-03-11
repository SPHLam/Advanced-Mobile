import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jarvis/View/Bot/model/bot.dart';

class NewBot extends StatefulWidget {
  const NewBot({super.key, required this.addBot});
  final void Function(Bot newBot) addBot;

  @override
  State<NewBot> createState() => _NewBotState();
}

class _NewBotState extends State<NewBot> {
  String? _selectedImagePath;

  final _formKey = GlobalKey<FormState>();
  int _accessOption = 1;

  String _enteredName = "";
  String _enteredPrompt = "";

  void _saveBot() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      widget.addBot(
        Bot(
          name: _enteredName,
          prompt: _enteredPrompt,
          team: "JarvisCopi Team",
          imageUrl: _selectedImagePath ??
              "assets/logo/default-bot.png",
          isPublish: _accessOption == 1,
          listKnowledge: [],
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.white,
      elevation: 8,
      contentPadding: const EdgeInsets.all(24.0),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Create New Bot',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: _openGallery,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Colors.blue, Colors.cyan],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.transparent,
                      backgroundImage: _selectedImagePath != null
                          ? Image.file(File(_selectedImagePath!)).image
                          : null,
                      child: _selectedImagePath == null
                          ? const Icon(Icons.add, size: 32, color: Colors.white)
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter bot name',
                  suffixIcon: const Icon(Icons.edit, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[100],
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
                    borderSide: const BorderSide(color: Colors.blue),
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
              const Text(
                'Example: JarvisCopi | Professional Translator | Writing Expert | Code Assistant',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 20),
              TextFormField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Enter bot description...',
                  filled: true,
                  fillColor: Colors.grey[100],
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
                    borderSide: const BorderSide(color: Colors.blue),
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
              const Text(
                'Example: You are an experienced translator with skills in multiple global languages.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                value: _accessOption,
                items: const [
                  DropdownMenuItem(
                    value: 1,
                    child: Text('Publish'),
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
                  fillColor: Colors.grey[100],
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
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                elevation: 2,
              ),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _saveBot,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                elevation: 2,
              ),
              child: const Text(
                "Create Now",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}