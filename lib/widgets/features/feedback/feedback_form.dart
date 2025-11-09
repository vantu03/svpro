import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:svpro/app_core.dart';
import 'package:svpro/app_navigator.dart';
import 'package:svpro/services/api_service.dart';
import 'package:svpro/widgets/app_text_field.dart';

class FeedbackForm extends StatefulWidget {
  const FeedbackForm({super.key});

  @override
  State<FeedbackForm> createState() => FeedbackFormState();
}

class FeedbackFormState extends State<FeedbackForm> {
  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final contentController = TextEditingController();

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;

    AppNavigator.showLoadingDialog(message: "Đang gửi góp ý...");

    try {
      final res = await ApiService.sendFeedback(title: titleController.text.trim(), content: contentController.text.trim());

      if (res.statusCode == 422) {
        AppCore.handleValidationError(res.body);
        return;
      }

      final data = jsonDecode(res.body);
      final detail = data['detail'];

      if (detail['status'] == true) {
        AppNavigator.success(detail['message']);
        titleController.clear();
        contentController.clear();
        AppNavigator.pop();
      } else {
        AppNavigator.error(detail['message']);
      }
    } catch (e) {
      AppNavigator.error("Không thể kết nối đến máy chủ");
    } finally {
      AppNavigator.pop();
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
                  const Text(
                    "Thông tin góp ý",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const Divider(),

                  const SizedBox(height: 12),

                  AppTextField(
                    controller: titleController,
                    label: "Tiêu đề góp ý",
                    minLength: 5,
                    maxLength: 255,
                  ),

                  AppTextField(
                    controller: contentController,
                    label: "Nội dung góp ý chi tiết",
                    minLength: 10,
                    maxLength: 2000,
                    maxLines: 5,
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      label: const Text("Gửi góp ý"),
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
