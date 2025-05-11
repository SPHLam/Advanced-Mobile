import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';

class InputWidget extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isOpenDeviceWidget;
  final Function toggleDeviceVisibility;
  final Function(String, List<String>?) sendMessage;
  final Function(String) onTextChanged;
  final bool hasText;
  final Function(List<String>?) updateImagePaths;
  final ScreenshotController screenshotController;

  const InputWidget({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.isOpenDeviceWidget,
    required this.toggleDeviceVisibility,
    required this.sendMessage,
    required this.onTextChanged,
    required this.hasText,
    required this.updateImagePaths,
    required this.screenshotController,
  }) : super(key: key);

  @override
  _InputWidgetState createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> {
  List<String>? imagePaths;

  Future<void> _openGallery() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
      setState(() {
        imagePaths = [...(imagePaths ?? []), ...images.map((e) => e.path).toList()];
        widget.updateImagePaths(imagePaths);
        widget.toggleDeviceVisibility();
      });
    }
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }
  }

  Future<void> _openCamera() async {
    await _requestCameraPermission();
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        imagePaths = [...(imagePaths ?? []), image.path];
        widget.updateImagePaths(imagePaths);
        widget.toggleDeviceVisibility();
      });
    }
  }

  Future<void> _takeScreenshot() async {
    try {
      final image = await widget.screenshotController.capture();
      if (image != null) {
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/screenshot_${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(image);
        setState(() {
          imagePaths = [...(imagePaths ?? []), file.path];
          widget.updateImagePaths(imagePaths);
          widget.toggleDeviceVisibility();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot take the screenshot')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error when taking the screenshot: $e')),
      );
    }
  }

  void _removeImage(String path) {
    setState(() {
      imagePaths?.remove(path);
      widget.updateImagePaths(imagePaths);
    });
  }

  void _handleSendMessage() {
    if (widget.hasText || (imagePaths != null && imagePaths!.isNotEmpty)) {
      widget.sendMessage(widget.controller.text, imagePaths);
      setState(() {
        imagePaths = null;
        widget.updateImagePaths(null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        IconButton(
          icon: widget.isOpenDeviceWidget
              ? const Icon(Icons.arrow_back_ios_new)
              : const Icon(Icons.arrow_forward_ios),
          onPressed: () => widget.toggleDeviceVisibility(),
        ),
        if (widget.isOpenDeviceWidget) ...[
          IconButton(
            icon: const Icon(Icons.image_rounded),
            onPressed: _openGallery,
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _openCamera,
          ),
          IconButton(
            icon: const Icon(Icons.screenshot),
            onPressed: _takeScreenshot,
          ),
        ],
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color.fromARGB(255, 238, 240, 243),
              border: Border.all(
                color: Colors.grey.withOpacity(0.5),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imagePaths != null && imagePaths!.isNotEmpty) ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: imagePaths!.map((path) {
                        return Padding(
                          padding: const EdgeInsets.all(4),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(path),
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: -15,
                                right: -15,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    size: 20,
                                    color: Color.fromARGB(136, 245, 237, 237),
                                  ),
                                  onPressed: () => _removeImage(path),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
                TextField(
                  focusNode: widget.focusNode,
                  controller: widget.controller,
                  onChanged: widget.onTextChanged,
                  maxLines: null,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    hintText: (imagePaths == null || imagePaths!.isEmpty)
                        ? 'Enter your message...'
                        : null,
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.5),
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: widget.hasText || (imagePaths != null && imagePaths!.isNotEmpty)
              ? _handleSendMessage
              : null,
          style: IconButton.styleFrom(
            foregroundColor: widget.hasText || (imagePaths != null && imagePaths!.isNotEmpty)
                ? Colors.black
                : Colors.grey,
          ),
        ),
      ],
    );
  }
}