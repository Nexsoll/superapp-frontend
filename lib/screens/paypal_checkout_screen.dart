import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaypalCheckoutScreen extends StatefulWidget {
  final String approvalUrl;
  final String returnUrl;
  final String cancelUrl;

  const PaypalCheckoutScreen({
    super.key,
    required this.approvalUrl,
    required this.returnUrl,
    required this.cancelUrl,
  });

  @override
  State<PaypalCheckoutScreen> createState() => _PaypalCheckoutScreenState();
}

class _PaypalCheckoutScreenState extends State<PaypalCheckoutScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() => _isLoading = true);
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onNavigationRequest: (request) {
            final url = request.url;
            if (url.startsWith(widget.returnUrl)) {
              Navigator.of(context).pop(true);
              return NavigationDecision.prevent;
            }
            if (url.startsWith(widget.cancelUrl)) {
              Navigator.of(context).pop(false);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    _initWebView();
  }

  Future<void> _initWebView() async {
    await WebViewCookieManager().clearCookies();
    await _controller.clearCache();
    await _controller.clearLocalStorage();
    _controller.loadRequest(Uri.parse(widget.approvalUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PayPal Checkout'.tr)),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
