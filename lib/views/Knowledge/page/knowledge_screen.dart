import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:jarvis/models/knowledge.dart';
import 'package:jarvis/views/Knowledge/page/edit_knowledge.dart';
import 'package:jarvis/views/Knowledge/page/new_knowledge.dart';
import 'package:jarvis/views/Knowledge/widgets/knowledge_card.dart';
import 'package:jarvis/services/analytics_service.dart';
import 'package:jarvis/viewmodels/knowledge_base_view_model.dart';
import 'package:provider/provider.dart';

class KnowledgeScreen extends StatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  State<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends State<KnowledgeScreen> {
  late ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          Provider.of<KnowledgeBaseProvider>(context, listen: false)
              .fetchAllKnowledgeBases(isLoadMore: true);
        }
      });
  }

  void _addKnowledge(String knowledgeName, String description) async {
    bool isSuccess =
        await Provider.of<KnowledgeBaseProvider>(context, listen: false)
            .addKnowledgeBase(knowledgeName, description);

    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully created '),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fail created '),
          backgroundColor: Colors.red,
        ),
      );
    }

    AnalyticsService().logEvent(
      "new_knowledge",
      {
        "name": knowledgeName,
        "description": description,
      },
    );
  }

  void _editKnowledge(
      String id, int index, String knowledgeName, String description) async {
    bool isSuccess =
        await Provider.of<KnowledgeBaseProvider>(context, listen: false)
            .editKnowledgeBase(id, index, knowledgeName, description);

    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully edited '),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fail edited '),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openAddBotDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => NewKnowledge(
        addNewKnowledge: (String knowledgeName, String description) {
          _addKnowledge(knowledgeName, description);
        },
      ),
    );
  }

  void _openEditKnowledgeDialog(
      BuildContext context, Knowledge knowledge, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditKnowledge(
          editKnowledge: (Knowledge knowledge) {
            _editKnowledge(
                knowledge.id, index, knowledge.name, knowledge.description);
          },
          knowledge: knowledge,
        ),
      ),
    );
  }

  void _removeKnowledge(String id, int index) async {
    bool isSuccess =
        await Provider.of<KnowledgeBaseProvider>(context, listen: false)
            .deleteKnowledgeBase(id, index);

    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully deleted '),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fail deleted '),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    Provider.of<KnowledgeBaseProvider>(context, listen: false).query(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Knowledge Bases",
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _openAddBotDialog(context);
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
                prefixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.grey),
                  onPressed: _onSearch,
                ),
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
              onChanged: (value) {
                _onSearch();
              },
              onSubmitted: (value) {
                _onSearch();
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Consumer<KnowledgeBaseProvider>(
                builder: (context, kbProvider, child) {
                  if (kbProvider.isLoading &&
                      kbProvider.knowledgeBases.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (kbProvider.error != null &&
                      kbProvider.knowledgeBases.isEmpty) {
                    return Center(
                      child: Text(
                        kbProvider.error ?? 'Server error, please try again',
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    );
                  }
                  if (kbProvider.knowledgeBases.isEmpty) {
                    return const Center(
                      child: Text(
                        'No knowledge base found',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    shrinkWrap: true,
                    itemCount: kbProvider.knowledgeBases.length + 1,
                    itemBuilder: (context, index) {
                      if (index == kbProvider.knowledgeBases.length) {
                        if (kbProvider.hasNext &&
                            kbProvider.knowledgeBases.length >= 8) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      }

                      final _listKnowledges = kbProvider.knowledgeBases;
                      return Slidable(
                        endActionPane: ActionPane(
                          motion: const StretchMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                _openEditKnowledgeDialog(
                                    context, _listKnowledges[index], index);
                              },
                              icon: Icons.edit,
                              backgroundColor: Colors.green,
                            ),
                            SlidableAction(
                              onPressed: (context) {
                                _removeKnowledge(
                                    _listKnowledges[index].id, index);
                              },
                              icon: Icons.delete,
                              backgroundColor: Colors.red,
                            ),
                          ],
                        ),
                        child: KnowledgeCard(
                          knowledge: _listKnowledges[index],
                        ),
                      );
                    },
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
