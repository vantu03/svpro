import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:svpro/app_navigator.dart';
import 'package:svpro/app_core.dart';
import 'package:svpro/models/order.dart';
import 'package:svpro/models/sender.dart';
import 'package:svpro/services/api_service.dart';
import 'package:svpro/services/location_service.dart';
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

  void submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    AppNavigator.showLoadingDialog();
    try {
      // Lấy GPS của người gửi
      final position = await LocationService.getCurrentLocation();
      if (position == null) {
        AppNavigator.hideDialog();
        AppNavigator.warning("Không thể lấy GPS của bạn, vui lòng thử lại!");
        return;
      }

      final response = await ApiService.createOrder(
        pickupAddress: senderAddress.text,
        itemValue: int.tryParse(itemValue.text),
        shippingFee: int.tryParse(shippingFee.text),
        note: senderNote.text,
        receiverName: receiverName.text,
        receiverPhone: receiverPhone.text,
        receiverAddress: receiverAddress.text,
        pickupLat: position.latitude,
        pickupLng: position.longitude,
      );

      if (response.statusCode == 422) {
        AppCore.handleValidationError(response.body);
        return;
      }

      var jsonData = jsonDecode(response.body);
      if (jsonData['detail']['status']) {
        AppNavigator.popIfCan(OrderModel.fromJson(jsonData['detail']['data']['order']));
        AppNavigator.success('Tạo đơn thành công!');
      } else {
        AppNavigator.error(jsonData['detail']['message']);
      }
    } catch (e) {
      debugPrint("error: $e");
      AppNavigator.error('Không thể kết nối tới máy chủ');
    } finally {
      AppNavigator.hideDialog();
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tạo đơn mới'),
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
                minLength: 5,
                maxLength: 255,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.my_location),
                  tooltip: "Lấy địa chỉ hiện tại",
                  onPressed: () async {
                    AppNavigator.showLoadingDialog(message: "Đang lấy địa chỉ...");
                    final address = await LocationService.getCurrentAddress();
                    AppNavigator.hideDialog();

                    if (address != null) {
                      setState(() {
                        senderAddress.text = address;
                      });
                      AppNavigator.info("Đã lấy địa chỉ thành công!");
                    } else {
                      AppNavigator.warning("Không thể lấy địa chỉ hiện tại");
                    }
                  },
                ),
              ),
              AppTextField(
                controller: itemValue,
                label: 'Giá trị hàng (VNĐ)',
                keyboardType: TextInputType.number,
                minValue: 5000,
                maxLength: 10000000,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: shippingFee,
                label: 'Phí ship (VNĐ)',
                keyboardType: TextInputType.number,
                isRequired: false,
                minValue: 5000,
                maxLength: 1000000,
              ),

              const SizedBox(height: 16),
              _sectionTitle('2. Thông tin người nhận'),
              AppTextField(
                controller: receiverName,
                keyboardType: TextInputType.name,
                label: 'Họ tên',
                minLength: 5,
                maxLength: 50,
              ),
              AppTextField(
                controller: receiverPhone,
                label: 'Số điện thoại',
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                minLength: 10,
                maxLength: 12,
              ),
              AppTextField(
                controller: receiverAddress,
                keyboardType: TextInputType.streetAddress,
                label: 'Địa chỉ nhận hàng',
                minLength: 5,
                maxLength: 255,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: senderNote,
                label: 'Ghi chú',
                maxLines: 2,
                keyboardType: TextInputType.multiline,
                isRequired: false,
                maxLength: 500,
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send,),
                  label: const Text('Gửi đơn'),
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
