import 'dart:convert';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:svpro/ws/ws_controller.dart';

class WebSocketClient {

  WebSocketChannel? channel;
  WebSocketController? controller;

  bool isConnected = false;
  bool manuallyClosed = false;
  Timer? pingTimer;

  Map<String, FutureOr<void> Function()> subscriptions = {};

  Function()? onLogout;
  Function()? onConnected;
  Function()? onDisconnected;
  Function(dynamic error)? onError;
  Function(dynamic data)? onNotificationInserted;
  Function(dynamic data)? onReadNotification;
  Function()? onReadNotificationAll;
  Function(dynamic data)? onOrderRemoved;
  Function(dynamic data)? onOrderStatusChanged;
  Function(dynamic data)? onOrderInserted;

  WebSocketClient() {
    controller = WebSocketController(client: this);
  }

  void connect(String url) {

    disconnect();

    debugPrint("Websocket: Connecting to $url ...");
    manuallyClosed = false;

    try {
      channel = WebSocketChannel.connect(Uri.parse(url));
    } catch (e) {
      debugPrint("error: $e");
      reconnect(url);
      return;
    }

    isConnected = true;
    onConnected?.call();
    //startPing();

    channel!.stream.listen(
          (message) {
        try {
          final msg = jsonDecode(message);
          controller?.onMessage(msg);
        } catch (e) {
          debugPrint("error: $e - $message");
        }
      },
      onError: (e) {
        debugPrint("error: $e");
        isConnected = false;
        channel = null;
        onError?.call(e);
        reconnect(url);
      },
      onDone: () {
        debugPrint("Websocket: Connection closed.");
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
      debugPrint("Websocket: Manual disconnect. No reconnect.");
      return;
    }

    debugPrint("Websocket: Reconnecting in 3s...");
    await Future.delayed(const Duration(seconds: 3));
    connect(url);
  }

  void startPing() {
    pingTimer?.cancel();
    pingTimer = Timer.periodic(Duration(seconds: 30), (_) {
      if (isConnected) {
        try {
          send('ping', {});
          debugPrint("Websocket: → ping");
        } catch (e) {
          debugPrint("error: $e");
        }
      }
    });
  }

  void disconnect() {
    if (isConnected) {
      debugPrint("Websocket: disconnect........");
      manuallyClosed = true;
      try {
        channel?.sink.close();
      } catch (_) {}
      pingTimer?.cancel();
      pingTimer = null;
      channel = null;
      isConnected = false;
    }
  }

  void send(String cmd, Map<String, dynamic> payload) {
    if (!isConnected || channel == null) {
      debugPrint("Websocket: Not connected. Cannot send.");
      return;
    }

    try {
      final msg = jsonEncode({'cmd': cmd, 'payload': payload});
      channel!.sink.add(msg);
    } catch (e) {
      debugPrint("error: $e");
    }
  }

  String addSubscription(FutureOr<void> Function() sub) {
    final id = UniqueKey().toString();
    subscriptions[id] = sub;

    // gọi ngay
    final result = sub();
    if (result is Future) {
      result.catchError((e) {
        debugPrint("error: $e");
      });
    }

    return id;
  }

  void removeSubscription(String id) {
    subscriptions.remove(id);
  }

  Future<void> reSubscribeAll() async {
    for (var sub in subscriptions.values) {
      final result = sub();
      if (result is Future) {
        await result;
      }
    }
  }
}

WebSocketClient wsService = WebSocketClient();