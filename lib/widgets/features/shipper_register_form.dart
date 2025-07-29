import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:svpro/services/api_service.dart';
import 'package:svpro/utils/notifier.dart';
import 'package:svpro/widgets/image_picker_tile.dart';
import 'package:svpro/widgets/date_picker_tile.dart';

class ShipperRegisterForm extends StatefulWidget {
  const ShipperRegisterForm({super.key});

  @override
  State<ShipperRegisterForm> createState() => ShipperRegisterFormState();
}

class ShipperRegisterFormState extends State<ShipperRegisterForm> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final identityController = TextEditingController();
  final addressController = TextEditingController();
  final licensePlateController = TextEditingController();

  DateTime? birthDate;
  String? vehicleType;

  dynamic profileImage;
  dynamic idFrontImage;
  dynamic idBackImage;

  final vehicleTypes = {
    'motorbike': 'Xe máy',
    'car': 'Ô tô',
  };

  Future<http.MultipartFile> createMultipart(String fieldName, dynamic file) async {
    if (kIsWeb && file is Uint8List) {
      return http.MultipartFile.fromBytes(
        fieldName,
        file,
        filename: '$fieldName.jpg',
        contentType: MediaType('image', 'jpeg'),
      );
    } else if (!kIsWeb && file is io.File) {
      return await http.MultipartFile.fromPath(
        fieldName,
        file.path,
        contentType: MediaType('image', 'jpeg'),
      );
    } else {
      throw Exception("Invalid image for $fieldName");
    }
  }

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;

    if ([profileImage, idFrontImage, idBackImage, birthDate, vehicleType].contains(null)) {
      Notifier.warning(context, 'Vui lòng nhập đầy đủ thông tin và ảnh!');
      return;
    }

    try {
      final response = await ApiService.registerShipper(
        nameController.text.trim(),
        phoneController.text.trim(),
        identityController.text.trim(),
        addressController.text.trim(),
        birthDate!,
        vehicleType!,
        licensePlateController.text.trim(),
        profileImage!,
        idFrontImage!,
        idBackImage!,
      );

      if (response.statusCode == 200) {
        Notifier.success(context, 'Đăng ký thành công!');
      } else {
        Notifier.error(context, 'Lỗi: ${response.body}');
      }
    } catch (e) {
      Notifier.error(context, 'Đã xảy ra lỗi: $e');
    }
  }


  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Họ và tên'),
                validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
              ),
              TextFormField(
                controller: identityController,
                decoration: const InputDecoration(labelText: 'Số CMND/CCCD'),
                validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
              ),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Địa chỉ'),
                validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
              ),
              TextFormField(
                controller: licensePlateController,
                decoration: const InputDecoration(labelText: 'Biển số xe'),
                validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Loại phương tiện'),
                value: vehicleType,
                items: vehicleTypes.entries
                    .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                    .toList(),
                onChanged: (val) => setState(() => vehicleType = val),
                validator: (v) => v == null ? 'Vui lòng chọn phương tiện' : null,
              ),
              DatePickerTile(
                label: 'Ngày sinh',
                date: birthDate,
                onChanged: (d) => setState(() => birthDate = d),
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
              ),
              const SizedBox(height: 8),
              ImagePickerTile(
                label: 'Ảnh đại diện',
                image: profileImage,
                onChanged: (img) => setState(() => profileImage = img),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ImagePickerTile(
                      label: 'CMND mặt trước',
                      image: idFrontImage,
                      onChanged: (img) => setState(() => idFrontImage = img),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ImagePickerTile(
                      label: 'CMND mặt sau',
                      image: idBackImage,
                      onChanged: (img) => setState(() => idBackImage = img),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white,),
                  label: const Text('Đăng ký', style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  onPressed: submitForm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
