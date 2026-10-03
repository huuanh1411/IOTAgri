import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../models/device.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_indicators.dart';
import '../../widgets/custom_buttons.dart';
import '../../cupertino/devices/cupertino_device_detail_screen.dart';
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
      appBar: AppBar(title: const Text('Quản Lý Thiết Bị')),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDevice,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingState(message: 'Đang tải thiết bị...');
    }

    if (_errorMessage != null) {
      return ErrorState(message: _errorMessage!, onRetry: _loadDevices);
    }

    if (_devices.isEmpty) {
      return EmptyState(
        icon: Icons.devices_other,
        title: 'Chưa có thiết bị nào',
        subtitle: 'Nhấn nút + để thêm thiết bị mới',
      );
    }

    final filteredDevices = _devices.where((device) {
      return device.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
    final hasSearch = _devices.length > 6;
    final hasNoResults = hasSearch && filteredDevices.isEmpty;

    return RefreshIndicator(
      onRefresh: _loadDevices,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount:
            (hasSearch ? 1 : 0) + (hasNoResults ? 1 : filteredDevices.length),
        itemBuilder: (context, index) {
          if (hasSearch && index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: CupertinoSearchTextField(
                placeholder: 'Tìm thiết bị',
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            );
          }
          final deviceIndex = index - (hasSearch ? 1 : 0);
          if (hasNoResults) {
            return const Padding(
              padding: EdgeInsets.only(top: 32),
              child: Center(child: Text('Không tìm thấy thiết bị.')),
            );
          }
          final device = filteredDevices[deviceIndex];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
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
                      children: [
                        Icon(
                          device.isOnline ? Icons.wifi : Icons.wifi_off,
                          color: device.isOnline ? Colors.green : Colors.red,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                device.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _DeviceStatusChip(isOnline: device.isOnline),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Vị trí chưa gán',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              if (device.lastSeenAt != null)
                                Text(
                                  'Lần hoạt động: ${_formatDate(device.lastSeenAt!)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomElevatedButton(
                          text: 'Chi tiết',
                          icon: Icons.visibility,
                          onPressed: () {
                            _openDevice(device);
                          },
                          isFullWidth: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
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
        },
      ),
    );
  }

  Future<void> _openDevice(Device device) async {
    await Navigator.of(context).push<void>(
      CupertinoPageRoute<void>(
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
      title: const Text('Thêm Thiết Bị Mới'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Tên thiết bị',
            hintText: 'Nhập tên thiết bị',
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
          child: const Text('Hủy'),
        ),
        ElevatedButton(
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
    return Container(
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
