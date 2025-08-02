import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:svpro/ws/ws_controller.dart';

class WebSocketClient {
  WebSocketChannel? channel;
  WebSocketController? controller;

  bool isConnected = false;
  bool manuallyClosed = false;

  Function()? onLogout;
  Function()? onConnected;
  Function()? onDisconnected;
  Function(dynamic error)? onError;
  Function(dynamic data)? onNotification;

  WebSocketClient() {
    controller = WebSocketController(client: this);
  }

  void connect(String url) {
    if (isConnected || channel != null) {
      print('[WS] Already connected or connecting.');
      return;
    }

    print('[WS] Connecting to $url ...');
    manuallyClosed = false;

    try {
      channel = WebSocketChannel.connect(Uri.parse(url));
    } catch (e) {
      print('[WS] Connection error: $e');
      reconnect(url);
      return;
    }

    isConnected = true;
    onConnected?.call();

    channel!.stream.listen(
          (message) {
        try {
          final msg = jsonDecode(message);
          controller?.onMessage(msg);
        } catch (e) {
          print('[WS] JSON decode error: $e - $message');
        }
      },
      onError: (error) {
        print('[WS] Connection error: $error');
        isConnected = false;
        channel = null;
        onError?.call(error);
        reconnect(url);
      },
      onDone: () {
        print('[WS] Connection closed.');
        isConnected = false;
        channel = null;
        onDisconnected?.call();
        reconnect(url);
      },
      cancelOnError: true,
    );

  }

  void reconnect(String url) async {
    if (manuallyClosed) {
      print('[WS] Manual disconnect. No reconnect.');
      return;
    }

    print('[WS] Reconnecting in 3s...');
    await Future.delayed(const Duration(seconds: 3));
    connect(url);
  }

  void disconnect() {
    manuallyClosed = true;
    isConnected = false;
    try {
      channel?.sink.close();
    } catch (_) {}
    channel = null;
  }

  void send(String cmd, Map<String, dynamic> payload) {
    if (!isConnected || channel == null) {
      print('[WS] Not connected. Cannot send.');
      return;
    }

    try {
      final msg = jsonEncode({'cmd': cmd, 'payload': payload});
      channel!.sink.add(msg);
      print('[WS] Sent: $msg');
    } catch (e) {
      print('[WS] Send error: $e');
    }
  }
}