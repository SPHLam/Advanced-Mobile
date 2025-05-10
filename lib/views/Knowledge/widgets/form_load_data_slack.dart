import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_ai_chat/viewmodels/knowledge_base_view_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class FormLoadDataSlack extends StatefulWidget {
  const FormLoadDataSlack(
      {super.key, required this.addNewData, required this.knowledgeId});
  final void Function(String newData) addNewData;
  final String knowledgeId;

  @override
  State<FormLoadDataSlack> createState() => _FormLoadDataSlackState();
}

class _FormLoadDataSlackState extends State<FormLoadDataSlack> {
  final _formKey = GlobalKey<FormState>();
  String _enteredName = "";
  String _enteredSlackBotToken = "";
  final String url = 'https://jarvis.cx/help/knowledge-base/connectors/slack/';

  void _saveFile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      bool isSuccess =
      await Provider.of<KnowledgeBaseViewModel>(context, listen: false)
          .uploadSlack(widget.knowledgeId, _enteredName, _enteredSlackBotToken);

      if (isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully connected'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to connect'),
            backgroundColor: Colors.red,
          ),
        );
      }

      widget.addNewData(_enteredName);
      Navigator.pop(context);
    }
  }

  Future<void> _openLink() async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Cannot open URL: $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey.shade400],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.network(
                        "https://static-00.iconduck.com/assets.00/slack-icon-2048x2048-vhdso1nk.png",
                        width: 40,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.storage,
                              size: 40, color: Colors.blue.shade600);
                        },
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Add Unit",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: _openLink,
                    child: Container(
                      padding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Docs',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Name',
                        hintText: 'Enter name',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon:
                        Icon(Icons.file_open, color: Colors.blue.shade600),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please input unit knowledge name';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredName = value!;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Slack Bot Token',
                        hintText: 'Enter Slack Bot Token',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon:
                        Icon(Icons.vpn_key, color: Colors.blue.shade600),
                      ),
                      obscureText: true, // Che nội dung Slack Bot Token
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please input slack bot token';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredSlackBotToken = value!;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saveFile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      backgroundColor: Colors.blue.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: Consumer<KnowledgeBaseViewModel>(
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
                          "Save",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
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