import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:svpro/app_navigator.dart';
import 'package:svpro/app_core.dart';
import 'package:svpro/services/api_service.dart';
import 'package:svpro/services/location_service.dart';
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
      final res = await ApiService.registerSender(
        nameController.text.trim(),
        phoneController.text.trim(),
        addressController.text.trim(),
      );

      if (res.statusCode == 422) {
        AppCore.handleValidationError(res.body);
        return;
      }
      var jsonData = jsonDecode(res.body);
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
  void initState() {
    super.initState();
    initForm();
  }

  Future<void> initForm() async {
    final address = await LocationService.getCurrentAddress();
    if (address != null && mounted) {
      setState(() {
        addressController.text = address;
      });
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
                    minLength: 5,
                    maxLength: 50,
                  ),

                  AppTextField(
                    controller: phoneController,
                    label: 'Số điện thoại',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    minLength: 10,
                    maxLength: 12,
                  ),
                  AppTextField(
                    maxLength: 255,
                    controller: addressController,
                    label: 'Địa chỉ mặc định / Địa chỉ ship tới nhận',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.my_location, color: Colors.blue),
                      tooltip: "Lấy địa chỉ hiện tại",
                      onPressed: () async {
                        AppNavigator.showLoadingDialog(message: "Đang lấy địa chỉ...");
                        final address = await LocationService.getCurrentAddress();
                        AppNavigator.hideDialog();

                        if (address != null) {
                          setState(() {
                            addressController.text = address;
                          });
                          AppNavigator.info("Đã lấy địa chỉ thành công!");
                        } else {
                          AppNavigator.warning("Không thể lấy địa chỉ hiện tại");
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline,),
                      label: const Text('Đăng ký'),
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