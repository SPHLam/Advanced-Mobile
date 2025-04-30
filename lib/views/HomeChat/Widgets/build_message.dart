import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:jarvis/models/response/message_response.dart';
import 'package:jarvis/utils/exceptions/chat_exception.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../viewmodels/homechat_view_model.dart';

class BuildMessage extends StatelessWidget {
  final Message message;

  const BuildMessage({
    Key? key,
    required this.message,
  }) : super(key: key);

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      // } else {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('Cannot open link: $url')),
      //   );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isUser = message.role == 'user';
    bool isError = message.isErrored ?? false;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isError
              ? Colors.red[100]
              : (isUser ? Colors.blue[100] : Colors.grey[200]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Consumer<MessageModel>(builder: (context, messageModel, child) {
          if (!isUser && message.content.isEmpty && messageModel.isSending) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Loading...',
                  style: TextStyle(
                    color: isError ? Colors.red : Colors.black,
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              isUser
                  ? Column(
                      children: [
                        if (message.imagePaths != null &&
                            message.imagePaths!.isNotEmpty) ...[
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: message.imagePaths!.map((path) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(path),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                        Text(
                          message.content,
                          style: TextStyle(
                              color: isError ? Colors.red : Colors.black),
                        ),
                      ],
                    )
                  : MarkdownBody(
                      data: message.content,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                            color: isError ? Colors.red : Colors.black),
                        a: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        listBullet: TextStyle(
                            color: isError ? Colors.red : Colors.black),
                      ),
                      selectable: true,
                      onTapLink: (text, href, title) {
                        if (href != null) {
                          _launchURL(href);
                        }
                      },
                    )
            ],
          );
        }),
      ),
    );
  }
}
