import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'esewa_service.dart';

class EsewaPaymentScreen extends StatefulWidget {
  final int amount;
  const EsewaPaymentScreen({super.key, required this.amount});

  @override
  State<EsewaPaymentScreen> createState() => _EsewaPaymentScreenState();
}

class _EsewaPaymentScreenState extends State<EsewaPaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _popped = false;

  @override
  void initState() {
    super.initState();

    final String amount = widget.amount.toString();
    final String uuid = EsewaService.generateUuid();
    final String signature = EsewaService.generateSignature(
      totalAmount: amount,
      transactionUuid: uuid,
    );

    // Build URL-encoded POST body
    final Map<String, String> params = {
      'amount': amount,
      'tax_amount': '0',
      'total_amount': amount,
      'transaction_uuid': uuid,
      'product_code': EsewaService.productCode,
      'product_service_charge': '0',
      'product_delivery_charge': '0',
      'success_url': 'https://developer.esewa.com.np/success',
      'failure_url': 'https://developer.esewa.com.np/failure',
      'signed_field_names': 'total_amount,transaction_uuid,product_code',
      'signature': signature,
    };

    final String postBody = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (!mounted) return;
            setState(() => _isLoading = true);
            debugPrint('[eSewa] Loading: $url');
            if (_popped) return;
            if (url.contains('developer.esewa.com.np/success')) {
              _popped = true;
              Navigator.pop(context, true);
            } else if (url.contains('developer.esewa.com.np/failure')) {
              _popped = true;
              Navigator.pop(context, false);
            }
          },
          onPageFinished: (url) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            debugPrint('[eSewa] WebView error: ${error.description}');
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(
        Uri.parse('https://rc-epay.esewa.com.np/api/epay/main/v2/form'),
        method: LoadRequestMethod.post,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: Uint8List.fromList(utf8.encode(postBody)),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('eSewa Payment'),
        backgroundColor: const Color(0xFF4FBF26),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
                child: CircularProgressIndicator(color: Color(0xFF4FBF26))),
        ],
      ),
    );
  }
}
