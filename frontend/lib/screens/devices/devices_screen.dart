import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/animation/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/section_chip.dart';
import '../../cupertino/devices/cupertino_device_detail_screen.dart';
import '../../models/device.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_buttons.dart';
import '../../widgets/loading_indicators.dart';
import 'provisioning_code_screen.dart';

class DevicesScreen extends StatefulWidget {
  final ApiService? apiService;

  const DevicesScreen({super.key, this.apiService});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  late final ApiService _apiService;
  List<Device> _devices = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final devicesData = await _apiService.getDevices();
      setState(() {
        _devices = devicesData.map((data) => Device.fromJson(data)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addDevice() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const AddDeviceDialog(),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await _apiService.createDevice(result);
        await _loadDevices();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thêm thiết bị thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.forestGreen,
          onRefresh: _loadDevices,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            children: [
              const PageHeader(
                chip: SectionChip(label: 'Thiết bị'),
                title: 'Thiết bị',
                subtitle: 'Theo dõi trạng thái và truy cập nhanh cài đặt.',
              ),
              const SizedBox(height: 18),
              _buildBody(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.forestGreen,
        foregroundColor: Colors.white,
        onPressed: _addDevice,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 48),
        child: LoadingState(message: 'Đang tải thiết bị...'),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: ErrorState(message: _errorMessage!, onRetry: _loadDevices),
      );
    }

    if (_devices.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: EmptyState(
          icon: Icons.devices_other,
          title: 'Chưa có thiết bị nào',
          subtitle: 'Nhấn nút + để thêm thiết bị mới',
        ),
      );
    }

    final filteredDevices = _devices.where((device) {
      return device.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
    final hasSearch = _devices.length > 6;
    final hasNoResults = hasSearch && filteredDevices.isEmpty;

    return Column(
      children: [
        if (hasSearch)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: CupertinoSearchTextField(
              placeholder: 'Tìm thiết bị',
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
        if (hasNoResults)
          const Padding(
            padding: EdgeInsets.only(top: 32),
            child: Center(child: Text('Không tìm thấy thiết bị.')),
          )
        else
          ...filteredDevices.map(_buildDeviceCard),
      ],
    );
  }

  Widget _buildDeviceCard(Device device) {
    final iconColor = device.isOnline ? AppColors.mint : AppColors.alertRed;
    final location = (device.location == null || device.location!.isEmpty)
        ? 'Vị trí chưa gán'
        : device.location!;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                _openDevice(device);
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      device.isOnline ? Icons.wifi : Icons.wifi_off,
                      color: iconColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.name,
                          style: AppText.heading(context, fontSize: 18),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _DeviceStatusChip(isOnline: device.isOnline),
                            Text(
                              location,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                        if (device.lastSeenAt != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Lần hoạt động: ${_formatDate(device.lastSeenAt!)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: AppColors.secondaryText),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: 180,
                  child: CustomElevatedButton(
                    text: 'Chi tiết',
                    icon: Icons.visibility,
                    onPressed: () {
                      _openDevice(device);
                    },
                    isFullWidth: true,
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: CustomOutlinedButton(
                    text: 'Mã thiết lập',
                    icon: Icons.qr_code_2,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProvisioningCodeScreen(device: device),
                        ),
                      );
                    },
                    isFullWidth: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDevice(Device device) async {
    await Navigator.of(context).push<void>(
      AppMotion.detailRoute<void>(
        context: context,
        builder: (_) => CupertinoDeviceDetailScreen(device: device),
      ),
    );
    if (mounted) _loadDevices();
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}

class AddDeviceDialog extends StatefulWidget {
  const AddDeviceDialog({super.key});

  @override
  State<AddDeviceDialog> createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends State<AddDeviceDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        'Thêm Thiết Bị Mới',
        style: AppText.heading(context, fontSize: 18),
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'Tên thiết bị',
            hintText: 'Nhập tên thiết bị',
            filled: true,
            fillColor: AppColors.rowBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.forestGreen),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập tên thiết bị';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: AppColors.secondaryText),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.forestGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _controller.text.trim());
            }
          },
          child: const Text('Thêm'),
        ),
      ],
    );
  }
}

class _DeviceStatusChip extends StatelessWidget {
  final bool isOnline;

  const _DeviceStatusChip({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    final color = isOnline ? Colors.green : Colors.grey;
    return AnimatedContainer(
      duration: AppMotion.duration(context, AppMotion.status),
      curve: AppMotion.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isOnline ? 'Online' : 'Offline',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
