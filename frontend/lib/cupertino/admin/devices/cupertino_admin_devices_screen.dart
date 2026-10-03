// ============================================================
// cupertino_admin_devices_screen.dart
// Màn hình Quản lý thiết bị của Admin.
// Chức năng:
//   - Hiển thị danh sách toàn bộ devices trong hệ thống
//   - Search theo tên device hoặc email owner
//   - Filter: All / Online / Offline / Pumping
//   - Tap vào device → mở chi tiết
//   - Long-press → action sheet (gán user, thu hồi, xóa)
// ============================================================

import 'package:flutter/cupertino.dart';
import '../widgets/admin_logout_button.dart';

import '../../../services/mock_admin_service.dart';
import 'cupertino_admin_device_detail.dart';
import 'widgets/admin_device_card.dart';
import 'widgets/device_filter_chips.dart';

class CupertinoAdminDevicesScreen extends StatefulWidget {
  const CupertinoAdminDevicesScreen({super.key});

  @override
  State<CupertinoAdminDevicesScreen> createState() =>
      _CupertinoAdminDevicesScreenState();
}

class _CupertinoAdminDevicesScreenState
    extends State<CupertinoAdminDevicesScreen> {
  final _mockService = MockAdminService();
  final _searchController = TextEditingController();

  // _allDevices: dữ liệu gốc
  // _filteredDevices: sau khi áp filter + search
  List<Map<String, dynamic>> _allDevices = [];
  List<Map<String, dynamic>> _filteredDevices = [];

  DeviceFilter _selectedFilter = DeviceFilter.all;
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load devices từ mock service
  Future<void> _loadDevices() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));

    _allDevices = _mockService.getMockDevices();

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _applyFilter();
    });
  }

  // Áp filter + search
  void _applyFilter() {
    List<Map<String, dynamic>> result = List.from(_allDevices);

    // Filter theo tab
    switch (_selectedFilter) {
      case DeviceFilter.all:
        break;
      case DeviceFilter.online:
        result = result.where((d) => d['isOnline'] == true).toList();
        break;
      case DeviceFilter.offline:
        result = result.where((d) => d['isOnline'] != true).toList();
        break;
      case DeviceFilter.pumping:
        result = result.where((d) => d['isPumping'] == true).toList();
        break;
    }

    // Filter theo search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((d) {
        final name = (d['name'] as String? ?? '').toLowerCase();
        final owner = (d['ownerEmail'] as String? ?? '').toLowerCase();
        final id = (d['id'] as String? ?? '').toLowerCase();
        return name.contains(query) ||
            owner.contains(query) ||
            id.contains(query);
      }).toList();
    }

    setState(() => _filteredDevices = result);
  }

  // Đếm số device cho mỗi filter chip
  Map<DeviceFilter, int> _getCounts() {
    return {
      DeviceFilter.all: _allDevices.length,
      DeviceFilter.online:
      _allDevices.where((d) => d['isOnline'] == true).length,
      DeviceFilter.offline:
      _allDevices.where((d) => d['isOnline'] != true).length,
      DeviceFilter.pumping:
      _allDevices.where((d) => d['isPumping'] == true).length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Navigation bar
        CupertinoSliverNavigationBar(
          largeTitle: const Text('Thiết bị'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size(44, 44),
                onPressed: _loadDevices,
                child: const Icon(CupertinoIcons.arrow_2_circlepath),
              ),
              const AdminLogoutButton(),
            ],
          ),
        ),

        // Pull to refresh
        CupertinoSliverRefreshControl(onRefresh: _loadDevices),

        // Search bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: CupertinoSearchTextField(
              controller: _searchController,
              placeholder: 'Tìm theo tên hoặc owner...',
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
            child: DeviceFilterChips(
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
        else if (_filteredDevices.isEmpty)
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
                  final device = _filteredDevices[index];

                  // 🐛 FIX BUG: ValueKey dựa trên status + pumping
                  // → Khi device đổi trạng thái, key thay đổi, widget rebuild
                  final key = ValueKey(
                    'device_${device['id']}_'
                        '${device['isOnline']}_'
                        '${device['isPumping']}',
                  );

                  return Padding(
                    key: key,
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AdminDeviceCard(
                      device: device,
                      onTap: () => _openDeviceDetail(device),
                      onLongPress: () => _showDeviceActions(device),
                    ),
                  );
                },
                childCount: _filteredDevices.length,
              ),
            ),
          ),
      ],
    );
  }

  // Empty state
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.device_phone_portrait,
              size: 64,
              color: CupertinoColors.tertiaryLabel.resolveFrom(context),
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy thiết bị',
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
                  : 'Chưa có thiết bị nào trong hệ thống.',
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

  // Mở màn hình chi tiết device
  Future<void> _openDeviceDetail(Map<String, dynamic> device) async {
    await Navigator.of(context).push<void>(
      CupertinoPageRoute(
        builder: (_) => CupertinoAdminDeviceDetailScreen(device: device),
      ),
    );
  }

  // Action sheet khi long-press device
  Future<void> _showDeviceActions(Map<String, dynamic> device) async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (actionContext) => CupertinoActionSheet(
        title: Text(device['name'] ?? ''),
        message: Text(device['ownerEmail'] ?? 'Chưa gán'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(actionContext).pop();
              _openDeviceDetail(device);
            },
            child: const Text('Xem chi tiết'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(actionContext).pop();
              _assignDevice(device);
            },
            child: Text(
              device['ownerId'] == null || device['ownerId'] == ''
                  ? 'Gán cho user'
                  : 'Đổi owner',
            ),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(actionContext).pop();
              _confirmDelete(device);
            },
            child: const Text('Xóa thiết bị'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(actionContext).pop(),
          child: const Text('Hủy'),
        ),
      ),
    );
  }

  // Gán device cho user (mock)
  void _assignDevice(Map<String, dynamic> device) {
    final users = _mockService.getMockUsers();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (actionContext) => CupertinoActionSheet(
        title: const Text('Chọn user để gán'),
        actions: users.take(5).map((user) {
          return CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(actionContext).pop();
              setState(() {
                device['ownerId'] = user.id;
                device['ownerEmail'] = user.email;
              });
              _applyFilter();
              _showToast('Đã gán cho ${user.email}');
            },
            child: Text(user.email),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(actionContext).pop(),
          child: const Text('Hủy'),
        ),
      ),
    );
  }

  // Xác nhận xóa device
  void _confirmDelete(Map<String, dynamic> device) {
    showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Xóa thiết bị'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Bạn có chắc muốn xóa "${device['name']}"?\n'
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
                _allDevices.removeWhere((d) => d['id'] == device['id']);
              });
              _applyFilter();
              _showToast('Đã xóa thiết bị');
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  // Toast thông báo
  void _showToast(String message) {
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