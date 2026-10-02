import '../models/user.dart';


/// Mock Service cung cấp dữ liệu giả cho Admin Panel.
/// XÓA FILE NÀY KHI BACKEND THẬT SẴN SÀNG.
class MockAdminService {
  // Singleton
  static final MockAdminService _instance = MockAdminService._internal();
  factory MockAdminService() => _instance;
  MockAdminService._internal();

  // ==================== USERS ====================
  List<User> getMockUsers() {
    return [
      User(id: 'u001', email: 'nguyenvana@gmail.com', fullName: 'Nguyễn Văn A', role: 'user'),
      User(id: 'u002', email: 'tranthib@gmail.com', fullName: 'Trần Thị B', role: 'user'),
      User(id: 'u003', email: 'levanc@gmail.com', fullName: 'Lê Văn C', role: 'user'),
      User(id: 'u004', email: 'phamthid@gmail.com', fullName: 'Phạm Thị D', role: 'user'),
      User(id: 'u005', email: 'hoangvane@gmail.com', fullName: 'Hoàng Văn E', role: 'user'),
      User(id: 'u006', email: 'vuthif@gmail.com', fullName: 'Vũ Thị F', role: 'user'),
      User(id: 'u007', email: 'dangvang@gmail.com', fullName: 'Đặng Văn G', role: 'user'),
      User(id: 'u008', email: 'bothih@gmail.com', fullName: 'Bùi Thị H', role: 'user'),
      User(id: 'u009', email: 'dovani@gmail.com', fullName: 'Đỗ Văn I', role: 'user'),
      User(id: 'u010', email: 'ngothik@gmail.com', fullName: 'Ngô Thị K', role: 'user'),
      User(id: 'u011', email: 'lyvanl@gmail.com', fullName: 'Lý Văn L', role: 'user'),
      User(id: 'u012', email: 'truongthim@gmail.com', fullName: 'Trương Thị M', role: 'user'),
      User(id: 'u013', email: 'chuvann@gmail.com', fullName: 'Chu Văn N', role: 'user'),
      User(id: 'u014', email: 'maithio@gmail.com', fullName: 'Mai Thị O', role: 'user'),
      User(id: 'u015', email: 'tavanp@gmail.com', fullName: 'Tạ Văn P', role: 'user'),
      User(id: 'u016', email: 'hathiq@gmail.com', fullName: 'Hà Thị Q', role: 'user'),
      User(id: 'u017', email: 'caovanr@gmail.com', fullName: 'Cao Văn R', role: 'user'),
      User(id: 'u018', email: 'dinhthis@gmail.com', fullName: 'Đinh Thị S', role: 'user'),
      User(id: 'u019', email: 'luuvant@gmail.com', fullName: 'Lưu Văn T', role: 'user'),
      User(id: 'u020', email: 'admin@aerogreen.com', fullName: 'Quản trị viên', role: 'admin'),
    ];
  }

  // ==================== DEVICE STATS ====================
  /// Trả về danh sách devices giả với đầy đủ thông tin.
  /// Vì model DeviceOverview phức tạp, ta trả về Map thay vì Object.
  List<Map<String, dynamic>> getMockDevices() {
    final now = DateTime.now().toUtc();
    return List.generate(30, (index) {
      final isOnline = index % 5 != 0; // 80% online
      final ownerIndex = index % 20;
      return {
        'id': 'device_${(index + 1).toString().padLeft(3, '0')}',
        'name': 'Vườn ${String.fromCharCode(65 + index % 26)}${index ~/ 26 > 0 ? (index ~/ 26 + 1) : ''}',
        'ownerId': 'u${(ownerIndex + 1).toString().padLeft(3, '0')}',
        'ownerEmail': 'user${ownerIndex + 1}@gmail.com',
        'isOnline': isOnline,
        'lastSeenAt': isOnline
            ? now.subtract(Duration(minutes: index * 2)).toIso8601String()
            : now.subtract(Duration(hours: index + 1)).toIso8601String(),
        'temperature': 22.0 + (index % 10),
        'humidity': 50.0 + (index % 30),
        'soilMoisture': 30.0 + (index % 40),
        'isPumping': index % 3 == 0,
        'createdAt': now.subtract(Duration(days: 30 + index)).toIso8601String(),
      };
    });
  }

  // ==================== TICKETS ====================
  List<Map<String, dynamic>> getMockTickets() {
    final now = DateTime.now();
    final statuses = ['open', 'in_progress', 'closed'];
    final subjects = [
      'Thiết bị không kết nối được',
      'Không nhận được cảnh báo',
      'Bơm không hoạt động',
      'Dữ liệu cảm biến sai',
      'Không đăng nhập được',
      'App bị đơ khi xem lịch sử',
      'Cần hỗ trợ cài đặt thiết bị mới',
      'Mực nước báo sai',
      'Nhiệt độ hiển thị không đúng',
      'Yêu cầu xóa tài khoản',
    ];
    return List.generate(10, (index) {
      return {
        'id': 'ticket_${(index + 1).toString().padLeft(4, '0')}',
        'subject': subjects[index],
        'userId': 'u${(index % 20 + 1).toString().padLeft(3, '0')}',
        'userName': 'Người dùng ${index + 1}',
        'userEmail': 'user${index + 1}@gmail.com',
        'status': statuses[index % 3],
        'priority': index % 4 == 0 ? 'high' : (index % 3 == 0 ? 'medium' : 'low'),
        'createdAt': now.subtract(Duration(hours: index * 5)).toIso8601String(),
        'lastMessage': 'Nội dung tin nhắn cuối cùng của ticket ${index + 1}...',
        'messageCount': 2 + (index % 5),
      };
    });
  }

  // ==================== ALERTS ====================
  List<Map<String, dynamic>> getMockAlerts() {
    final now = DateTime.now();
    final types = ['LOW_WATER_LEVEL', 'HIGH_TEMPERATURE', 'LOW_HUMIDITY', 'DEVICE_OFFLINE'];
    return List.generate(15, (index) {
      final type = types[index % types.length];
      return {
        'id': 'alert_${(index + 1).toString().padLeft(4, '0')}',
        'deviceId': 'device_${(index % 30 + 1).toString().padLeft(3, '0')}',
        'deviceName': 'Vườn ${String.fromCharCode(65 + index % 26)}',
        'type': type,
        'severity': index % 3 == 0 ? 'critical' : (index % 2 == 0 ? 'warning' : 'info'),
        'message': _alertMessage(type, index),
        'measuredValue': 20.0 + (index % 30),
        'threshold': 30.0,
        'createdAt': now.subtract(Duration(hours: index * 2)).toIso8601String(),
        'isResolved': index % 4 == 0,
      };
    });
  }

  String _alertMessage(String type, int index) {
    switch (type) {
      case 'LOW_WATER_LEVEL':
        return 'Mực nước thấp: ${20 + index % 10}%';
      case 'HIGH_TEMPERATURE':
        return 'Nhiệt độ cao: ${35 + index % 5}°C';
      case 'LOW_HUMIDITY':
        return 'Độ ẩm thấp: ${30 + index % 10}%';
      case 'DEVICE_OFFLINE':
        return 'Thiết bị mất kết nối ${index + 1} giờ';
      default:
        return 'Cảnh báo không xác định';
    }
  }

  // ==================== SYSTEM HEALTH ====================
  Map<String, dynamic> getMockSystemHealth() {
    return {
      'server': {
        'status': 'online',
        'cpu': 42.5,
        'ram': 61.2,
        'uptimeDays': 15,
        'responseTimeMs': 45,
      },
      'mqtt': {
        'status': 'online',
        'connections': 1234,
        'messagesPerSec': 456,
        'topics': 89,
      },
      'database': {
        'status': 'online',
        'sizeGb': 2.3,
        'queriesPerSec': 123,
        'responseTimeMs': 45,
      },
      'totalUsers': 20,
      'totalDevices': 30,
      'onlineDevices': 24,
      'totalAlerts': 15,
      'unresolvedAlerts': 11,
      'openTickets': 4,
    };
  }

  // ==================== LOGS ====================
  List<Map<String, dynamic>> getMockLogs() {
    final now = DateTime.now();
    final actions = [
      {'type': 'auth', 'severity': 'info', 'message': 'User logged in'},
      {'type': 'device', 'severity': 'info', 'message': 'Device connected'},
      {'type': 'device', 'severity': 'warning', 'message': 'Device disconnected'},
      {'type': 'alert', 'severity': 'critical', 'message': 'Low water level detected'},
      {'type': 'user', 'severity': 'info', 'message': 'New user registered'},
      {'type': 'system', 'severity': 'error', 'message': 'MQTT connection lost'},
      {'type': 'pump', 'severity': 'info', 'message': 'Pump turned on'},
      {'type': 'pump', 'severity': 'info', 'message': 'Pump turned off'},
    ];
    return List.generate(50, (index) {
      final action = actions[index % actions.length];
      return {
        'id': 'log_${(index + 1).toString().padLeft(4, '0')}',
        'type': action['type'],
        'severity': action['severity'],
        'message': action['message'],
        'detail': 'Chi tiết log số ${index + 1}',
        'userId': index % 3 == 0 ? 'u${(index % 20 + 1).toString().padLeft(3, '0')}' : null,
        'deviceId': index % 2 == 0 ? 'device_${(index % 30 + 1).toString().padLeft(3, '0')}' : null,
        'createdAt': now.subtract(Duration(minutes: index * 7)).toIso8601String(),
      };
    });
  }

  // ==================== REPORT STATS ====================
  Map<String, dynamic> getMockReportStats() {
    return {
      'users': {
        'total': 20,
        'newThisMonth': 5,
        'active': 18,
        'locked': 2,
      },
      'devices': {
        'total': 30,
        'online': 24,
        'offline': 6,
        'newThisMonth': 3,
      },
      'alerts': {
        'total': 15,
        'critical': 5,
        'warning': 6,
        'resolved': 4,
      },
      'tickets': {
        'total': 10,
        'open': 4,
        'inProgress': 3,
        'closed': 3,
      },
    };
  }
}