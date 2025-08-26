import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:svpro/app_navigator.dart';
import 'package:svpro/app_core.dart';
import 'package:svpro/services/api_service.dart';
import 'package:svpro/services/app_permission_service.dart';
import 'package:svpro/services/local_storage.dart';

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
    await AppCore.checkForUpdate();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Đăng nhập'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 6,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Dùng tài khoản đã đăng ký hoặc dùng tài khoản của sinh viên ở các trang tín chỉ.',
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
                                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
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
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                                    : const Text('Đăng nhập', style: TextStyle(fontSize: 16, color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Logo lồng vào viền trên
                    Positioned(
                      top: -40,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.blueAccent, width: 2),
                          ),
                          child: Image.asset(
                            'assets/icon/app_icon.png',
                            height: 64,
                            width: 64,
                          ),

                        ),
                      ),
                    ),
                  ],
                ),
              ],
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
