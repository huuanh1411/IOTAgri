// lib/screens/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text.dart';
import '../core/theme/ui_consts.dart';
import '../core/widgets/app_button.dart';
import '../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

// Provider to control which tab is selected: 0 = Login, 1 = Sign‑up
final authTabProvider = StateProvider<int>((ref) => 0);

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  // Form controllers
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPwdCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  bool _obscurePwd = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPwdCtrl.dispose();
    _fullNameCtrl.dispose();
    super.dispose();
  }

  // Simple email validation
  bool _isValidEmail(String email) => RegExp(r"^[\w-.]+@[\w-]+\.[\w-.]+$").hasMatch(email);

  Future<void> _handleLogin() async {
    final email = _emailCtrl.text.trim();
    final pwd = _passwordCtrl.text;
    if (!_isValidEmail(email)) {
      _showSnack('Email không hợp lệ.');
      return;
    }
    if (pwd.length < 8) {
      _showSnack('Mật khẩu tối thiểu 8 ký tự.');
      return;
    }
    final success = await ref.read(authControllerProvider.notifier).login(email, pwd);
    if (success) {
      if (mounted) {
        context.go('/home');
      }
    } else {
      _showSnack(ref.read(authControllerProvider).errorMessage ?? 'Đăng nhập thất bại.');
    }
  }

  Future<void> _handleRegister() async {
    final fullName = _fullNameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pwd = _passwordCtrl.text;
    final confirm = _confirmPwdCtrl.text;
    if (fullName.isEmpty) {
      _showSnack('Họ và tên không được để trống.');
      return;
    }
    if (!_isValidEmail(email)) {
      _showSnack('Email không hợp lệ.');
      return;
    }
    if (pwd.length < 8) {
      _showSnack('Mật khẩu tối thiểu 8 ký tự.');
      return;
    }
    if (pwd != confirm) {
      _showSnack('Mật khẩu xác nhận không khớp.');
      return;
    }
    final success = await ref.read(authControllerProvider.notifier).register(fullName, email, pwd);
    if (success) {
      if (mounted) {
        context.go('/home');
      }
    } else {
      _showSnack(ref.read(authControllerProvider).errorMessage ?? 'Đăng ký thất bại.');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final tabIndex = ref.watch(authTabProvider);
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, AppColors.mintChip],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              // Logo placeholder (replace with actual asset)
              const Icon(Icons.eco, size: 80, color: AppColors.forestGreen),
              const SizedBox(height: 24),
              Text('Trồng Rau Đô Thị Nhàn Tênh', style: AppText.heading),
              const SizedBox(height: 8),
              Text(
                'Trồng rau sạch ngay trên mặt bếp — Aerogreen lo phần còn lại.',
                style: AppText.body.copyWith(color: AppColors.secondaryText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Segmented tab
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(UIConsts.cardRadius),
                ),
                child: Row(
                  children: [
                    _buildTab('Đăng nhập', 0, tabIndex),
                    _buildTab('Đăng ký', 1, tabIndex),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Form fields
              if (tabIndex == 1) ...[
                AppTextField(
                  controller: _fullNameCtrl,
                  label: 'Họ và tên',
                ),
                const SizedBox(height: 12),
              ],
              AppTextField(
                controller: _emailCtrl,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _passwordCtrl,
                label: 'Mật khẩu',
                obscureText: _obscurePwd,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePwd ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePwd = !_obscurePwd),
                ),
              ),
              const SizedBox(height: 12),
              if (tabIndex == 1) ...[
                AppTextField(
                  controller: _confirmPwdCtrl,
                  label: 'Xác nhận mật khẩu',
                  obscureText: _obscureConfirm,
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 8),
              // Primary button
              GradientButton(
                onPressed: isLoading
                    ? null
                    : tabIndex == 0
                        ? _handleLogin
                        : _handleRegister,
                isLoading: isLoading,
                child: Text(tabIndex == 0 ? 'Đăng nhập' : 'Đăng ký'),
              ),
              const SizedBox(height: 16),
              // Divider with text
              Row(
                children: [
                  Expanded(child: Divider(color: AppColors.secondaryText.withOpacity(0.5))),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('hoặc tiếp tục với', style: TextStyle(color: Colors.black54)),
                  ),
                  Expanded(child: Divider(color: AppColors.secondaryText.withOpacity(0.5))),
                ],
              ),
              const SizedBox(height: 12),
              // Social buttons (outline)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlineButton(
                    onPressed: () => _showSnack('Google login được mô phỏng'),
                    icon: Icons.g_mobiledata,
                    label: 'Google',
                  ),
                  OutlineButton(
                    onPressed: () => _showSnack('Apple login được mô phỏng'),
                    icon: Icons.apple,
                    label: 'Apple',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Footnote with links
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  const Text('Tiếp tục đồng nghĩa bạn đồng ý với '),
                  GestureDetector(
                    onTap: () => _showSnack('Điều khoản'),
                    child: Text('Điều khoản', style: TextStyle(color: AppColors.forestGreen, decoration: TextDecoration.underline)),
                  ),
                  const Text(' & '),
                  GestureDetector(
                    onTap: () => _showSnack('Quyền riêng tư'),
                    child: Text('Quyền riêng tư', style: TextStyle(color: AppColors.forestGreen, decoration: TextDecoration.underline)),
                  ),
                  const Text('.'),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index, int selected) {
    final bool isSelected = index == selected;
    return Expanded(
      child: InkWell(
        onTap: () => ref.read(authTabProvider.notifier).state = index,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.forestGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(UIConsts.buttonRadius),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppText.button.copyWith(color: isSelected ? Colors.white : AppColors.forestGreen),
          ),
        ),
      ),
    );
  }
}

// Simple outline button used for social login (simulated)
class OutlineButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  const OutlineButton({super.key, required this.onPressed, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: AppColors.forestGreen),
      label: Text(label, style: const TextStyle(color: AppColors.forestGreen)),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(120, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(UIConsts.buttonRadius)),
        side: const BorderSide(color: AppColors.forestGreen),
      ),
    );
  }
}
