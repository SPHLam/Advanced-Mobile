import 'package:flutter/material.dart';

class PromptDetails extends StatefulWidget {
  final String itemTitle;
  final String content;
  final String category;
  final String description;
  final bool isPublic;
  final bool isFavorite;

  const PromptDetails({
    super.key,
    required this.itemTitle,
    this.content = '',
    this.category = 'Other',
    this.description = '',
    this.isPublic = false,
    this.isFavorite = false,
  });

  static Future<String?> show(BuildContext context, {
    required String itemTitle,
    String content = '',
    String category = 'Other',
    String description = '',
    bool isPublic = false,
    bool isFavorite = false,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => PromptDetails(
        itemTitle: itemTitle,
        content: content,
        category: category,
        description: description,
        isPublic: isPublic,
        isFavorite: isFavorite,
      ),
    );
  }

  @override
  State<PromptDetails> createState() => _PromptDetails();
}

class _PromptDetails extends State<PromptDetails> {
  bool isPromptVisible = false;
  String selectedLanguage = 'English';
  late TextEditingController contentController;
  late List<String> placeholders;
  late List<String> inputs;

  @override
  void initState() {
    super.initState();
    contentController = TextEditingController(text: widget.content);
    placeholders = extractPlaceholders(widget.content);
    inputs = List.filled(placeholders.length, '');
  }

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }

  List<String> extractPlaceholders(String content) {
    final regex = RegExp(r'\[(.+?)\]');
    return regex.allMatches(content).map((match) => match.group(1) ?? '').toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.itemTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Category',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.category,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Description',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.description.isEmpty ? 'No description' : widget.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => setState(() => isPromptVisible = !isPromptVisible),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isPromptVisible ? 'Hide Prompt' : 'View Prompt',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (isPromptVisible) ...[
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 120,
                          child: TextField(
                            controller: contentController,
                            maxLines: null,
                            expands: true,
                            readOnly: widget.isPublic,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        if (!widget.isPublic) ...[
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, contentController.text);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Save', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ],
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 6,
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Output Language',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            DropdownButton<String>(
                              value: selectedLanguage,
                              items: ['English', 'Japanese', 'Spanish', 'French', 'German']
                                  .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                                  .toList(),
                              onChanged: (value) => setState(() => selectedLanguage = value!),
                              underline: const SizedBox(),
                              icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      for (int i = 0; i < placeholders.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: TextField(
                            onChanged: (value) => inputs[i] = value,
                            decoration: InputDecoration(
                              hintText: placeholders[i],
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.blue[600]!),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: ElevatedButton(
                            onPressed: () {
                              String updatedContent = contentController.text;
                              final regex = RegExp(r'\[(.+?)\]');
                              int index = 0;
                              updatedContent = updatedContent.replaceAllMapped(regex, (match) {
                                if (index < inputs.length && inputs[index].isNotEmpty) {
                                  return inputs[index++];
                                }
                                return match.group(0)!;
                              });
                              updatedContent += "\nRespond in $selectedLanguage";
                              Navigator.pop(context, updatedContent);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Send',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}