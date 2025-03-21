import 'package:flutter/material.dart';

import '../../models/ai_logo.dart';

class AIDropdown extends StatelessWidget {
  final List<AIItem> listAIItems;
  final ValueChanged<String?> onChanged;

  const AIDropdown({
    super.key,
    required this.listAIItems,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[50],
        ),
        height: 38,
        child: DropdownButtonFormField<String>(
          value: listAIItems.first.name,
          isExpanded: true,
          onChanged: onChanged,
          items:  listAIItems.map<DropdownMenuItem<String>>((AIItem item) {
            return DropdownMenuItem<String>(
              value: item.name,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.asset(
                      fit: BoxFit.cover,
                      item.logoPath,
                      width: 25,
                      height: 25,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const Icon(Icons.flash_on, color: Colors.orangeAccent, size: 12),
                  const Text('24', style: TextStyle(fontSize: 12)),
                ],
              ),
            );
          }).toList(),
          selectedItemBuilder: (BuildContext context) {
            return listAIItems.map<Widget>((AIItem item) {
              return Image.asset(
                fit: BoxFit.cover,
                item.logoPath,
                width: 25,
                height: 25,
              );
            }).toList();
          },
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
        ),
      ),
    );
  }
}