import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AppWebView extends StatefulWidget {
  const AppWebView({
    super.key,
    required this.url,
    this.headers,
    this.onSuccessUrlPrefix,
    this.onCustomScheme,
    this.allowedHostSuffix,
    this.onSuccess,
  });

  final String url;
  final Map<String, String>? headers;
  final String? onSuccessUrlPrefix; // URL bắt đầu bằng => success
  final String? onCustomScheme;     // Scheme đặc biệt => success
  final String? allowedHostSuffix;  // Giới hạn domain
  final VoidCallback? onSuccess;    // Callback khi thành công

  @override
  State<AppWebView> createState() => AppWebViewState();
}

class AppWebViewState extends State<AppWebView> {
  late final WebViewController controller;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => loading = true),
          onPageFinished: (_) => setState(() => loading = false),
          onNavigationRequest: (req) {
            debugPrint('[WEB] → ${req.url}');

            // Thành công qua URL prefix
            if (widget.onSuccessUrlPrefix != null &&
                req.url.startsWith(widget.onSuccessUrlPrefix!)) {
              widget.onSuccess?.call();
              return NavigationDecision.prevent;
            }

            // Thành công qua custom scheme
            if (widget.onCustomScheme != null &&
                req.url.startsWith(widget.onCustomScheme!)) {
              widget.onSuccess?.call();
              return NavigationDecision.prevent;
            }

            // Giới hạn domain
            if (widget.allowedHostSuffix != null &&
                !req.url.contains(widget.allowedHostSuffix!)) {
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url), headers: widget.headers ?? {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: controller),
        if (loading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
