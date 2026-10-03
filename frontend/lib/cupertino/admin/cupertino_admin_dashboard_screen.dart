// ============================================================
// cupertino_admin_dashboard_screen.dart
// Màn hình chính của Admin Panel.
// Chịu trách nhiệm:
//   - Layout responsive (mobile bottom bar / desktop sidebar)
//   - Điều hướng giữa các tab (Tổng quan, Người dùng, Thiết bị, Khác)
//   - Xử lý đăng xuất
// ============================================================

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../theme/cupertino_theme.dart';
import 'dashboard/admin_overview_tab.dart';
import 'users/cupertino_users_screen.dart';
import 'devices/cupertino_admin_devices_screen.dart';
import 'tickets/cupertino_tickets_screen.dart';

// ==================== MAIN WIDGET ====================
class CupertinoAdminDashboardScreen extends StatefulWidget {
  const CupertinoAdminDashboardScreen({super.key});

  @override
  State<CupertinoAdminDashboardScreen> createState() =>
      _CupertinoAdminDashboardScreenState();
}

class _CupertinoAdminDashboardScreenState
    extends State<CupertinoAdminDashboardScreen> {
  // Tab hiện tại: 0 = Tổng quan, 1 = Người dùng, 2 = Thiết bị, 3 = Khác
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Nếu màn hình >= 1024px → dùng sidebar (desktop/tablet)
            final isDesktop = constraints.maxWidth >= 1024;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sidebar chỉ hiển thị trên desktop
                if (isDesktop) _buildSidebar(context),
                // Nội dung chính (mobile + desktop)
                Expanded(child: _buildContent(context, isDesktop)),
              ],
            );
          },
        ),
      ),
    );
  }

  // ==================== CONTENT BUILDER ====================
  // Quyết định hiển thị widget nào dựa trên tab hiện tại.
  Widget _buildContent(BuildContext context, bool isDesktop) {
    // Tab "Tổng quan" (index 0) → AdminOverviewTab
    if (_selectedTab == 0) {
      return _wrapWithBottomBar(
        context,
        isDesktop,
        const AdminOverviewTab(),
      );
    }

    // Tab "Người dùng" (index 1) → CupertinoUsersScreen
    if (_selectedTab == 1) {
      return _wrapWithBottomBar(
        context,
        isDesktop,
        const CupertinoUsersScreen(),
      );
    }

    // Tab "Thiết bị" (index 2) → CupertinoAdminDevicesScreen
    if (_selectedTab == 2) {
      return _wrapWithBottomBar(
        context,
        isDesktop,
        const CupertinoAdminDevicesScreen(),
      );
    }

    // Các tab khác (3)
    if (_selectedTab == 3) {
      return _wrapWithBottomBar(
        context,
        isDesktop,
        const CupertinoTicketsScreen(),
      );
    }
    // Fallback
    final content = CustomScrollView(

      physics: const BouncingScrollPhysics(),
      slivers: [
        // Navigation bar với large title (tên tab hiện tại)
        CupertinoSliverNavigationBar(
          largeTitle: Text(_getTabTitle(_selectedTab)),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 44,
            onPressed: () => _confirmLogout(context),
            child: const Icon(CupertinoIcons.square_arrow_right),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            isDesktop ? 32 : 20,
            16,
            isDesktop ? 32 : 20,
            32,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildPlaceholderCard(
                context,
                icon: CupertinoIcons.hammer_fill,
                title: 'Đang phát triển',
                subtitle: 'Tính năng này sẽ được cập nhật sớm.',
                color: CupertinoColors.systemGrey,
              ),
            ]),
          ),
        ),
      ],
    );

    return _wrapWithBottomBar(context, isDesktop, content);
  }

  // ==================== HELPER: TAB TITLE ====================
  // Trả về tên hiển thị của từng tab.
  String _getTabTitle(int tab) {
    switch (tab) {
      case 0:
        return 'Tổng quan';
      case 1:
        return 'Người dùng';
      case 2:
        return 'Thiết bị';
      case 3:
        return 'Khác';
      default:
        return 'Admin';
    }
  }

  // ==================== HELPER: WRAP WITH BOTTOM BAR ====================
  // Trên mobile: bọc content + bottom bar.
  // Trên desktop: trả về content (vì đã có sidebar).
  Widget _wrapWithBottomBar(
      BuildContext context,
      bool isDesktop,
      Widget content,
      ) {
    if (isDesktop) return content;
    return Column(
      children: [
        Expanded(child: content),
        _buildBottomBar(context),
      ],
    );
  }

  // ==================== PLACEHOLDER CARD ====================
  // Card hiển thị cho các tab chưa hoàn thiện.
  // Sẽ được thay thế bằng UI thật ở các Bước 7.2, 7.3, 7.4...
  Widget _buildPlaceholderCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required Color color,
      }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // Icon trong khung màu
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: CupertinoColors.label.resolveFrom(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Chevron chỉ hướng
          Icon(
            CupertinoIcons.chevron_right,
            color: CupertinoColors.tertiaryLabel.resolveFrom(context),
            size: 18,
          ),
        ],
      ),
    );
  }

  // ==================== SIDEBAR (DESKTOP) ====================
  // Sidebar bên trái, hiển thị:
  //   - Logo + tên "Admin Panel"
  //   - Danh sách tabs (Tổng quan, Người dùng, Thiết bị, Tickets)
  //   - Thông tin admin đang đăng nhập + nút Đăng xuất
  Widget _buildSidebar(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Container(
      width: 248,
      padding: const EdgeInsets.fromLTRB(20, 28, 16, 20),
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemBackground.resolveFrom(context),
        border: Border(
          right: BorderSide(
            color: CupertinoColors.separator.resolveFrom(context),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon + tên panel
          Row(
            children: [
              const Icon(
                CupertinoIcons.shield_lefthalf_fill,
                color: AerogreenCupertinoTheme.aerogreenPrimary,
              ),
              const SizedBox(width: 10),
              Text(
                'Admin Panel',
                style: TextStyle(
                  color: CupertinoColors.label.resolveFrom(context),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 36),

          // ==================== SIDEBAR ITEMS ====================
          _SidebarItem(
            icon: CupertinoIcons.house_fill,
            label: 'Tổng quan',
            selected: _selectedTab == 0,
            onTap: () => setState(() => _selectedTab = 0),
          ),
          _SidebarItem(
            icon: CupertinoIcons.person_2_fill,
            label: 'Người dùng',
            selected: _selectedTab == 1,
            onTap: () => setState(() => _selectedTab = 1),
          ),
          _SidebarItem(
            icon: CupertinoIcons.device_phone_portrait,
            label: 'Thiết bị',
            selected: _selectedTab == 2,
            onTap: () => setState(() => _selectedTab = 2),
          ),
          _SidebarItem(
            icon: CupertinoIcons.chat_bubble_2_fill,
            label: 'Tickets',
            selected: _selectedTab == 3,
            onTap: () => setState(() => _selectedTab = 3),
          ),

          // Đẩy phần dưới xuống cuối sidebar
          const Spacer(),

          // ==================== USER INFO ====================
          Text(
            'ĐĂNG NHẬP VỚI',
            style: TextStyle(
              color: CupertinoColors.tertiaryLabel.resolveFrom(context),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            user?.email ?? '',
            style: TextStyle(
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),

          // Nút Đăng xuất
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            onPressed: () => _confirmLogout(context),
            child: Row(
              children: const [
                Icon(
                  CupertinoIcons.square_arrow_right,
                  size: 17,
                  color: CupertinoColors.systemRed,
                ),
                SizedBox(width: 8),
                Text(
                  'Đăng xuất',
                  style: TextStyle(color: CupertinoColors.systemRed),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== BOTTOM BAR (MOBILE) ====================
  // Thanh điều hướng dưới cùng của màn hình mobile, chứa 4 tab.
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground
            .resolveFrom(context)
            .withValues(alpha: 0.94),
        border: Border(
          top: BorderSide(
            color: CupertinoColors.separator.resolveFrom(context),
          ),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 8, top: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomItem(
            icon: CupertinoIcons.house_fill,
            label: 'Tổng quan',
            selected: _selectedTab == 0,
            onTap: () => setState(() => _selectedTab = 0),
          ),
          _BottomItem(
            icon: CupertinoIcons.person_2_fill,
            label: 'Users',
            selected: _selectedTab == 1,
            onTap: () => setState(() => _selectedTab = 1),
          ),
          _BottomItem(
            icon: CupertinoIcons.device_phone_portrait,
            label: 'Thiết bị',
            selected: _selectedTab == 2,
            onTap: () => setState(() => _selectedTab = 2),
          ),
          _BottomItem(
            icon: CupertinoIcons.ellipsis_circle_fill,
            label: 'Khác',
            selected: _selectedTab == 3,
            onTap: () => setState(() => _selectedTab = 3),
          ),
        ],
      ),
    );
  }

  // ==================== LOGOUT CONFIRMATION ====================
  // Hiển thị dialog xác nhận trước khi đăng xuất.
  void _confirmLogout(BuildContext context) {
    showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Đăng xuất'),
        content: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text('Bạn có chắc muốn đăng xuất khỏi Admin Panel?'),
        ),
        actions: [
          // Nút Hủy
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          // Nút Đăng xuất (màu đỏ)
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthProvider>().logout();
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}

// ==================== SIDEBAR ITEM WIDGET ====================
// Widget con cho mỗi mục trong sidebar (desktop).
class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => CupertinoButton(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    alignment: Alignment.centerLeft,
    onPressed: onTap,
    child: Row(
      children: [
        // Icon đổi màu theo trạng thái selected
        Icon(
          icon,
          size: 18,
          color: selected
              ? AerogreenCupertinoTheme.aerogreenPrimary
              : CupertinoColors.secondaryLabel.resolveFrom(context),
        ),
        const SizedBox(width: 12),
        // Label đổi màu + weight theo trạng thái selected
        Text(
          label,
          style: TextStyle(
            color: selected
                ? AerogreenCupertinoTheme.aerogreenPrimary
                : CupertinoColors.label.resolveFrom(context),
            fontSize: 14,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    ),
  );
}

// ==================== BOTTOM ITEM WIDGET ====================
// Widget con cho mỗi tab trong bottom bar (mobile).
class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BottomItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => CupertinoButton(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    minimumSize: const Size(44, 44), // Đảm bảo touch target >= 44px
    onPressed: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon ở trên
        Icon(
          icon,
          size: 21,
          color: selected
              ? AerogreenCupertinoTheme.aerogreenPrimary
              : CupertinoColors.secondaryLabel.resolveFrom(context),
        ),
        const SizedBox(height: 3),
        // Label ở dưới
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: selected
                ? AerogreenCupertinoTheme.aerogreenPrimary
                : CupertinoColors.secondaryLabel.resolveFrom(context),
          ),
        ),
      ],
    ),
  );
}