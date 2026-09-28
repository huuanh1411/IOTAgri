# Workflow Phát Triển Frontend

## 📋 Cấu Trúc Repository

- **`main`**: Branch chính - chứa backend + frontend đầy đủ
- **`FE`**: Branch riêng cho Flutter frontend (nếu cần tách biệt)
- **`datho`**: Branch development

## 🚀 Workflow Hàng Ngày

### 1. Làm việc với Frontend

```bash
# Đảm bảo đang ở branch main
git checkout main
git pull origin main

# Làm việc với code Flutter trong thư mục frontend/
cd frontend
flutter run

# Test và commit changes
git add .
git commit -m "feat: mô tả thay đổi"
git push origin main
```

### 2. Khi cần Sync với Backend API Changes

Khi backend có thay đổi API cần frontend cập nhật:

```bash
# Đảm bảo có các thay đổi backend mới nhất
git pull origin main

# Kiểm tra API constants trong frontend/lib/constants/api_constants.dart
# Cập nhật nếu cần thiết

# Test lại frontend với backend mới
cd frontend
flutter run
```

### 3. Workflow Tách Biệt Frontend (nếu cần)

Nếu bạn muốn làm việc với branch FE riêng:

```bash
# Tạo và chuyển sang branch FE
git checkout -b FE
git push -u origin FE

# Làm việc với code frontend
# ... thay đổi code ...

# Khi muốn merge vào main
git checkout main
git merge FE
git push origin main
```

## 📝 Quy Tắc Commit

- Sử dụng tiếng Việt có dấu
- Format: `[type]: mô tả ngắn gọn`
- Types: `feat`, `fix`, `refactor`, `style`, `docs`, `test`, `chore`

Ví dụ:
```
feat: thêm màn hình đăng nhập mới
fix: sửa lỗi không load được danh sách thiết bị
refactor: tối ưu hóa API service
docs: cập nhật hướng dẫn sử dụng
```

## 🛠️ Development Commands

### Chạy ứng dụng Flutter:
```bash
cd frontend
flutter run
```

### Build ứng dụng:
```bash
cd frontend
flutter build apk    # Android
flutter build ios    # iOS
flutter build web    # Web
```

### Check code quality:
```bash
cd frontend
flutter analyze
flutter test
```

### Cài đặt dependencies:
```bash
cd frontend
flutter pub get
```

## 🔗 Cấu Hình API Connection

### Mặc định:
Backend API URL: `http://localhost:8080`

### Cấu hình cho môi trường khác:
Thay đổi trong `frontend/lib/constants/api_constants.dart`:
```dart
static const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080',
);
```

Hoặc chạy với biến môi trường:
```bash
flutter run --dart-define=API_BASE_URL=https://your-api-url.com
```

## 📋 Checklist Trước Khi Commit

- [ ] Code đã được test kỹ
- [ ] Không có warnings từ `flutter analyze`
- [ ] Đã commit với message rõ ràng
- [ ] Đã push lên branch
- [ ] Backend tương thích với frontend changes
- [ ] Đã test integration với backend (nếu có thay đổi API)

## 🚨 Xử Lý Conflict

Khi merge có conflict:

```bash
# Bắt đầu merge
git merge FE

# Nếu có conflict:
git status  # Xem các file conflict
# Mở file conflict, sửa các dấu <<<<<<<, =======, >>>>>>>
git add file.conflict  # Sau khi sửa xong
git commit  # Hoàn thành merge
git push
```

## 📱 Testing Trước Khi Push

1. **Test trên simulator/emulator**
2. **Test trên real device nếu có**
3. **Test tất cả screens chính**
4. **Test authentication flow**
5. **Test API connections với backend**
6. **Test error handling**
7. **Test với backend đang chạy**

## 🎯 Cấu Trúc Frontend

```
frontend/
├── lib/
│   ├── main.dart                 # Entry point
│   ├── models/                   # Data models
│   │   ├── user.dart
│   │   ├── device.dart
│   │   ├── sensor_reading.dart
│   │   ├── device_alert.dart
│   │   ├── pump_command.dart
│   │   └── pump_schedule.dart
│   ├── services/                 # API services
│   │   └── api_service.dart
│   ├── providers/                # State management
│   │   └── auth_provider.dart
│   ├── screens/                  # UI screens
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── dashboard/
│   │   │   └── dashboard_screen.dart
│   │   └── devices/
│   │       ├── devices_screen.dart
│   │       └── device_detail_screen.dart
│   ├── constants/                # Constants
│   │   └── api_constants.dart
│   └── widgets/                  # Reusable widgets
├── android/                      # Android platform files
├── ios/                          # iOS platform files
├── web/                          # Web platform files
├── windows/                      # Windows platform files
├── macos/                        # macOS platform files
├── linux/                        # Linux platform files
└── pubspec.yaml                  # Dependencies
```

## 🔄 Integration với Backend

### Backend API Endpoints:

Frontend kết nối với backend tại `http://localhost:8080`:

- **Authentication**: `/api/auth/*`
- **Devices**: `/api/devices/*`
- **Dashboard**: `/api/dashboard/*`
- **Sensor Readings**: `/api/devices/{id}/readings`
- **Pump Control**: `/api/devices/{id}/pump/*`
- **Alerts**: `/api/devices/{id}/alerts`

### Backend chạy với Docker:

```bash
# Chạy backend (từ thư mục gốc)
docker compose up -d --build
```

Backend sẽ chạy tại `http://localhost:8080`

## 🚀 Triển Khai

### Deploy Backend + Frontend:

1. Backend chạy trên server (Docker/Local)
2. Frontend kết nối đến server URL
3. Build và deploy frontend app:
   - Android: Upload APK lên Google Play
   - iOS: Upload IPA lên App Store
   - Web: Deploy frontend/web/ to hosting

### Cấu hình API URL cho Production:

Thay đổi `API_BASE_URL` trong build hoặc runtime config.

## 📞 Support

Nếu gặp vấn đề:
1. Check `git status` để xem trạng thái
2. Check `git log` để xem lịch sử commit
3. Test backend với Swagger: `http://localhost:8080/swagger`
4. Test kết nối network giữa frontend và backend
5. Check Flutter logs với `flutter logs`