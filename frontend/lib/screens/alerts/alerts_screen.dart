import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/device.dart';
import '../../models/device_alert.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_indicators.dart';
import '../../widgets/custom_cards.dart';

class AlertsScreen extends StatefulWidget {
  final Device device;

  const AlertsScreen({super.key, required this.device});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final ApiService _apiService = ApiService();
  List<DeviceAlert> _alerts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final alertsData = await _apiService.getAlerts(widget.device.id);
      final items = alertsData['items'] as List<dynamic>?;
      setState(() {
        _alerts = items?.map((data) => DeviceAlert.fromJson(data)).toList() ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  AlertSeverity _getSeverity(String type) {
    if (type == 'HighTemperature') {
      return AlertSeverity.warning;
    } else if (type == 'LowWaterLevel') {
      return AlertSeverity.critical;
    }
    return AlertSeverity.info;
  }

  String _getAlertTitle(String type) {
    switch (type) {
      case 'HighTemperature':
        return 'Nhiệt độ cao';
      case 'LowWaterLevel':
        return 'Mực nước thấp';
      default:
        return type;
    }
  }

  String _getAlertMessage(String type, dynamic measuredValue, dynamic threshold) {
    switch (type) {
      case 'HighTemperature':
        return 'Nhiệt độ vượt ngưỡng: $measuredValue°C (ngưỡng: $threshold°C)';
      case 'LowWaterLevel':
        return 'Mực nước thấp: $measuredValue% (ngưỡng: $threshold%)';
      default:
        return 'Giá trị: $measuredValue - Ngưỡng: $threshold';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cảnh báo - ${widget.device.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAlerts,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingState(message: 'Đang tải cảnh báo...');
    }

    if (_errorMessage != null) {
      return ErrorState(
        message: _errorMessage!,
        onRetry: _loadAlerts,
      );
    }

    if (_alerts.isEmpty) {
      return const EmptyState(
        icon: Icons.check_circle,
        title: 'Không có cảnh báo nào',
        subtitle: 'Tất cả thông số đang ở mức bình thường',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAlerts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _alerts.length,
        itemBuilder: (context, index) {
          final alert = _alerts[index];
          return AlertCard(
            title: _getAlertTitle(alert.type),
            message: _getAlertMessage(alert.type, alert.measuredValue, alert.threshold),
            timestamp: _formatDate(alert.triggeredAt),
            severity: _getSeverity(alert.type),
          );
        },
      ),
    );
  }
}