import 'package:flutter/material.dart';
import 'package:jarvis/View/Bot/widgets/publish_platform.dart';

class PublicBot extends StatelessWidget {
  const PublicBot({super.key});

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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: const Column(
              children: [
                PublishPlatform(
                  platformName: "Slack",
                  imagePath:
                  "assets/logo/slack.png",
                ),
                PublishPlatform(
                  platformName: 'Messenger',
                  imagePath:
                  "assets/logo/messenger.png",
                ),
                PublishPlatform(
                  platformName: 'Telegram',
                  imagePath:
                  "assets/logo/telegram.png",
                ),
                PublishPlatform(
                  platformName: 'Facebook',
                  imagePath:
                  "assets/logo/facebook.png",
                ),
                PublishPlatform(
                  platformName: 'Discord',
                  imagePath:
                  "assets/logo/discord.png",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}