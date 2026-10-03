// ============================================================
// cupertino_users_screen.dart
// Màn hình Quản lý người dùng của Admin.
// Chức năng:
//   - Hiển thị danh sách users
//   - Search theo tên/email
//   - Filter theo trạng thái (All/Active/Locked/Admin)
//   - Tap vào user → mở chi tiết
//   - Long-press → action sheet (khóa/mở khóa, reset, xóa)
//
// Đồng bộ state:
//   - Khi mở Detail, truyền callback onUserUpdated
//   - Detail gọi callback khi user thay đổi → update _allUsers
//   - KHÔNG gọi _loadUsers() sau khi pop (tránh reset)
//
// 🐛 FIX BUG:
//   - Thêm ValueKey cho UserListTile dựa trên isLocked + index
//   - Khi isLocked thay đổi → key thay đổi → Flutter tự rebuild widget
// ============================================================

import 'package:flutter/cupertino.dart';
import '../widgets/admin_logout_button.dart';

import '../../../services/mock_admin_service.dart';
import 'cupertino_user_detail_screen.dart';
import 'widgets/user_filter_chips.dart';
import 'widgets/user_list_tile.dart';

class CupertinoUsersScreen extends StatefulWidget {
  const CupertinoUsersScreen({super.key});

  @override
  State<CupertinoUsersScreen> createState() => _CupertinoUsersScreenState();
}

class _CupertinoUsersScreenState extends State<CupertinoUsersScreen> {
  final _mockService = MockAdminService();
  final _searchController = TextEditingController();

  // _allUsers: dữ liệu gốc (không bị filter)
  // _filteredUsers: dữ liệu đã áp filter + search để hiển thị
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];

  UserFilter _selectedFilter = UserFilter.all;
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load danh sách users từ mock service
  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));

    final mockUsers = _mockService.getMockUsers();
    // Chuyển User model → Map để dễ xử lý state
    _allUsers = mockUsers.map((u) {
      final userId = u.id;
      // Đếm devices thuộc user này
      final deviceCount = _mockService
          .getMockDevices()
          .where((d) => d['ownerId'] == userId)
          .length;
      return {
        'id': u.id,
        'email': u.email,
        'fullName': u.fullName,
        'role': u.role,
        'isLocked': userId == 'u003' || userId == 'u007', // Mock: 2 user bị khóa
        'deviceCount': deviceCount,
        'joinedAt': DateTime.now()
            .subtract(Duration(days: int.parse(userId.substring(1))))
            .toIso8601String(),
      };
    }).toList();

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _applyFilter();
    });
  }

  // Áp dụng filter theo tab + search query
  void _applyFilter() {
    List<Map<String, dynamic>> result = List.from(_allUsers);

    // Filter theo tab
    switch (_selectedFilter) {
      case UserFilter.all:
        break;
      case UserFilter.active:
        result = result.where((u) => u['isLocked'] != true).toList();
        break;
      case UserFilter.locked:
        result = result.where((u) => u['isLocked'] == true).toList();
        break;
      case UserFilter.admin:
        result = result.where((u) => u['role'] == 'admin').toList();
        break;
    }

    // Filter theo search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((u) {
        final name = (u['fullName'] as String? ?? '').toLowerCase();
        final email = (u['email'] as String? ?? '').toLowerCase();
        return name.contains(query) || email.contains(query);
      }).toList();
    }

    setState(() => _filteredUsers = result);
  }

  // Đếm số user cho từng filter chip
  Map<UserFilter, int> _getCounts() {
    return {
      UserFilter.all: _allUsers.length,
      UserFilter.active:
      _allUsers.where((u) => u['isLocked'] != true).length,
      UserFilter.locked:
      _allUsers.where((u) => u['isLocked'] == true).length,
      UserFilter.admin:
      _allUsers.where((u) => u['role'] == 'admin').length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Navigation bar
        CupertinoSliverNavigationBar(
          largeTitle: const Text('Người dùng'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size(44, 44),
                onPressed: _loadUsers,
                child: const Icon(CupertinoIcons.arrow_2_circlepath),
              ),
              const AdminLogoutButton(),
            ],
          ),
        ),

        // Pull to refresh
        CupertinoSliverRefreshControl(onRefresh: _loadUsers),

        // Search bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: CupertinoSearchTextField(
              controller: _searchController,
              placeholder: 'Tìm theo tên hoặc email...',
              onChanged: (value) {
                _searchQuery = value;
                _applyFilter();
              },
            ),
          ),
        ),

        // Filter chips
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: UserFilterChips(
              selected: _selectedFilter,
              counts: _getCounts(),
              onChanged: (filter) {
                setState(() => _selectedFilter = filter);
                _applyFilter();
              },
            ),
          ),
        ),

        // Content: loading / empty / list
        if (_isLoading)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: CupertinoActivityIndicator(radius: 14),
            ),
          )
        else if (_filteredUsers.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _buildEmptyState(context),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final user = _filteredUsers[index];

                  // 🐛 FIX BUG: ValueKey dựa trên id + isLocked
                  // Khi isLocked thay đổi → key khác → Flutter rebuild
                  final isLocked = user['isLocked'] == true;
                  final key = ValueKey(
                    'user_${user['id']}_${isLocked ? 'locked' : 'active'}',
                  );

                  return Padding(
                    key: key,
                    padding: const EdgeInsets.only(bottom: 8),
                    child: UserListTile(
                      user: user,
                      onTap: () => _openUserDetail(user),
                      onLongPress: () => _showUserActions(user),
                    ),
                  );
                },
                childCount: _filteredUsers.length,
              ),
            ),
          ),
      ],
    );
  }

  // Empty state khi không có user nào
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.person_2,
              size: 64,
              color: CupertinoColors.tertiaryLabel.resolveFrom(context),
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy người dùng',
              style: TextStyle(
                color: CupertinoColors.label.resolveFrom(context),
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Thử tìm với từ khóa khác.'
                  : 'Chưa có người dùng nào trong hệ thống.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mở màn hình chi tiết user
  // Truyền callback onUserUpdated để nhận data mới khi user thay đổi
  Future<void> _openUserDetail(Map<String, dynamic> user) async {
    await Navigator.of(context).push<void>(
      CupertinoPageRoute(
        builder: (_) => CupertinoUserDetailScreen(
          user: user,
          // 🔥 Callback: nhận data mới từ Detail và update _allUsers
          onUserUpdated: (updatedUser) {
            final index =
            _allUsers.indexWhere((u) => u['id'] == updatedUser['id']);
            if (index != -1) {
              setState(() {
                // Replace user cũ bằng data mới (copy để tránh reference)
                _allUsers[index] = Map<String, dynamic>.from(updatedUser);
              });
              // Apply lại filter để UI refresh
              _applyFilter();
            }
          },
        ),
      ),
    );
    // KHÔNG gọi _loadUsers() ở đây — sẽ reset data về gốc
  }

  // Action sheet khi long-press user
  Future<void> _showUserActions(Map<String, dynamic> user) async {
    final isLocked = user['isLocked'] as bool? ?? false;

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (actionContext) => CupertinoActionSheet(
        title: Text(user['fullName'] ?? ''),
        message: Text(user['email'] ?? ''),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(actionContext).pop();
              _openUserDetail(user);
            },
            child: const Text('Xem chi tiết'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(actionContext).pop();
              _toggleLock(user);
            },
            child: Text(isLocked ? 'Mở khóa tài khoản' : 'Khóa tài khoản'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(actionContext).pop();
              _resetPassword(user);
            },
            child: const Text('Reset mật khẩu'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(actionContext).pop();
              _confirmDelete(user);
            },
            child: const Text('Xóa người dùng'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(actionContext).pop(),
          child: const Text('Hủy'),
        ),
      ),
    );
  }

  // Khóa / Mở khóa tài khoản (từ long-press action sheet)
  void _toggleLock(Map<String, dynamic> user) {
    final isLocked = user['isLocked'] as bool? ?? false;
    setState(() {
      user['isLocked'] = !isLocked;
    });
    _applyFilter();
    _showToast(
      !isLocked ? 'Đã khóa tài khoản' : 'Đã mở khóa tài khoản',
      color:
      !isLocked ? CupertinoColors.systemRed : CupertinoColors.systemGreen,
    );
  }

  // Reset mật khẩu (từ long-press action sheet)
  void _resetPassword(Map<String, dynamic> user) {
    showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Reset mật khẩu'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Gửi email reset mật khẩu cho:\n${user['email']}?',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _showToast(
                'Đã gửi email reset mật khẩu',
                color: CupertinoColors.systemBlue,
              );
            },
            child: const Text('Gửi'),
          ),
        ],
      ),
    );
  }

  // Xác nhận xóa user (từ long-press action sheet)
  void _confirmDelete(Map<String, dynamic> user) {
    showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Xóa người dùng'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Bạn có chắc muốn xóa "${user['fullName']}"?\n'
                'Hành động này không thể hoàn tác.',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(dialogContext).pop();
              setState(() {
                _allUsers.removeWhere((u) => u['id'] == user['id']);
              });
              _applyFilter();
              _showToast(
                'Đã xóa người dùng',
                color: CupertinoColors.systemRed,
              );
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  // Dialog thông báo đơn giản (toast-like)
  void _showToast(String message, {required Color color}) {
    showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(message),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}