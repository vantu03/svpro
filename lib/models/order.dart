import 'package:svpro/models/shiper.dart';

class OrderModel {
  final int id;
  final int senderId;
  final String pickupAddress;
  final String? note;
  final String receiverName;
  final String receiverPhone;
  final String receiverAddress;
  final int itemValue;
  final int? shippingFee;
  final bool shippingFeeConfirmed;
  final int? shipperId;
  final ShipperModel? shipper;
  final String status;
  final String createAt;
  final String updateAt;

  OrderModel({
    required this.id,
    required this.senderId,
    required this.pickupAddress,
    this.note,
    required this.receiverName,
    required this.receiverPhone,
    required this.receiverAddress,
    required this.itemValue,
    this.shippingFee,
    required this.shippingFeeConfirmed,
    this.shipperId,
    this.shipper,
    required this.status,
    required this.createAt,
    required this.updateAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int,
      senderId: json['sender_id'] as int,
      pickupAddress: json['pickup_address'] ?? '',
      note: json['note'],
      receiverName: json['receiver_name'] ?? '',
      receiverPhone: json['receiver_phone'] ?? '',
      receiverAddress: json['receiver_address'] ?? '',
      itemValue: json['item_value'] ?? 0,
      shippingFee: json['shipping_fee'],
      shippingFeeConfirmed: json['shipping_fee_confirmed'] ?? false,
      shipperId: json['shipper_id'],
      shipper: json['shipper'] != null  ? ShipperModel.fromJson(json['shipper']) : null,
      status: json['status'] ?? '',
      createAt: json['create_at'] ?? '',
      updateAt: json['update_at'] ?? '',
    );
  }
}
