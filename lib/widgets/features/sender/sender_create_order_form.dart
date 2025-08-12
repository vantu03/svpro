import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:svpro/app_navigator.dart';
import 'package:svpro/widgets/app_text_field.dart';

class SenderCreateOrderForm extends StatefulWidget {
  const SenderCreateOrderForm({super.key});

  @override
  State<SenderCreateOrderForm> createState() => SenderCreateOrderFormState();
}

class SenderCreateOrderFormState extends State<SenderCreateOrderForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final senderName = TextEditingController();
  final senderPhone = TextEditingController();
  final senderAddress = TextEditingController();

  final receiverName = TextEditingController();
  final receiverPhone = TextEditingController();
  final receiverAddress = TextEditingController();

  final itemType = TextEditingController();
  final itemDescription = TextEditingController();
  final itemWeight = TextEditingController();
  final itemDimensions = TextEditingController();
  final itemValue = TextEditingController();

  final codAmount = TextEditingController();

  String serviceType = 'Giao thường';
  String shipFeePayer = 'Người gửi';

  void submitForm() {
    if (!_formKey.currentState!.validate()) return;
    AppNavigator.warning("Đã được ghi nhận");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo đơn hàng'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              _sectionTitle('1. Thông tin người gửi'),
              AppTextField(
                controller: senderName,
                label: 'Họ tên / Tên shop',
              ),
              AppTextField(
                controller: senderPhone,
                label: 'Số điện thoại',
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              AppTextField(
                controller: senderAddress,
                label: 'Địa chỉ lấy hàng',
                maxLength: 255,
              ),
              const SizedBox(height: 16),

              _sectionTitle('2. Thông tin người nhận'),
              AppTextField(
                controller: receiverName,
                label: 'Họ tên',
              ),
              AppTextField(
                controller: receiverPhone,
                label: 'Số điện thoại',
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              AppTextField(
                controller: receiverAddress,
                label: 'Địa chỉ nhận hàng',
                maxLength: 255,
              ),
              const SizedBox(height: 16),

              _sectionTitle('3. Thông tin kiện hàng'),
              AppTextField(
                controller: itemType,
                label: 'Loại hàng hóa',
              ),
              AppTextField(
                controller: itemDescription,
                label: 'Mô tả hàng hóa',
                maxLines: 2,
              ),
              AppTextField(
                controller: itemWeight,
                label: 'Trọng lượng (gram)',
                keyboardType: TextInputType.number,
              ),
              AppTextField(
                controller: itemDimensions,
                label: 'Kích thước (D x R x C)',
              ),
              AppTextField(
                controller: itemValue,
                label: 'Giá trị hàng (VNĐ)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: codAmount,
                label: 'Tiền thu hộ (COD)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Checkbox(value: true, onChanged: (_) {}),
                  const Expanded(
                    child: Text(
                      'Tôi cam kết thông tin hàng hóa hợp lệ, không vi phạm pháp luật.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text('Gửi đơn'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: submitForm,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }
}
