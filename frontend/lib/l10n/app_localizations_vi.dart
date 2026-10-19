// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get settings => 'Cài đặt';

  @override
  String get customize => 'Tùy chỉnh';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get notifications => 'Thông báo';

  @override
  String get home => 'Trang chủ';

  @override
  String get alerts => 'Cảnh báo';

  @override
  String get choosePlant => 'Chọn giống';

  @override
  String get more => 'Khác';

  @override
  String get lowWaterAlert => 'Cảnh báo nước thấp';

  @override
  String get lowNutrientAlert => 'Cảnh báo dinh dưỡng thấp';

  @override
  String get temperatureAlert => 'Cảnh báo nhiệt độ';

  @override
  String get harvestReminder => 'Nhắc nhở thu hoạch';

  @override
  String get goodMorning => 'Chào buổi sáng';

  @override
  String get goodAfternoon => 'Chào buổi chiều';

  @override
  String get goodEvening => 'Chào buổi tối';

  @override
  String gardenOf(String name) {
    return 'Vườn của $name';
  }

  @override
  String get gardenTitle => 'Vườn của bạn';

  @override
  String get gardenSubtitle => 'Không gian xanh của bạn';

  @override
  String get sensorLoadError => 'Không thể tải dữ liệu cảm biến';

  @override
  String get healthy => 'KHỎE MẠNH';

  @override
  String get growing => 'ĐANG TRỒNG';

  @override
  String dayProgress(String variety, int day, int totalDays) {
    return '$variety · Ngày $day / $totalDays';
  }

  @override
  String get germination => 'Nảy mầm';

  @override
  String get growth => 'Sinh trưởng';

  @override
  String get harvest => 'Thu hoạch';

  @override
  String get liveSensors => 'Cảm biến trực tiếp';

  @override
  String get synced => '● Đã đồng bộ';

  @override
  String get waterLevel => 'Mực nước';

  @override
  String get airTemperature => 'Nhiệt độ không khí';

  @override
  String get light => 'ÁNH SÁNG';

  @override
  String get waterTemperature => 'NHIỆT ĐỘ NƯỚC';

  @override
  String get airHumidity => 'ĐỘ ẨM KHÔNG KHÍ';

  @override
  String careScheduleFor(String plantName) {
    return 'Lịch chăm sóc $plantName';
  }

  @override
  String get automaticOptimized => 'Tự động tối ưu';

  @override
  String get paused => 'Đã tạm dừng';

  @override
  String get wateringCycle => 'CHU KỲ TƯỚI';

  @override
  String wateringCycleValue(int minutes, int interval) {
    return '$minutes phút mỗi $interval phút';
  }

  @override
  String get nutrientCycle => 'CHU KỲ DINH DƯỠNG';

  @override
  String nutrientCycleValue(int amount, int days) {
    return '$amount ml mỗi $days ngày';
  }

  @override
  String get idealTemperature => 'NHIỆT ĐỘ LÝ TƯỞNG';

  @override
  String get all => 'Tất cả';

  @override
  String get alertsSubtitle => 'Theo dõi các vấn đề trong khu vườn của bạn.';

  @override
  String get unresolved => 'Chưa xử lý';

  @override
  String get resolved => 'Đã xử lý';

  @override
  String get noAlerts => 'Hiện chưa có cảnh báo.';

  @override
  String get noUnresolvedAlerts => 'Không có cảnh báo chưa xử lý.';

  @override
  String get noResolvedAlerts => 'Chưa có cảnh báo đã xử lý.';

  @override
  String get markResolved => 'Đánh dấu đã xử lý';

  @override
  String get choosePlantTitle => 'Chọn giống cây';

  @override
  String get choosePlantSubtitle =>
      'Chọn cây — hệ thống sẽ tự động điều chỉnh ánh sáng, nước và dinh dưỡng.';

  @override
  String get confirm => 'Xác nhận';

  @override
  String replacePlantConfirmation(String currentPlant, String newPlant) {
    return 'Bạn sẽ thay thế \"$currentPlant\" bằng \"$newPlant\". Tiếp tục?';
  }

  @override
  String get cancel => 'Hủy';

  @override
  String get agree => 'Đồng ý';

  @override
  String startedPlanting(String plantName) {
    return 'Bắt đầu trồng $plantName';
  }

  @override
  String weeks(int count) {
    return '$count tuần';
  }

  @override
  String pumpCycle(int minutes, int interval) {
    return 'Bơm $minutes phút mỗi $interval phút';
  }

  @override
  String nutrientCycleShort(int amount, int days) {
    return 'Bổ sung $amount ml mỗi $days ngày';
  }

  @override
  String get currentlyGrowing => 'Đang trồng';

  @override
  String get startGrowing => 'Bắt đầu trồng';

  @override
  String get devicesTitle => 'Thiết bị';

  @override
  String get devicesSubtitle => 'Quản lý và kết nối thiết bị Aerogreen.';

  @override
  String get account => 'Tài khoản';

  @override
  String get moreSubtitle => 'Tài khoản và các tùy chọn ứng dụng.';

  @override
  String get customization => 'Tùy chỉnh';

  @override
  String get languageAndNotifications => 'Ngôn ngữ và thông báo';

  @override
  String get harvestHistory => 'Lịch sử thu hoạch';

  @override
  String get plantsGrown => 'Đã trồng 32 cây';

  @override
  String get helpAndSupport => 'Trợ giúp & hỗ trợ';

  @override
  String get faqAndChat => 'Câu hỏi thường gặp và chat';

  @override
  String get logOut => 'Đăng xuất';

  @override
  String get logoutConfirmation => 'Bạn có chắc muốn đăng xuất?';

  @override
  String get authHeadline => 'Trồng rau đô thị nhàn tênh';

  @override
  String get authTagline =>
      'Trồng rau sạch ngay trên mặt bếp — Aerogreen lo phần còn lại.';

  @override
  String get fullName => 'Họ và tên';

  @override
  String get emailExample => 'ban@vidu.com';

  @override
  String get password => 'Mật khẩu';

  @override
  String get confirmPassword => 'Xác nhận mật khẩu';

  @override
  String get invalidEmail => 'Email không hợp lệ';

  @override
  String get passwordRequired => 'Vui lòng nhập mật khẩu';

  @override
  String get passwordRequirements =>
      'Mật khẩu cần có:\n• Ít nhất 8 ký tự\n• Chữ thường\n• Chữ hoa\n• Số\n• Ký tự đặc biệt';

  @override
  String get passwordsDoNotMatch => 'Mật khẩu không khớp';

  @override
  String get checkSignUpDetails =>
      'Vui lòng kiểm tra email, mật khẩu (ít nhất 8 ký tự) và phần xác nhận mật khẩu.';

  @override
  String get signIn => 'Đăng nhập';

  @override
  String get signUp => 'Đăng ký';

  @override
  String get createAccount => 'Tạo tài khoản';

  @override
  String get orContinueWith => 'hoặc tiếp tục với';

  @override
  String get termsNotice =>
      'Tiếp tục đồng nghĩa bạn đồng ý với Điều khoản & Quyền riêng tư.';

  @override
  String get authInvalidCredentials => 'Email hoặc mật khẩu không đúng.';

  @override
  String get authNetworkError =>
      'Lỗi kết nối. Vui lòng kiểm tra mạng và thử lại.';

  @override
  String get authGenericError => 'Đã xảy ra lỗi. Vui lòng thử lại.';

  @override
  String get socialSignInNotAvailable =>
      'Đăng nhập bằng mạng xã hội hiện chưa được hỗ trợ.';

  @override
  String get harvestLog => 'Nhật ký thu hoạch';

  @override
  String startedOn(String date) {
    return 'Bắt đầu: $date';
  }

  @override
  String harvestedOn(String date) {
    return 'Thu hoạch: $date';
  }

  @override
  String get help => 'Trợ giúp';

  @override
  String get support => 'Hỗ trợ';

  @override
  String get chatNotAvailable => 'Chat chưa được tích hợp';

  @override
  String get chatWithUs => 'Chat với chúng tôi';

  @override
  String get faqAddPlantQuestion => 'Cách thêm cây mới?';

  @override
  String get faqAddPlantAnswer =>
      'Vào tab Cây, nhấn nút + và điền thông tin cây.';

  @override
  String get faqAlertsQuestion => 'Cách thiết lập cảnh báo?';

  @override
  String get faqAlertsAnswer =>
      'Vào Khác, chọn Tùy chỉnh và bật các công tắc cảnh báo.';

  @override
  String get faqUnitsQuestion => 'Làm sao thay đổi đơn vị?';

  @override
  String get faqUnitsAnswer =>
      'Vào Khác, chọn Tùy chỉnh để chọn đơn vị và ngôn ngữ.';

  @override
  String get faqHarvestQuestion => 'Thu hoạch đã qua?';

  @override
  String get faqHarvestAnswer =>
      'Xem lịch sử thu hoạch trong mục Lịch sử thu hoạch.';

  @override
  String get offlineBanner => 'Bạn đang offline. Hiển thị dữ liệu gần nhất.';

  @override
  String get offlineBannerSemantics =>
      'Cảnh báo mất kết nối mạng. Bạn đang offline. Hiển thị dữ liệu gần nhất.';

  @override
  String get idealRange => 'Khoảng phù hợp';

  @override
  String get selectTimeRange => 'Chọn khoảng thời gian';

  @override
  String get trendDescription => 'Theo dõi xu hướng thay đổi';

  @override
  String get sensorHistoryLoadError => 'Không thể tải lịch sử cảm biến.';

  @override
  String get noSensorHistory => 'Chưa có dữ liệu trong khoảng thời gian này.';

  @override
  String get retry => 'Thử lại';

  @override
  String get cannotStartPumpLowWater => 'Không thể bật bơm khi mực nước thấp.';

  @override
  String get frontendSimulationOnly => 'Chỉ mô phỏng trên giao diện frontend';

  @override
  String get automaticScheduleSimulation => 'Lịch tự động (mô phỏng)';

  @override
  String get addSchedule => 'Thêm lịch';

  @override
  String get noSchedules =>
      'Chưa có lịch. Chọn Thêm lịch để xem lịch trên giao diện.';

  @override
  String get invalidSchedule =>
      'Nhập thời gian hợp lệ và chọn ít nhất một ngày.';

  @override
  String get save => 'Lưu';

  @override
  String manualControl(String device) {
    return 'Điều khiển $device thủ công';
  }

  @override
  String deviceOn(String device) {
    return '$device đang bật';
  }

  @override
  String deviceOff(String device) {
    return '$device đang tắt';
  }

  @override
  String get lowWaterPumpOnlyOff => 'Mức nước dưới 30%: chỉ có thể tắt bơm.';

  @override
  String get confirmDeletion => 'Xác nhận xóa';

  @override
  String get deleteScheduleConfirmation =>
      'Bạn có chắc muốn xóa lịch trình này?';

  @override
  String get delete => 'Xóa';

  @override
  String get error => 'Lỗi';

  @override
  String get dismiss => 'Đã hiểu';

  @override
  String deleteScheduleFailed(String error) {
    return 'Không thể xóa: $error';
  }

  @override
  String wateringScheduleFor(String deviceName) {
    return 'Lịch tưới - $deviceName';
  }

  @override
  String get scheduleLoadError => 'Không thể tải lịch trình';

  @override
  String get noSchedulesYet => 'Chưa có lịch trình';

  @override
  String get addAutomaticWateringSchedule => 'Thêm lịch trình tưới tự động';

  @override
  String get addScheduleTitle => 'Thêm lịch trình';

  @override
  String get deviceSetup => 'Thiết lập thiết bị';

  @override
  String copiedLabel(String label) {
    return 'Đã sao chép $label.';
  }

  @override
  String get manualMode => 'Chế độ thủ công';

  @override
  String get autoMode => 'Chế độ tự động';

  @override
  String get keepManual => 'Giữ thủ công';

  @override
  String get switchToAuto => 'Chuyển tự động';

  @override
  String get switchToManual => 'Chuyển sang thủ công';

  @override
  String get autoScheduleWillPause => 'Lịch tự động sẽ tạm dừng. Bạn có chắc?';

  @override
  String get cannotStartPumpLowWaterDetail =>
      'Không thể bật bơm khi mực nước đang thấp.';

  @override
  String cannotSendCommand(String error) {
    return 'Không thể gửi lệnh: $error';
  }

  @override
  String get selectRunDuration => 'Chọn thời gian chạy';

  @override
  String get pumpAutoStop => 'Bơm sẽ tự động tắt sau thời gian đã chọn';

  @override
  String get seconds30 => '30 giây';

  @override
  String get minute1 => '1 phút';

  @override
  String get minutes5 => '5 phút';

  @override
  String get minutes10 => '10 phút';

  @override
  String get device => 'Thiết bị';

  @override
  String get sensors => 'Cảm biến';

  @override
  String get noRecentData => 'Không có dữ liệu mới';

  @override
  String get stableConnection => 'Kết nối ổn định';

  @override
  String get deviceOffline => 'Thiết bị ngoại tuyến';

  @override
  String get noData => 'Không có dữ liệu';

  @override
  String cannotPauseAutoSchedule(String error) {
    return 'Không thể tạm dừng lịch tự động: $error';
  }

  @override
  String cannotRestoreAutoSchedule(String error) {
    return 'Không thể khôi phục lịch tự động: $error';
  }

  @override
  String updatedAt(String time) {
    return 'Cập nhật $time';
  }

  @override
  String get schedulesContinueOffline =>
      'Lịch tự động vẫn tiếp tục chạy khi thiết bị ngoại tuyến.';

  @override
  String get humidity => 'Độ ẩm';

  @override
  String get solutionTemperature => 'Nhiệt độ dung dịch';

  @override
  String get pumpControl => 'Điều khiển bơm';

  @override
  String get unavailableOffline => 'Không khả dụng khi ngoại tuyến';

  @override
  String get sendingCommand => 'Đang gửi lệnh…';

  @override
  String get pumpRunning => 'Bơm đang chạy';

  @override
  String get pumpStopped => 'Bơm đang tắt';

  @override
  String nextSprayIn(String time) {
    return 'Lần phun tiếp theo sau $time';
  }

  @override
  String get noActiveSpraySchedule => 'Không có lịch phun được kích hoạt';

  @override
  String get stop => 'Dừng';

  @override
  String get startPump => 'BẬT BƠM';

  @override
  String get wateringSchedule => 'Lịch tưới';

  @override
  String get edit => 'Sửa';

  @override
  String get noAutomaticSchedules => 'Chưa có lịch tự động.';

  @override
  String get history24Hours => 'Lịch sử 24 giờ';

  @override
  String get notEnoughChartData => 'Chưa đủ dữ liệu để tạo biểu đồ.';

  @override
  String alertsOpen(int count) {
    return '$count cảnh báo đang mở';
  }

  @override
  String get noOpenAlerts => 'Không có cảnh báo đang mở.';

  @override
  String get renameDevice => 'Đổi tên thiết bị';

  @override
  String get deviceName => 'Tên thiết bị';

  @override
  String get deviceNameRequired => 'Tên thiết bị không được để trống';

  @override
  String get deviceRenamed => 'Đã đổi tên thiết bị';

  @override
  String cannotRenameDevice(String error) {
    return 'Không thể đổi tên: $error';
  }

  @override
  String get deleteDevice => 'Xóa thiết bị';

  @override
  String get deleteDeviceWarning =>
      'Thiết bị sẽ được đặt lại và ngừng báo cáo. Lịch phun đã lưu có thể dừng. Hãy chắc chắn cây đã được chăm sóc.';

  @override
  String cannotDeleteDevice(String error) {
    return 'Không thể xóa thiết bị: $error';
  }

  @override
  String get deviceSettings => 'Cài đặt thiết bị';

  @override
  String get highTemperatureAlert => 'Cảnh báo nhiệt độ cao (°C)';

  @override
  String get lowWaterAlertThreshold => 'Cảnh báo mực nước thấp (%)';

  @override
  String get saveSettings => 'Lưu cài đặt';

  @override
  String get deviceInformation => 'Thông tin thiết bị';

  @override
  String get wifiSignal => 'Tín hiệu Wi-Fi';

  @override
  String get cannotLoadDeviceDetails => 'Không thể tải chi tiết thiết bị';
}
