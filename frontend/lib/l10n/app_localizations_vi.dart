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
  String get goodNight => 'Chúc ngủ ngon';

  @override
  String gardenOf(String name) {
    return 'Vườn của $name';
  }

  @override
  String gardenOfEndingWithS(String name) {
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

  @override
  String get addDevice => 'Thêm thiết bị';

  @override
  String get createDeviceTitle => 'Tạo thiết bị Aerogreen';

  @override
  String get createDeviceExplanation =>
      'Đặt tên thiết bị trước. Sau khi tạo, bạn sẽ nhận mã thiết lập dùng một lần.';

  @override
  String get createAndContinue => 'Tạo và tiếp tục';

  @override
  String get returnToDeviceList => 'Về danh sách thiết bị';

  @override
  String get deviceCreateOutcomeUnknown =>
      'Yêu cầu bị gián đoạn nên thiết bị có thể đã được tạo. Hãy về danh sách kiểm tra trước khi thử lại để tránh tạo trùng.';

  @override
  String get deviceCreateFailed => 'Không thể tạo thiết bị. Vui lòng thử lại.';

  @override
  String get sessionExpired =>
      'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';

  @override
  String get deviceActionForbidden =>
      'Bạn không có quyền quản lý thiết bị này.';

  @override
  String get tooManyRequests => 'Quá nhiều yêu cầu. Vui lòng chờ rồi thử lại.';

  @override
  String get serverUnavailable =>
      'Máy chủ tạm thời không khả dụng. Vui lòng thử lại sau.';

  @override
  String get provisioningCodeExpired =>
      'Mã thiết lập đã hết hạn. Hãy tạo mã mới.';

  @override
  String get provisioningAcceptedWaiting =>
      'ESP đã nhận cấu hình. Đang chờ backend xác nhận thiết bị trực tuyến.';

  @override
  String get provisioningOutcomeUnknown =>
      'Yêu cầu bị gián đoạn và mã dùng một lần có thể đã được sử dụng. Hãy tạo mã mới trước khi thử lại.';

  @override
  String get deviceOnlineConfirmed =>
      'Backend đã xác nhận thiết bị đang trực tuyến.';

  @override
  String get deviceOnlineNotConfirmed =>
      'ESP đã nhận cấu hình nhưng backend chưa xác nhận thiết bị trực tuyến. Hãy kiểm tra lại danh sách thiết bị sau ít phút.';

  @override
  String get malformedProvisioningResponse =>
      'Máy chủ trả về dữ liệu mã thiết lập không hợp lệ.';

  @override
  String get provisioningCodeRequestFailed => 'Không thể tạo mã thiết lập.';

  @override
  String get regenerateCodeTitle => 'Tạo mã mới?';

  @override
  String get regenerateCodeWarning =>
      'Mã hiện tại sẽ mất hiệu lực ngay lập tức.';

  @override
  String get generateNewCode => 'Tạo mã mới';

  @override
  String get networkError => 'Hãy kiểm tra kết nối mạng và thử lại.';

  @override
  String get deleteDeviceTitle => 'Xóa thiết bị?';

  @override
  String deleteNamedDeviceConfirmation(String value0) {
    return 'Bạn có chắc muốn xóa \"$value0\"? Thao tác này không thể hoàn tác.';
  }

  @override
  String get actionFailed => 'Không thể hoàn tất';

  @override
  String get searchDevicesHint => 'Tìm theo tên hoặc vị trí';

  @override
  String get noMatchingDevices => 'Không tìm thấy thiết bị.';

  @override
  String get unassignedLocation => 'Vị trí chưa gán';

  @override
  String deviceNeverConnected(String value0) {
    return 'Chưa có kết nối · $value0';
  }

  @override
  String deviceLastSeen(String value0, String value1) {
    return 'Lần cuối $value0 · $value1';
  }

  @override
  String get devicesEmptyTitle => 'Chưa có thiết bị nào';

  @override
  String get devicesEmptyExplanation =>
      'Tạo thiết bị để bắt đầu thiết lập kết nối.';

  @override
  String get devicesLoadFailed => 'Không thể tải danh sách thiết bị.';

  @override
  String switchDeviceToAutoConfirmation(String value0) {
    return '$value0 đang ở chế độ Thủ công và chưa phun. Chuyển về Tự động?';
  }

  @override
  String lightCommandFailed(String value0) {
    return 'Không thể gửi lệnh đèn: $value0';
  }

  @override
  String get switchMode => 'Chuyển';

  @override
  String get deviceDeleted => 'Đã xóa thiết bị thành công';

  @override
  String get noReadingsYet => 'Chưa có dữ liệu';

  @override
  String get automaticMode => 'Tự động';

  @override
  String get manualControlModeLabel => 'Thủ công';

  @override
  String pumpRunningCountdown(String value0) {
    return 'Bơm đang chạy - còn $value0';
  }

  @override
  String get noScheduledTime => 'Không có lịch';

  @override
  String get scheduledTimePassed => 'Đã qua';

  @override
  String minutesRemaining(String value0) {
    return '$value0 phút';
  }

  @override
  String get lightControl => 'Điều khiển đèn';

  @override
  String get lightIsOn => 'Đèn đang bật';

  @override
  String get lightIsOff => 'Đèn đang tắt';

  @override
  String sprayScheduleSummary(
    String value0,
    String value1,
    String value2,
    String value3,
  ) {
    return 'Phun $value0 giây mỗi $value1 phút, $value2-$value3';
  }

  @override
  String get savedSchedulesContinue =>
      'Lịch đã lưu tiếp tục chạy tự động khi có kết nối.';

  @override
  String temperatureRecordCount(String value0) {
    return '$value0 lần ghi · Nhiệt độ';
  }

  @override
  String get lowWaterTitle => 'Mực nước thấp';

  @override
  String get highTemperatureTitle => 'Nhiệt độ cao';

  @override
  String get invalidDeviceThresholds =>
      'Kiểm tra lại ngưỡng nhiệt độ và mực nước.';

  @override
  String get renameAction => 'Đổi tên';

  @override
  String get wifiSignalGood => 'Tốt (-65 dBm)';

  @override
  String get wifiSignalMissing => 'Không có tín hiệu';

  @override
  String get espFoundNoNetworks =>
      'Đã thấy ESP nhưng chưa tìm thấy mạng Wi-Fi 2.4 GHz.';

  @override
  String get espConnectedChooseNetwork =>
      'Đã kết nối ESP. Chọn mạng Wi-Fi bên dưới.';

  @override
  String get espConnectionFailed =>
      'Không kết nối được ESP. Hãy nối thiết bị này vào Wi-Fi IOTAgri-Setup rồi thử lại.';

  @override
  String get wifiSsidRequired => 'Vui lòng nhập hoặc chọn tên Wi-Fi 2.4 GHz.';

  @override
  String get wifiPasswordRequired => 'Vui lòng nhập mật khẩu Wi-Fi.';

  @override
  String get espSendingConfiguration =>
      'Đang gửi cấu hình trực tiếp tới ESP...';

  @override
  String get setupCodeValidity => 'Có hiệu lực trong 15 phút';

  @override
  String get setupCodeExpired => 'Mã đã hết hạn';

  @override
  String setupCodeSecondsRemaining(String value0) {
    return 'Còn $value0 giây';
  }

  @override
  String setupCodeExpiresAt(String value0) {
    return 'Hết hạn lúc $value0';
  }

  @override
  String get setupCodeMissing => 'Máy chủ chưa trả về mã thiết lập.';

  @override
  String get setupCodeLabel => 'Mã thiết lập';

  @override
  String get copyCodeAgain => 'Sao chép lại mã';

  @override
  String get copySetupCode => 'Sao chép mã';

  @override
  String get espSetupStepOne =>
      'Giữ laptop chạy backend và frontend trên Wi-Fi chính. Trên điện thoại, mở màn hình này trước.';

  @override
  String get espSetupStepTwo =>
      'Kết nối điện thoại với Wi-Fi IOTAgri-Setup, quay lại màn hình này và nhấn Kiểm tra kết nối ESP.';

  @override
  String get espSetupStepThree =>
      'Chọn Wi-Fi 2.4 GHz, nhập mật khẩu rồi nhấn Kết nối ESP. Frontend tự gửi mã và địa chỉ backend.';

  @override
  String get espSetupStepFour =>
      'Khi báo thành công, kết nối điện thoại trở lại Wi-Fi chính và chờ thiết bị chuyển sang trạng thái online.';

  @override
  String espBackendAddress(String value0) {
    return 'Backend dành cho ESP: $value0';
  }

  @override
  String get regenerateSetupCode => 'Tạo mã mới (mã cũ sẽ hết hiệu lực)';

  @override
  String get directEspSetup => 'Kết nối trực tiếp với ESP';

  @override
  String get directEspSetupHint =>
      'Không cần mở Swagger hoặc trang cấu hình 192.168.4.1.';

  @override
  String get checkEspConnection => 'Kiểm tra kết nối ESP';

  @override
  String espDetected(String value0) {
    return 'Đã thấy ESP: $value0';
  }

  @override
  String get espAvailableNetworks => 'Wi-Fi 2.4 GHz ESP nhìn thấy:';

  @override
  String get wifiSsidHint => 'Tên Wi-Fi 2.4 GHz (SSID)';

  @override
  String get wifiPasswordHint => 'Mật khẩu Wi-Fi';

  @override
  String get connectedStatus => 'Đã kết nối';

  @override
  String get connectEsp => 'Kết nối ESP';

  @override
  String get seedlingsPreset => 'Cây giống';

  @override
  String get leafyPreset => 'Rau lá';

  @override
  String get herbsPreset => 'Thảo mộc';

  @override
  String sprayDurationSummary(String value0) {
    return 'Thời gian phun: $value0 giây';
  }

  @override
  String sprayIntervalSummary(String value0) {
    return 'Lặp lại mỗi $value0 phút';
  }

  @override
  String scheduleDaysSummary(String value0) {
    return 'Ngày: $value0';
  }

  @override
  String get noDaysSelected => 'chưa chọn ngày';

  @override
  String get sprayDurationRequired => 'Vui lòng nhập thời gian phun';

  @override
  String get sprayDurationRange => 'Thời gian phun từ 1-120 giây';

  @override
  String get scheduleIntervalRequired => 'Vui lòng nhập khoảng cách';

  @override
  String get scheduleIntervalRange => 'Khoảng cách từ 1-60 phút';

  @override
  String get sprayDurationLessThanInterval =>
      'Thời gian phun phải nhỏ hơn khoảng cách';

  @override
  String get scheduleEndAfterStart =>
      'Giờ kết thúc phải sau giờ bắt đầu (trừ khi qua đêm)';

  @override
  String schedulePreview(
    String value0,
    String value1,
    String value2,
    String value3,
    String value4,
  ) {
    return 'Phun $value0 giây mỗi $value1 phút, $value2-$value3, $value4';
  }

  @override
  String get selectScheduleDay => 'Vui lòng chọn ít nhất một ngày';

  @override
  String get savedTitle => 'Đã lưu';

  @override
  String get savedToDevice => 'Đã lưu vào thiết bị';

  @override
  String saveFailed(String value0) {
    return 'Không thể lưu: $value0';
  }

  @override
  String get unsavedTitle => 'Chưa lưu';

  @override
  String get unsavedChangesConfirmation =>
      'Bạn có thay đổi chưa được lưu. Bạn có muốn rời đi?';

  @override
  String get keepEditing => 'Giữ lại';

  @override
  String get discardChanges => 'Bỏ thay đổi';

  @override
  String get deviceScheduleTimezoneHint =>
      'Giờ thiết bị: Asia/Ho_Chi_Minh. Lịch ưu tiên hơn điều khiển thủ công.';

  @override
  String get schedulePreset => 'Mẫu cài đặt';

  @override
  String get sprayDurationSeconds => 'Thời gian phun (giây)';

  @override
  String get scheduleIntervalMinutes => 'Khoảng cách (phút)';

  @override
  String get scheduleTimeWindow => 'Khung giờ hoạt động';

  @override
  String get scheduleStart => 'Bắt đầu';

  @override
  String get scheduleEnd => 'Kết thúc';

  @override
  String get scheduleRepeatDays => 'Ngày lặp lại';

  @override
  String get pumpLabel => 'Bơm';

  @override
  String get lightLabel => 'Đèn';

  @override
  String get turnLightOn => 'Bật đèn';

  @override
  String localScheduleSummary(
    String value0,
    String value1,
    String value2,
    String value3,
    String value4,
  ) {
    return '$value0 $value1 giây mỗi $value2 phút · $value3\n$value4 · chỉ hiển thị';
  }

  @override
  String actionDurationSeconds(String value0) {
    return 'Thời gian $value0 (giây)';
  }

  @override
  String get timezoneLabel => 'Múi giờ';

  @override
  String get vietnamTimezone => 'Việt Nam · GMT+07:00';

  @override
  String get localScheduleNotice =>
      'Lịch này chỉ hiển thị trên frontend, chưa gửi tới thiết bị hoặc backend.';

  @override
  String get waterSensorTitle => 'Mức nước';

  @override
  String get waterSensorLabel => 'MỨC NƯỚC';

  @override
  String get waterSensorDescription =>
      'Theo dõi lượng nước trong hệ thống để cây luôn được tưới phù hợp.';

  @override
  String get waterSensorHistory => 'Lịch sử mức nước';

  @override
  String get waterSensorLow => 'Mức nước thấp';

  @override
  String get waterSensorStable => 'Mức nước ổn định';

  @override
  String get notConfigured => 'Chưa cấu hình';

  @override
  String get nutrientSensorDescription =>
      'Theo dõi nồng độ dinh dưỡng để hỗ trợ cây phát triển đồng đều.';

  @override
  String get nutrientSensorHistory => 'Lịch sử mức dinh dưỡng';

  @override
  String get dataReceived => 'Đã nhận dữ liệu';

  @override
  String get temperatureSensorTitle => 'Nhiệt độ';

  @override
  String get temperatureSensorLabel => 'NHIỆT ĐỘ';

  @override
  String get temperatureSensorDescription =>
      'Theo dõi nhiệt độ môi trường quanh khu vực trồng cây.';

  @override
  String get temperatureSensorHistory => 'Lịch sử nhiệt độ';

  @override
  String get temperatureSensorAttention => 'Nhiệt độ cần chú ý';

  @override
  String get temperatureSensorHealthy => 'Nhiệt độ phù hợp';

  @override
  String get waterTemperatureSensorTitle => 'Nhiệt độ nước';

  @override
  String get waterTemperatureSensorDescription =>
      'Theo dõi nhiệt độ dung dịch bằng cảm biến nhiệt độ nước.';

  @override
  String get waterTemperatureSensorHistory => 'Lịch sử nhiệt độ nước';

  @override
  String get humiditySensorTitle => 'Độ ẩm không khí';

  @override
  String get humiditySensorDescription =>
      'Theo dõi độ ẩm không khí bằng cảm biến AHT20.';

  @override
  String get humiditySensorHistory => 'Lịch sử độ ẩm không khí';

  @override
  String get lightSensorTitle => 'Ánh sáng';

  @override
  String get lightSensorDescription =>
      'Theo dõi cường độ ánh sáng để cây nhận đủ năng lượng quang hợp.';

  @override
  String get lightSensorHistory => 'Lịch sử ánh sáng';

  @override
  String get resolveNow => 'Xử lý ngay';

  @override
  String get plantLettuce => 'Xà lách';

  @override
  String get plantBasil => 'Húng quế';

  @override
  String get plantSpinach => 'Rau chân vịt';

  @override
  String get plantMint => 'Bạc hà';

  @override
  String get plantKale => 'Cải xoăn';

  @override
  String get plantCoriander => 'Rau mùi';

  @override
  String get difficultyEasy => 'Dễ';

  @override
  String get difficultyMedium => 'Trung bình';

  @override
  String get lowNutrientTitle => 'Dinh dưỡng thấp';

  @override
  String get lowWaterMessage => 'Mực nước đang dưới 30% – cần nạp thêm nước.';

  @override
  String get lowNutrientMessage => 'Mức dinh dưỡng dưới 45% – cần bón thêm.';

  @override
  String get refillWater => 'Nạp nước';

  @override
  String get addNutrients => 'Bổ dinh dưỡng';

  @override
  String get lowTemperatureTitle => 'Nhiệt độ thấp';

  @override
  String get waterEmptyTitle => 'Bình nước đã cạn';

  @override
  String get humidityAlertTitle => 'Độ ẩm ngoài ngưỡng';

  @override
  String get pumpFaultTitle => 'Lỗi bơm';

  @override
  String get deviceOfflineTitle => 'Thiết bị mất kết nối';

  @override
  String get deviceOnlineTitle => 'Thiết bị đã trực tuyến';

  @override
  String get nutrientAlertTitle => 'Dinh dưỡng ngoài ngưỡng';

  @override
  String get phAlertTitle => 'pH ngoài ngưỡng';

  @override
  String get sensorAlertTitle => 'Cảnh báo cảm biến';

  @override
  String highTemperatureMessage(String value, String threshold) {
    return 'Nhiệt độ $value°C vượt ngưỡng $threshold°C.';
  }

  @override
  String lowWaterThresholdMessage(String value, String threshold) {
    return 'Mực nước $value% thấp hơn ngưỡng $threshold%.';
  }

  @override
  String sensorThresholdMessage(String value, String threshold) {
    return 'Giá trị $value · Ngưỡng $threshold.';
  }

  @override
  String get sprayAction => 'Phun';

  @override
  String get sundayShort => 'CN';

  @override
  String get mondayShort => 'T2';

  @override
  String get tuesdayShort => 'T3';

  @override
  String get wednesdayShort => 'T4';

  @override
  String get thursdayShort => 'T5';

  @override
  String get fridayShort => 'T6';

  @override
  String get saturdayShort => 'T7';

  @override
  String get stillActiveTitle => 'Vẫn đang xảy ra';

  @override
  String get alertRecoveredTitle => 'Đã khôi phục';

  @override
  String alertResolvedMessage(String device, String alert) {
    return '$device: $alert đã được xử lý.';
  }

  @override
  String deviceAlertsTitle(String value0) {
    return 'Cảnh báo · $value0';
  }

  @override
  String get markAllAlertsRead => 'Đánh dấu tất cả đã đọc';

  @override
  String get todayLabel => 'Hôm nay';

  @override
  String get earlierLabel => 'Trước đó';

  @override
  String get criticalSeverity => 'Nghiêm trọng';

  @override
  String get unreadFilter => 'Chưa đọc';

  @override
  String get activeAlertStatus => 'Đang xảy ra';

  @override
  String get alertDetailsTitle => 'Chi tiết cảnh báo';

  @override
  String get timeLabel => 'Thời gian';

  @override
  String get statusLabel => 'Trạng thái';

  @override
  String get openAlertDevice => 'Đi tới thiết bị';

  @override
  String get alertsQuietTitle => 'Mọi thứ yên tĩnh';

  @override
  String get noMatchingAlerts => 'Không có cảnh báo phù hợp với bộ lọc.';

  @override
  String get invalidAlertThreshold =>
      'Ngưỡng phải là số hợp lệ; mực nước từ 0–100%.';

  @override
  String get alertThresholdsSaved => 'Đã lưu ngưỡng cảnh báo';

  @override
  String deviceSettingsUpdated(String value0) {
    return 'Cài đặt cho $value0 đã được cập nhật.';
  }

  @override
  String get alertThresholdsTitle => 'Ngưỡng cảnh báo';

  @override
  String get supportedSensorsOnly =>
      'Chỉ những cảm biến thiết bị hiện hỗ trợ mới được hiển thị.';

  @override
  String get resetRecommendedThresholds => 'Đặt lại khuyến nghị';

  @override
  String get notificationPreferencesTitle => 'Tùy chọn thông báo';

  @override
  String get notificationsToggleHint => 'Bật hoặc tắt toàn bộ thông báo';

  @override
  String get severityHeading => 'MỨC ĐỘ';

  @override
  String get criticalNotificationsHint => 'Lỗi bơm, hết nước, mất kết nối';

  @override
  String get warningNotificationsHint => 'Chỉ số cảm biến ngoài ngưỡng';

  @override
  String get infoSeverity => 'Thông tin';

  @override
  String get infoNotificationsHint =>
      'Đã lưu lịch, online lại, cập nhật firmware';

  @override
  String get quietHoursTitle => 'Giờ yên tĩnh';

  @override
  String get criticalIgnoresQuietHours =>
      'Cảnh báo nghiêm trọng bỏ qua giờ yên tĩnh.';

  @override
  String deviceHistoryTitle(String value0) {
    return 'Lịch sử · $value0';
  }

  @override
  String get hourlyAverages => 'Hiển thị trung bình theo giờ';

  @override
  String get historyFiltersTitle => 'Bộ lọc lịch sử';

  @override
  String get showPumpEvents => 'Hiển thị sự kiện bơm';

  @override
  String get resetAction => 'Đặt lại';

  @override
  String get applyAction => 'Áp dụng';

  @override
  String get fromDateLabel => 'Từ ngày';

  @override
  String get toDateLabel => 'Đến ngày';

  @override
  String get customHistoryRangeInvalid =>
      'Khoảng tùy chọn phải từ 1 đến 31 ngày.';

  @override
  String get exportDataTitle => 'Xuất dữ liệu';

  @override
  String get exportDataFailed => 'Không thể tạo tệp. Hãy thử khoảng ngắn hơn.';

  @override
  String get createFileAction => 'Tạo tệp';

  @override
  String pumpEventsCount(String value0) {
    return 'Sự kiện bơm · $value0';
  }

  @override
  String get minimumLabel => 'Thấp nhất';

  @override
  String get maximumLabel => 'Cao nhất';

  @override
  String get historyLoadFailed => 'Không thể tải lịch sử';

  @override
  String get newDeviceInsufficientData => 'Thiết bị mới chưa có đủ dữ liệu';

  @override
  String get historyRangeEmpty => 'Không có dữ liệu trong khoảng này';

  @override
  String get changeHistoryRange => 'Đổi khoảng thời gian';

  @override
  String viewSensorDetails(String value0) {
    return 'Xem chi tiết $value0';
  }

  @override
  String get genericErrorTitle => 'Đã xảy ra lỗi';

  @override
  String get requestValidationFailed =>
      'Kiểm tra thông tin đã nhập và thử lại.';

  @override
  String get historySevenDays => '7 ngày';

  @override
  String get historyThirtyDays => '30 ngày';

  @override
  String get averageLabel => 'Trung bình';
}
