import 'package:flutter/cupertino.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../services/api_service.dart';

enum PasswordStrength { none, weak, medium, strong }

class CupertinoChangePasswordScreen extends StatefulWidget {
  final ApiService? apiService;

  const CupertinoChangePasswordScreen({super.key, this.apiService});

  @override
  State<CupertinoChangePasswordScreen> createState() =>
      _CupertinoChangePasswordScreenState();
}

class _CupertinoChangePasswordScreenState
    extends State<CupertinoChangePasswordScreen> {
  late final ApiService _apiService;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _logoutOtherDevices = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  PasswordStrength _strength = PasswordStrength.none;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    _newPasswordController.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    _newPasswordController.removeListener(_updatePasswordStrength);
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    final password = _newPasswordController.text;
    if (password.isEmpty) {
      setState(() => _strength = PasswordStrength.none);
      return;
    }

    int score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 10) score++;
    if (RegExp(r'[A-Z]').hasMatch(password) && RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

    PasswordStrength strength;
    if (score <= 2) {
      strength = PasswordStrength.weak;
    } else if (score <= 4) {
      strength = PasswordStrength.medium;
    } else {
      strength = PasswordStrength.strong;
    }

    setState(() => _strength = strength);
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final current = _currentPasswordController.text;
    final newPass = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (current.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập mật khẩu hiện tại.');
      return;
    }

    if (newPass.length < 8) {
      setState(() => _errorMessage = 'Mật khẩu mới phải có ít nhất 8 ký tự.');
      return;
    }

    if (newPass != confirm) {
      setState(() => _errorMessage = 'Mật khẩu xác nhận không khớp.');
      return;
    }

    if (newPass == current) {
      setState(() => _errorMessage = 'Mật khẩu mới không được trùng mật khẩu cũ.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final success = await _apiService.changePassword(
        current,
        newPass,
        logoutOtherDevices: _logoutOtherDevices,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (success) {
        showCupertinoDialog<void>(
          context: context,
          builder: (dialogContext) => CupertinoAlertDialog(
            title: const Text('Thành công'),
            content: const Text('Mật khẩu của bạn đã được thay đổi thành công.'),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        setState(() => _errorMessage = 'Đổi mật khẩu thất bại. Vui lòng kiểm tra lại mật khẩu hiện tại.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fieldDecoration = BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFEAE2D5)),
    );
    const labelStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.primaryText,
    );
    const placeholderStyle = TextStyle(color: AppColors.mutedSage);

    return CupertinoTheme(
      data: CupertinoTheme.of(context).copyWith(
        primaryColor: AppColors.forestGreen,
        scaffoldBackgroundColor: AppColors.background,
      ),
      child: CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppColors.background,
        border: null,
        middle: Text(
          'Đổi mật khẩu',
          style: AppText.heading(context, fontSize: 20).copyWith(
            color: AppColors.primaryText,
          ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemRed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.exclamationmark_circle,
                        color: CupertinoColors.systemRed, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: CupertinoColors.systemRed,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            const Text(
              'Mật khẩu hiện tại',
              style: labelStyle,
            ),
            const SizedBox(height: 6),
            CupertinoTextField(
              controller: _currentPasswordController,
              obscureText: _obscureCurrent,
              placeholder: 'Nhập mật khẩu hiện tại',
              placeholderStyle: placeholderStyle,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: fieldDecoration,
              suffix: CupertinoButton(
                padding: const EdgeInsets.only(right: 12),
                onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent), minimumSize: Size(0, 0),
                child: Icon(
                  _obscureCurrent ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                  size: 20,
                  color: AppColors.mutedSage,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Mật khẩu mới',
              style: labelStyle,
            ),
            const SizedBox(height: 6),
            CupertinoTextField(
              controller: _newPasswordController,
              obscureText: _obscureNew,
              placeholder: 'Tối thiểu 8 ký tự',
              placeholderStyle: placeholderStyle,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: fieldDecoration,
              suffix: CupertinoButton(
                padding: const EdgeInsets.only(right: 12),
                onPressed: () => setState(() => _obscureNew = !_obscureNew), minimumSize: Size(0, 0),
                child: Icon(
                  _obscureNew ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                  size: 20,
                  color: AppColors.mutedSage,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildStrengthMeter(),
            const SizedBox(height: 20),
            const Text(
              'Xác nhận mật khẩu mới',
              style: labelStyle,
            ),
            const SizedBox(height: 6),
            CupertinoTextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              placeholder: 'Nhập lại mật khẩu mới',
              placeholderStyle: placeholderStyle,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: fieldDecoration,
              suffix: CupertinoButton(
                padding: const EdgeInsets.only(right: 12),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm), minimumSize: Size(0, 0),
                child: Icon(
                  _obscureConfirm ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                  size: 20,
                  color: AppColors.mutedSage,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFEAE2D5)),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đăng xuất các thiết bị khác',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Hủy phiên đăng nhập trên các máy khác để bảo mật',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mutedSage,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CupertinoSwitch(
                    value: _logoutOtherDevices,
                    activeTrackColor: AppColors.forestGreen,
                    onChanged: (val) => setState(() => _logoutOtherDevices = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: CupertinoButton(
                color: const Color(0x00000000),
                disabledColor: const Color(0x00000000),
                borderRadius: BorderRadius.circular(20),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                    : const Text(
                        'Xác nhận đổi mật khẩu',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildStrengthMeter() {
    if (_strength == PasswordStrength.none) return const SizedBox.shrink();

    Color color;
    String label;
    double progress;

    switch (_strength) {
      case PasswordStrength.weak:
        color = CupertinoColors.systemRed;
        label = 'Yếu (Thêm chữ hoa, số hoặc ký tự đặc biệt)';
        progress = 0.33;
        break;
      case PasswordStrength.medium:
        color = CupertinoColors.systemOrange;
        label = 'Trung bình';
        progress = 0.66;
        break;
      case PasswordStrength.strong:
        color = CupertinoColors.systemGreen;
        label = 'Mạnh';
        progress = 1.0;
        break;
      case PasswordStrength.none:
        color = CupertinoColors.systemGrey;
        label = '';
        progress = 0.0;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  height: 6,
                  color: CupertinoColors.systemGrey5.resolveFrom(context),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(color: color),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Độ mạnh mật khẩu: $label',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
