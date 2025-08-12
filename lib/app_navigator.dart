import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';

class AppNavigator {
  // ===== Core =====
  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();
  static BuildContext? get ctx => key.currentContext;
  static bool get hasContext => key.currentState?.mounted == true && ctx != null;
  static bool get hasPending => pendingPath != null;

  //
  static void _post(void Function() fn) {
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle) {
      // Không trong build/layout/paint → chạy ngay
      fn();
    } else {
      // Đang build/layout/paint → hoãn sang frame sau
      WidgetsBinding.instance.addPostFrameCallback((_) => fn());
    }
  }

  // ===== Điều hướng an toàn =====
  static String? pendingPath;

  static void safeGo(String path) {
    if (!hasContext) {
      pendingPath = path;
      return;
    }
    _post(() => ctx?.go(path));
  }

  static void safePush(String path) {
    if (!hasContext) { pendingPath = path; return; }
    _post(() => ctx?.push(path));
  }

  static void safeReplace(String path) {
    if (!hasContext) { pendingPath = path; return; }
    _post(() => ctx?.go(path));
  }

  static void safePushWidget(Widget page, {bool fullscreenDialog = false}) {
    if (!hasContext) {
      return;
    }
    _post(() => Navigator.of(ctx!).push(
      MaterialPageRoute(
        builder: (_) => page,
        fullscreenDialog: fullscreenDialog,
      ),
    ));
  }

  static void safeReplaceWidget(Widget page) {
    if (!hasContext) return;
    _post(() => Navigator.of(ctx!).pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    ));
  }

  static void safeGoWidget(Widget page) {
    if (!hasContext) return;
    _post(() => Navigator.of(ctx!).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => page),
          (route) => false,
    ));
  }

  //điều hướng còn tồn đọng
  static void flushPending() {
    if (!hasContext || pendingPath == null) return;
    final path = pendingPath!;
    pendingPath = null;
    _post(() => ctx?.go(path));
    AppNavigator.warning(path);
  }

  // ===== Pop =====
  static void pop<T extends Object?>([T? result]) {
    if (!hasContext) return;
    Navigator.of(ctx!).pop(result);
  }

  static void popIfCan<T extends Object?>([T? result]) {
    if (!hasContext) return;
    final nav = Navigator.of(ctx!);
    if (nav.canPop()) nav.pop(result);
  }
  // ===== Dialogs =====
  static Future<void> showConfirmationDialog({
    required String title,
    required String content,
    required String confirmText,
    required VoidCallback onConfirm,
    String? cancelText = 'Hủy',
    Color confirmColor = Colors.blue,
    bool useRootNavigator = true,
  }) async {
    if (!hasContext) return;
    return showDialog(
      context: ctx!,
      useRootNavigator: useRootNavigator,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          if (cancelText != null)
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(cancelText),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  static void showLoadingDialog({bool useRootNavigator = true}) {
    if (!hasContext) return;
    showDialog(
      context: ctx!,
      useRootNavigator: useRootNavigator,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  static void hideDialog({bool useRootNavigator = true}) {
    if (!hasContext) return;
    final navigator = Navigator.of(ctx!, rootNavigator: useRootNavigator);
    if (navigator.canPop()) navigator.pop();
  }

  static Future<void> showForcedActionDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
    String confirmText = 'Xác nhận',
  }) async {
    if (!hasContext) return;
    return showDialog(
      context: ctx!,
      barrierDismissible: false,
      builder: (dctx) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dctx).pop();
                  onConfirm();
                },
                child: Text(confirmText),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===== Snackbars =====
  static void _snack(String message, {Color? backgroundColor, Duration duration = const Duration(seconds: 2)}) {
    if (!hasContext) return;
    final messenger = ScaffoldMessenger.maybeOf(ctx!);
    if (messenger == null) return;
    _post(() {
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(content: Text(message), backgroundColor: backgroundColor, duration: duration),
      );
    });
  }

  static void snack(String message) => _snack(message);
  static void success(String message) => _snack(message, backgroundColor: Colors.green);
  static void error(String message)   => _snack(message, backgroundColor: Colors.red);
  static void warning(String message) => _snack(message, backgroundColor: Colors.orange);
  static void info(String message)    => _snack(message, backgroundColor: Colors.blue);
}
