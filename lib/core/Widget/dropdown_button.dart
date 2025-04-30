import 'package:flutter/material.dart';

import '../../models/ai_logo.dart';

class AIDropdown extends StatelessWidget {
  final List<AIItem> listAIItems;
  final ValueChanged<String?> onChanged;

  const AIDropdown({
    Key? key,
    required this.listAIItems,
    required this.onChanged,
  }) : super(key: key);

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
          value: listAIItems.first.name,
          isExpanded: true,
          onChanged: onChanged,
          items: listAIItems.map<DropdownMenuItem<String>>((AIItem item) {
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
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(
                          fontSize: 12, overflow: TextOverflow.ellipsis),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(left: 10, right: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(20),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}
