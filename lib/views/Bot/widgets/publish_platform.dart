import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PublishPlatform extends StatelessWidget {
  const PublishPlatform(
      {super.key, required this.platformName, required this.imagePath});
  final String platformName;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          leading: Image.network(imagePath),
          title: Text(platformName),
          trailing: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                  color: Colors.blue,
                  width: 2.0), // Customize border color and width
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(10), // Optional: Rounded corners
              ),
            ),
            child: const Icon(
              Icons.publish,
              color: Colors.blue, // Màu của icon
            ),
          ),
        ),
      ),
    );
  }
}
