import 'package:flutter/material.dart';
import 'package:svpro/widgets/feature_item.dart';

class FeatureSend extends StatefulWidget implements FeatureItem {
  const FeatureSend({super.key});

  @override
  String get label => 'Gửi đơn';

  @override
  IconData get icon => Icons.send;

  @override
  State<FeatureSend> createState() => _FeatureSendState();
}

class _FeatureSendState extends State<FeatureSend> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final contentController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    contentController.dispose();
    super.dispose();
  }

  void submitOrder() {
    if (_formKey.currentState!.validate()) {
      final name = nameController.text.trim();
      final phone = phoneController.text.trim();
      final address = addressController.text.trim();
      final content = contentController.text.trim();

      // TODO: Gửi API ở đây nếu cần
      print('Gửi đơn:');
      print('Tên: $name');
      print('SĐT: $phone');
      print('Địa chỉ: $address');
      print('Nội dung: $content');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi đơn thành công!')),
      );

      // Xóa form
      _formKey.currentState!.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.label)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Thông tin đơn hàng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Họ tên người nhận'),
                validator: (value) => value!.isEmpty ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                validator: (value) =>
                value!.length < 9 ? 'Số điện thoại không hợp lệ' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Địa chỉ'),
                validator: (value) => value!.isEmpty ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Nội dung đơn'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: submitOrder,
                icon: const Icon(Icons.send),
                label: const Text('Gửi đơn'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
