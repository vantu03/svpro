import 'package:flutter/material.dart';
import 'package:svpro/widgets/feature_item.dart';

class FeatureShipper extends StatelessWidget implements FeatureItem {
  const FeatureShipper({super.key});

  @override
  String get label => 'Shipper';

  @override
  IconData get icon => Icons.delivery_dining;

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Đăng ký làm Shipper',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Họ tên'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Nhập họ tên' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Số điện thoại'),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                value == null || value.length < 10 ? 'SĐT không hợp lệ' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: Icon(Icons.check),
                label: Text('Gửi đăng ký'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Gửi dữ liệu lên server nếu cần
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã gửi đăng ký!')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
