import 'package:flutter/material.dart';
import 'package:jarvis/views/EmailChat/widgets/button_custom.dart';
import 'package:jarvis/views/EmailChat/widgets/textformfield_custom.dart';
import 'package:jarvis/core/Widget/dropdown_button.dart';
import 'package:jarvis/viewmodels/emailchat_view_model.dart';
import 'package:jarvis/viewmodels/homechat_view_model.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/aichat_list_view_model.dart';
import '../../models/ai_logo.dart';

class EmailComposer extends StatefulWidget {
  @override
  _EmailComposerState createState() => _EmailComposerState();
}

class _EmailComposerState extends State<EmailComposer> {
  final TextEditingController _emailReceivedController =
      TextEditingController();
  final TextEditingController _aiActionController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _senderController = TextEditingController();
  final TextEditingController _receiverController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();
  late String selectedAIItem;
  late List<AIItem> _listAIItem;
  int? _token;
  final _formKey = GlobalKey<FormState>();
  String? _selectedIdea;
  @override
  void initState() {
    super.initState();
    _listAIItem = Provider.of<AIChatList>(context, listen: false).aiItems;
    int? maxtoken =
        Provider.of<HomeChatViewModel>(context, listen: false).maxTokens;
    if (maxtoken == 99999)
      _token = 99999;
    else {
      int remaningToken =
          Provider.of<HomeChatViewModel>(context, listen: false).remainingUsage;
      _token = remaningToken;
    }
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
      _aiActionController.text = draft;
    });
  }

  void _updateSelectedAIItem(String newValue) {
    setState(() {
      selectedAIItem = newValue;
      AIItem aiItem =
          _listAIItem.firstWhere((aiItem) => aiItem.name == newValue);

      // Cập nhật selectedAIItem trong AIChatList
      Provider.of<AIChatList>(context, listen: false).setSelectedAIItem(aiItem);

      // Di chuyển item được chọn lên đầu danh sách
      _listAIItem.removeWhere((aiItem) => aiItem.name == newValue);
      _listAIItem.insert(0, aiItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Spacer(),
          AIDropdown(
            listAIItems: _listAIItem,
            onChanged: (String? newValue) {
              if (newValue != null) {
                _updateSelectedAIItem(newValue);
              }
            },
          ),
          SizedBox(
            width: 10,
          ),
          Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 238, 240, 243),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Consumer<EmailChatViewModel>(
                builder: (context, emailViewModel, _) {
              int? tokenCount = emailViewModel.remainingUsage;
              return Row(
                children: [
                  const Icon(
                    Icons.flash_on,
                    color: Colors.orange,
                  ),
                  _token == 99999
                      ? const Text(
                          "Unlimited",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange,
                          ),
                        )
                      : Text(
                          '${tokenCount != null ? tokenCount : _token}',
                          style: const TextStyle(
                              color: Color.fromRGBO(119, 117, 117, 1.0)),
                        ),
                ],
              );
            }),
          ),
          SizedBox(
            width: 15,
          )
        ],
      ),
      body: Consumer<EmailChatViewModel>(
        builder: (context, emailViewModel, child) {
          if (emailViewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 10.0, left: 16.0, right: 16.0, bottom: 10.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Received Email',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            buildTextFormField(
                                'Action', _aiActionController, 1),
                            const SizedBox(height: 10),
                            buildTextFormField(
                                'Email content', _emailReceivedController, 5),
                            const SizedBox(height: 10),
                            buildTextFormField(
                                'Subject', _subjectController, 1),
                            const SizedBox(height: 10),
                            buildTextFormField('Sender', _senderController, 1),
                            const SizedBox(height: 10),
                            buildTextFormField(
                                'Receiver', _receiverController, 1),
                            const SizedBox(height: 10),
                            buildTextFormField(
                                'Language', _languageController, 1),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    if (emailViewModel.ideas != null) ...[
                      const SizedBox(height: 20),
                      Column(
                        children: [
                          Text(
                            'Please choose idea',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: emailViewModel.ideas!.map((idea) {
                              return ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _selectedIdea == idea
                                        ? Colors.blue[300]
                                        : Colors.grey[200],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () async {
                                    await Provider.of<EmailChatViewModel>(
                                            context,
                                            listen: false)
                                        .fetchEmailResponse(
                                            mainIdea: idea,
                                            action: _aiActionController.text,
                                            email:
                                                _emailReceivedController.text,
                                            subject: _subjectController.text,
                                            sender: _senderController.text,
                                            receiver: _receiverController.text,
                                            language: _languageController.text);
                                    setState(() {
                                      _selectedIdea = idea;
                                    });
                                  },
                                  child: Text(
                                    idea,
                                    style: TextStyle(
                                      color: _selectedIdea == idea
                                          ? Colors.white
                                          : Colors.black87,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ));
                            }).toList(),
                          ),
                        ],
                      ),
                    ],
                    if (emailViewModel.emailReply != null) ...[
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 10.0, left: 16.0, right: 16.0, bottom: 10.0),
                          child: Container(
                            constraints: BoxConstraints(
                              minHeight: 100,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Reply Email',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                if (emailViewModel.emailReply != null)
                                  Text(
                                    '${emailViewModel.emailReply}',
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 15),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        buildButton('Thanks', () => _createDraft('Thanks')),
                        buildButton('Sorry', () => _createDraft('Sorry')),
                        buildButton('Yes', () => _createDraft('Yes')),
                        buildButton('No', () => _createDraft('No')),
                        buildButton(
                            'Follow Up', () => _createDraft('Follow Up')),
                        buildButton('Request for more information',
                            () => _createDraft('Request for more information')),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              border:
                                  Border.all(color: Colors.grey, width: 1.0),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Enter your message...',
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 10),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await Provider.of<EmailChatViewModel>(context,
                                      listen: false)
                                  .getEmailSuggestions(
                                      action: _aiActionController.text,
                                      email: _emailReceivedController.text,
                                      subject: _subjectController.text,
                                      sender: _senderController.text,
                                      receiver: _receiverController.text,
                                      language: _languageController.text);
                            }
                          },
                          icon: Icon(Icons.send),
                          color: Colors.black87,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
