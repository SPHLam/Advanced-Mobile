import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jarvis/views/Knowledge/widgets/form_load_data.dart';
import 'package:jarvis/views/Knowledge/widgets/form_load_data_confluence.dart';
import 'package:jarvis/views/Knowledge/widgets/form_load_data_ggdrive.dart';
import 'package:jarvis/views/Knowledge/widgets/form_load_data_slack.dart';
import 'package:jarvis/views/Knowledge/widgets/form_load_data_web.dart';

class LoadDataKnowledge extends StatefulWidget {
  const LoadDataKnowledge({
    super.key,
    required this.addNewData,
    required this.removeData,
    required this.knowledgeId,
  });
  final String knowledgeId;
  final void Function(String newData) addNewData;
  final void Function(String newData) removeData;

  @override
  State<LoadDataKnowledge> createState() => _LoadDataKnowledgeState();
}

class _LoadDataKnowledgeState extends State<LoadDataKnowledge> {
  int _selectedIndex = 0;
  final List<Map<String, dynamic>> _options = [
    {
      'title': 'Local files',
      'subtitle': 'Upload pdf, docx, ...',
      'image':
          'https://icon-library.com/images/files-icon-png/files-icon-png-10.jpg'
    },
    {
      'title': 'Google drive',
      'subtitle': 'Connect Google drive to get data',
      'image':
          'https://static-00.iconduck.com/assets.00/google-drive-icon-1024x1024-h7igbgsr.png'
    },
    {
      'title': 'Website',
      'subtitle': 'Connect Website to get data',
      'image': 'https://cdn-icons-png.flaticon.com/512/5339/5339181.png'
    },
    {
      'title': 'Slack',
      'subtitle': 'Connect Slack to get data',
      'image':
          'https://static-00.iconduck.com/assets.00/slack-icon-2048x2048-vhdso1nk.png'
    },
    {
      'title': 'Confluence',
      'subtitle': 'Connect Confluence to get data',
      'image':
          'https://static.wixstatic.com/media/f9d4ea_637d021d0e444d07bead34effcb15df1~mv2.png/v1/fill/w_340,h_340,al_c,lg_1,q_85,enc_auto/Apt-website-icon-confluence.png'
    },
  ];

  void _handleOptionTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addNewFile(String name) {
    widget.addNewData(name);
  }

  void _openDialogAddFile(BuildContext context) {
    if (_selectedIndex == 0) {
      showDialog(
        context: context,
        builder: (context) => FormLoadData(
          addNewData: _addNewFile,
          knowledgeId: widget.knowledgeId,
        ),
      );
    } else if (_selectedIndex == 1) {
      showDialog(
          context: context,
          builder: (context) => FormLoadDataGGDrive(
                addNewData: _addNewFile,
              ));
    } else if (_selectedIndex == 2) {
      showDialog(
          context: context,
          builder: (context) => FormLoadDataWeb(
                addNewData: _addNewFile,
                knowledgeId: widget.knowledgeId,
              ));
    } else if (_selectedIndex == 3) {
      showDialog(
          context: context,
          builder: (context) => FormLoadDataSlack(
                addNewData: _addNewFile,
                knowledgeId: widget.knowledgeId,
              ));
    } else if (_selectedIndex == 4) {
      showDialog(
          context: context,
          builder: (context) => FormLoadDataConfluence(
                addNewData: _addNewFile,
                knowledgeId: widget.knowledgeId,
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Data Sources',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Column(
          children: _options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final bool isSelected = _selectedIndex == index;
            return Card(
              color: isSelected ? Colors.blue[100] : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color:
                      isSelected ? Colors.blue : Colors.grey.withOpacity(0.2),
                  width: isSelected ? 2 : 1,
                ),
              ),
              margin: EdgeInsets.symmetric(vertical: 8),
              child: GestureDetector(
                onTap: () => _handleOptionTap(index),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Image.network(
                        option['image'],
                        width: 34,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.storage);
                        },
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option['title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color:
                                    isSelected ? Colors.blue : Colors.black87,
                              ),
                            ),
                            Text(
                              option['subtitle'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 6),
        ElevatedButton(
          onPressed: () {
            _openDialogAddFile(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.upload,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(
                'Upload',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
