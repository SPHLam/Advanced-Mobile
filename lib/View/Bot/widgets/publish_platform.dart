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
          leading: Image.asset(imagePath),
          title: Text(platformName),
          trailing: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Icon(
              Icons.publish,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
