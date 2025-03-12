import 'package:flutter/material.dart';
import '../data/knowledge_data.dart';
import '../model/knowledge.dart';
import './edit_knowledge.dart';
import './new_knowledge.dart';
import '../widgets/knowledge_card.dart';

class KnowledgeScreen extends StatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  State<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends State<KnowledgeScreen> {
  final List<Knowledge> _listKnowledge = knowledge;
  List<Knowledge> _filteredKnowledge = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredKnowledge = List.from(_listKnowledge);
    _searchController.addListener(_filterKnowledge);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterKnowledge() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredKnowledge = List.from(_listKnowledge);
      } else {
        _filteredKnowledge = _listKnowledge.where((knowledge) {
          return knowledge.name.toLowerCase().contains(query) ||
              knowledge.description.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _addKnowledge(Knowledge newKnowledge) {
    setState(() {
      _listKnowledge.add(newKnowledge);
      _filterKnowledge();
    });
  }

  void _editKnowledge(Knowledge newEditKnowledge, int indexEdit) {
    setState(() {
      _listKnowledge[indexEdit] = newEditKnowledge;
      _filterKnowledge();
    });
  }

  void _removeKnowledge(Knowledge knowledge) {
    final knowledgeDeleteIndex = _listKnowledge.indexOf(knowledge);
    setState(() {
      _listKnowledge.remove(knowledge);
      _filterKnowledge();
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.grey[800],
        content: const Text("Knowledge Base has been deleted!"),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.cyan,
          onPressed: () {
            setState(() {
              _listKnowledge.insert(knowledgeDeleteIndex, knowledge);
              _filterKnowledge();
            });
          },
        ),
      ),
    );
  }

  void _openAddKnowledgeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => NewKnowledge(
        addNewKnowledge: (newKnowledge) {
          _addKnowledge(newKnowledge);
        },
      ),
    );
  }

  void _openEditKnowledgeDialog(
      BuildContext context, Knowledge knowledge, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditKnowledge(
          editKnowledge: (knowledge) {
            _editKnowledge(knowledge, index);
          },
          knowledge: knowledge,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Knowledge Hub",
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _openAddKnowledgeDialog(context);
            },
            icon: const Icon(Icons.add),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                hintText: 'Search Knowledge...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.cyan),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _filteredKnowledge.isEmpty
                  ? const Center(
                      child: Text(
                        "No knowledge available",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredKnowledge.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              KnowledgeCard(
                                  knowledge: _filteredKnowledge[index]),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 15, right: 13),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () {
                                        _openEditKnowledgeDialog(context,
                                            _filteredKnowledge[index], index);
                                      },
                                      icon: const Icon(Icons.edit, size: 18),
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 6),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () {
                                        _removeKnowledge(
                                            _filteredKnowledge[index]);
                                      },
                                      icon: const Icon(Icons.delete, size: 18),
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
