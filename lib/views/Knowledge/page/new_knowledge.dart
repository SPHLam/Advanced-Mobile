import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_ai_chat/viewmodels/knowledge_base_view_model.dart';
import 'package:project_ai_chat/models/knowledge.dart';
import 'package:project_ai_chat/views/Knowledge/widgets/load_data_knowledge.dart';
import 'package:provider/provider.dart';

class NewKnowledge extends StatefulWidget {
  const NewKnowledge({super.key, required this.addNewKnowledge});
  final void Function(String knowledgeName, String description) addNewKnowledge;

  @override
  State<NewKnowledge> createState() => _NewKnowledgeState();
}

class _NewKnowledgeState extends State<NewKnowledge> {
  final _formKey = GlobalKey<FormState>();
  String _enteredName = "";
  String _enteredDescription = "";

  void _saveKnowledgeBase() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      widget.addNewKnowledge(
        _enteredName,
        _enteredDescription,
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Create Knowledge Base',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter name',
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.title_rounded, color: Colors.blue),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please input name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredName = value!;
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'Example: Professional Translator | Writing Expert | Code Assistant',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 24),
              TextFormField(
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter description...',
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                onSaved: (value) {
                  _enteredDescription = value ?? "";
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'Example: You are an experienced translator skilled in multiple global languages.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveKnowledgeBase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Consumer<KnowledgeBaseProvider>(
                        builder: (context, kbProvider, child) {
                          return kbProvider.isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                              : const Text(
                            'Create',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ),
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