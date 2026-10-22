# Aerogreen Storefront

Website giới thiệu và bán thiết bị/refill. React 18 + TypeScript + Vite + Tailwind,
dùng backend ASP.NET Core 10, PostgreSQL và ASP.NET Core Identity cho tài khoản.

Xem [README ở thư mục gốc](../README.md) để cấu hình và chạy đầy đủ website bằng Docker.

## Chạy local

1. Chạy PostgreSQL và backend theo README gốc. Backend có migration `AddStoreCommerce`,
   được áp dụng cùng các migration hiện có khi khởi động. Luôn sao lưu DB thật trước triển khai.
2. Trong `website/`, chạy `npm ci` rồi `npm run dev`.
3. Mở http://localhost:5173. Vite proxy `/api` đến http://localhost:8080.
   Đổi biến môi trường shell `API_PROXY_TARGET` nếu API chạy cổng khác.
4. `npm run build` để kiểm tra TypeScript và tạo bản production.

FE mặc định gọi `/api` cùng origin. `VITE_API_BASE_URL` chỉ cần khi API ở origin khác;
khi đó cấu hình `Cors:AllowedOrigins` ở backend cho đúng origin website.
Đăng nhập bằng email/mật khẩu. Admin được tạo từ cấu hình `ADMIN_BOOTSTRAP_*`
khi backend khởi động; website không có tài khoản admin mặc định cố định.

## Danh mục và cách bán

- Thiết bị Aerogreen: 2.950.000đ, giữ giá trong source cũ.
- Refill rau ăn 1 chu kỳ: 299.000đ, gồm cây con và dung dịch dinh dưỡng.
- Gói nhiều chu kỳ: admin tạo qua **Quản lý cửa hàng** hoặc API. Giá và vật tư phải
  do chủ cửa hàng cấu hình; không tự suy ra giảm giá hoặc các vật tư chưa được xác nhận.
- `contents` của một gói mô tả toàn bộ vật tư giao. `cycleCount` là số chu kỳ
  của một gói; mua 2 gói 3 chu kỳ nghĩa là 6 chu kỳ vật tư tổng cộng.
- Toàn bộ vật tư được giao một lần. Không có lịch giao theo chu kỳ, gia hạn tự động
  hoặc tự động trừ tiền.
- Phí giao hàng cố định lấy từ `Store:ShippingFeeVnd`, mặc định **0đ**; cần chốt
  chính sách vận chuyển trước mở bán. FE hiển thị phí và server lưu phí theo từng đơn.
- Đây là bán theo danh mục, chưa có quản lý tồn kho/reservation, mã giảm giá, hóa đơn
  điện tử, hoàn tiền tự động hoặc tích hợp hãng vận chuyển.

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
Redirect/IPN phải là HTTPS và IPN phải truy cập được từ MoMo.
Cấu hình domain/reverse proxy theo hạ tầng triển khai.

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
`StorePayments`. Tài khoản được quản lý bằng ASP.NET Core Identity.

## Docker tùy chọn

Từ repo root, với `.env` đã cấu hình:

```powershell
docker compose -p aerogreen-website-local -f compose.yaml -f compose.website.yaml up -d --build website
```

Website ở http://localhost:5180. Nginx của website proxy `/api` sang service `api`.
Production cần reverse proxy HTTPS cho domain website;
overlay không tự thay cấu hình domain đang triển khai.

## Kiểm tra

```powershell
# Từ repo root; frontend cần npm ci trong website/ trước đó.
npm --prefix website run build
# Integration cần Docker đang chạy.
dotnet test backend/tests/IOTAgriBackend.Tests.csproj
```

Không commit `.env`, khóa MoMo, `node_modules`, `dist`, DB local hay dữ liệu khách hàng.

### Kiểm thử và các giới hạn

- Kiểm thử commerce bao gồm tính tiền từ danh mục, giữ snapshot đơn hàng, chống tạo
  đơn trùng, phân quyền xem đơn, tái sử dụng link thanh toán và xác minh IPN.
- Kiểm thử PostgreSQL tạo container riêng, không dùng database khách hàng.
- Cần kiểm thử merchant MoMo sandbox với bộ khóa và URL IPN của môi trường triển khai.
- Kiểm tra dependency bằng `npm audit --offline=false` trong `website/`.
  Lần kiểm tra ngày 22/10/2026 ghi nhận 7 cảnh báo (5 high, 2 moderate) trong chuỗi
  dependency dev/build của Tailwind 3. Việc nâng Tailwind 4 cần kiểm tra lại giao diện.
  Image production chỉ chứa Nginx và static assets, không chứa Vite/Tailwind dev server.
