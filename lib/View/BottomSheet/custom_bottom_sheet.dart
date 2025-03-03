import 'package:flutter/material.dart';

import 'Dialog/custom_dialog.dart';

class CustomBottomSheet {

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,  // Cho phép kiểm soát kích thước của Bottom Sheet
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.8,  // Chiếm 8/10 chiều cao màn hình
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Title + Icons (Plus and X)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Prompt Library',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 35, // Đảm bảo kích thước bằng với IconButton khác
                          height: 35,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue, Colors.purple], // Màu gradient
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(width: 0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              CustomDialog.show(context);
                            },
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 24, // Kích thước icon
                            ),
                          ),
                        ),
                        SizedBox(width: 10), // Khoảng cách giữa các nút
                        IconButton(
                          icon: Icon(Icons.close),
                          iconSize: 24, // Đảm bảo icon close có kích thước tương tự
                          onPressed: () {
                            Navigator.pop(context); // Đóng Bottom Sheet
                          },
                        ),
                      ],
                    )

                  ],
                ),

                SizedBox(height: 10),  // Khoảng cách giữa các row

                // Row 2: My Prompts and Public Prompts (Segmented Control with Radio)
                _buildSegmentedControl(),

                SizedBox(height: 10),

                // Row 3: Search bar with Icon + Star Icon
                _buildSearchBar(),

                SizedBox(height: 10),

                // Row 4: Prompt Types

                _buildPromptType(),

                SizedBox(height: 10),

                // Row 5: Scrollable List
                _buildPromptsList(),

              ],
            ),
          ),
        );
      },
    );
  }

  // Segment Control with Radio button-like selection
  static Widget _buildSegmentedControl() {
    int selectedIndex = 0;
    return StatefulBuilder(
      builder: (context, setState) {


        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildOption(
              context,
              'My Prompts',
              selectedIndex == 0,
                  () => setState(() => selectedIndex = 0),
            ),
            _buildOption(
              context,
              'Public Prompts',
              selectedIndex == 1,
                  () => setState(() => selectedIndex = 1),
            ),
          ],
        );
      },
    );
  }

  // Widget cho từng option với radio-like selection
  static Widget _buildOption(
      BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: isSelected ? Colors.blue : Colors.black,
          ),
        ),
      ),
    );
  }

  static Widget _buildSearchBar() {
    bool isStarred = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade200, // Màu nền của TextField
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade600), // Màu icon nhạt
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.grey.shade600), // Màu chữ gợi ý
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none, // Không có viền mặc định
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blue, width: 1), // Viền mỏng khi chọn
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                setState(() {
                  isStarred = !isStarred; // Thay đổi trạng thái ngôi sao khi nhấn
                });
              },
              child: Container(
                padding: EdgeInsets.all(6), // Khoảng cách giữa ngôi sao và viền
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: Colors.grey.shade400, width: 1), // Viền ngoài bo góc
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isStarred ? Icons.star : Icons.star_border, // Ngôi sao rỗng hoặc đầy
                  color: isStarred ? Colors.yellow : Colors.grey.shade600, // Màu vàng khi được chọn
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildPromptType() {
    bool isExpanded = false;
    final chips = List.generate(
      10, // Số lượng chip bạn muốn
          (index) => Chip(
        label: Text(
          'Type ${index + 1}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade900,
          ),
        ),
        backgroundColor: Colors.blue.shade100,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.grey.shade300, // Viền màu xám nhạt
            width: 0,
          ),
        ),
      ),
    );
    return StatefulBuilder(
      builder: (context, setState) {
        return Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: isExpanded
                    ? chips
                    : chips.take(3).toList(), // Chỉ hiển thị 3 chip khi chưa mở rộng
              ),
            ),
            IconButton(
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
            ),
          ],
        );
      },
    );
  }

  static Widget _buildPromptsList() {
    List<bool> isStarred = List.generate(10, (index) => false); // Trạng thái ngôi sao cho từng item
    return StatefulBuilder(
      builder: (context, setState) {
        return Expanded(
          child: ListView.builder(
            itemCount: 10, // Số lượng item trong list
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0), // Tăng khoảng cách giữa các row
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context); // Đóng BottomSheet hiện tại
                            _showPromptDetailsBottomSheet(context, 'Title $index'); // Mở BottomSheet mới
                          },
                          child: Text(
                            'Title $index',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isStarred[index] = !isStarred[index]; // Đổi trạng thái ngôi sao
                                });
                              },
                              child: Icon(
                                isStarred[index] ? Icons.star : Icons.star_border,
                                color: isStarred[index] ? Colors.yellow : Colors.grey,
                              ),
                            ),
                            SizedBox(width: 15), // Tăng khoảng cách giữa các icon
                            Icon(Icons.info_outline, color: Colors.grey),
                            SizedBox(width: 15),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context); // Đóng BottomSheet hiện tại
                                _showPromptDetailsBottomSheet(context, 'Title $index'); // Mở BottomSheet mới
                              },
                              child: Icon(Icons.arrow_right, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8), // Tăng khoảng cách giữa các dòng
                    Text('This is a description for title $index.'),
                    const Divider(thickness: 1.2), // Tăng độ dày của Divider
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  static void _showPromptDetailsBottomSheet(BuildContext context, String itemTitle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Để bottom sheet có thể chiếm toàn bộ màn hình nếu cần
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row 1: Icon "<", Title, Star, and Close icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back),  // Icon "<"
                        onPressed: () {
                          Navigator.pop(context);  // Quay lại BottomSheet cũ
                        },
                      ),
                      SizedBox(width: 8),
                      Text(
                        itemTitle,  // Tên của phần tử được nhấn
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.star_border),  // Icon ngôi sao chỉ có outline
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.close),  // Icon "X" để đóng bottom sheet
                        onPressed: () {
                          Navigator.pop(context);  // Thoát khỏi BottomSheet
                        },
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Row 2: Category
              Row(
                children: [
                  Text("Category: Example Category"),  // Thay thế bằng giá trị category thật
                ],
              ),
              SizedBox(height: 16),

              // Row 3: Description
              Row(
                children: [
                  Expanded(
                    child: Text("Description: This is a sample description for the selected item."),  // Thay thế bằng mô tả thật
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Row 4: View Prompt (toggle khi nhấn)
              StatefulBuilder(
                builder: (context, setState) {
                  bool isPromptVisible = false;  // Biến để theo dõi trạng thái ViewPrompt
                  return Column(
                    children: [
                      if (!isPromptVisible)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isPromptVisible = true;
                            });
                          },
                          child: Text(
                            "View Prompt",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      if (isPromptVisible)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Prompt:"),
                            TextField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                hintText: 'Your prompt here...',
                                filled: true,
                                fillColor: Colors.grey[200],
                              ),
                            ),
                          ],
                        ),
                    ],
                  );
                },
              ),
              SizedBox(height: 16),

              // Row 5: Output Language Dropdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Output Language"),
                  DropdownButton<String>(
                    value: "Auto",  // Giá trị mặc định
                    items: <String>['Auto', 'English', 'Spanish'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      // Xử lý khi thay đổi giá trị
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Row 6: Input Field
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Enter text here...',
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 16),

              // Row 7: Send Button
              ElevatedButton.icon(
                onPressed: () {
                  // Xử lý khi nhấn Send
                },
                icon: Icon(Icons.send),
                label: Text('Send'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,  // Background màu xanh
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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
