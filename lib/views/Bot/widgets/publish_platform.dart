import 'package:flutter/material.dart';
import 'package:project_ai_chat/views/Bot/widgets/publish_messenger.dart';
import 'package:project_ai_chat/views/Bot/widgets/publish_slack.dart';
import 'package:project_ai_chat/views/Bot/widgets/publish_telegram.dart';

class PublishPlatform extends StatelessWidget {
  const PublishPlatform({
    super.key,
    required this.platformName,
    required this.imagePath,
    required this.assistantId,
  });
  final String platformName;
  final String imagePath;
  final String assistantId;

  void _showPublishDialog(BuildContext context) {
    if (platformName == "Slack") {
      showDialog(
        context: context,
        builder: (context) => PublishSlack(assistantId: assistantId),
      );
    } else if (platformName == "Telegram") {
      showDialog(
        context: context,
        builder: (context) => PublishTelegram(assistantId: assistantId),
      );
    } else if (platformName == "Messenger") {
      showDialog(
        context: context,
        builder: (context) => PublishMessenger(assistantId: assistantId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          leading: Image.asset(imagePath),
          title: Text(platformName),
          trailing: ElevatedButton(
            onPressed: () => _showPublishDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Icon(
              Icons.publish,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}