import 'package:flutter/material.dart';
import 'package:jarvis/view_models/knowledge_base_view_model.dart';
import 'package:provider/provider.dart';

class NewBotKnowledge extends StatelessWidget {
  const NewBotKnowledge({super.key, required this.arrKnowledgeAdded});
  final List<String> arrKnowledgeAdded;

  void _addKnowledge(BuildContext context, String nameKnowledge) {
    Navigator.of(context).pop(nameKnowledge);
  }

  @override
  Widget build(BuildContext context) {
    final arrKnowledge =
    Provider.of<KnowledgeBase>(context, listen: false)
        .knowledgeBases
        .where((element) => !arrKnowledgeAdded.contains(element));

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add Knowledge Base',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue[50],
              ),
              child: const Icon(
                Icons.library_add,
                color: Colors.blue,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (arrKnowledge.isEmpty)
            const Center(
              child: Text(
                'No available knowledge bases',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
          else
            ...arrKnowledge.map(
                  (knowledge) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: const Icon(Icons.book, color: Colors.blue),
                  title: Text(
                    knowledge,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.add_circle, color: Colors.blue[700]),
                    onPressed: () => _addKnowledge(context, knowledge),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}