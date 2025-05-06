import 'package:flutter/material.dart';

import '../../models/ai_logo.dart';

class AIDropdown extends StatefulWidget {
  final List<AIItem> listAIItems;
  final ValueChanged<String?> onChanged;

  const AIDropdown({
    Key? key,
    required this.listAIItems,
    required this.onChanged,
  }) : super(key: key);

  @override
  _AIDropdownState createState() => _AIDropdownState();
}

class _AIDropdownState extends State<AIDropdown> {
  late List<AIItem> _currentListAIItems;
  late List<int> _currentPrices;
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _currentListAIItems = List.from(widget.listAIItems);
    _currentPrices = [1, 5, 1, 5, 1, 3, 1];
    _selectedValue = _currentListAIItems.first.name;
  }

  void _onItemSelected(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedValue = newValue;
        final selectedIndex = _currentListAIItems.indexWhere((item) => item.name == newValue);
        if (selectedIndex != -1) {
          // Move selected item and price to the top
          final selectedItem = _currentListAIItems.removeAt(selectedIndex);
          final selectedPrice = _currentPrices.removeAt(selectedIndex);
          _currentListAIItems.insert(0, selectedItem);
          _currentPrices.insert(0, selectedPrice);
        }
      });
      widget.onChanged(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color.fromARGB(255, 238, 240, 243),
        ),
        height: 30,
        child: DropdownButtonFormField<String>(
          value: _selectedValue,
          isExpanded: true,
          onChanged: _onItemSelected,
          items: List.generate(_currentListAIItems.length, (index) {
            final item = _currentListAIItems[index];
            final price = _currentPrices[index];
            return DropdownMenuItem<String>(
              value: item.name,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      fit: BoxFit.cover,
                      item.logoPath,
                      width: 20,
                      height: 20,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 12,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.flash_on,
                    color: Colors.orange,
                    size: 16,
                  ),
                  Text(
                    '$price',
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(left: 10, right: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(20),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          selectedItemBuilder: (BuildContext context) {
            return _currentListAIItems.map<Widget>((AIItem item) {
              return Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      fit: BoxFit.cover,
                      item.logoPath,
                      width: 20,
                      height: 20,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 12,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ],
              );
            }).toList();
          },
        ),
      ),
    );
  }
}