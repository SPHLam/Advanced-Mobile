import 'package:flutter/material.dart';
import './form_load_data.dart';
import './form_load_data_confluence.dart';
import './form_load_data_ggdrive.dart';
import './form_load_data_slack.dart';
import './form_load_data_web.dart';

class LoadDataKnowledge extends StatefulWidget {
  const LoadDataKnowledge(
      {super.key,
      required this.type,
      required this.arrFile,
      required this.nameTypeData,
      required this.imageAddress,
      required this.addNewData,
      required this.removeData});
  final int type;
  final List<String> arrFile;
  final String nameTypeData;
  final String imageAddress;
  final void Function(String newData) addNewData;
  final void Function(String newData) removeData;

  @override
  State<LoadDataKnowledge> createState() => _LoadDataKnowledgeState();
}

class _LoadDataKnowledgeState extends State<LoadDataKnowledge> {
  void _openDialogAddFile(BuildContext context) {
    if (widget.type == 1) {
      showDialog(
          context: context,
          builder: (context) => FormLoadData(
                addNewData: _addNewFile,
              ));
    } else if (widget.type == 2) {
      showDialog(
          context: context,
          builder: (context) => FormLoadDataGGDrive(
                addNewData: _addNewFile,
              ));
    } else if (widget.type == 3) {
      showDialog(
          context: context,
          builder: (context) => FormLoadDataWeb(
                addNewData: _addNewFile,
              ));
    } else if (widget.type == 4) {
      showDialog(
          context: context,
          builder: (context) => FormLoadDataSlack(
                addNewData: _addNewFile,
              ));
    } else if (widget.type == 5) {
      showDialog(
          context: context,
          builder: (context) => FormLoadDataConfluence(
                addNewData: _addNewFile,
              ));
    }
  }

  void _addNewFile(String name) {
    widget.addNewData(name);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(widget.nameTypeData),
        ),
        Column(
          children: widget.arrFile
              .map(
                (knowledge) => Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Image.network(
                          widget.imageAddress,
                          width: 34,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.storage);
                          },
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            knowledge,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete),
                              iconSize: 20,
                              onPressed: () {
                                widget.removeData(knowledge);
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(
          height: 6,
        ),
        ElevatedButton(
          onPressed: () {
            _openDialogAddFile(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // Background color
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
        )
      ],
    );
  }
}
