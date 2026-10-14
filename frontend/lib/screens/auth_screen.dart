import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../core/widgets/gradient_button.dart';
import '../providers/auth_controller.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});
  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng kiểm tra email, mật khẩu (ít nhất 8 ký tự) và phần xác nhận mật khẩu.',
          ),
        ),
      );
      return;
    }
    final controller = ref.read(authControllerProvider.notifier);
    if (ref.read(authTabProvider) == 0) {
      await controller.login(
        email: _email.text.trim(),
        password: _password.text,
      );
    } else {
      await controller.signUp(
        fullName: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final isLogin = ref.watch(authTabProvider) == 0;
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.user != null && previous?.user?.id != next.user!.id && mounted) {
        context.go('/home');
      }
    });
    if (auth.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(auth.error!)));
        ref.read(authControllerProvider.notifier).clearError();
      });
    }
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 34, 24, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  const _Brand(),
                  const SizedBox(height: 26),
                  Text(
                    'Trồng Rau Đô Thị Nhàn Tênh',
                    style: AppText.heading(context, fontSize: 26),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Trồng rau sạch ngay trên mặt bếp — Aerogreen lo phần còn lại.',
                    textAlign: TextAlign.center,
                    style: AppText.body(
                      context,
                      fontSize: 13,
                    ).copyWith(color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 38),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFEF9),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFFE3EADF)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x183A5568),
                          blurRadius: 28,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _Tabs(isLogin: isLogin),
                          const SizedBox(height: 18),
                          if (!isLogin) ...[
                            _Field(
                              controller: _name,
                              icon: Icons.person_outline,
                              hint: 'Họ và tên',
                            ),
                            const SizedBox(height: 12),
                          ],
                          _Field(
                            controller: _email,
                            icon: Icons.mail_outline,
                            hint: 'ban@vidu.com',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) =>
                                value == null || !value.contains('@')
                                ? 'Email không hợp lệ'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          _Field(
                            controller: _password,
                            icon: Icons.lock_outline,
                            hint: 'Mật khẩu',
                            obscure: _hidePassword,
                            suffix: IconButton(
                              icon: Icon(
                                _hidePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () => setState(
                                () => _hidePassword = !_hidePassword,
                              ),
                            ),
                            validator: (value) =>
                                value == null || value.length < 8
                                ? 'Mật khẩu ít nhất 8 ký tự'
                                : null,
                          ),
                          if (!isLogin) ...[
                            const SizedBox(height: 12),
                            _Field(
                              controller: _confirmPassword,
                              icon: Icons.lock_outline,
                              hint: 'Xác nhận mật khẩu',
                              obscure: _hideConfirmPassword,
                              suffix: IconButton(
                                icon: Icon(
                                  _hideConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () => setState(
                                  () => _hideConfirmPassword =
                                      !_hideConfirmPassword,
                                ),
                              ),
                              validator: (value) => value != _password.text
                                  ? 'Mật khẩu không khớp'
                                  : null,
                            ),
                          ],
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: GradientButton(
                              label: isLogin
                                  ? 'Đăng nhập  →'
                                  : 'Tạo tài khoản  →',
                              isLoading: auth.isLoading,
                              onPressed: _submit,
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Row(
                            children: [
                              Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'hoặc tiếp tục với',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 18),
                          const Row(
                            children: [
                              Expanded(
                                child: _SocialButton(
                                  label: 'Google',
                                  letter: 'G',
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _SocialButton(
                                  label: 'Apple',
                                  letter: 'A',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Tiếp tục đồng nghĩa bạn đồng ý với Điều khoản & Quyền riêng tư.',
                    textAlign: TextAlign.center,
                    style: AppText.body(
                      context,
                      fontSize: 10,
                    ).copyWith(color: AppColors.secondaryText),
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

class _Brand extends StatelessWidget {
  const _Brand();
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [AppColors.sage, AppColors.forestGreen],
          ),
        ),
        child: const Icon(Icons.eco_outlined, color: Colors.white, size: 27),
      ),
      const SizedBox(width: 10),
      Text('Aerogreen', style: AppText.heading(context, fontSize: 19)),
    ],
  );
}

class _Tabs extends ConsumerWidget {
  const _Tabs({required this.isLogin});
  final bool isLogin;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: AppColors.rowBackground,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(
      children: [
        _tab(context, ref, 'Đăng Nhập', 0, isLogin),
        _tab(context, ref, 'Đăng Ký', 1, !isLogin),
      ],
    ),
  );
  Widget _tab(
    BuildContext context,
    WidgetRef ref,
    String label,
    int index,
    bool selected,
  ) {
    return Expanded(
      child: InkWell(
        onTap: () => ref.read(authTabProvider.notifier).state = index,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x182F5D3F),
                      blurRadius: 7,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppText.body(
              context,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ).copyWith(color: AppColors.forestGreen),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.icon,
    required this.hint,
    this.keyboardType,
    this.obscure = false,
    this.suffix,
    this.validator,
  });
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffix;
  final String? Function(String?)? validator;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscure,
    validator: validator,
    decoration: InputDecoration(
      prefixIcon: Icon(icon, size: 19, color: AppColors.secondaryText),
      suffixIcon: suffix,
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF859486)),
      filled: true,
      fillColor: AppColors.rowBackground,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      border: _border(const Color(0xFFDCE6D8)),
      enabledBorder: _border(const Color(0xFFDCE6D8)),
      focusedBorder: _border(AppColors.forestGreen, 1.5),
    ),
  );
  OutlineInputBorder _border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(color: color, width: width),
      );
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.letter});
  final String label;
  final String letter;
  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: null,
    style: OutlinedButton.styleFrom(
      disabledForegroundColor: AppColors.primaryText,
      side: const BorderSide(color: Color(0xFFE3EADF)),
      padding: const EdgeInsets.symmetric(vertical: 11),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 9,
          backgroundColor: AppColors.mintChip,
          child: Text(
            letter,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.forestGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    ),
  );
}
