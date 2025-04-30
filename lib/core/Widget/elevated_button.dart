import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart';

class ElevatedButtonCustom extends StatelessWidget {
  final String text;
  final void Function() onPressed;


  const ElevatedButtonCustom({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          onPressed();
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(),
          foregroundColor: whiteColor,
          backgroundColor: secondaryColor,
          side: BorderSide(color: secondaryColor),
          padding: EdgeInsets.symmetric(vertical: tButtonHeight),
        ),
        child: Text(text));
  }
}