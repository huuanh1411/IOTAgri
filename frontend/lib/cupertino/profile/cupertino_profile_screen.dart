import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../theme/cupertino_theme.dart';

/// Hồ sơ người dùng: xem, cập nhật thông tin cá nhân và đăng xuất ở cuối màn hình.
class CupertinoProfileScreen extends StatefulWidget {
  const CupertinoProfileScreen({super.key});

  @override
  State<CupertinoProfileScreen> createState() => _CupertinoProfileScreenState();
}

class _CupertinoProfileScreenState extends State<CupertinoProfileScreen> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  bool _isSaving = false;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshProfile());
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _refreshProfile() async {
    if (!mounted) return;
    setState(() => _isRefreshing = true);

    final provider = context.read<AuthProvider>();
    final loaded = await provider.loadProfile();
    if (!mounted) return;

    if (loaded) {
      _fullNameController.text = provider.user?.fullName ?? '';
      _phoneController.text = provider.user?.phoneNumber ?? '';
    }
    setState(() => _isRefreshing = false);
  }

  Future<void> _save() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final fullName = _fullNameController.text.trim();
    if (fullName.isEmpty) {
      _showMessage('Họ và tên không được để trống.');
      return;
    }

    final phoneNumber = _phoneController.text.trim();
    setState(() => _isSaving = true);

    final provider = context.read<AuthProvider>();
    final saved = await provider.updateProfile(
      fullName: fullName,
      phoneNumber: phoneNumber.isEmpty ? null : phoneNumber,
    );
    if (!mounted) return;

    setState(() => _isSaving = false);
    if (saved) {
      _fullNameController.text = provider.user?.fullName ?? fullName;
      _phoneController.text = provider.user?.phoneNumber ?? '';
      _showMessage('Đã lưu thông tin tài khoản.');
    } else {
      _showMessage(
        provider.errorMessage ?? 'Cập nhật thất bại. Vui lòng thử lại.',
      );
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Đăng xuất'),
        content: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text('Bạn có chắc muốn đăng xuất khỏi tài khoản này?'),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Hủy'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await context.read<AuthProvider>().logout();
  }

  void _showMessage(String message) {
    showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        CupertinoSliverNavigationBar(
          largeTitle: const Text('Tài khoản'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: const Size(44, 44),
            onPressed: _isRefreshing ? null : _refreshProfile,
            child: const Icon(CupertinoIcons.arrow_2_circlepath),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildIdentityCard(context, user),
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'THÔNG TIN CÁ NHÂN'),
              const SizedBox(height: 10),
              _buildField(
                context,
                label: 'Họ và tên',
                controller: _fullNameController,
                placeholder: 'Nhập họ và tên',
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              _buildField(
                context,
                label: 'Số điện thoại',
                controller: _phoneController,
                placeholder: 'Chưa cập nhật',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildEmailRow(context, user?.email ?? ''),
              const SizedBox(height: 22),
              _buildSaveButton(context),
              const SizedBox(height: 36),
              _buildLogoutButton(context),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildIdentityCard(BuildContext context, User? user) {
    final fullName = (user?.fullName ?? '').trim();
    final isAdmin = user?.isAdmin ?? false;
    final initial = fullName.isEmpty
        ? '?'
        : fullName.substring(0, 1).toUpperCase();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AerogreenCupertinoTheme.aerogreenPrimary,
              shape: BoxShape.circle,
            ),
            child: Text(
              initial,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName.isEmpty ? 'Chưa cập nhật tên' : fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: CupertinoColors.label.resolveFrom(context),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (isAdmin
                                ? AerogreenCupertinoTheme.aerogreenTertiary
                                : AerogreenCupertinoTheme.aerogreenPrimary)
                            .withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isAdmin ? 'Quản trị viên' : 'Người dùng',
                    style: TextStyle(
                      color: isAdmin
                          ? AerogreenCupertinoTheme.aerogreenTertiary
                          : AerogreenCupertinoTheme.aerogreenPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) => Text(
    title,
    style: TextStyle(
      color: CupertinoColors.tertiaryLabel.resolveFrom(context),
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1,
    ),
  );

  Widget _buildField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required String placeholder,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: CupertinoColors.secondarySystemBackground.resolveFrom(
              context,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: CupertinoColors.separator.resolveFrom(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailRow(BuildContext context, String email) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: TextStyle(
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          decoration: BoxDecoration(
            color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                    fontSize: 15,
                  ),
                ),
              ),
              Icon(
                CupertinoIcons.lock_fill,
                size: 15,
                color: CupertinoColors.tertiaryLabel.resolveFrom(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Email dùng để đăng nhập nên không thể thay đổi tại đây.',
          style: TextStyle(
            color: CupertinoColors.tertiaryLabel.resolveFrom(context),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: _isSaving ? null : _save,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AerogreenCupertinoTheme.aerogreenPrimary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: _isSaving
            ? const CupertinoActivityIndicator(color: CupertinoColors.white)
            : const Text(
                'Lưu thay đổi',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Column(
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _confirmLogout,
          child: Container(
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: CupertinoColors.systemRed.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.square_arrow_right,
                  size: 18,
                  color: CupertinoColors.systemRed,
                ),
                SizedBox(width: 8),
                Text(
                  'Đăng xuất',
                  style: TextStyle(
                    color: CupertinoColors.systemRed,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Bạn sẽ cần đăng nhập lại để tiếp tục sử dụng.',
          style: TextStyle(
            color: CupertinoColors.tertiaryLabel.resolveFrom(context),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
