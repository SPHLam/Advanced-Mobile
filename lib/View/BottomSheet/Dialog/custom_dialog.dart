import 'package:flutter/material.dart';

class CustomDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _CustomDialogContent();
      },
    );
  }
}

class _CustomDialogContent extends StatefulWidget {
  @override
  _CustomDialogContentState createState() => _CustomDialogContentState();
}

class _CustomDialogContentState extends State<_CustomDialogContent> {
  int selectedRadio = 0; // 0: Private Prompt, 1: Public Prompt
  String selectedLanguage = 'Auto';
  String selectedCategory = 'Other';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: FractionallySizedBox(
        heightFactor: selectedRadio == 1 ? 0.9 : 0.7,
        // Điều chỉnh chiều cao dialog
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: Title + Close Icon
            _buildTitleRow(context),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 2: Radio buttons
                    _buildRadioOptions(),
                    SizedBox(height: 10),
                    // Hiển thị nội dung dựa trên sự lựa chọn (Private / Public)
                    selectedRadio == 0
                        ? _buildPrivateForm()
                        : _buildPublicForm(),
                  ],
                ),
              ),
            ),
            // Row buttons (Cancel & Create)
            _buildDialogButtons(context),
          ],
        ),
      ),
    );
  }

  // Row 1: Title + Close Icon
  Widget _buildTitleRow(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Create Prompt',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // Row 2: Radio buttons for Private and Public
  Widget _buildRadioOptions() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: RadioListTile<int>(
            contentPadding: EdgeInsets.zero,
            title: Text('Private Prompt'),
            value: 0,
            groupValue: selectedRadio,
            onChanged: (value) {
              setState(() {
                selectedRadio = value!;
              });
            },
          ),
        ),
        Expanded(
          child: RadioListTile<int>(
            contentPadding: EdgeInsets.zero,
            title: Text('Public Prompt'),
            value: 1,
            groupValue: selectedRadio,
            onChanged: (value) {
              setState(() {
                selectedRadio = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  // Form cho Private Prompt
  Widget _buildPrivateForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 3: Name
        _buildLabeledField(
          label: 'Name',
          isRequired: true,
          hint: 'Name of the prompt',
        ),
        SizedBox(height: 10),
        // Row 4: Prompt
        _buildLabeledFieldWithInfo(
          label: 'Prompt',
          isRequired: true,
          hint:
              'e.g: Write an article about [TOPIC], make sure to include these keywords: [KEYWORDS]',
          infoText: 'Use square brackets [ ] to specify user input',
        ),
      ],
    );
  }

  // Form cho Public Prompt
  Widget _buildPublicForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 3: Prompt Language
        _buildLabeledDropdown(
          label: 'Prompt Language',
          isRequired: true,
          value: selectedLanguage,
          onChanged: (newValue) {
            setState(() {
              selectedLanguage = newValue!;
            });
          },
          items: [
            'Auto',
            'English',
            'Spanish',
            'French',
            'German'
          ], // Các giá trị mẫu
        ),
        SizedBox(height: 10),
        // Row 4: Name
        _buildLabeledField(
          label: 'Name',
          isRequired: true,
          hint: 'Name of the prompt',
        ),
        SizedBox(height: 10),
        // Row 5: Category
        _buildLabeledDropdown(
          label: 'Category',
          isRequired: true,
          value: selectedCategory,
          onChanged: (newValue) {
            setState(() {
              selectedCategory = newValue!;
            });
          },
          items: [
            'Other',
            'Business',
            'Education',
            'Health',
            'Entertainment'
          ], // Các giá trị mẫu
        ),
        SizedBox(height: 10),
        // Row 6: Description
        _buildLabeledField(
          label: 'Description',
          hint:
              'Describe your prompt so others can have a better understanding',
        ),
        SizedBox(height: 10),
        // Row 7: Prompt
        _buildLabeledFieldWithInfo(
          label: 'Prompt',
          isRequired: true,
          hint:
              'e.g: Write an article about [TOPIC], make sure to include these keywords: [KEYWORDS]',
          infoText: 'Use square brackets [ ] to specify user input',
        ),
      ],
    );
  }

  // Input field với label
  Widget _buildLabeledField({
    required String label,
    required String hint,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label),
            if (isRequired)
              Text(
                '*',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
        SizedBox(height: 5),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
      ],
    );
  }

  // Input field với label và info text
  Widget _buildLabeledFieldWithInfo({
    required String label,
    required String hint,
    required String infoText,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label),
            if (isRequired)
              Text(
                '*',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
        SizedBox(height: 5),
        Container(
          color: Colors.lightBlue[50],
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.lightBlue),
              SizedBox(width: 5),
              Expanded(child: Text(infoText)),
            ],
          ),
        ),
        SizedBox(height: 5),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
      ],
    );
  }

  // Dropdown với label
  Widget _buildLabeledDropdown({
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
            Text(label),
            if (isRequired)
              Text(
                '*',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
        SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
      ],
    );
  }

  // Row buttons (Cancel & Create)
  Widget _buildDialogButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end, // Căn trái cho các nút
        children: [
          // Nút Cancel với viền gradient
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple], // Gradient cho viền
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                backgroundColor: Colors.white, // Nền trong suốt
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                side: BorderSide(
                    color: Colors.transparent), // Để gradient từ container
              ),
              child: Text(
                'Cancel',
                style:
                    TextStyle(color: Colors.blue.shade900), // Chữ màu xanh đậm
              ),
            ),
          ),
          SizedBox(width: 10), // Khoảng cách giữa các nút

          // Nút Create với nền gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple], // Gradient nền
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ElevatedButton(
              onPressed: () {
                // Xử lý khi bấm nút Create
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                backgroundColor: Colors.transparent,
                // Để nền từ Container hiển thị
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Create',
                style: TextStyle(color: Colors.white), // Chữ trắng
              ),
            ),
          ),
        ],
      ),
    );
  }
}
