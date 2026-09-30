import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/device.dart';
import '../../models/sensor_reading.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_indicators.dart';

class SensorHistoryScreen extends StatefulWidget {
  final Device device;

  const SensorHistoryScreen({super.key, required this.device});

  @override
  State<SensorHistoryScreen> createState() => _SensorHistoryScreenState();
}

class _SensorHistoryScreenState extends State<SensorHistoryScreen> {
  final ApiService _apiService = ApiService();
  List<SensorReading> _readings = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedInterval = 'hour'; // hour, day, week

  @override
  void initState() {
    super.initState();
    _loadReadings();
  }

  Future<void> _loadReadings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final readingsData = await _apiService.getDeviceReadings(
        widget.device.id,
        limit: _getLimitForInterval(),
      );
      setState(() {
        _readings = readingsData.map((data) => SensorReading.fromJson(data)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  int _getLimitForInterval() {
    switch (_selectedInterval) {
      case 'hour':
        return 60; // 1 hour with 1-minute intervals
      case 'day':
        return 144; // 1 day with 10-minute intervals
      case 'week':
        return 168; // 1 week with 1-hour intervals
      default:
        return 60;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch sử cảm biến - ${widget.device.name}'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedInterval = value;
              });
              _loadReadings();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'hour',
                child: Text('1 giờ'),
              ),
              const PopupMenuItem(
                value: 'day',
                child: Text('1 ngày'),
              ),
              const PopupMenuItem(
                value: 'week',
                child: Text('1 tuần'),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingState(message: 'Đang tải dữ liệu lịch sử...');
    }

    if (_errorMessage != null) {
      return ErrorState(
        message: _errorMessage!,
        onRetry: _loadReadings,
      );
    }

    if (_readings.isEmpty) {
      return const EmptyState(
        icon: Icons.history,
        title: 'Chưa có dữ liệu lịch sử',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReadings,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIntervalSelector(),
            const SizedBox(height: 16),
            _buildTemperatureChart(),
            const SizedBox(height: 24),
            _buildHumidityChart(),
            const SizedBox(height: 24),
            _buildPhChart(),
            const SizedBox(height: 24),
            _buildWaterLevelChart(),
            const SizedBox(height: 24),
            _buildReadingsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildIntervalSelector() {
    return Row(
      children: [
        _buildIntervalChip('hour', '1 giờ'),
        const SizedBox(width: 8),
        _buildIntervalChip('day', '1 ngày'),
        const SizedBox(width: 8),
        _buildIntervalChip('week', '1 tuần'),
      ],
    );
  }

  Widget _buildIntervalChip(String value, String label) {
    final isSelected = _selectedInterval == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedInterval = value;
          });
          _loadReadings();
        }
      },
      selectedColor: Colors.green.withValues(alpha: 0.3),
      checkmarkColor: Colors.green,
    );
  }

  Widget _buildTemperatureChart() {
    final data = _readings
        .where((r) => r.temperature != null)
        .map((r) => r.temperature!)
        .toList();

    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nhiệt độ (°C)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(0),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: data.length > 10 ? (data.length / 5).ceil().toDouble() : 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= data.length) return const SizedBox.shrink();
                          return Text(
                            _formatDate(_readings[value.toInt()].recordedAt),
                            style: const TextStyle(fontSize: 8),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        data.length,
                        (index) => FlSpot(index.toDouble(), data[index]),
                      ),
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 2,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHumidityChart() {
    final data = _readings
        .where((r) => r.humidity != null)
        .map((r) => r.humidity!)
        .toList();

    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Độ ẩm (%)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(0),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: data.length > 10 ? (data.length / 5).ceil().toDouble() : 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= data.length) return const SizedBox.shrink();
                          return Text(
                            _formatDate(_readings[value.toInt()].recordedAt),
                            style: const TextStyle(fontSize: 8),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        data.length,
                        (index) => FlSpot(index.toDouble(), data[index]),
                      ),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 2,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhChart() {
    final data = _readings
        .where((r) => r.ph != null)
        .map((r) => r.ph!)
        .toList();

    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'pH',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: data.length > 10 ? (data.length / 5).ceil().toDouble() : 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= data.length) return const SizedBox.shrink();
                          return Text(
                            _formatDate(_readings[value.toInt()].recordedAt),
                            style: const TextStyle(fontSize: 8),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        data.length,
                        (index) => FlSpot(index.toDouble(), data[index]),
                      ),
                      isCurved: true,
                      color: Colors.purple,
                      barWidth: 2,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterLevelChart() {
    final data = _readings
        .where((r) => r.waterLevel != null)
        .map((r) => r.waterLevel!)
        .toList();

    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mực nước (%)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(0),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: data.length > 10 ? (data.length / 5).ceil().toDouble() : 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= data.length) return const SizedBox.shrink();
                          return Text(
                            _formatDate(_readings[value.toInt()].recordedAt),
                            style: const TextStyle(fontSize: 8),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        data.length,
                        (index) => FlSpot(index.toDouble(), data[index]),
                      ),
                      isCurved: true,
                      color: Colors.teal,
                      barWidth: 2,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingsList() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Danh sách chi tiết',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _readings.length,
            itemBuilder: (context, index) {
              final reading = _readings[index];
              return ListTile(
                title: Text(_formatDate(reading.recordedAt)),
                subtitle: Text(
                  'Nhiệt độ: ${reading.temperature?.toStringAsFixed(1) ?? 'N/A'}°C, '
                  'Độ ẩm: ${reading.humidity?.toStringAsFixed(1) ?? 'N/A'}%, '
                  'pH: ${reading.ph?.toStringAsFixed(1) ?? 'N/A'}, '
                  'Mực nước: ${reading.waterLevel?.toStringAsFixed(1) ?? 'N/A'}%',
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}