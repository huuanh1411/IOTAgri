import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import 'login_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({required this.email, super.key});

  final String email;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isLoading || !_formKey.currentState!.validate()) return;
    final success = await authProvider.verifyEmail(
      widget.email,
      _codeController.text,
    );

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
      return;
    }

    _showMessage(
      authProvider.errorMessage ?? 'Không thể xác minh email. Vui lòng thử lại.',
      Colors.red,
    );
  }

  Future<void> _resendCode() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.resendVerificationCode(widget.email);

    if (!mounted) return;
    _showMessage(
      success
          ? 'Đã gửi lại mã xác minh.'
          : authProvider.errorMessage ??
              'Không thể gửi lại mã xác minh. Vui lòng thử lại.',
      success ? Colors.green : Colors.red,
    );
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xác Minh Email')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.mark_email_read_outlined,
                    size: 80,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Xác Minh Email',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nhập mã gồm 6 chữ số đã gửi đến\n${widget.email}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  TextFormField(
                    controller: _codeController,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Mã xác minh',
                      hintText: '000000',
                      prefixIcon: Icon(Icons.password),
                    ),
                    validator: (value) {
                      if (value == null || !RegExp(r'^\d{6}$').hasMatch(value)) {
                        return 'Vui lòng nhập mã xác minh gồm 6 chữ số';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _verify(),
                  ),
                  const SizedBox(height: 24),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) => ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _verify,
                      child: authProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Xác Minh'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) => TextButton(
                      onPressed: authProvider.isLoading ? null : _resendCode,
                      child: const Text('Gửi lại mã'),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Quay lại đăng ký'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
