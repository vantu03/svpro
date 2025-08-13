import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:svpro/config.dart';

class CallPhoneWidget extends StatelessWidget {
  final String phoneNumber;

  const CallPhoneWidget({
    super.key,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Config.callPhone(phoneNumber),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon rung rung
          Swing(
            infinite: true,
            duration: const Duration(milliseconds: 800),
            child: const Icon(
              Icons.phone,
              color: Colors.blue,
              size: 22,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            phoneNumber,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
