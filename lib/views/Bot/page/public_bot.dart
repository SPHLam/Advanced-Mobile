import 'package:flutter/material.dart';
import 'package:project_ai_chat/views/Bot/widgets/publish_platform.dart';

class PublicBot extends StatelessWidget {
  const PublicBot({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text(
                'Publish to',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Icon(
            Icons.warning,
            color: Colors.red,
            size: 30,
          ),
          const Text(
            'By publishing your bot on the following platforms, you fully understand and agree to abide by Terms of service for each publishing channel.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 20),
          const PublishPlatform(
            platformName: "Slack",
            imagePath:
                "https://static-00.iconduck.com/assets.00/slack-icon-2048x2048-vhdso1nk.png",
          ),
          const PublishPlatform(
            platformName: 'Messenger',
            imagePath:
                "https://cdn4.iconfinder.com/data/icons/social-media-2285/1024/logo-512.png",
          ),
          const PublishPlatform(
            platformName: 'Telegram',
            imagePath:
                "https://cdn.pixabay.com/photo/2021/12/27/10/50/telegram-icon-6896828_1280.png",
          ),
        ],
      ),
    );
  }
}
