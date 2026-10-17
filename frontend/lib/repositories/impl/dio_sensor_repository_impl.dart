import 'package:dio/dio.dart';

import '../../constants/api_constants.dart';
import '../../models/sensor_reading.dart';
import '../dio_client.dart';
import '../sensor_repository.dart';

class DioSensorRepositoryImpl implements SensorRepository {
  final DioClient client;

  DioSensorRepositoryImpl({DioClient? dioClient})
      : client = dioClient ?? DioClient();

  Dio get _dio => client.dio;

  @override
  Future<List<SensorReading>> getDeviceReadings(String deviceId, {int? limit}) async {
    final response = await _dio.get(
      ApiConstants.deviceReadings(deviceId),
      queryParameters: limit != null ? {'take': limit} : null,
    );
    final list = response.data as List<dynamic>;
    return list.map((item) => SensorReading.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getAggregatedReadings(
    String deviceId, {
    String range = '24h',
    String? interval,
  }) async {
    final now = DateTime.now().toUtc();
    final hours = switch (range) {
      '7d' => 24 * 7,
      '30d' => 24 * 30,
      _ => 24,
    };
    final response = await _dio.get(
      ApiConstants.deviceAggregatedReadings(deviceId),
      queryParameters: {
        'from': now.subtract(Duration(hours: hours)).toIso8601String(),
        'to': now.toIso8601String(),
        'interval': ?interval,
      },
    );
    final list = response.data as List<dynamic>;
    return list.map((item) => item as Map<String, dynamic>).toList();
  }
}
