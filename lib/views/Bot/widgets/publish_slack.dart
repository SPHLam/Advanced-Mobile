import 'package:flutter/material.dart';
import 'package:project_ai_chat/services/analytics_service.dart';
import 'package:provider/provider.dart';
import 'package:project_ai_chat/viewmodels/bot_view_model.dart';
import 'package:url_launcher/url_launcher.dart';

class PublishSlack extends StatefulWidget {
  const PublishSlack({super.key, required this.assistantId});
  final String assistantId;

  @override
  State<PublishSlack> createState() => _PublishSlackState();
}

class _PublishSlackState extends State<PublishSlack> {
  final TextEditingController _botTokenController = TextEditingController();
  final TextEditingController _clientIdController = TextEditingController();
  final TextEditingController _clientSecretController = TextEditingController();
  final TextEditingController _signingSecretController = TextEditingController();
  final String _url = 'https://jarvis.cx/help/knowledge-base/publish-bot/slack';
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
    if (!value.startsWith('xoxb-')) {
      return 'Bot Token must start with "xoxb-"';
    }
    if (value.length < 20) {
      return 'Bot Token is too short';
    }
    return null;
  }

  String? _validateClientId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Client ID is required';
    }
    if (value.length < 10) {
      return 'Client ID is too short';
    }
    return null;
  }

  String? _validateClientSecret(String? value) {
    if (value == null || value.isEmpty) {
      return 'Client Secret is required';
    }
    if (value.length < 30) {
      return 'Client Secret is too short';
    }
    return null;
  }

  String? _validateSigningSecret(String? value) {
    if (value == null || value.isEmpty) {
      return 'Signing Secret is required';
    }
    if (value.length < 30) {
      return 'Signing Secret is too short';
    }
    return null;
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = Provider.of<BotViewModel>(context, listen: false);
    bool isSuccess = await provider.publishToSlack(
      widget.assistantId,
      _botTokenController.text,
      _clientIdController.text,
      _clientSecretController.text,
      _signingSecretController.text,
    );

    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully published to Slack'),
          backgroundColor: Colors.green,
        ),
      );
      AnalyticsService().logEvent("publish_slack", {
        "bot_token": _botTokenController.text,
        "client_id": _clientIdController.text,
        // Không log client_secret và signing_secret vì lý do bảo mật
      });
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to publish to Slack'),
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
                    "Slack",
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
                controller: _clientIdController,
                validator: _validateClientId,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Client ID',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _clientSecretController,
                validator: _validateClientSecret,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Client Secret',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _signingSecretController,
                validator: _validateSigningSecret,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Signing Secret',
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
                        return botViewModel.isLoading ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ) : const Text(
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