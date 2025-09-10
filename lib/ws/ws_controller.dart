
import 'package:flutter/material.dart';
import 'package:svpro/services/local_storage.dart';
import 'package:svpro/ws/ws_client.dart';

class WebSocketController {

  final WebSocketClient client;

  WebSocketController({required this.client});

  void onMessage(Map<String, dynamic> msg) async {
    String cmd = msg['cmd'];
    final Map<String, dynamic> payload = msg['payload'] ?? {};
    switch (cmd) {
      case 'auth':
        client.send('auth', {'token': LocalStorage.auth_token});
        break;
      case 'auth_done':
        client.reSubscribeAll();
        debugPrint('info: auth done!');
        break;
      case 'logout':
        await client.onLogout?.call();
        break;
      case 'auth_failed':
        await client.onLogout?.call();
        break;
      case 'notification':
        await client.onNotificationInserted?.call(payload);
        break;
      case 'notification_read':
        await client.onReadNotification?.call(payload);
        break;
      case 'notification_read_all':
        await client.onReadNotificationAll?.call();
        break;
      case 'order_removed':
        await client.onOrderRemoved?.call(payload);
        break;
      case 'order_status_changed':
        client.onOrderStatusChanged?.call(payload);
        break;
      case 'order_inserted':
        client.onOrderInserted?.call(payload);
        break;
    }
  }

}