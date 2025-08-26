import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppNavigator {
  // ===== Core =====
  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();
  static BuildContext? get ctx => key.currentContext;
  static bool get hasContext => key.currentState?.mounted == true && ctx != null;
  static bool get hasPending => pendingPath != null;

  /// Đảm bảo code chạy sau build/layout/paint
  static Future<T?> _post<T>(FutureOr<T> Function() fn) {
    final completer = Completer<T?>();
    final phase = SchedulerBinding.instance.schedulerPhase;

    void run() async {
      completer.complete(await fn());
    }

    if (phase == SchedulerPhase.idle) {
      run();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => run());
    }
    return completer.future;
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
    if (!hasContext) {
      pendingPath = path;
      return;
    }
    _post(() => ctx?.push(path));
  }

  static void safeReplace(String path) {
    if (!hasContext) {
      pendingPath = path;
      return;
    }
    _post(() => ctx?.go(path));
  }

  static void safePushWidget(Widget page, {bool fullscreenDialog = false}) {
    if (!hasContext) return;
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

  /// Điều hướng còn tồn đọng
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
    _post(() => Navigator.of(ctx!).pop(result));
  }

  static void popIfCan<T extends Object?>([T? result]) {
    if (!hasContext) return;
    _post(() {
      final nav = Navigator.of(ctx!);
      if (nav.canPop()) nav.pop(result);
    });
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
  }) {
    if (!hasContext) return Future.value();

    return _post(() {
      return showDialog<void>(
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
    });
  }

  static Future<void> showLoadingDialog({bool useRootNavigator = true, String? message}) {
    if (!hasContext) return Future.value();
    return _post(() {
      return showDialog<void>(
        context: ctx!,
        useRootNavigator: useRootNavigator,
        barrierDismissible: false,
        builder: (_) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  if (message != null && message.isNotEmpty) ...[
                    const SizedBox(width: 20),
                    Flexible(
                      child: Text(
                        message,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );
    });
  }


  static void hideDialog({bool useRootNavigator = true}) {
    if (!hasContext) return;
    _post(() {
      final navigator = Navigator.of(ctx!, rootNavigator: useRootNavigator);
      if (navigator.canPop()) navigator.pop();
    });
  }

  static Future<void> showForcedActionDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
    String confirmText = 'Xác nhận',
  }) {
    if (!hasContext) return Future.value();

    return _post(() {
      return showDialog<void>(
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
    });
  }

  static void _snack(
      String message, {
        IconData? icon,
        Color? baseColor,
        Duration duration = const Duration(seconds: 3),
      }) {
    if (!hasContext) return;
    final messenger = ScaffoldMessenger.maybeOf(ctx!);
    if (messenger == null) return;

    final theme = Theme.of(ctx!);
    final color = baseColor ?? theme.colorScheme.primary;

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        duration: duration,
        content: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.1),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// ===== Public Methods =====
  static void info(String message) =>
      _snack(message, icon: Icons.info_outline, baseColor: Colors.blue);

  static void success(String message) =>
      _snack(message, icon: Icons.check_circle, baseColor: Colors.green);

  static void error(String message) =>
      _snack(message, icon: Icons.error, baseColor: Colors.red);

  static void warning(String message) =>
      _snack(message, icon: Icons.warning_amber_rounded, baseColor: Colors.orange);

  static Future<String> getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

}
