import 'package:flutter/material.dart';
import 'package:jarvis/views/Prompt/widgets/new_prompt.dart';
import 'package:jarvis/views/Prompt/widgets/prompt_details.dart';
import 'package:jarvis/viewmodels/prompt_list_view_model.dart';
import 'package:jarvis/models/prompt_list.dart';
import 'package:jarvis/models/prompt.dart';
import 'enums.dart';

class PromptScreen extends StatefulWidget {
  const PromptScreen({super.key});

  @override
  State<PromptScreen> createState() => _PromptScreenState();
}

class _PromptScreenState extends State<PromptScreen> {
  int selectedSegment = 0;
  bool isExpanded = false;
  late Future<PromptList> promptsFuture;
  String searchQuery = '';
  Category? selectedCategory;
  bool _showFavoritesOnly = false;
  final TextEditingController _searchController = TextEditingController();
  final PromptListViewModel viewModel = PromptListViewModel();
  final Map<String, bool> _favoriteStates = {};

  @override
  void initState() {
    super.initState();
    _refreshPrompts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshPrompts() {
    setState(() {
      promptsFuture = viewModel.fetchPrompts(
        category: selectedCategory?.value ?? 'all',
        query: searchQuery,
        isFavorite: _showFavoritesOnly,
        isPublic: selectedSegment == 1,
      );
    });
  }

  Future<void> _toggleFavorite(String promptId, bool isFavorite) async {
    final success = await viewModel.toggleFavorite(promptId, isFavorite);
    if (success) {
      setState(() {
        _favoriteStates[promptId] = !isFavorite;
        _refreshPrompts();
      });
    }
  }

  Future<void> _deletePrompt(String promptId) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final success = await viewModel.deletePrompt(promptId);
    if (success) {
      _refreshPrompts();
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Failed to delete prompt.')),
      );
    }
  }

  void _openPromptDetailsDialog(BuildContext context, Prompt prompt) {
    PromptDetails.show(
      context,
      promptId: prompt.id,
      itemTitle: prompt.title,
      content: prompt.content,
      category: prompt.category,
      description: prompt.description,
      language: prompt.language,
      isPublic: prompt.isPublic,
      isFavorite: _favoriteStates[prompt.id] ?? prompt.isFavorite,
    ).then((result) {
      if (result != null) {
        setState(() {
          if (result['action'] == 'send') {
            Navigator.pop(context, result['content']);
          } else if (result['action'] == 'update') {
            _refreshPrompts();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue,
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
                final currentContext = context;
                NewPrompt.show(currentContext, onPromptCreated: () {
                  _refreshPrompts();
                });
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
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4)
          ],
        ),
        child: Row(children: [
          _buildSegmentOption('My Prompts', 0),
          _buildSegmentOption('Public Prompts', 1),
        ]),
      );

  Widget _buildSegmentOption(String label, int index) => Expanded(
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedSegment = index;
                _refreshPrompts();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color:
                    selectedSegment == index ? Colors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      selectedSegment == index ? Colors.white : Colors.black87,
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
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4)
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                    _refreshPrompts();
                  });
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showFavoritesOnly = !_showFavoritesOnly;
                  _refreshPrompts();
                });
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4)
                  ],
                ),
                child: Icon(
                  _showFavoritesOnly ? Icons.star : Icons.star_border,
                  color: _showFavoritesOnly
                      ? Colors.yellow[700]
                      : Colors.grey[600],
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
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = null;
                      _refreshPrompts();
                    });
                  },
                  child: Chip(
                    label: Text(
                      'All',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: selectedCategory == null
                            ? Colors.white
                            : Colors.blue[900],
                      ),
                    ),
                    backgroundColor: selectedCategory == null
                        ? Colors.blue
                        : Colors.blue[50],
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                for (var category
                    in (isExpanded ? Category.values : Category.values.take(3)))
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                        _refreshPrompts();
                      });
                    },
                    child: Chip(
                      label: Text(
                        category.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: selectedCategory == category
                              ? Colors.white
                              : Colors.blue[900],
                        ),
                      ),
                      backgroundColor: selectedCategory == category
                          ? Colors.blue
                          : Colors.blue[50],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
              ],
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
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4)
          ],
        ),
        child: FutureBuilder<PromptList>(
          future: promptsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.items.isEmpty) {
              return const Center(child: Text('No prompts found'));
            }
            final prompts = snapshot.data!.items;
            for (var prompt in prompts) {
              _favoriteStates[prompt.id] ??= prompt.isFavorite;
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: prompts.length,
              itemBuilder: (context, index) {
                final prompt = prompts[index];
                final isFavorite = _favoriteStates[prompt.id] ?? false;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () =>
                                  _openPromptDetailsDialog(context, prompt),
                              child: Text(
                                prompt.title,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () =>
                                    _toggleFavorite(prompt.id, isFavorite),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    isFavorite ? Icons.star : Icons.star_border,
                                    color: isFavorite
                                        ? Colors.yellow[700]
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            if (!(prompt.isPublic))
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () => _deletePrompt(prompt.id),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(Icons.delete_outline,
                                        color: Colors.grey),
                                  ),
                                ),
                              ),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () =>
                                    _openPromptDetailsDialog(context, prompt),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(Icons.arrow_right,
                                      color: Colors.grey[600]),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      prompt.description,
                      style: TextStyle(color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const Divider(),
                  ],
                );
              },
            );
          },
        ),
      );
}
