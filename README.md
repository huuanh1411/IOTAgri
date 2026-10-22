# Aerogreen Website

Website giới thiệu Aerogreen, bán thiết bị phần cứng và gói refill rau ăn.
README này dành cho website trên nhánh `Website`.

## Chức năng

- Giới thiệu sản phẩm, giải pháp và đội ngũ.
- Điều hướng cố định ở đầu màn hình khi cuộn trang.
- Đăng ký, đăng nhập và xem lịch sử đơn hàng.
- Chọn thiết bị hoặc gói refill, số lượng và địa chỉ nhận hàng.
- Thanh toán một lần qua MoMo; theo dõi trạng thái thanh toán và giao hàng.
- Quản trị danh mục, giá, gói nhiều chu kỳ và trạng thái giao hàng.

## Công nghệ

| Thành phần | Công nghệ |
| --- | --- |
| Giao diện | React 18, TypeScript, Vite 6 |
| CSS và icon | Tailwind CSS 3, Lucide React |
| Backend | ASP.NET Core 10, C# |
| Cơ sở dữ liệu | PostgreSQL 17, Entity Framework Core |
| Tài khoản | ASP.NET Core Identity, JWT access/refresh token |
| Thanh toán | MoMo `captureWallet`, xác minh kết quả qua IPN |

Frontend gọi API; backend chịu trách nhiệm tính tiền và lưu đơn hàng.

## Sản phẩm và cách bán

| Sản phẩm | Giá khởi tạo | Nội dung |
| --- | --- | --- |
| Thiết bị Aerogreen | 2.950.000đ | Bộ thiết bị Aerogreen |
| Gói rau ăn 1 chu kỳ | 299.000đ | Cây con và dung dịch dinh dưỡng |
| Gói nhiều chu kỳ | Admin cấu hình | Số chu kỳ, vật tư và giá của toàn gói |

Toàn bộ thiết bị và vật tư trong đơn được giao một lần. Gói refill được thanh toán
trước, không tự động gia hạn hoặc trừ tiền định kỳ. Thông tin gói và giá được lưu
theo thời điểm tạo đơn; thay đổi danh mục không làm đổi đơn đã tạo.

Phí giao hàng cấu hình bằng `STORE_SHIPPING_FEE_VND`, mặc định **0đ**.

## Chạy website bằng Docker

Yêu cầu Docker Desktop đang chạy với Linux containers. Thực hiện từ thư mục gốc repo.

### 1. Tạo cấu hình local

```powershell
if (-not (Test-Path .env)) { Copy-Item .env.example .env }
```

Chỉnh các giá trị trong `.env`:

| Biến | Mục đích |
| --- | --- |
| `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD` | Database của website |
| `POSTGRES_PORT` | Cổng PostgreSQL trên máy, mặc định 5432 |
| `JWT_KEY` | Khóa ký token, ít nhất 32 ký tự |
| `ADMIN_BOOTSTRAP_EMAIL`, `ADMIN_BOOTSTRAP_PASSWORD` | Tài khoản admin được tạo khi backend khởi động |
| `ADMIN_BOOTSTRAP_FULL_NAME` | Tên hiển thị admin |
| `API_PORT` | Cổng backend, mặc định 8080 |
| `WEBSITE_PORT` | Cổng website Docker, mặc định 5180 |
| `STORE_SHIPPING_FEE_VND` | Phí giao hàng cố định |
| `PGADMIN_DEFAULT_EMAIL`, `PGADMIN_DEFAULT_PASSWORD` | Cần có để Compose đọc cấu hình gốc; không khởi động pgAdmin trong lệnh bên dưới |

Giữ các biến hạ tầng còn lại từ file mẫu. Backend hiện có phụ thuộc service
`mosquitto`; Compose tự khởi động dependency này khi chạy website.

### 2. Khởi động

```powershell
docker compose -p aerogreen-website-local -f compose.yaml -f compose.website.yaml up -d --build website
```

Lệnh chỉ chạy website và các dependency cần thiết. Backend tự áp dụng migration
và khởi tạo danh mục khi chạy lần đầu.

Mở **http://127.0.0.1:5180/**, hoặc cổng đã đặt trong `WEBSITE_PORT`.
Đăng nhập bằng tài khoản admin cấu hình trong `.env`.

### 3. Kiểm tra và dừng

```powershell
docker compose -p aerogreen-website-local -f compose.yaml -f compose.website.yaml ps
docker compose -p aerogreen-website-local -f compose.yaml -f compose.website.yaml logs --tail 100 website api
docker compose -p aerogreen-website-local -f compose.yaml -f compose.website.yaml stop
```

Dừng service không xóa dữ liệu database.

## Phát triển giao diện với Vite

Chạy backend và database:

```powershell
docker compose -p aerogreen-website-local -f compose.yaml -f compose.website.yaml up -d --build api
```

Mở terminal khác từ thư mục gốc repo:

```powershell
cd website
npm ci
npm run dev
```

Mở **http://localhost:5173/**. Vite mặc định proxy `/api` đến
`http://localhost:8080`.

Nếu đổi `API_PORT` thành 5088, đặt proxy tương ứng trước khi chạy Vite:

```powershell
$env:API_PROXY_TARGET = "http://127.0.0.1:5088"
npm run dev
```

Dùng `Ctrl+C` trong terminal Vite để dừng giao diện.

## Thanh toán MoMo

Mặc định thanh toán **chưa mở**. Website vẫn hiển thị sản phẩm và cho đăng nhập;
tạo đơn và thanh toán chỉ hoạt động khi cấu hình MoMo đầy đủ.

Thêm vào `.env`:

```dotenv
MOMO_ENABLED=true
MOMO_PARTNER_CODE=<merchant-partner-code>
MOMO_ACCESS_KEY=<merchant-access-key>
MOMO_SECRET_KEY=<merchant-secret-key>
MOMO_ENDPOINT=https://test-payment.momo.vn/v2/gateway/api/create
MOMO_REDIRECT_URL=https://<website-domain>/
MOMO_IPN_URL=https://<api-domain>/api/store/payments/momo/ipn
```

Khởi động lại service `api` sau khi đổi cấu hình. Khóa merchant chỉ dùng ở backend.
Cần kiểm thử sandbox với bộ khóa MoMo và URL IPN HTTPS công khai trước khi mở bán.

Xem [tài liệu kỹ thuật website](website/README.md) để biết luồng xác minh thanh toán,
các API và cấu hình production.

## Cấu trúc source liên quan đến website

```text
website/                  Giao diện React, assets, cấu hình Vite và Nginx
backend/Endpoints/        API tài khoản, danh mục, đơn hàng và thanh toán
backend/Models/           Model dữ liệu
backend/Data/             DbContext và cấu hình dữ liệu
backend/Migrations/       Migration PostgreSQL
backend/Services/         Nghiệp vụ đơn hàng và tích hợp MoMo
backend/tests/            Kiểm thử backend
compose.website.yaml      Cấu hình chạy website bằng Docker
```

## Kiểm tra source

Từ thư mục gốc:

```powershell
npm --prefix website run build
dotnet test backend/tests/IOTAgriBackend.Tests.csproj
```

Build frontend cần Node.js 22 và dependency đã cài. Kiểm thử backend cần .NET SDK 10;
các bài integration PostgreSQL cần Docker đang chạy.

## Lưu ý khi triển khai

- Cấu hình HTTPS cho domain website và API; Compose local không tự xuất bản website.
- Chốt giá các gói nhiều chu kỳ và phí giao hàng trước khi mở bán.
- Chưa có quản lý tồn kho, mã giảm giá, hóa đơn điện tử, hoàn tiền tự động
  hoặc tích hợp hãng vận chuyển.
- Không commit `.env`, khóa MoMo, dữ liệu khách hàng, `node_modules` hoặc bản build.

## Xử lý lỗi thường gặp

| Hiện tượng | Cách kiểm tra |
| --- | --- |
| Docker chưa sẵn sàng | Mở Docker Desktop và chờ engine chạy |
| Cổng bị chiếm | Đổi cổng trong `.env`; nếu dùng Vite, cập nhật `API_PROXY_TARGET` theo backend |
| Không tải được sản phẩm | Kiểm tra service `api`, log và `/api/store/products` |
| Không kết nối được DB sau khi đổi mật khẩu | Volume cũ giữ mật khẩu đã khởi tạo; dùng lại cấu hình đúng của database |
| Nút thanh toán chưa mở | Kiểm tra cấu hình merchant MoMo, redirect và IPN HTTPS |
| Giá đổi khi đặt hàng | Tải lại danh mục để xác nhận tổng tiền mới |
