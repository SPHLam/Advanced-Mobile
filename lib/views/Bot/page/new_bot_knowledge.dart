import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_ai_chat/models/knowledge.dart';
import 'package:project_ai_chat/viewmodels/bot_view_model.dart';
import 'package:project_ai_chat/viewmodels/knowledge_base_view_model.dart';
import 'package:provider/provider.dart';

class NewBotKnowledge extends StatefulWidget {
  const NewBotKnowledge({super.key});

  @override
  State<NewBotKnowledge> createState() => _NewBotKnowledgeState();
}

class _NewBotKnowledgeState extends State<NewBotKnowledge> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()
      ..addListener(() {
        // Khi cuộn đến cuối danh sách
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          Provider.of<KnowledgeBaseProvider>(context, listen: false)
              .fetchAllKnowledgeBases(isLoadMore: true);
        }
      });
  }

  void _addKnowledge(BuildContext context, String knowledgeId) {
    Provider.of<BotViewModel>(context, listen: false)
        .importKnowledge(knowledgeId);
    Navigator.of(context).pop(knowledgeId);
  }

  @override
  Widget build(BuildContext context) {
    final botModel = context.read<BotViewModel>();

    // final arrKnowledge =
    //     Provider.of<KnowledgeBaseProvider>(context, listen: false)
    //         .knowledgeBases
    //         .where((element) => !botModel.knowledgeList.contains(element.id))
    //         .map((element) => element.id).toList();

    // final List<Knowledge> arrKnowledge =
    //     Provider.of<KnowledgeBaseProvider>(context, listen: false)
    //         .knowledgeBases
    //         .where((element) =>
    //             !botModel.knowledgeList.any((item) => item.id == element.id))
    //         .toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text(
                'Thêm bộ dữ liệu tri thức',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Icon(
            Icons.addchart,
            color: Colors.blue,
            size: 30,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Consumer<KnowledgeBaseProvider>(
              builder: (context, kbProvider, child) {
                if (kbProvider.isLoading && kbProvider.knowledgeBases.isEmpty) {
                  // Display loading indicator while fetching conversations
                  return const Center(child: CircularProgressIndicator());
                }
                if (kbProvider.error != null &&
                    kbProvider.knowledgeBases.isEmpty) {
                  // Display error message if there's an error
                  return Center(
                    child: Text(
                      kbProvider.error ?? 'Server error, please try again',
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  );
                }
                final List<Knowledge> arrKnowledge = kbProvider.knowledgeBases
                    .where((element) => !botModel.knowledgeList
                        .any((item) => item.id == element.id))
                    .toList();

                return ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemCount: arrKnowledge.length + 1,
                  itemBuilder: (context, index) {
                    if (index == arrKnowledge.length) {
                      // Loader khi đang tải thêm
                      if (kbProvider.hasNext) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else {
                        return const SizedBox.shrink(); // Không còn dữ liệu
                      }
                    }

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Image.network(
                              'assets/images/open-book.png',
                              width: 30,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons
                                    .storage); // Hiển thị icon lỗi nếu không load được hình
                              },
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                arrKnowledge[index].name,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  iconSize: 20,
                                  color: Colors.blue,
                                  onPressed: () {
                                    _addKnowledge(
                                        context, arrKnowledge[index].id);
                                  },
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
