import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/models/help_item.dart';

class HelpData {
  static const List<HelpItem> helpItems = [
    HelpItem(
      id: 'post_guide',
      title: 'Hướng dẫn đăng bài chi tiết',
      description: '''📌 CÁCH ĐĂNG BÀI HIỆU QUẢ:

1️⃣ CHỌN LOẠI BÀI:
• 🎁 Tặng đồ: Cho đi đồ không dùng nữa
• 🔍 Tìm đồ thất lạc: Đồ bạn đánh mất
• 📌 Đồ nhặt được: Đồ bạn tìm thấy
• 🙏 Cần nhận đồ: Đồ bạn muốn xin
• ✏️ Bài viết tự do: Chia sẻ thông tin

2️⃣ THÔNG TIN CƠ BẢN:
• Tiêu đề: Ngắn gọn, rõ ràng (10-100 ký tự)
• Mô tả: Chi tiết tình trạng, đặc điểm (tối thiểu 20 ký tự)
• Ảnh: Tối đa 4 ảnh (≤5MB/ảnh), chụp rõ nét

3️⃣ THÔNG TIN BỔ SUNG:
• 📍 Địa điểm: Nơi mất/tìm/thường xuyên gặp
• 🕒 Thời gian: Khoảng thời gian liên quan
• 🏷️ Danh mục: Chọn đúng loại đồ
• 🔢 Số lượng: Khai báo chính xác

⚠️ LƯU Ý QUAN TRỌNG:
• KHÔNG đăng thông tin cá nhân nhạy cảm
• KHÔNG đăng đồ cấm/chất gây nghiện
• Mô tả TRUNG THỰC tình trạng đồ
• Kiểm tra kỹ trước khi đăng

⏳ QUY TRÌNH KIỂM DUYỆT:
• Bài đăng sẽ được xét duyệt trong 24h
• Bài vi phạm sẽ bị xóa không báo trước
• Cập nhật trạng thái khi đồ đã được tặng/nhận

📞 HỖ TRỢ:
Liên hệ quản trị viên nếu cần giúp đỡ thêm!''',
      icon: Icons.help_center_rounded,
      iconColor: Colors.blueAccent,
    ),
    HelpItem(
      id: 'post_actions',
      title: 'Hướng dẫn thao tác với bài đăng',
      description: '''📌 CÁC THAO TÁC VỚI BÀI ĐĂNG CỦA BẠN:

1️⃣ MÀN HÌNH CHI TIẾT BÀI ĐĂNG VÀ LỊCH SỬ BÀI ĐĂNG:
• ✏️ Chỉnh sửa bài đăng (nếu chưa bị khóa)
• 🗑️ Xóa bài đăng (nếu chưa có người quan tâm)
• 🔒 Khóa/Mở khóa bài đăng
• 📌 Ghim lại bài đăng (sau 7 ngày)

2️⃣ CÁC TRẠNG THÁI BÀI ĐĂNG:
• ✅ Đã duyệt: Bài đang hiển thị công khai
• 🔒 Bị khóa: Bài đăng tạm ẩn với người khác
• ⌛ Chờ duyệt: Bài đang chờ admin xét duyệt
• ❌ Từ chối: Bài vi phạm quy định

4️3️⃣ THAO TÁC QUAN TRỌNG:
• 🔄 GHIM LẠI:
  - Chỉ được thực hiện sau 7 ngày từ lần đăng cuối
  - Đưa bài đăng lên đầu danh sách
  - Mỗi bài chỉ được ghim tối đa 3 lần

• 🔒 KHÓA BÀI:
  - Không cho phép bài đăng được quan tâm
  - Vẫn hiển thị trong phần bài đăng của bạn
  - Có thể mở khóa bất kỳ lúc nào

• 🗑️ XÓA BÀI:
  - Xóa vĩnh viễn bài đăng
  - Không thể khôi phục sau khi xóa
  - Không thể xóa nếu đã có người quan tâm

⚠️ LƯU Ý:
- Thao tác khóa/ghim/xóa có thể mất vài giây để xử lý
- Liên hệ admin nếu thao tác không thành công sau 1 phút''',
      icon: Icons.touch_app,
      iconColor: Colors.purpleAccent,
    ),
    HelpItem(
      id: 'trading_process',
      title: 'Hướng dẫn trao đổi và giao dịch',
      description: '''📌 QUY TRÌNH TRAO ĐỔI ĐỒ GIỮA SINH VIÊN:

1️⃣ QUAN TÂM BÀI ĐĂNG:
• Nhấn "Quan tâm" để bày tỏ mong muốn nhận/trao đổi đồ
• Hệ thống tự động tạo phòng trò chuyện riêng
• Truy cập mục "Quan tâm" để xem các cuộc trò chuyện

2️⃣ QUYỀN HẠN CÁC BÊN:
• 🙋 Người quan tâm (không phải chủ bài):
  - Gửi tin nhắn trao đổi
  - Gửi yêu cầu giao dịch chính thức
  - Theo dõi trạng thái giao dịch

• ✍️ Chủ bài đăng:
  - Xem xét yêu cầu
  - Chỉnh sửa điều kiện giao dịch
  - Từ chối/Chấp nhận yêu cầu
  - Xác nhận hoàn tất giao dịch

3️⃣ QUY TRÌNH GIAO DỊCH:
1. Người quan tâm gửi yêu cầu
2. Chủ bài xem xét và phản hồi
3. Hai bên thống nhất điều kiện
4. Thực hiện trao đổi trực tiếp
5. Chủ bài xác nhận hoàn tất

4️⃣ QUẢN LÝ ĐIỂM:
• 💯 Điểm chỉ được cộng khi:
  - Cả hai bên xác nhận hoàn tất
  - Giao dịch thực sự diễn ra

• 🔄 Hoàn tác giao dịch:
  - Thực hiện khi giao dịch thất bại
  - Điểm sẽ bị hoàn lại nếu đã cộng

⚠️ LƯU Ý QUAN TRỌNG:
- CHỈ hoàn tất giao dịch khi đã trao đổi thành công
- Kiểm tra kỹ đồ trước khi xác nhận
- Giữ liên lạc với đối phương qua chat
- Báo cáo ngay nếu có vấn đề phát sinh''',
      icon: Icons.swap_horiz,
      iconColor: Colors.green,
    ),
    HelpItem(
      id: 'warehouse_claim_process',
      title: 'Quy trình nhận đồ từ kho đồ cũ',
      description: '''📌 CÁCH NHẬN ĐỒ TỪ KHO ĐỒ CŨ:

1️⃣ CHỌN ĐỒ CẦN NHẬN:
• Duyệt danh sách đồ có sẵn trong kho
• Chọn đồ phù hợp với nhu cầu
• Kiểm tra số lượng còn lại và giới hạn nhận

2️⃣ THÊM VÀO GIỎ ĐỒ:
• Nhấn "Thêm" để chọn số lượng muốn nhận
• Số lượng tối đa = MIN(số lượng còn lại, giới hạn nhận)
• Có thể chỉnh sửa số lượng trong giỏ đồ

3️⃣ GỬI YÊU CẦU NHẬN:
• Xem lại các món đồ đã chọn
• Nhấn "Xác nhận" để gửi yêu cầu
• Hệ thống sẽ gửi yêu cầu đến quản trị viên

4️⃣ CHỜ XÉT DUYỆT:
• Yêu cầu sẽ được xét trong vòng 24-48h
• Kiểm tra trạng thái trong mục "Danh sách yêu cầu"
• Nhận thông báo khi yêu cầu được duyệt/từ chối

5️⃣ NHẬN LỊCH HẸN:
• Khi yêu cầu được duyệt, hệ thống sẽ gửi lịch hẹn
• Xem lịch hẹn trong thông báo hoặc mục "Danh sách cuộc hẹn"

6️⃣ ĐẾN NHẬN ĐỒ:
• Mang theo thẻ sinh viên khi đến nhận
• Đến đúng địa chỉ và thời gian trong lịch hẹn
• Xuất trình mã yêu cầu cho quản trị viên

⚠️ LƯU Ý QUAN TRỌNG:
- Mỗi yêu cầu chỉ được duyệt 1 lần
- Không đến nhận đồ khi chưa có lịch hẹn
- Nếu không đến đúng hẹn, yêu cầu sẽ bị hủy
- Liên hệ quản trị viên nếu cần hủy/đổi lịch hẹn''',
      icon: Icons.warehouse_outlined,
      iconColor: Colors.orange,
    ),
  ];
}
