import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:svpro/app_navigator.dart';
import 'package:svpro/app_core.dart';
import 'package:svpro/services/api_service.dart';
import 'package:svpro/services/app_permission_service.dart';
import 'package:svpro/services/local_storage.dart';
import 'package:svpro/widgets/app_web_view.dart';

class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initLogin();
  }

  Future<void> initLogin() async {
    await AppNavigator.showConfirmationDialog(
      title: 'Bật thông báo',
      content: 'Bật để nhận lịch học và nhắc nhở quan trọng.',
      confirmText: 'Bật ngay',
      confirmColor: Colors.blueAccent,
      onConfirm: () async {
        final granted = await NotificationPermissionService.requestNotificationPermission();
        if (!granted) {
          await AppNavigator.showConfirmationDialog(
              title: '',
              content: 'Bật lại thông báo hãy mở \'Cài đặt\' nhé!',
              confirmText: 'OK',
              cancelText: null,
              onConfirm: () {}
          );
        }
        await NotificationPermissionService.initFcmToken();
        await LocalStorage.push();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 6,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Đăng nhập',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Dùng tài khoản đã đăng ký hoặc dùng tài khoản sinh viên ở các trang tín chỉ ICTU, TNUE.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: studentIdController,
                      decoration: InputDecoration(
                        labelText: 'Tài khoản, mã sinh viên',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: !isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () => setState(
                                  () => isPasswordVisible = !isPasswordVisible),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                            : const Text('Đăng nhập',
                            style: TextStyle(
                                fontSize: 16, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 24),


                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          final res = await ApiService.getLoginConfig();

                          if (res.statusCode == 422) {
                            AppCore.handleValidationError(res.body);
                            return;
                          }
                          var jsonData = jsonDecode(res.body);
                          if (jsonData['detail']['status']) {
                            final loginUrl = jsonData['detail']['data']["login_url"];
                            final successUrl = jsonData['detail']['data']["success_url"];
                            AppNavigator.safePushWidget(
                              AppWebView(
                                url: loginUrl,
                                allowedHostSuffix: Uri.parse(loginUrl).host,
                                onSuccessUrlPrefix: successUrl,
                                onSuccess: (String url) async {
                                  final uri = Uri.parse(url);
                                  final token = uri.queryParameters["token"];

                                  if (token != null && token.isNotEmpty) {
                                    LocalStorage.auth_token = token;
                                    await LocalStorage.push();

                                    if (context.mounted) {
                                      AppNavigator.pop();
                                      AppNavigator.safeGo('/home');
                                      AppNavigator.success("Đăng nhập thành công!");
                                    }
                                  } else {
                                    AppNavigator.error("Không tìm thấy token trong URL!");
                                  }
                                },
                              ),
                            );
                          } else {
                            AppNavigator.error(jsonData['detail']['message']);
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Colors.blueAccent, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blueAccent,
                        ),
                        child: const Text(
                          "Đăng nhập bằng cách khác",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }



  Future<void> handleLogin() async {
    final username = studentIdController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      AppNavigator.warning('Vui lòng nhập đầy đủ thông tin!');
      return;
    }

    setState(() => isLoading = true);

    try {
      final deviceInfo = await AppCore.getDeviceInfo();
      final res = await ApiService.login(username, password, deviceInfo['deviceName']);
      if (res.statusCode == 422) {
        AppCore.handleValidationError(res.body);
        return;
      }
      var jsonData = jsonDecode(res.body);
      if (jsonData['detail']['status']) {
        LocalStorage.auth_token = jsonData['detail']['data']['token'];
        await LocalStorage.push();
        AppNavigator.safeGo('/home');
        AppNavigator.success(jsonData['detail']['message']);
      } else {
        AppNavigator.error(jsonData['detail']['message']);
      }
    } catch (e) {
      debugPrint("error: $e");
      AppNavigator.error('Không thể kết nối tới máy chủ');
    } finally {
      setState(() => isLoading = false);
    }
  }

}
