// ============================================================
// admin_logout_button.dart
// Nút Logout dùng chung cho tất cả các tab Admin.
// Hiển thị icon + xác nhận trước khi đăng xuất.
// ============================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/auth_controller.dart';

class AdminLogoutButton extends ConsumerWidget {
  const AdminLogoutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(44, 44),
      onPressed: () => _confirmLogout(context, ref),
      child: const Icon(CupertinoIcons.square_arrow_right),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Đăng xuất'),
        content: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text('Bạn có chắc muốn đăng xuất khỏi Admin Panel?'),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await ref.read(authControllerProvider.notifier).logout();
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}