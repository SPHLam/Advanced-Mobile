import 'package:flutter/material.dart';
import 'package:project_ai_chat/services/analytics_service.dart';
import 'package:provider/provider.dart';
import 'package:project_ai_chat/viewmodels/bot_view_model.dart';
import 'package:url_launcher/url_launcher.dart';

class PublishMessenger extends StatefulWidget {
  const PublishMessenger({super.key, required this.assistantId});
  final String assistantId;

  @override
  State<PublishMessenger> createState() => _PublishMessengerState();
}

class _PublishMessengerState extends State<PublishMessenger> {
  final TextEditingController _botTokenController = TextEditingController();
  final TextEditingController _pageIdController = TextEditingController();
  final TextEditingController _appSecretController = TextEditingController();
  final String _url = 'https://jarvis.cx/help/knowledge-base/publish-bot/messenger';
  final _formKey = GlobalKey<FormState>();

  Future<void> _openLink() async {
    final uri = Uri.parse(_url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Cannot open URL: $_url';
    }
  }

  String? _validateBotToken(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bot Token is required';
    }
    if (value.length < 20) {
      return 'Bot Token is too short';
    }
    return null;
  }

  String? _validatePageId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Page ID is required';
    }
    // Page ID thường là số hoặc chuỗi số
    final RegExp pageIdRegex = RegExp(r'^\d+$');
    if (!pageIdRegex.hasMatch(value)) {
      return 'Page ID must be numeric';
    }
    if (value.length < 10) {
      return 'Page ID is too short';
    }
    return null;
  }

  String? _validateAppSecret(String? value) {
    if (value == null || value.isEmpty) {
      return 'App Secret is required';
    }
    if (value.length < 30) {
      return 'App Secret is too short';
    }
    return null;
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = Provider.of<BotViewModel>(context, listen: false);
    bool isSuccess = await provider.publishToMessenger(
      widget.assistantId,
      _botTokenController.text,
      _pageIdController.text,
      _appSecretController.text,
    );

    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully published to Messenger'),
          backgroundColor: Colors.green,
        ),
      );
      AnalyticsService().logEvent("publish_messenger", {
        "bot_token": _botTokenController.text,
        "page_id": _pageIdController.text,
        // Không log app_secret vì lý do bảo mật
      });
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to publish to Messenger'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey.shade400],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Messenger",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  InkWell(
                    onTap: _openLink,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
              const SizedBox(height: 20),
              TextFormField(
                controller: _botTokenController,
                validator: _validateBotToken,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Bot Token',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pageIdController,
                validator: _validatePageId,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Page ID',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _appSecretController,
                validator: _validateAppSecret,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'App Secret',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      backgroundColor: Colors.blue.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Consumer<BotViewModel>(
                      builder: (context, botViewModel, child) {
                        return botViewModel.isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                            : const Text(
                          "Publish",
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