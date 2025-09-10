import 'package:svpro/models/shiper.dart';

class OrderModel {
  final int id;
  final int senderId;
  final String senderName;
  final String senderPhone;
  final String pickupAddress;
  final double pickupLat;
  final double pickupLng;
  final String? note;
  final String receiverName;
  final String receiverPhone;
  final String receiverAddress;
  final double? receiverLat;
  final double? receiverLng;
  final int itemValue;
  final int? shippingFee;
  final bool shippingFeeConfirmed;
  final int? shipperId;
  final ShipperModel? shipper;
  String status;
  final String createdAt;
  final String updatedAt;

  OrderModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderPhone,
    required this.pickupAddress,
    required this.pickupLat,
    required this.pickupLng,
    this.note,
    required this.receiverName,
    required this.receiverPhone,
    required this.receiverAddress,
    this.receiverLat,
    this.receiverLng,
    required this.itemValue,
    this.shippingFee,
    required this.shippingFeeConfirmed,
    this.shipperId,
    this.shipper,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      senderPhone: json['sender_phone'],
      senderName: json['sender_name'],
      senderId: json['sender_id'],
      pickupAddress: json['pickup_address'] ?? '',
      pickupLat: json['pickup_lat'],
      pickupLng: json['pickup_lng'],
      note: json['note'] ?? '',
      receiverName: json['receiver_name'] ?? '',
      receiverPhone: json['receiver_phone'] ?? '',
      receiverAddress: json['receiver_address'] ?? '',
      receiverLat: json['receiver_lat'],
      receiverLng: json['receiver_lng'],
      itemValue: json['item_value'] ?? 0,
      shippingFee: json['shipping_fee'],
      shippingFeeConfirmed: json['shipping_fee_confirmed'] ?? false,
      shipperId: json['shipper_id'],
      shipper: json['shipper'] != null ? ShipperModel.fromJson(json['shipper']) : null,
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
