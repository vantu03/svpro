import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:svpro/services/api_service.dart';
import 'package:svpro/utils/notifier.dart';

class ImageUploadTile extends StatefulWidget {
  final String? label;
  final String? url;
  final String fileType;
  final void Function(String? url) onChanged;

  const ImageUploadTile({
    super.key,
    this.label,
    required this.url,
    required this.fileType,
    required this.onChanged,
  });

  @override
  State<ImageUploadTile> createState() => ImageUploadTileState();
}

class ImageUploadTileState extends State<ImageUploadTile> {
  bool uploading = false;
  String? fileSizeLabel;

  Future<void> pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() {
      uploading = true;
      fileSizeLabel = null;
    });

    try {
      final response = await ApiService.uploadImage(picked, widget.fileType);
      final jsonData = jsonDecode(response.body);
      if (jsonData['detail']['status'] == true) {
        final data = jsonData['detail']['data'];
        final url = data['url'];
        final sizeInBytes = data['size'];
        final sizeInMB = (sizeInBytes / 1024 / 1024).toStringAsFixed(2);

        setState(() {
          fileSizeLabel = '$sizeInMB MB';
        });

        widget.onChanged(url);
      } else {
        Notifier.error(
            context, 'Upload thất bại: ${jsonData['detail']['message']}');
      }
    } catch (e) {
      print(e);
      Notifier.error(context, 'Không thể kết nối tới máy chủ');
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  void removeImage() {
    widget.onChanged(null);
    setState(() {
      fileSizeLabel = null;
    });
  }

  Widget buildImageWidget() {
    if (uploading) {
      return const Center(child: CircularProgressIndicator());
    }

    final url = widget.url;
    if (url == null || url.isEmpty) {
      return const Center(child: Icon(Icons.add_a_photo, size: 32));
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
      const Center(child: Icon(Icons.broken_image)),
    );
  }


  @override
  Widget build(BuildContext context) {
    final hasImage = widget.url != null;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null && widget.label!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 6),
              child: Text(widget.label!, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          GestureDetector(
            onTap: uploading ? null : () => pickImage(context),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: buildImageWidget(),
                    ),
                  ),
                  if (hasImage && !uploading)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: removeImage,
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black54,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.close, size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (fileSizeLabel != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text('Kích thước: $fileSizeLabel', style: const TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }
}
