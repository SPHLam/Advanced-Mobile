import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.lightbulb_outline),
          label: 'Bot AI',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Prompt',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Information',
        ),
      ],
      currentIndex: currentIndex,
      unselectedItemColor: Colors.grey[600],
      selectedItemColor: Colors.blue,
      onTap: onTap,
    );
  }
}