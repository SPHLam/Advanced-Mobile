import 'package:flutter/material.dart';
import '../model/knowledge.dart';
import '../widgets/load_data_knowledge.dart';

class EditKnowledge extends StatefulWidget {
  const EditKnowledge(
      {super.key, required this.editKnowledge, required this.knowledge});
  final void Function(Knowledge newKnowledge) editKnowledge;
  final Knowledge knowledge;

  @override
  State<EditKnowledge> createState() => _NewKnowledgeState();
}

class _NewKnowledgeState extends State<EditKnowledge> {
  final _formKey = GlobalKey<FormState>();
  String _enteredName = "";
  String _enteredPrompt = "";
  List<String> _listFiles = [];
  List<String> _listGGDrives = [];
  List<String> _listUrlWebsite = [];
  List<String> _listSlackFiles = [];
  List<String> _listConfluenceFiles = [];

  @override
  void initState() {
    super.initState();
    _enteredName = widget.knowledge.name;
    _enteredPrompt = widget.knowledge.description;
    _listFiles = List.from(widget.knowledge.listFiles);
    _listGGDrives = List.from(widget.knowledge.listGGDrives);
    _listUrlWebsite = List.from(widget.knowledge.listUrlWebsite);
    _listSlackFiles = List.from(widget.knowledge.listSlackFiles);
    _listConfluenceFiles = List.from(widget.knowledge.listConfluenceFiles);
  }

  void _saveKnowledgeBase() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.editKnowledge(
        Knowledge(
          name: _enteredName,
          description: _enteredPrompt,
          imageUrl: "assets/images/open-book.png",
          listFiles: _listFiles,
          listGGDrives: _listGGDrives,
          listUrlWebsite: _listUrlWebsite,
          listSlackFiles: _listSlackFiles,
          listConfluenceFiles: _listConfluenceFiles,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _addNewFile(String newData) {
    setState(() {
      _listFiles.add(newData);
    });
  }

  void _addGGDrive(String newData) {
    setState(() {
      _listGGDrives.add(newData);
    });
  }

  void _addUrlWebsite(String newData) {
    setState(() {
      _listUrlWebsite.add(newData);
    });
  }

  void _addSlackFiles(String newData) {
    setState(() {
      _listSlackFiles.add(newData);
    });
  }

  void _addConfluenceFiles(String newData) {
    setState(() {
      _listConfluenceFiles.add(newData);
    });
  }

  void _removeFile(String newData) {
    setState(() {
      _listFiles.remove(newData);
    });
  }

  void _removeGGDrive(String newData) {
    setState(() {
      _listGGDrives.remove(newData);
    });
  }

  void _removeUrlWebsite(String newData) {
    setState(() {
      _listUrlWebsite.remove(newData);
    });
  }

  void _removeSlackFiles(String newData) {
    setState(() {
      _listSlackFiles.remove(newData);
    });
  }

  void _removeConfluenceFiles(String newData) {
    setState(() {
      _listConfluenceFiles.remove(newData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.indigo,
        title: const Text(
          "Edit Knowledge Base",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Knowledge Details",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            initialValue: _enteredName,
                            decoration: InputDecoration(
                              labelText: "Name",
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a name';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredName = value!;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: _enteredPrompt,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: "Description",
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a description';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredPrompt = value!;
                            },
                          ),
                          const SizedBox(height: 24),
                          LoadDataKnowledge(
                            type: 1,
                            arrFile: _listFiles,
                            nameTypeData: "Files",
                            imageAddress:
                                'https://i0.wp.com/static.vecteezy.com/system/resources/previews/022/086/609/non_2x/file-type-icons-format-and-extension-of-documents-pdf-icon-free-vector.jpg?ssl=1',
                            addNewData: _addNewFile,
                            removeData: _removeFile,
                          ),
                          const SizedBox(height: 16),
                          LoadDataKnowledge(
                            type: 2,
                            arrFile: _listGGDrives,
                            nameTypeData: "Google Drive",
                            imageAddress:
                                "https://static-00.iconduck.com/assets.00/google-drive-icon-1024x1024-h7igbgsr.png",
                            addNewData: _addGGDrive,
                            removeData: _removeGGDrive,
                          ),
                          const SizedBox(height: 16),
                          LoadDataKnowledge(
                            type: 3,
                            arrFile: _listUrlWebsite,
                            nameTypeData: "Website URLs",
                            imageAddress:
                                "https://cdn-icons-png.flaticon.com/512/5339/5339181.png",
                            addNewData: _addUrlWebsite,
                            removeData: _removeUrlWebsite,
                          ),
                          const SizedBox(height: 16),
                          LoadDataKnowledge(
                            type: 4,
                            arrFile: _listSlackFiles,
                            nameTypeData: "Slack Files",
                            imageAddress:
                                "https://static-00.iconduck.com/assets.00/slack-icon-2048x2048-vhdso1nk.png",
                            addNewData: _addSlackFiles,
                            removeData: _removeSlackFiles,
                          ),
                          const SizedBox(height: 16),
                          LoadDataKnowledge(
                            type: 5,
                            arrFile: _listConfluenceFiles,
                            nameTypeData: "Confluence Files",
                            imageAddress:
                                "https://static.wixstatic.com/media/f9d4ea_637d021d0e444d07bead34effcb15df1~mv2.png/v1/fill/w_340,h_340,al_c,lg_1,q_85,enc_auto/Apt-website-icon-confluence.png",
                            addNewData: _addConfluenceFiles,
                            removeData: _removeConfluenceFiles,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveKnowledgeBase,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
