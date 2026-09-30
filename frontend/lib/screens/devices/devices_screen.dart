import 'package:flutter/material.dart';
import '../../models/device.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_indicators.dart';
import '../../widgets/custom_cards.dart';
import 'device_detail_screen.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  final ApiService _apiService = ApiService();
  List<Device> _devices = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
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
            SnackBar(
              content: Text('Lỗi: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Thiết Bị'),
      ),
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
      return ErrorState(
        message: _errorMessage!,
        onRetry: _loadDevices,
      );
    }

    if (_devices.isEmpty) {
      return EmptyState(
        icon: Icons.devices_other,
        title: 'Chưa có thiết bị nào',
        subtitle: 'Nhấn nút + để thêm thiết bị mới',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDevices,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _devices.length,
        itemBuilder: (context, index) {
          final device = _devices[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DeviceDetailScreen(device: device),
                ),
              );
            },
            child: StatusCard(
              title: device.name,
              status: device.isOnline ? 'Đang hoạt động' : 'Mất kết nối',
              subtitle: device.lastSeenAt != null 
                  ? 'Lần hoạt động: ${_formatDate(device.lastSeenAt!)}' 
                  : null,
              isActive: device.isOnline,
              statusIcon: device.isOnline ? Icons.wifi : Icons.wifi_off,
            ),
          );
        },
      ),
    );
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