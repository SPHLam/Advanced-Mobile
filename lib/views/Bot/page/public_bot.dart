import 'package:flutter/material.dart';
import 'package:project_ai_chat/views/Bot/widgets/publish_platform.dart';

class PublicBot extends StatelessWidget {
  const PublicBot({super.key, required this.assistantId});
  final String assistantId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Publish to Platforms',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red[50],
              ),
              child: const Icon(
                Icons.info,
                color: Colors.red,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'By publishing your bot on the following platforms, you agree to comply with each platform\'s Terms of Service.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Column(
            children: [
              PublishPlatform(
                platformName: "Slack",
                imagePath: "assets/logo/slack.png",
                assistantId: assistantId,
              ),
              PublishPlatform(
                platformName: 'Messenger',
                imagePath: "assets/logo/messenger.png",
                assistantId: assistantId,
              ),
              PublishPlatform(
                platformName: 'Telegram',
                imagePath: "assets/logo/telegram.png",
                assistantId: assistantId,
              ),
            ],
          ),
        ],
      ),
    );
  }
}