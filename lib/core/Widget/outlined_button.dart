import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart';

class OutlinedButtonCustom extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Image? icon; // Thay đổi thành Image? để có thể null

  const OutlinedButtonCustom({
    Key? key,
    required this.label,
    required this.onPressed,
    this.icon, // Icon không bắt buộc
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: icon ?? SizedBox.shrink(), // Nếu không có icon, sử dụng SizedBox.shrink()
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(),
        foregroundColor: secondaryColor,
        side: BorderSide(color: secondaryColor),
        padding: EdgeInsets.symmetric(vertical: tButtonHeight),
      ),
      onPressed: onPressed,
      label: Text(label),
    );
  }
}
