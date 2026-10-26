# F08 · Giới hạn và trạng thái bằng chứng

## 1. Những gì đã được kiểm tra

- Mô hình chuẩn Python và mô phỏng RTL có log PASS trong `05_VERIFICATION/`.
- RTL core tổng hợp được; README dự án công bố 101 cell và 15 flip-flop.
- Archive trong `06_GDSII/runs/RUN_2026-10-26_04-13-31/` có GDS, metrics
  post-route, DRC và LVS.

## 2. Những gì chưa được chứng minh

- Gate-level simulation và post-layout simulation có back-annotate SDF.
- Clock/tần số vận hành được yêu cầu bởi hệ thống tích hợp. Chu kỳ 10 ns trong
  SDC là giả định phân tích, không được diễn giải thành 100 MHz.
- Hành vi của động cơ, tầng công suất, nhiệt độ/cuộn dây, độ chính xác vị trí
  hoặc đáp ứng cơ điện.
- So sánh thực nghiệm giữa bảng ROM, logic giải mã và phương án one-hot.
- ASIC sign-off, tape-out, chế tạo hoặc kiểm tra sau chế tạo.

## 3. Khác biệt trạng thái cần chốt

README nguồn ghi P&R là chưa chạy, trong khi archive LibreLane hiện có các
artifact cuối GDS, routing, DRC và LVS của run `RUN_2026-10-26_04-13-31`.
Không sửa nội dung README nguồn theo yêu cầu; vì vậy báo cáo phân biệt trạng
thái trong README với archive đã lưu. Trước khi nộp, chủ dự án cần xác nhận
README mô tả lần chạy nào và cập nhật trạng thái bằng tay nếu cần.

Các con số 101 cell / 835,8016 µm² / 3,48 ns / 7.10e-05 W trong README và các
con số 148 standard-cell instances / 1362,56 µm² / 1,82346e-04 W trong metrics
archive thuộc các giai đoạn hoặc cấu hình báo cáo khác nhau. Không so sánh
trực tiếp diện tích hoặc công suất nếu chưa chuẩn hóa điểm đo, thư viện, PVT và
đầu vào.

## 4. Ngôn ngữ kết luận

Chỉ kết luận những gì bằng chứng tương ứng hỗ trợ. Có GDS/DRC/LVS trong archive
không đồng nghĩa thiết kế được sign-off, sẵn sàng sản xuất hay đã chế tạo.
