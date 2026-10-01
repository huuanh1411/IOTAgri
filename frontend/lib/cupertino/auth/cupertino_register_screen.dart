import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class CupertinoRegisterScreen extends StatefulWidget {
  const CupertinoRegisterScreen({super.key});

  @override
  State<CupertinoRegisterScreen> createState() => _CupertinoRegisterScreenState();
}

class _CupertinoRegisterScreenState extends State<CupertinoRegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (name.isEmpty || !email.contains('@')) {
      _showMessage('Vui lòng nhập họ tên và email hợp lệ.');
      return;
    }
    if (password.length < 8) {
      _showMessage('Mật khẩu phải có ít nhất 8 ký tự.');
      return;
    }
    if (password != _confirmController.text) {
      _showMessage('Mật khẩu xác nhận không khớp.');
      return;
    }

    final success = await context.read<AuthProvider>().register(email, password, name);
    if (!success && mounted) {
      _showMessage(context.read<AuthProvider>().errorMessage ?? 'Đăng ký thất bại.');
    }
  }

  void _showMessage(String message) {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Kiểm tra thông tin'),
        content: Padding(padding: const EdgeInsets.only(top: 8), child: Text(message)),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Tạo tài khoản')),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth > 520 ? 420 : double.infinity),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(CupertinoIcons.person_crop_circle_badge_plus, size: 64, color: Color(0xFF34C759)),
                    const SizedBox(height: 18),
                    Text('Bắt đầu cùng Aerogreen', textAlign: TextAlign.center, style: TextStyle(color: CupertinoColors.label.resolveFrom(context), fontSize: 27, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text('Tạo không gian riêng cho nông trại của bạn.', textAlign: TextAlign.center, style: TextStyle(color: CupertinoColors.secondaryLabel.resolveFrom(context), fontSize: 15)),
                    const SizedBox(height: 30),
                    _RegisterField(label: 'Họ và tên', controller: _nameController, placeholder: 'Nguyễn Văn A', icon: CupertinoIcons.person),
                    const SizedBox(height: 14),
                    _RegisterField(label: 'Email', controller: _emailController, placeholder: 'you@example.com', icon: CupertinoIcons.mail, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 14),
                    _RegisterField(label: 'Mật khẩu', controller: _passwordController, placeholder: 'Tối thiểu 8 ký tự', icon: CupertinoIcons.lock, obscureText: _obscurePassword, suffix: _visibilityButton(_obscurePassword, () => setState(() => _obscurePassword = !_obscurePassword))),
                    const SizedBox(height: 14),
                    _RegisterField(label: 'Xác nhận mật khẩu', controller: _confirmController, placeholder: 'Nhập lại mật khẩu', icon: CupertinoIcons.lock, obscureText: _obscureConfirm, suffix: _visibilityButton(_obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm)), onSubmitted: (_) => _submit()),
                    const SizedBox(height: 24),
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) => CupertinoButton.filled(
                        minSize: 52,
                        borderRadius: BorderRadius.circular(16),
                        onPressed: authProvider.isLoading ? null : _submit,
                        child: authProvider.isLoading ? const CupertinoActivityIndicator(color: CupertinoColors.white) : const Text('Đăng ký', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    CupertinoButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Đã có tài khoản? Đăng nhập')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _visibilityButton(bool obscured, VoidCallback onPressed) => CupertinoButton(padding: const EdgeInsets.all(12), minSize: 44, onPressed: onPressed, child: Icon(obscured ? CupertinoIcons.eye : CupertinoIcons.eye_slash, size: 19));
}

class _RegisterField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String placeholder;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final ValueChanged<String>? onSubmitted;

  const _RegisterField({required this.label, required this.controller, required this.placeholder, required this.icon, this.obscureText = false, this.keyboardType, this.suffix, this.onSubmitted});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(padding: const EdgeInsets.only(left: 4, bottom: 7), child: Text(label, style: TextStyle(color: CupertinoColors.secondaryLabel.resolveFrom(context), fontSize: 13, fontWeight: FontWeight.w600))),
    CupertinoTextField(controller: controller, placeholder: placeholder, obscureText: obscureText, keyboardType: keyboardType, onSubmitted: onSubmitted, prefix: Padding(padding: const EdgeInsets.only(left: 14), child: Icon(icon, size: 19)), suffix: suffix, padding: const EdgeInsets.fromLTRB(14, 16, 4, 16), decoration: BoxDecoration(color: CupertinoColors.secondarySystemBackground.resolveFrom(context), borderRadius: BorderRadius.circular(16), border: Border.all(color: CupertinoColors.separator.resolveFrom(context)))),
  ]);
}
