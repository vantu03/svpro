import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:svpro/app_navigator.dart';
import 'package:svpro/services/api_service.dart';
import 'package:svpro/widgets/app_text_field.dart';

class SenderRegisterForm extends StatefulWidget {
  const SenderRegisterForm({super.key});

  @override
  State<SenderRegisterForm> createState() => SenderRegisterFormState();
}

class SenderRegisterFormState extends State<SenderRegisterForm> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;

    AppNavigator.showLoadingDialog();
    try {
      final response = await ApiService.registerSender(
        nameController.text.trim(),
        phoneController.text.trim(),
        addressController.text.trim(),
      );

      var jsonData = jsonDecode(response.body);
      if (jsonData['detail']['status']) {
        AppNavigator.success(jsonData['detail']['message']);
      } else {
        AppNavigator.error(jsonData['detail']['message']);
      }
      AppNavigator.pop(true);
    } catch (e) {
      AppNavigator.error('Không thể kết nối tới máy chủ');
    } finally {
      AppNavigator.hideDialog();
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
                    child: Text(
                      'Đăng ký gửi đơn',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                    label: 'Họ và tên / Tên shop',
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
                    maxLength: 255,
                    controller: addressController,
                    label: 'Địa chỉ mặc định / Địa chỉ ship tới nhận',
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