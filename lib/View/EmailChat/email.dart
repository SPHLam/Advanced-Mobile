
import 'package:flutter/material.dart';
import '../../core/Widget/dropdown-button.dart';
import 'package:provider/provider.dart';

import '../../ViewModel/ai-chat-list.dart';
import '../HomeChat/model/ai-logo-list.dart';

class EmailComposer extends StatefulWidget {
  @override
  _EmailComposerState createState() => _EmailComposerState();
}

class _EmailComposerState extends State<EmailComposer> {
  final TextEditingController _emailReceivedController = TextEditingController();
  final TextEditingController _emailReplyController = TextEditingController();
  late int _countToken ;
  late List<AIItem> _listAIItems;
  @override
  void initState() {
    _listAIItems = Provider.of<AIChatList>(context,listen: false).aiItems;
    _countToken = _listAIItems.first.tokenCount;
    super.initState();
  }
  void _createDraft(String action) {
    String draft;
    switch (action) {
      case 'Thanks':
        draft = 'Thank you for your email.';
        break;
      case 'Sorry':
        draft = 'I apologize for any inconvenience caused.';
        break;
      case 'Yes':
        draft = 'Yes, I agree with your proposal.';
        break;
      case 'No':
        draft = 'No, I do not agree with your proposal.';
        break;
      case 'Follow Up':
        draft = 'I am following up on our previous conversation.';
        break;
      case 'Request for more information':
        draft = 'Could you please provide more information?';
        break;
      default:
        draft = '';
    }
    setState(() {
      _emailReplyController.text = draft;
    });
  }
  Widget _buildTextField(String label, TextEditingController controller) {
    return Expanded(
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.blue,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.blue,
              width: 1.0,
            ),
          ),
        ),
        maxLines: 20,
      ),
    );
  }
  Widget _buildButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              label,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back,size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Spacer(),
          Container(
            width: 140,
            child: AIDropdown(
              listAIItems: _listAIItems,
              onChanged: (value) {
                setState(() {
                  _countToken = _listAIItems.firstWhere((element) => element.name == value).tokenCount;
                });
              },
            ),
          ),
          SizedBox(width: 10,),
          Container(
            padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              children: [
                Icon(
                  size: 20,
                  Icons.flash_on,
                  color: Colors.orangeAccent,
                ),
                Text(
                  '$_countToken',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10,)
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField('Email received', _emailReceivedController),
            const SizedBox(height: 20),
            _buildTextField('AI reply', _emailReplyController),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              children: [
                _buildButton('Thanks',() => _createDraft('Thanks')),
                _buildButton('Explain more detail for me', () => _createDraft('Explain more detail for me')),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.grey, width: 1.0),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter your message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(color: Colors.black, width: 1),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.send),
                  color: Colors.grey[600], // Icon color
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            )
          ],
        ),
      ),
    );
  }
}