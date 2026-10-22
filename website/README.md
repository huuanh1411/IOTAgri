# Aerogreen Storefront

Website giới thiệu và bán thiết bị/refill. React 18 + TypeScript + Vite + Tailwind,
dùng backend ASP.NET Core 10, PostgreSQL và tài khoản Identity chung với app Flutter.
Không sử dụng Express/SQLite, không có giao diện giám sát hoặc điều khiển IoT.

## Chạy local

1. Chạy PostgreSQL và backend theo README gốc. Backend có migration `AddStoreCommerce`,
   được áp dụng cùng các migration hiện có khi khởi động. Luôn sao lưu DB thật trước triển khai.
2. Trong `website/`, chạy `npm ci` rồi `npm run dev`.
3. Mở http://localhost:5173. Vite proxy `/api` đến http://localhost:8080.
   Đổi biến môi trường shell `API_PROXY_TARGET` nếu API chạy cổng khác.
4. `npm run build` để kiểm tra TypeScript và tạo bản production.

FE mặc định gọi `/api` cùng origin. `VITE_API_BASE_URL` chỉ cần khi API ở origin khác;
khi đó cấu hình `Cors:AllowedOrigins` ở backend cho đúng origin website.
Tài khoản, mật khẩu và phân quyền dùng chung app; không tạo admin mặc định riêng.
Google Sign-In của website cũ đã bỏ vì backend app chưa có API tương ứng.

## Danh mục và cách bán

- Thiết bị Aerogreen: 2.950.000đ, giữ giá trong source cũ.
- Refill rau ăn 1 chu kỳ: 299.000đ, gồm cây con và dung dịch dinh dưỡng.
- Gói nhiều chu kỳ: admin tạo qua **Quản lý cửa hàng** hoặc API. Giá và vật tư phải
  do chủ cửa hàng cấu hình; không tự suy ra giảm giá hoặc các vật tư chưa được xác nhận.
- `contents` của một gói mô tả toàn bộ vật tư giao. `cycleCount` là số chu kỳ
  của một gói; mua 2 gói 3 chu kỳ nghĩa là 6 chu kỳ vật tư tổng cộng.
- Toàn bộ vật tư được giao một lần. Không có lịch giao theo chu kỳ, gia hạn tự động
  hoặc tự động trừ tiền. Không liên kết việc mua hàng với quyền điều khiển thiết bị.
- Phí giao hàng cố định lấy từ `Store:ShippingFeeVnd`, mặc định **0đ**; cần chốt
  chính sách vận chuyển trước mở bán. FE hiển thị phí và server lưu phí theo từng đơn.
- Đây là bán theo danh mục, chưa có quản lý tồn kho/reservation, mã giảm giá, hóa đơn
  điện tử, hoàn tiền tự động, tích hợp hãng vận chuyển hoặc tự cấp thiết bị vào app.

## MoMo

Backend dùng thanh toán một lần `captureWallet` theo tài liệu chính thức:
https://developers.momo.vn/v3/docs/payment/api/wallet/onetime/
https://developers.momo.vn/v3/docs/payment/api/result-handling/notification/

Đặt các biến môi trường của **backend**, không đặt khóa bí mật trong Vite/FE:

```env
Momo__Enabled=true
Momo__PartnerCode=<merchant partner code>
Momo__AccessKey=<merchant access key>
Momo__SecretKey=<merchant secret key>
Momo__Endpoint=https://test-payment.momo.vn/v2/gateway/api/create
Momo__RedirectUrl=https://<website-domain>/
Momo__IpnUrl=https://<api-domain>/api/store/payments/momo/ipn
Store__ShippingFeeVnd=0
```

Khi dùng `compose.website.yaml`, tên biến `.env` tương ứng là `MOMO_ENABLED`,
`MOMO_PARTNER_CODE`, `MOMO_ACCESS_KEY`, `MOMO_SECRET_KEY`, `MOMO_ENDPOINT`,
`MOMO_REDIRECT_URL`, `MOMO_IPN_URL`, `STORE_SHIPPING_FEE_VND`, `WEBSITE_PORT`.
Backend mặc định tắt thanh toán. Khi thiếu cấu hình, website vẫn tải danh mục nhưng
không cho tạo đơn/thanh toán. Merchant sandbox và production dùng bộ khóa riêng;
production đổi endpoint sang `https://payment.momo.vn/v2/gateway/api/create`.
Redirect/IPN phải là HTTPS và IPN phải truy cập được từ MoMo. Không dùng ngrok hoặc
public tunnel tự động. Tự cấu hình domain/reverse proxy theo hạ tầng đang dùng.

Server tính tiền từ danh mục, đối chiếu tổng tiền khách đã thấy, lưu snapshot sản phẩm,
số chu kỳ, vật tư và giá. Mỗi order có một giao dịch MoMo với ID cố định; việc bấm lại
không tạo thêm giao dịch. Chỉ IPN có HMAC hợp lệ và khớp merchant, số tiền, order ID,
request ID, order info mới xác nhận đã thanh toán. Redirect trình duyệt chỉ mở màn
hình trạng thái, không xác nhận thanh toán. `9000` chưa được coi là đã thu tiền.
Thông báo trùng không làm giao hàng lặp; callback thất bại không hạ trạng thái đã trả.

Nếu MoMo timeout sau khi nhận yêu cầu, giữ nguyên giao dịch; không đổi ID để thử thu
tiền lần nữa. Kiểm tra trạng thái đơn/IPN và đối soát merchant trước khi tạo đơn mới.
Chưa có job tự động query/đối soát hoặc hoàn tiền MoMo. Cần kiểm thử sandbox với
merchant thật, callback công khai, thanh toán thành công/hủy/thất bại và đối soát
trước mở bán. Bộ kiểm thử local dùng gateway giả, không phát sinh tiền thật.

## API

| Method | Route | Quyền / mục đích |
|---|---|---|
| GET | `/api/store/products` | Công khai: danh mục, khả năng thanh toán, phí giao hàng |
| POST | `/api/store/orders` | User: `checkoutKey` UUID, `customerName`, `phone`, `address`, `expectedTotalVnd`, `items: [{productId, quantity}]` |
| GET | `/api/store/orders?page=1` | User: chỉ đơn của mình, 20 đơn/trang |
| GET | `/api/store/orders/{id}` | User: chi tiết đơn thuộc tài khoản |
| POST | `/api/store/orders/{id}/payment` | User: lấy/reuse `payUrl` MoMo |
| POST | `/api/store/payments/momo/ipn` | MoMo: xác minh chữ ký, cập nhật giao dịch |
| GET | `/api/admin/store/products` | Admin: danh mục kể cả ẩn |
| PUT | `/api/admin/store/products/{id}` | Admin: tạo/cập nhật theo UUID, body `sku,name,kind,cycleCount,contents,priceVnd,isActive` |
| GET | `/api/admin/store/orders?page=1` | Admin: đơn hàng |
| PUT | `/api/admin/store/orders/{id}/fulfillment` | Admin: `status`, `trackingNumber`; chỉ `unfulfilled → shipping → delivered` khi đã trả tiền |

Trạng thái thanh toán: `pending`, `paid`, `failed`, tách khỏi trạng thái giao hàng.
Danh mục/đơn hàng mới nằm ở các bảng `StoreProducts`, `StoreOrders`, `StoreOrderItems`,
`StorePayments`, không sửa dữ liệu cảm biến hoặc bảng Identity hiện có.

## Docker tùy chọn

Từ repo root, với `.env` đã cấu hình:

```powershell
docker compose -f compose.yaml -f compose.website.yaml up -d --build
```

Website ở http://localhost:5180; app Flutter giữ cấu hình cũ. Nginx của website proxy
`/api` sang service `api`. Production cần thêm reverse proxy HTTPS cho domain website;
overlay không tự thay Caddyfile hoặc domain của app đang chạy.

## Kiểm tra

```powershell
npm run build
# từ repo root; Integration cần Docker đang chạy
dotnet test backend/tests/IOTAgriBackend.Tests.csproj
```

Không commit `.env`, khóa MoMo, `node_modules`, `dist`, DB local hay dữ liệu khách hàng.

### Kết quả kiểm tra local (22/10/2026)

- Toàn bộ 139 kiểm thử backend đã qua, bao gồm PostgreSQL dùng container riêng.
- 11 kiểm thử riêng cho commerce đã được chạy lại sau chỉnh sửa cuối của backend.
- Migration mới khớp model, không có thay đổi model chưa được migration bao phủ.
- Frontend TypeScript/Vite build thành công; image Docker build độc lập thành công.
- Compose overlay hợp lệ. Không có commit/push hoặc thay đổi DB production.
- Chưa kiểm thử trực quan trên trình duyệt vì phiên làm việc không có browser khả dụng.
- Chưa kiểm thử merchant MoMo sandbox/thật vì chưa cấu hình bộ khóa và URL IPN công khai.
- Đã cập nhật bản vá Vite trong dải 6.x. `npm audit --offline=false` còn 7 cảnh báo
  (5 high, 2 moderate) trong chuỗi dependency **dev/build của Tailwind 3**. npm đề xuất
  Tailwind 4 để loại hết các cảnh báo này; chưa tự chuyển major vì cần kiểm tra lại
  giao diện trên trình duyệt. Image phục vụ production chỉ chứa Nginx và static assets,
  không chứa node_modules hoặc Vite/Tailwind dev server.
- `graphify update .` chưa chạy được vì máy không có lệnh graphify; repo không có graph sẵn.
