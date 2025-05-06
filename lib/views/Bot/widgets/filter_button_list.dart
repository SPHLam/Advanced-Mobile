import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_ai_chat/views/Bot/widgets/filter_button.dart';

class FilterButtonList extends StatelessWidget {
  const FilterButtonList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 10, // Display 10 buttons
      itemBuilder: (context, index) {
        return FilterButton(
            label: 'Test', isSelected: index == 0 ? true : false);
      },
    );
  }
}
