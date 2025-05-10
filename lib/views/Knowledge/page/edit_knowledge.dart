import 'package:flutter/material.dart';
import 'package:project_ai_chat/views/Knowledge/widgets/load_data_knowledge.dart';
import 'package:project_ai_chat/models/knowledge.dart';
import 'package:project_ai_chat/viewmodels/knowledge_base_view_model.dart';
import 'package:provider/provider.dart';
import 'package:project_ai_chat/core/Widget/delete_confirm_dialog.dart';

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
  late ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();
  String _enteredName = "";
  String _enteredPrompt = "";

  @override
  void initState() {
    super.initState();
    _enteredName = widget.knowledge.name;
    _enteredPrompt = widget.knowledge.description;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<KnowledgeBaseViewModel>(context, listen: false)
          .fetchUnitsOfKnowledge(false, widget.knowledge.id);
    });

    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          Provider.of<KnowledgeBaseViewModel>(context, listen: false)
              .fetchUnitsOfKnowledge(true, widget.knowledge.id);
        }
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _saveKnowledgeBase() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      widget.editKnowledge(
        Knowledge(
          name: _enteredName,
          description: _enteredPrompt,
          id: widget.knowledge.id,
          imageUrl: "assets/images/open-book.png",
        ),
      );
      Navigator.pop(context);
    }
  }

  String getImageByUnitType(String unitType) {
    switch (unitType) {
      case "local_file":
        return 'https://icon-library.com/images/files-icon-png/files-icon-png-10.jpg';
      case "gg_drive":
        return 'https://static-00.iconduck.com/assets.00/google-drive-icon-1024x1024-h7igbgsr.png';
      case "web":
        return 'https://cdn-icons-png.flaticon.com/512/5339/5339181.png';
      case "slack":
        return 'https://static-00.iconduck.com/assets.00/slack-icon-2048x2048-vhdso1nk.png';
      case "confluence":
        return 'https://static.wixstatic.com/media/f9d4ea_637d021d0e444d07bead34effcb15df1~mv2.png/v1/fill/w_340,h_340,al_c,lg_1,q_85,enc_auto/Apt-website-icon-confluence.png';
      default:
        return "";
    }
  }

  void _addNewFile(String newData) {}

  void _removeFile(String newData) {}

  void _showDeleteUnitDialog(BuildContext context, String unitId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteConfirmationDialog(
          title: 'Delete Unit',
          message: 'Are you sure you want to delete this unit?',
          onConfirm: () => _removeUnit(unitId),
        );
      },
    );
  }

  void _removeUnit(String unitId) async {
    bool isSuccess =
    await Provider.of<KnowledgeBaseViewModel>(context, listen: false)
        .deleteUnit(unitId, widget.knowledge.id);

    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Delete unit successful'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Delete unit failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleUnitStatus(String unitId, bool isActive) async {
    await Provider.of<KnowledgeBaseViewModel>(context, listen: false)
        .updateStatusUnit(widget.knowledge.id, unitId, isActive);
  }

  void _onSearch(String query) {
    Provider.of<KnowledgeBaseViewModel>(context, listen: false)
        .queryUnit(query.trim(), widget.knowledge.id);
  }

  void _showAddUnitsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add Knowledge Unit',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close, color: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LoadDataKnowledge(
                  addNewData: _addNewFile,
                  removeData: _removeFile,
                  knowledgeId: widget.knowledge.id,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
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
                                return 'Please input name';
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
                                return 'Please input the description';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredPrompt = value!;
                            },
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'List Units',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: _showAddUnitsDialog,
                                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                                label: const Text('Add Unit'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search units...',
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon:
                              const Icon(Icons.search, color: Colors.grey),
                            ),
                            onChanged: _onSearch,
                          ),
                          const SizedBox(height: 8),
                          Consumer<KnowledgeBaseViewModel>(
                            builder: (context, kbProvider, child) {
                              Knowledge kb = kbProvider
                                  .getKnowledgeById(widget.knowledge.id);

                              if (kbProvider.isLoading &&
                                  kb.listUnits.isEmpty) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (kbProvider.error != null &&
                                  kb.listUnits.isEmpty) {
                                return Center(
                                  child: Text(
                                    kbProvider.error ??
                                        'Server error, please try again',
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 16),
                                  ),
                                );
                              }

                              return SizedBox(
                                height: 300,
                                child: ListView.builder(
                                  controller: _scrollController,
                                  shrinkWrap: true,
                                  itemCount: kb.listUnits.length + 1,
                                  itemBuilder: (context, index) {
                                    if (index == kb.listUnits.length) {
                                      if (kbProvider.hasNextUnit) {
                                        return const Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Center(
                                              child: CircularProgressIndicator()),
                                        );
                                      } else {
                                        return const SizedBox.shrink();
                                      }
                                    }
                                    return Card(
                                      color: Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Image.network(
                                              getImageByUnitType(
                                                  kb.listUnits[index].unitType),
                                              width: 34,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return const Icon(Icons.storage);
                                              },
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                kb.listUnits[index].unitName,
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Switch(
                                                  value: kb.listUnits[index].isActived,
                                                  onChanged: (bool value) {
                                                    _toggleUnitStatus(kb.listUnits[index].unitId, value);
                                                  },
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.delete,
                                                    color: Colors.red.shade600,
                                                  ),
                                                  onPressed: kbProvider.isLoading ? null : () {
                                                    _showDeleteUnitDialog(context, kb.listUnits[index].unitId);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
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