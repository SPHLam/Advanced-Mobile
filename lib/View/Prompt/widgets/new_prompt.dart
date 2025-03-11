import 'package:flutter/material.dart';

class NewPrompt {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const NewPromptContent();
      },
    );
  }
}

class NewPromptContent extends StatefulWidget {
  const NewPromptContent({super.key});

  @override
  NewPromptContentState createState() => NewPromptContentState();
}

class NewPromptContentState extends State<NewPromptContent> {
  int selectedRadio = 0;
  String selectedLanguage = 'Auto';
  String selectedCategory = 'Other';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: 400,
        height: selectedRadio == 1 ? 650 : 450,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildToggleSwitch(),
                    const SizedBox(height: 24),
                    selectedRadio == 0 ? _buildPrivateLayout() : _buildPublicLayout(),
                  ],
                ),
              ),
            ),
            _buildFooterButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.purple.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'New Prompt',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedRadio = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selectedRadio == 0 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: selectedRadio == 0
                      ? [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10)]
                      : [],
                ),
                child: Text(
                  'Private',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selectedRadio == 0 ? Colors.blue.shade700 : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedRadio = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selectedRadio == 1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: selectedRadio == 1
                      ? [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10)]
                      : [],
                ),
                child: Text(
                  'Public',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selectedRadio == 1 ? Colors.blue.shade700 : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivateLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(label: 'Name', hint: 'Prompt name', isRequired: true),
        const SizedBox(height: 20),
        _buildTextFieldWithInfo(
          label: 'Prompt',
          hint: 'e.g: Write an article about [TOPIC]',
          info: 'Use [ ] for user input',
          isRequired: true,
        ),
      ],
    );
  }

  Widget _buildPublicLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown(
          label: 'Language',
          value: selectedLanguage,
          items: ['Auto', 'English', 'Spanish', 'French', 'German'],
          onChanged: (value) => setState(() => selectedLanguage = value!),
          isRequired: true,
        ),
        const SizedBox(height: 20),
        _buildTextField(label: 'Name', hint: 'Prompt name', isRequired: true),
        const SizedBox(height: 20),
        _buildDropdown(
          label: 'Category',
          value: selectedCategory,
          items: ['Other', 'Business', 'Education', 'Health', 'Entertainment'],
          onChanged: (value) => setState(() => selectedCategory = value!),
          isRequired: true,
        ),
        const SizedBox(height: 20),
        _buildTextField(label: 'Description', hint: 'Describe your prompt'),
        const SizedBox(height: 20),
        _buildTextFieldWithInfo(
          label: 'Prompt',
          hint: 'e.g: Write an article about [TOPIC]',
          info: 'Use [ ] for user input',
          isRequired: true,
        ),
      ],
    );
  }

  Widget _buildTextField({required String label, required String hint, bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFieldWithInfo({
    required String label,
    required String hint,
    required String info,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: Colors.blue.shade400),
            const SizedBox(width: 6),
            Text(
              info,
              style: TextStyle(fontSize: 12, color: Colors.blue.shade400),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: TextStyle(color: Colors.grey.shade800),
          dropdownColor: Colors.white,
        ),
      ],
    );
  }

  Widget _buildFooterButtons() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: Colors.green,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text(
              'Create',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}