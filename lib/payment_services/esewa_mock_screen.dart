import 'package:flutter/material.dart';

/// A mock eSewa payment screen that simulates the real eSewa UI.
/// Use test credentials: Phone: 9825200720, Password: 2335, MPIN: 1122
class EsewaMockScreen extends StatefulWidget {
  final int amount;
  const EsewaMockScreen({super.key, required this.amount});

  @override
  State<EsewaMockScreen> createState() => _EsewaMockScreenState();
}

class _EsewaMockScreenState extends State<EsewaMockScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mpinController = TextEditingController();

  bool _showMpin = false;
  bool _isLoading = false;
  String? _error;

  static const String _testPhone = '9800000001';
  static const String _testPassword = '1111';
  static const String _testMpin = '1122';

  static const Color _esewaGreen = Color(0xFF4FBF26);

  void _submitCredentials() {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phone != _testPhone || password != _testPassword) {
      setState(() => _error = 'Invalid eSewa ID or Password. Use test credentials.');
      return;
    }

    setState(() { _error = null; _isLoading = true; });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() { _isLoading = false; _showMpin = true; });
    });
  }

  void _submitMpin() {
    if (_mpinController.text.trim() != _testMpin) {
      setState(() => _error = 'Invalid MPIN. Use: $_testMpin');
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
    _passwordController.dispose();
    _mpinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _esewaGreen,
      appBar: AppBar(
        backgroundColor: _esewaGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Row(
          children: [
            Image.asset('assets/images/esewalogo.png', width: 28, height: 28,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.account_balance_wallet, color: Colors.white, size: 28)),
            const SizedBox(width: 8),
            const Text('eSewa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Amount header
          Container(
            width: double.infinity,
            color: _esewaGreen,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Amount',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Text('NPR. ${widget.amount}.00',
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
                child: _showMpin ? _buildMpinForm() : _buildLoginForm(),
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
        const Text('Sign in to your account',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('Enter your eSewa credentials',
            style: TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 24),

        _buildField('eSewa ID (Phone)', _phoneController,
            hint: '98XXXXXXXX', keyboardType: TextInputType.phone, maxLength: 10),
        const SizedBox(height: 16),
        _buildField('Password', _passwordController,
            hint: '••••••', obscure: true),

        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
        ],

        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Test: Phone 9800000001 | Password 1111',
            style: TextStyle(fontSize: 12, color: _esewaGreen),
          ),
        ),

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _esewaGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _isLoading ? null : _submitCredentials,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('LOGIN', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildMpinForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Enter MPIN',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text('Confirm payment of NPR ${widget.amount}',
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 24),

        _buildField('MPIN', _mpinController,
            hint: '4-digit MPIN', obscure: true, keyboardType: TextInputType.number),

        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
        ],

        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Test MPIN: 1122',
            style: TextStyle(fontSize: 12, color: _esewaGreen),
          ),
        ),

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _esewaGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _isLoading ? null : _submitMpin,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('CONFIRM PAYMENT',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
              borderSide: const BorderSide(color: _esewaGreen, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ],
    );
  }
}
