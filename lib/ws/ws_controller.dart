
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
        await client.onLoadHome?.call();
        await client.onLoadNotification?.call();
        print('auth done!');
        break;
      case 'logout':
        await client.onLogout?.call();
        break;
      case 'auth_failed':
        await client.onLogout?.call();
        break;
      case 'notification':
        await client.onInsertNotification?.call(payload);
        break;
    }
  }

}