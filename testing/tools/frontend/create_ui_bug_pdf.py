import json
from pathlib import Path
from xml.sax.saxutils import escape

from reportlab.pdfgen import canvas
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import Paragraph
from reportlab.lib.styles import ParagraphStyle
from PIL import Image

ROOT = Path(__file__).resolve().parents[3]
SOURCE = ROOT / 'docs/testing/2026-10-19-ui'
OUT = ROOT / 'docs/testing/2026-10-19-ui/Bao_cao_loi_giao_dien_FE_2026-10-19.pdf'
OUT.parent.mkdir(parents=True, exist_ok=True)
DATA = json.loads((SOURCE / 'results.json').read_text(encoding='utf-8'))
assert (DATA['total'], DATA['passed'], DATA['failed']) == (33, 22, 11)

pdfmetrics.registerFont(TTFont('ArialVN', 'C:/Windows/Fonts/arial.ttf'))
pdfmetrics.registerFont(TTFont('ArialVN-Bold', 'C:/Windows/Fonts/arialbd.ttf'))
pdfmetrics.registerFontFamily('ArialVN', normal='ArialVN', bold='ArialVN-Bold', italic='ArialVN', boldItalic='ArialVN-Bold')
W, H = A4
M = 42
INK = colors.HexColor('#193D2A')
MUTED = colors.HexColor('#596D60')
GREEN = colors.HexColor('#39764F')
PALE = colors.HexColor('#EEF4ED')
RED = colors.HexColor('#AC3D3D')
C = canvas.Canvas(str(OUT), pagesize=A4)
C.setTitle('Báo cáo lỗi giao diện FE - IOTAgri - 19/10/2026')
C.setAuthor('IOTAgri - FE testing')

def para(text, y, size=10.5, leading=None, bold=False, color=INK, x=M, width=W-2*M, gap=8):
    style = ParagraphStyle('p', fontName='ArialVN-Bold' if bold else 'ArialVN', fontSize=size,
                           leading=leading or size*1.36, textColor=color)
    p = Paragraph(text, style)
    _, height = p.wrap(width, H)
    p.drawOn(C, x, y-height)
    return y-height-gap

def start(page, section):
    C.setFillColor(GREEN)
    C.rect(0, H-8, W, 8, fill=1, stroke=0)
    C.setFont('ArialVN-Bold', 9)
    C.drawString(M, H-34, 'AEROGREEN / IOTAGRI')
    C.setFont('ArialVN', 9)
    C.setFillColor(MUTED)
    C.drawRightString(W-M, H-34, section)
    C.setStrokeColor(colors.HexColor('#D8E3D8'))
    C.line(M, 43, W-M, 43)
    C.setFont('ArialVN', 8)
    C.drawString(M, 28, 'Kiểm thử ngày 19/10/2026 | Giờ Việt Nam')
    C.drawRightString(W-M, 28, f'{page} / 4')
    return H-61

def gallery(images, top, max_height=397):
    gap = 18
    col = (W-2*M-gap)/2
    bottom = top
    for index, (relative, caption) in enumerate(images):
        x = M+index*(col+gap)
        y = para(caption, top, size=9, bold=True, x=x, width=col, gap=7)
        path = SOURCE / relative
        with Image.open(path) as im:
            width, height = im.size
        scale = min((col-10)/width, max_height/height)
        iw, ih = width*scale, height*scale
        ix = x+(col-iw)/2
        C.setFillColor(colors.white)
        C.setStrokeColor(colors.HexColor('#D7DFD7'))
        C.roundRect(ix-2, y-ih-2, iw+4, ih+4, 5, fill=1, stroke=1)
        C.drawImage(str(path), ix, y-ih, width=iw, height=ih, preserveAspectRatio=True)
        bottom = min(bottom, y-ih)
    return bottom-14

y = start(1, 'TỔNG HỢP KẾT QUẢ')
y = para('Báo cáo lỗi giao diện FE', y, size=26, bold=True, gap=7)
y = para('3 lỗi đã xác minh, kèm ảnh minh họa và bước tái hiện', y, size=12, color=MUTED, gap=20)

box_h = 76
C.setFillColor(PALE)
C.roundRect(M, y-box_h, W-2*M, box_h, 12, fill=1, stroke=0)
for i, (number, label, tone) in enumerate([('33', 'Ca kiểm thử riêng biệt', INK), ('22', 'Ca đạt', GREEN), ('11', 'Ca chưa đạt', RED)]):
    x = M+20+i*(W-2*M)/3
    C.setFillColor(tone)
    C.setFont('ArialVN-Bold', 27)
    C.drawString(x, y-34, number)
    C.setFont('ArialVN', 9)
    C.drawString(x, y-57, label)
y -= box_h+18
y = para('Ma trận kiểm tra', y, size=13, bold=True)
row_h = 27
table = [('Kích thước', 'Đạt', 'Chưa đạt'), ('Mobile 390 x 844', '8 / 11', '3'), ('Mobile nhỏ 320 x 568', '6 / 11', '5'), ('Desktop 1280 x 900', '8 / 11', '3')]
for i, row in enumerate(table):
    C.setFillColor(PALE if i == 0 else colors.white)
    C.rect(M, y-row_h, W-2*M, row_h, fill=1, stroke=0)
    C.setFont('ArialVN-Bold' if i == 0 else 'ArialVN', 10)
    C.setFillColor(INK)
    for x, text in zip([M+12, M+310, M+403], row):
        C.drawString(x, y-18, text)
    y -= row_h
y -= 10
y = para('11 ca chưa đạt gồm 10 ca thất bại và 1 ca hết thời gian chờ. Nhiều ca cùng phát hiện một lỗi; không phải 11 lỗi khác nhau.', y, size=9.5, color=MUTED, gap=14)
for title, detail in [
    ('F-01 | Thiếu phản hồi khi đăng nhập lỗi', 'Sai thông tin hoặc mất kết nối nhưng không hiện thông báo. Ảnh và chi tiết ở trang 2.'),
    ('F-02 | Trang tài khoản bị cắt trên mobile nhỏ', 'Màn hình 320 x 568 không hiển thị nút Đăng xuất. Ảnh đối chiếu ở trang 3.'),
    ('F-03 | Dashboard chưa theo ngôn ngữ đã chọn', 'Chọn Tiếng Việt nhưng lời chào và tên vườn vẫn bằng tiếng Anh. Ảnh ở trang 4.'),
]:
    y = para(title, y, size=11, bold=True, gap=3)
    y = para(detail, y, size=10, gap=12)
y = para('Phạm vi và giới hạn', y, size=12, bold=True, gap=5)
y = para('Chrome chạy bản Flutter web với viewport mobile/desktop. Đăng nhập, dashboard và đăng xuất gọi BE thật; ca mất kết nối được mô phỏng bằng cách chặn request login. Đã thực thi 39 lượt cho 33 ca riêng biệt, gồm 6 lượt chụp lại sau loading/hoạt ảnh. Đây không phải test Android/iOS native hoặc thiết bị IoT thật.', y, size=9.5, gap=9)
y = para('Ghi chú từ lượt test tự động trước: flutter analyze có 1 cảnh báo biến r không dùng tại api_service.dart:509. Có 57/133 test cũ là placeholder; chúng chưa chứng minh chức năng hoạt động. Các điểm này không được tính vào 3 lỗi giao diện trên.', y, size=9, color=MUTED, gap=0)
assert y > 49, y
C.showPage()

y = start(2, 'F-01 / PHẢN HỒI ĐĂNG NHẬP')
y = para('Không hiện thông báo khi đăng nhập thất bại', y, size=19, bold=True, gap=6)
y = para('Ưu tiên đề xuất: cao | Tái hiện ở cả 3 kích thước | Ca UI-04, UI-09', y, size=9, color=RED, gap=10)
y = para('<b>Tái hiện:</b> Mở trang đăng nhập, nhập email/mật khẩu không đúng rồi bấm Đăng nhập. Với ca thứ hai, chặn request login để mô phỏng mất kết nối BE.', y, size=10, gap=6)
y = para('<b>Mong đợi:</b> Hiện thông báo rõ lý do để người dùng sửa thông tin hoặc thử lại.<br/><b>Thực tế:</b> BE trả HTTP 401 ở ca sai thông tin; cả hai ca đều không tìm thấy thông báo trên UI trong 12 giây.', y, size=10, gap=10)
y = gallery([
    ('screenshots/mobile-UI-04-01.png', 'Sai thông tin: BE trả HTTP 401'),
    ('screenshots/mobile-UI-09-01.png', 'Mất kết nối: request bị chặn có chủ đích'),
], y)
y = para('<b>Tác động:</b> Người dùng vẫn ở trang đăng nhập mà không biết vì sao thất bại.', y, size=9.5, gap=5)
y = para('<b>Nhận định kỹ thuật:</b> AuthController gán error trong catch, sau đó finally gọi copyWith(isLoading: false) có thể xóa error trước khi AuthScreen dựng SnackBar. Cần sửa và chạy lại để xác nhận. Vị trí: lib/providers/auth_controller.dart và lib/screens/auth_screen.dart.', y, size=9, color=MUTED, gap=0)
assert y > 49, y
C.showPage()

y = start(3, 'F-02 / BỐ CỤC MOBILE NHỎ')
y = para('Trang tài khoản bị cắt, không thấy nút Đăng xuất', y, size=19, bold=True, gap=6)
y = para('Ưu tiên đề xuất: cao trên mobile nhỏ | Viewport 320 x 568 | Ca UI-07, UI-08', y, size=9, color=RED, gap=10)
y = para('<b>Tái hiện:</b> Đăng nhập trên viewport 320 x 568, mở tab Khác, tìm nút Đăng xuất ở cuối trang.', y, size=10, gap=6)
y = para('<b>Mong đợi:</b> Xem và bấm được nút Đăng xuất; nội dung dài có thể cuộn.<br/><b>Thực tế:</b> Phần dưới trang bị cắt, nút không hiển thị. Ca đăng xuất hết thời gian chờ 45 giây do không tìm được nút.', y, size=10, gap=10)
y = gallery([
    ('screenshots/small-mobile-UI-07-01.png', '320 x 568: mất phần dưới và nút Đăng xuất'),
    ('screenshots/mobile-UI-07-01.png', '390 x 844: đối chiếu bố cục rộng hơn'),
], y)
y = para('<b>Tác động:</b> Người dùng trên màn hình nhỏ không thực hiện được luồng đăng xuất bằng giao diện.', y, size=9.5, gap=5)
y = para('<b>Hướng kiểm tra/sửa:</b> MoreScreen dùng Column cố định, chưa có cuộn cho toàn bộ nội dung. Xem lib/screens/more_screen.dart; điều chỉnh bố cục và kiểm tra lại khi bàn phím hoặc cỡ chữ làm giảm vùng hiển thị.', y, size=9, color=MUTED, gap=0)
assert y > 49, y
C.showPage()

y = start(4, 'F-03 / ĐỒNG BỘ NGÔN NGỮ')
y = para('Chọn Tiếng Việt nhưng dashboard vẫn có tiếng Anh', y, size=19, bold=True, gap=6)
y = para('Ưu tiên đề xuất: trung bình | Tái hiện ở cả 3 kích thước | Ca UI-11', y, size=9, color=RED, gap=10)
y = para('<b>Tái hiện:</b> Đăng nhập, vào Khác &gt; Tùy chỉnh; xác nhận Tiếng Việt đang được chọn, sau đó quay về Trang chủ.', y, size=10, gap=6)
y = para('<b>Mong đợi:</b> Dashboard hiển thị lời chào và tên vườn bằng tiếng Việt.<br/><b>Thực tế:</b> Vẫn xuất hiện "Good morning" và "UI\'s Garden", trong khi các nhãn khác là tiếng Việt.', y, size=10, gap=10)
y = gallery([
    ('screenshots/mobile-UI-11-01.png', 'Cài đặt: Tiếng Việt đang được chọn'),
    ('screenshots/mobile-UI-11-02.png', 'Dashboard: lời chào và tên vườn bằng tiếng Anh'),
], y)
y = para('<b>Tác động:</b> Giao diện trộn ngôn ngữ, lựa chọn của người dùng chưa được áp dụng nhất quán.', y, size=9.5, gap=5)
y = para('<b>Nhận định kỹ thuật:</b> app.dart truyền locale nhưng chưa khai báo hỗ trợ tiếng Việt; HomeScreen đọc Localizations.localeOf, còn thanh điều hướng đọc AppSettingsProvider. Hai nguồn locale có thể lệch nhau. Cần đồng bộ và chạy lại ca UI-11.', y, size=9, color=MUTED, gap=0)
assert y > 49, y
C.save()
print(str(OUT))
