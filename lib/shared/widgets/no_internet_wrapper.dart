import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

class NoInternetWrapper extends StatefulWidget {
  final Widget child;
  const NoInternetWrapper({super.key, required this.child});

  @override
  State<NoInternetWrapper> createState() => _NoInternetWrapperState();
}

class _NoInternetWrapperState extends State<NoInternetWrapper> {
  bool _hasInternet = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _check();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _check());
  }

  Future<void> _check() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 4));
      final has = result.isNotEmpty && result.first.rawAddress.isNotEmpty;
      if (mounted && has != _hasInternet) setState(() => _hasInternet = has);
    } catch (_) {
      if (mounted && _hasInternet) setState(() => _hasInternet = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasInternet) return widget.child;
    return const _NoInternetScreen();
  }
}

class _NoInternetScreen extends StatelessWidget {
  const _NoInternetScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No Internet Connection',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B4332),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Please check your connection.\nThe app will reconnect automatically.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
