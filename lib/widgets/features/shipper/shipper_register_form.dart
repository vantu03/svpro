import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:svpro/services/api_service.dart';
import 'package:svpro/utils/notifier.dart';
import 'package:svpro/widgets/app_dropdown_field.dart';
import 'package:svpro/widgets/app_text_field.dart';
import 'package:svpro/widgets/date_picker_tile.dart';
import 'package:svpro/widgets/image_upload_tile.dart';

class ShipperRegisterForm extends StatefulWidget {
  const ShipperRegisterForm({super.key});

  @override
  State<ShipperRegisterForm> createState() => _ShipperRegisterFormState();
}

class _ShipperRegisterFormState extends State<ShipperRegisterForm> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final identityController = TextEditingController();
  final addressController = TextEditingController();
  final licensePlateController = TextEditingController();

  DateTime? birthDate;
  String? gender;
  String? vehicleType;

  String? profileImageUrl;
  String? idFrontUrl;
  String? idBackUrl;

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;

    if ([profileImageUrl, idFrontUrl, idBackUrl, birthDate, gender, vehicleType].contains(null)) {
      Notifier.warning(context, 'Vui lòng nhập đầy đủ thông tin và ảnh!');
      return;
    }

    try {
      final response = await ApiService.registerShipper(
        nameController.text.trim(),
        phoneController.text.trim(),
        identityController.text.trim(),
        addressController.text.trim(),
        birthDate!.toIso8601String(),
        gender!,
        vehicleType!,
        licensePlateController.text.trim(),
        profileImageUrl!,
        idFrontUrl!,
        idBackUrl!,
      );

      var jsonData = jsonDecode(response.body);
      if (jsonData['detail']['status']) {
        Notifier.success(context, jsonData['detail']['message']);
      } else {
        Notifier.error(context, jsonData['detail']['message']);
      }Navigator.pop(context, true);
    } catch (e) {
      Notifier.error(context, 'Đã xảy ra lỗi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: const [
                        Icon(Icons.app_registration, size: 48, color: Colors.blue),
                        SizedBox(height: 8),
                        Text(
                          'Đăng ký Shipper',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Thông tin cá nhân',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const Divider(),
                  const SizedBox(height: 12),

                  AppTextField(
                    controller: nameController,
                    label: 'Họ và tên',
                  ),

                  AppTextField(
                    controller: phoneController,
                    label: 'Số điện thoại',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    minLength: 9,
                    maxLength: 11,
                    customValidator: (v) {
                      if (!RegExp(r'^\d{9,11}$').hasMatch(v!)) {
                        return 'Số điện thoại không hợp lệ';
                      }
                      return null;
                    },
                  ),

                  AppTextField(
                    controller: identityController,
                    label: 'Số CMND/CCCD',
                  ),

                  AppTextField(
                    controller: addressController,
                    label: 'Địa chỉ',
                  ),

                  const SizedBox(height: 12),

                  AppDropdownField<String>(
                    label: 'Loại phương tiện',
                    value: vehicleType,
                    items: {
                      'motorbike': 'Xe máy',
                      'car': 'Ô tô',
                    },
                    onChanged: (val) => setState(() => vehicleType = val),
                  ),


                  const SizedBox(height: 12),

                  AppTextField(
                    controller: licensePlateController,
                    label: 'Biển số xe',
                  ),

                  const SizedBox(height: 12),

                  AppDropdownField<String>(
                    label: 'Giới tính',
                    value: gender,
                    items: {
                      'male': 'Nam',
                      'female': 'Nữ',
                      'other': 'Khác',
                    },
                    onChanged: (val) => setState(() => gender = val),
                  ),


                  const SizedBox(height: 12),

                  DatePickerTile(
                    label: 'Ngày sinh',
                    date: birthDate,
                    onChanged: (d) => setState(() => birthDate = d),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                  ),

                  const SizedBox(height: 24),
                  const Text('Ảnh hồ sơ',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const Divider(),
                  const SizedBox(height: 12),

                  ImageUploadTile(
                    label: 'Ảnh đại diện',
                    url: profileImageUrl,
                    fileType: 'portrait',
                    onChanged: (url) => setState(() => profileImageUrl = url),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: ImageUploadTile(
                          label: 'CMND mặt trước',
                          url: idFrontUrl,
                          fileType: 'portrait',
                          onChanged: (url) => setState(() => idFrontUrl = url),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ImageUploadTile(
                          label: 'CMND mặt sau',
                          url: idBackUrl,
                          fileType: 'portrait',
                          onChanged: (url) => setState(() => idBackUrl = url),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline,
                          color: Colors.white),
                      label: const Text('Đăng ký',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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
        ),
      ),
    );
  }

}