import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:svpro/app_navigator.dart';
import 'package:svpro/models/sender.dart';
import 'package:svpro/services/api_service.dart';
import 'package:svpro/widgets/app_text_field.dart';

class SenderCreateOrderForm extends StatefulWidget {

  final SenderModel sender;

  const SenderCreateOrderForm({super.key, required this.sender});

  @override
  State<SenderCreateOrderForm> createState() => SenderCreateOrderFormState();
}

class SenderCreateOrderFormState extends State<SenderCreateOrderForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final senderName = TextEditingController();
  final senderPhone = TextEditingController();
  final senderAddress = TextEditingController();
  final senderNote = TextEditingController();
  final itemValue = TextEditingController();
  final shippingFee = TextEditingController();

  final receiverName = TextEditingController();
  final receiverPhone = TextEditingController();
  final receiverAddress = TextEditingController();

  String serviceType = 'Giao thường';
  String shipFeePayer = 'Người gửi';

  void submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    AppNavigator.showLoadingDialog();
    try {
      final response = await ApiService.createOrder(
        pickupAddress: senderAddress.text,
        itemValue: int.tryParse(itemValue.text),
        shippingFee: int.tryParse(shippingFee.text),
        note: senderNote.text,
        receiverName: receiverName.text,
        receiverPhone: receiverPhone.text,
        receiverAddress: receiverAddress.text
      );

      var jsonData = jsonDecode(response.body);
      if (jsonData['detail']['status']) {
        AppNavigator.popIfCan();
        AppNavigator.success('Tạo đơn thành công!');
      } else {
        AppNavigator.error(jsonData['detail']['message']);
      }
    } catch (e) {
      print(e);
      AppNavigator.error('Không thể kết nối tới máy chủ');
    } finally {
      AppNavigator.hideDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tạo đơn mới',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        centerTitle: false,
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
                readOnly: false,
                defaultText: widget.sender.fullName,
              ),
              AppTextField(
                controller: senderPhone,
                label: 'Số điện thoại',
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                defaultText: widget.sender.phoneNumber,
                readOnly: false,
              ),
              AppTextField(
                controller: senderAddress,
                label: 'Địa chỉ lấy hàng',
                defaultText: widget.sender.defaultAddress,
                keyboardType: TextInputType.streetAddress,
                maxLength: 255,
              ),
              AppTextField(
                controller: itemValue,
                label: 'Giá trị hàng (VNĐ)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: shippingFee,
                label: 'Phí ship (VNĐ)',
                keyboardType: TextInputType.number,
                isRequired: false,
              ),

              const SizedBox(height: 16),
              _sectionTitle('2. Thông tin người nhận'),
              AppTextField(
                controller: receiverName,
                keyboardType: TextInputType.name,
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
                keyboardType: TextInputType.streetAddress,
                label: 'Địa chỉ nhận hàng',
                maxLength: 255,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: senderNote,
                label: 'Ghi chú',
                maxLines: 2,
                keyboardType: TextInputType.multiline,
                isRequired: false,
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send, color: Colors.white,),
                  label: const Text('Gửi đơn', style: TextStyle(color: Colors.white),),
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
