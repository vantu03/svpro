import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ShipperRegisterForm extends StatefulWidget {
  const ShipperRegisterForm({super.key});

  @override
  State<ShipperRegisterForm> createState() => ShipperRegisterFormState();
}

class ShipperRegisterFormState extends State<ShipperRegisterForm> {
  final formKey = GlobalKey<FormState>();
  final formData = <String, String>{};
  final picker = ImagePicker();

  File? avatarImage;
  File? identityFront;
  File? identityBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Thông tin cá nhân',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            buildTextField('Họ và tên', 'full_name'),
            buildTextField('Số điện thoại', 'phone_number', keyboardType: TextInputType.phone),
            buildTextField('Số CCCD/CMND', 'identity_number'),
            buildTextField('Địa chỉ', 'address'),

            const SizedBox(height: 16),
            const Text(
              'Phương tiện',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            buildTextField('Loại phương tiện', 'vehicle_type'),
            buildTextField('Biển số xe', 'license_plate'),

            const SizedBox(height: 16),
            const Text(
              'Ảnh hồ sơ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Hai ảnh CCCD nằm cùng hàng
            buildImagePickerRow(
              'CCCD mặt trước', identityFront, (file) {
              setState(() => identityFront = file);
            },
              'CCCD mặt sau', identityBack, (file) {
              setState(() => identityBack = file);
            },
            ),

            const SizedBox(height: 16),
            // Ảnh đại diện nằm riêng 1 hàng
            buildImagePicker('Ảnh đại diện', avatarImage, (file) {
              setState(() => avatarImage = file);
            }),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: handleSubmit,
              icon: const Icon(Icons.send),
              label: const Text('Gửi đăng ký'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, String key,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
        value == null || value.trim().isEmpty ? 'Vui lòng nhập $label' : null,
        onSaved: (value) => formData[key] = value!.trim(),
      ),
    );
  }

  Widget buildImagePicker(String label, File? file, Function(File) onPicked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () async {
              final picked = await picker.pickImage(source: ImageSource.gallery);
              if (picked != null) onPicked(File(picked.path));
            },
            child: Container(
              width: 100,
              height: 100,
              color: Colors.grey[200],
              child: file != null
                  ? Image.file(file, fit: BoxFit.cover)
                  : const Icon(Icons.add_a_photo),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildImagePickerRow(
      String label1, File? file1, Function(File) onPicked1,
      String label2, File? file2, Function(File) onPicked2,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: buildImagePicker(label1, file1, onPicked1),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: buildImagePicker(label2, file2, onPicked2),
        ),
      ],
    );
  }

  void handleSubmit() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      if (avatarImage == null || identityFront == null || identityBack == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn đầy đủ ảnh')),
        );
        return;
      }

      print('Dữ liệu nhập: $formData');
      print('Ảnh avatar: ${avatarImage!.path}');
      print('CCCD trước: ${identityFront!.path}');
      print('CCCD sau: ${identityBack!.path}');

      // TODO: Gửi formData + ảnh lên server (multipart/form-data)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi đăng ký thành công')),
      );
    }
  }
}