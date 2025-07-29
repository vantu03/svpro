import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerTile extends StatelessWidget {
  final String? label;
  final dynamic image;
  final void Function(dynamic) onChanged;

  const ImagePickerTile({
    super.key,
    this.label,
    required this.image,
    required this.onChanged,
  });

  Future<void> pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        onChanged(bytes);
      } else {
        onChanged(io.File(picked.path));
      }
    }
  }

  void removeImage() => onChanged(null);

  Widget buildImageWidget() {
    if (image == null) {
      return const Center(child: Icon(Icons.add_a_photo, size: 32));
    }

    if (kIsWeb && image is Uint8List) {
      return Image.memory(image, fit: BoxFit.cover);
    }

    if (!kIsWeb && image is io.File) {
      return Image.file(image, fit: BoxFit.cover);
    }

    return const Center(child: Icon(Icons.broken_image));
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = image != null;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null && label!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 6),
              child: Text(label!, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          GestureDetector(
            onTap: () => pickImage(context),
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
                  if (hasImage)
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
        ],
      ),
    );
  }
}
