// ============================================================
// cupertino_reports_screen.dart
// Màn hình Báo cáo & Thống kê.
// Chức năng:
//   - Stats cards (Users, Devices, Alerts, Tickets)
//   - Biểu đồ đơn giản (bar chart)
//   - Export (PDF/CSV)
// ============================================================

import 'package:flutter/cupertino.dart';

import '../../../services/mock_admin_service.dart';
import '../../theme/cupertino_theme.dart';

class CupertinoReportsScreen extends StatefulWidget {
  const CupertinoReportsScreen({super.key});

  @override
  State<CupertinoReportsScreen> createState() =>
      _CupertinoReportsScreenState();
}

class _CupertinoReportsScreenState extends State<CupertinoReportsScreen> {
  final _mockService = MockAdminService();
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      _stats = _mockService.getMockReportStats();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        CupertinoSliverNavigationBar(
          largeTitle: const Text('Báo cáo'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: const Size(44, 44),
            onPressed: _showExportOptions,
            child: const Icon(CupertinoIcons.share),
          ),
        ),
        CupertinoSliverRefreshControl(onRefresh: _loadData),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CupertinoActivityIndicator(radius: 14)),
                )
              else if (_stats != null) ...[
                _buildStatCard(
                  context,
                  icon: CupertinoIcons.person_2_fill,
                  color: CupertinoColors.systemBlue,
                  title: 'Người dùng',
                  stats: _stats!['users'] as Map<String, dynamic>,
                  metrics: [
                    {'label': 'Tổng', 'value': 'total'},
                    {'label': 'Mới tháng này', 'value': 'newThisMonth'},
                    {'label': 'Hoạt động', 'value': 'active'},
                    {'label': 'Đã khóa', 'value': 'locked'},
                  ],
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  context,
                  icon: CupertinoIcons.device_phone_portrait,
                  color: AerogreenCupertinoTheme.aerogreenPrimary,
                  title: 'Thiết bị',
                  stats: _stats!['devices'] as Map<String, dynamic>,
                  metrics: [
                    {'label': 'Tổng', 'value': 'total'},
                    {'label': 'Online', 'value': 'online'},
                    {'label': 'Offline', 'value': 'offline'},
                    {'label': 'Mới tháng này', 'value': 'newThisMonth'},
                  ],
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  context,
                  icon: CupertinoIcons.exclamationmark_triangle_fill,
                  color: CupertinoColors.systemOrange,
                  title: 'Cảnh báo',
                  stats: _stats!['alerts'] as Map<String, dynamic>,
                  metrics: [
                    {'label': 'Tổng', 'value': 'total'},
                    {'label': 'Nghiêm trọng', 'value': 'critical'},
                    {'label': 'Cảnh báo', 'value': 'warning'},
                    {'label': 'Đã xử lý', 'value': 'resolved'},
                  ],
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  context,
                  icon: CupertinoIcons.chat_bubble_2_fill,
                  color: CupertinoColors.systemPurple,
                  title: 'Tickets',
                  stats: _stats!['tickets'] as Map<String, dynamic>,
                  metrics: [
                    {'label': 'Tổng', 'value': 'total'},
                    {'label': 'Mới', 'value': 'open'},
                    {'label': 'Đang xử lý', 'value': 'inProgress'},
                    {'label': 'Đã đóng', 'value': 'closed'},
                  ],
                ),
                const SizedBox(height: 24),
                _buildExportCard(context),
              ],
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      BuildContext context, {
        required IconData icon,
        required Color color,
        required String title,
        required Map<String, dynamic> stats,
        required List<Map<String, String>> metrics,
      }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: CupertinoColors.label.resolveFrom(context),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: metrics.map((m) {
              final value = stats[m['value']] ?? 0;
              return Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$value',
                      style: TextStyle(
                        color: color,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      m['label'] ?? '',
                      style: TextStyle(
                        color: CupertinoColors.secondaryLabel
                            .resolveFrom(context),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExportCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AerogreenCupertinoTheme.aerogreenPrimary
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.doc_text_fill,
                color: AerogreenCupertinoTheme.aerogreenPrimary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'Xuất báo cáo',
                style: TextStyle(
                  color: CupertinoColors.label.resolveFrom(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Xuất dữ liệu thống kê ra file để lưu trữ hoặc chia sẻ.',
            style: TextStyle(
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildExportButton(
                  context,
                  icon: CupertinoIcons.doc_fill,
                  label: 'PDF',
                  color: CupertinoColors.systemRed,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildExportButton(
                  context,
                  icon: CupertinoIcons.table,
                  label: 'CSV',
                  color: CupertinoColors.systemGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
      }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(double.infinity, 44),
      onPressed: () => _exportReport(label),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: CupertinoColors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExportOptions() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (actionContext) => CupertinoActionSheet(
        title: const Text('Xuất báo cáo'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(actionContext).pop();
              _exportReport('PDF');
            },
            child: const Text('Xuất PDF'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(actionContext).pop();
              _exportReport('CSV');
            },
            child: const Text('Xuất CSV'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(actionContext).pop(),
          child: const Text('Hủy'),
        ),
      ),
    );
  }

  void _exportReport(String format) {
    showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text('Xuất $format'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text('Đang xuất báo cáo $format...\nVui lòng chờ.'),
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