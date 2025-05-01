import 'package:flutter/material.dart';
import 'package:jarvis/viewmodels/prompt_list_view_model.dart';
import 'package:jarvis/models/prompt_model.dart';
import '../enums.dart';

class PromptDetails extends StatefulWidget {
  final String promptId, itemTitle, content, category, description, language;
  final bool isPublic, isFavorite;

  const PromptDetails({
    super.key,
    required this.promptId,
    required this.itemTitle,
    this.content = '',
    this.category = 'other',
    this.description = '',
    this.language = 'English',
    this.isPublic = false,
    this.isFavorite = false,
  });

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required String promptId,
    required String itemTitle,
    String content = '',
    String category = 'other',
    String description = '',
    String language = 'English',
    bool isPublic = false,
    bool isFavorite = false,
  }) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => PromptDetails(
        promptId: promptId,
        itemTitle: itemTitle,
        content: content,
        category: category,
        description: description,
        language: language,
        isPublic: isPublic,
        isFavorite: isFavorite,
      ),
    );
  }

  @override
  State<PromptDetails> createState() => _PromptDetails();
}

class _PromptDetails extends State<PromptDetails> {
  bool isPromptVisible = false, hasChanges = false;
  late Language selectedLanguage;
  late Category selectedCategory;
  late TextEditingController titleController,
      contentController,
      descriptionController;
  late List<String> placeholders, inputs;
  final viewModel = PromptListViewModel();

  @override
  void initState() {
    super.initState();
    selectedLanguage = widget.isPublic
        ? Language.English
        : Language.values.firstWhere(
            (e) => e.value == widget.language.toLowerCase(),
            orElse: () => Language.English,
          );
    selectedCategory = Category.values.firstWhere(
      (e) => e.value == widget.category.toLowerCase(),
      orElse: () => Category.other,
    );
    titleController = TextEditingController(text: widget.itemTitle);
    contentController = TextEditingController(text: widget.content);
    descriptionController = TextEditingController(text: widget.description);
    placeholders = RegExp(r'$$   (.+?)   $$')
        .allMatches(widget.content)
        .map((m) => m.group(1) ?? '')
        .toList();
    inputs = List.filled(placeholders.length, '');
    for (var c in [titleController, contentController, descriptionController])
      c.addListener(_checkForChanges);
  }

  @override
  void dispose() {
    for (var c in [titleController, contentController, descriptionController]) {
      c.removeListener(_checkForChanges);
      c.dispose();
    }
    super.dispose();
  }

  void _checkForChanges() {
    setState(() {
      hasChanges = titleController.text != widget.itemTitle ||
          contentController.text != widget.content ||
          selectedCategory.value != widget.category.toLowerCase() ||
          descriptionController.text != widget.description ||
          selectedLanguage.value != widget.language.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        color: Colors.white,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                child:
                    widget.isPublic ? _buildPublicView() : _buildEditableView(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 8),
            Text(widget.itemTitle,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87)),
          ],
        ),
      );

  Widget _buildPublicView() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCard([
            _buildReadOnlyField('Title', widget.itemTitle),
            const SizedBox(height: 16),
            _buildReadOnlyField('Category', selectedCategory.label),
            const SizedBox(height: 16),
            _buildReadOnlyField('Description', widget.description),
          ]),
          const SizedBox(height: 20),
          _buildTogglePromptButton(),
          if (isPromptVisible) ...[
            const SizedBox(height: 20),
            _buildPromptContent(),
          ],
          const SizedBox(height: 20),
          _buildLanguageDropdown(),
          const SizedBox(height: 20),
          ...placeholders.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildInputField(e.value, (v) => inputs[e.key] = v),
              )),
          const SizedBox(height: 24),
          _buildSendButton(),
        ],
      );

  Widget _buildEditableView() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCard([
            _buildTextField('Title', titleController, isRequired: true),
            const SizedBox(height: 16),
            _buildDropdown(
              'Category',
              selectedCategory,
              Category.values,
              (v) => setState(() {
                selectedCategory = v!;
                _checkForChanges();
              }),
              isRequired: true,
            ),
            const SizedBox(height: 16),
            _buildTextField('Description', descriptionController),
          ]),
          const SizedBox(height: 20),
          _buildTogglePromptButton(),
          if (isPromptVisible) ...[
            const SizedBox(height: 20),
            SizedBox(height: 120, child: _buildPromptTextField()),
          ],
          const SizedBox(height: 20),
          _buildLanguageDropdown(),
          const SizedBox(height: 20),
          ...placeholders.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildInputField(e.value, (v) => inputs[e.key] = v),
              )),
          const SizedBox(height: 24),
          if (hasChanges) ...[
            _buildSaveButton(),
            const SizedBox(height: 16),
          ],
          _buildSendButton(),
        ],
      );

  Widget _buildCard(List<Widget> children) => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      );

  Widget _buildTogglePromptButton() => Center(
        child: GestureDetector(
          onTap: () => setState(() => isPromptVisible = !isPromptVisible),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
                color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
            child: Text(
              isPromptVisible ? 'Hide Prompt' : 'View Prompt',
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
      );

  Widget _buildPromptContent() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
        child: Text(widget.content,
            style: const TextStyle(fontSize: 14, color: Colors.black87)),
      );

  Widget _buildPromptTextField() => TextField(
        controller: contentController,
        maxLines: null,
        expands: true,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
        ),
      );

  Widget _buildLanguageDropdown() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 6)
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Output Language',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87)),
            DropdownButton<Language>(
              value: selectedLanguage,
              items: Language.values
                  .map((v) => DropdownMenuItem(value: v, child: Text(v.label)))
                  .toList(),
              onChanged: (v) => setState(() {
                selectedLanguage = v!;
                _checkForChanges();
              }),
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
            ),
          ],
        ),
      );

  Widget _buildInputField(String hint, Function(String) onChanged) => TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue[600]!)),
        ),
      );

  Widget _buildSendButton() => SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            String updatedContent = contentController.text;
            final regex = RegExp(r'$$   (.+?)   $$');
            int index = 0;
            updatedContent = updatedContent.replaceAllMapped(
                regex,
                (m) => index < inputs.length && inputs[index].isNotEmpty
                    ? inputs[index++]
                    : m.group(0)!);
            updatedContent += "\nRespond in ${selectedLanguage.label}";
            Navigator.pop(
                context, {'action': 'send', 'content': updatedContent});
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[600],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.send, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Send',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );

  Widget _buildSaveButton() => SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () async {
            if (titleController.text.trim().isEmpty ||
                contentController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Please fill in all required fields!')));
              return;
            }
            if (widget.promptId.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid prompt ID.')));
              return;
            }
            final newPrompt = PromptRequest(
              language: selectedLanguage.value,
              title: titleController.text,
              category: selectedCategory.value,
              description: descriptionController.text,
              content: contentController.text,
              isPublic: widget.isPublic,
            );
            final success =
                await viewModel.updatePrompt(newPrompt, widget.promptId);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    success ? 'Prompt updated.' : 'Failed to update prompt.')));
            if (success) Navigator.pop(context, {'action': 'update'});
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
          ),
          child: const Text('Save',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600)),
        ),
      );

  Widget _buildReadOnlyField(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      );

  Widget _buildTextField(String label, TextEditingController controller,
          {bool isRequired = false}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800)),
              if (isRequired)
                const Text(' *',
                    style: TextStyle(
                        color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      );

  Widget _buildDropdown<T extends Enum>(
    String label,
    T value,
    List<T> items,
    ValueChanged<T?>? onChanged, {
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800)),
            if (isRequired)
              const Text(' *',
                  style: TextStyle(
                      color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items.map((item) {
            String displayLabel = item is Language
                ? (item as Language).label
                : (item as Category).label;
            return DropdownMenuItem(value: item, child: Text(displayLabel));
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: TextStyle(color: Colors.grey.shade800),
          dropdownColor: Colors.white,
        ),
      ],
    );
  }
}
