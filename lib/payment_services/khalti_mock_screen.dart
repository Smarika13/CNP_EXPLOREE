import 'package:flutter/material.dart';

/// A mock Khalti payment screen that simulates the real Khalti UI.
/// Use test credentials: Phone: 9800000001, MPIN: 1111, OTP: 987654
class KhaltiMockScreen extends StatefulWidget {
  final int amount;
  const KhaltiMockScreen({super.key, required this.amount});

  @override
  State<KhaltiMockScreen> createState() => _KhaltiMockScreenState();
}

class _KhaltiMockScreenState extends State<KhaltiMockScreen> {
  final _phoneController = TextEditingController();
  final _mpinController = TextEditingController();
  final _otpController = TextEditingController();

  bool _showOtp = false;
  bool _isLoading = false;
  String? _error;

  static const String _testPhone = '9800000001';
  static const String _testMpin = '1111';
  static const String _testOtp = '987654';

  void _submitCredentials() {
    final phone = _phoneController.text.trim();
    final mpin = _mpinController.text.trim();

    if (phone != _testPhone || mpin != _testMpin) {
      setState(() => _error = 'Invalid Khalti ID or MPIN. Use test credentials.');
      return;
    }

    setState(() {
      _error = null;
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() { _isLoading = false; _showOtp = true; });
    });
  }

  void _submitOtp() {
    if (_otpController.text.trim() != _testOtp) {
      setState(() => _error = 'Invalid OTP. Use: $_testOtp');
      return;
    }

    setState(() { _error = null; _isLoading = true; });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) Navigator.pop(context, true);
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _mpinController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5C2D91),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C2D91),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Row(
          children: [
            Image.asset('assets/images/khaltilogo.png', width: 28, height: 28,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.account_balance_wallet, color: Colors.white, size: 28)),
            const SizedBox(width: 8),
            const Text('Khalti', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Amount header
          Container(
            width: double.infinity,
            color: const Color(0xFF5C2D91),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Payable Amount',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Text('Rs. ${widget.amount}',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // Form card
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _showOtp ? _buildOtpForm() : _buildLoginForm(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pay with Khalti',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('Enter your Khalti credentials',
            style: TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 24),

        _buildField('Khalti ID (Phone)', _phoneController,
            hint: '98XXXXXXXX', keyboardType: TextInputType.phone, maxLength: 10),
        const SizedBox(height: 16),
        _buildField('MPIN', _mpinController,
            hint: '••••', obscure: true, keyboardType: TextInputType.number),

        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
        ],

        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Test: Phone 9800000001 | MPIN 1111',
            style: TextStyle(fontSize: 12, color: Color(0xFF5C2D91)),
          ),
        ),

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5C2D91),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _isLoading ? null : _submitCredentials,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Continue', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Enter OTP',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text('OTP sent to ${_phoneController.text}',
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 24),

        _buildField('OTP', _otpController,
            hint: '6-digit OTP', keyboardType: TextInputType.number),

        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
        ],

        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Test OTP: 987654',
            style: TextStyle(fontSize: 12, color: Color(0xFF5C2D91)),
          ),
        ),

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5C2D91),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _isLoading ? null : _submitOtp,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Confirm Payment', style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {String? hint, bool obscure = false, TextInputType? keyboardType, int? maxLength}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF5C2D91), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ],
    );
  }
}
