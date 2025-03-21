import 'package:flutter/material.dart';
import 'package:jarvis/views/Prompt/widgets/new_prompt.dart';
import 'package:jarvis/views/Prompt/widgets/prompt_details.dart';

import '../../constants/colors.dart';

class PromptScreen extends StatefulWidget {
  const PromptScreen({super.key});

  @override
  State<PromptScreen> createState() => _PromptScreenState();
}

class _PromptScreenState extends State<PromptScreen> {
  int selectedSegment = 0;
  bool isExpanded = false;
  List<bool> isStarred = List.generate(10, (_) => false);
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openPromptDetailsDialog(BuildContext context, String itemTitle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return PromptDetails(itemTitle: itemTitle);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Prompt Library",
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
        ),
        actions: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: IconButton(
              onPressed: () {
                NewPrompt.show(context);
              },
              icon: const Icon(Icons.add),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSegmentedControl(),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildPromptType(),
            const SizedBox(height: 16),
            Expanded(child: _buildPromptsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedControl() => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 4)],
    ),
    child: Row(children: [_buildSegmentOption('My Prompts', 0), _buildSegmentOption('Public Prompts', 1)]),
  );

  Widget _buildSegmentOption(String label, int index) => Expanded(
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => selectedSegment = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selectedSegment == index ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selectedSegment == index ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildSearchBar() => Row(
    children: [
      Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 4)],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              hintText: 'Search...',
              hintStyle: TextStyle(color: Colors.grey[600]),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => setState(() {
            bool allStarred = isStarred.every((starred) => starred);
            isStarred = List.generate(10, (_) => !allStarred);
          }),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 4)],
            ),
            child: Icon(
              isStarred.every((starred) => starred) ? Icons.star : Icons.star_border,
              color: isStarred.every((starred) => starred) ? Colors.yellow[700] : Colors.grey[600],
            ),
          ),
        ),
      ),
    ],
  );

  Widget _buildPromptType() => Row(
    children: [
      Expanded(
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            isExpanded ? 10 : 3,
                (index) => Chip(
              label: Text('Type ${index + 1}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.blue[900])),
              backgroundColor: Colors.blue[50],
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ),
      ),
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: IconButton(
          icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
          onPressed: () => setState(() => isExpanded = !isExpanded),
        ),
      ),
    ],
  );

  Widget _buildPromptsList() => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 4)],
    ),
    child: ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: 10,
      itemBuilder: (context, index) {
        final title = 'Title $index';
        final description = 'This is a description for title $index.';
        if (searchQuery.isNotEmpty &&
            !title.toLowerCase().contains(searchQuery) &&
            !description.toLowerCase().contains(searchQuery)) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => _openPromptDetailsDialog(context, title),
                    child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                Row(
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => setState(() => isStarred[index] = !isStarred[index]),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0), // Increased touch area
                          child: Icon(
                            isStarred[index] ? Icons.star : Icons.star_border,
                            color: isStarred[index] ? Colors.yellow[700] : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => _openPromptDetailsDialog(context, title),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0), // Increased touch area
                          child: Icon(Icons.arrow_right, color: Colors.grey[600]),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description, style: TextStyle(color: Colors.grey[600])),
            const Divider(),
          ],
        );
      },
    ),
  );
}