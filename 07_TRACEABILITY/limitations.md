# F08 · Giới hạn và trạng thái bằng chứng

## 1. Những gì đã được kiểm tra

- Mô hình chuẩn Python và mô phỏng RTL có log PASS trong `05_VERIFICATION/`.
- RTL core tổng hợp được; README dự án công bố 101 cell và 15 flip-flop.
- Archive mới nhất trong `06_GDSII/runs/RUN_2026-10-26_05-07-08/` có GDS,
  metrics post-route, SPEF/SDF, DRC và LVS; archive trước được giữ để đối chiếu.

## 2. Những gì chưa được chứng minh

- Gate-level simulation và post-layout simulation có back-annotate SDF.
- Clock/tần số vận hành được yêu cầu bởi hệ thống tích hợp. Chu kỳ 10 ns trong
  SDC là giả định phân tích, không được diễn giải thành 100 MHz.
- Hành vi của động cơ, tầng công suất, nhiệt độ/cuộn dây, độ chính xác vị trí
  hoặc đáp ứng cơ điện.
- So sánh thực nghiệm giữa bảng ROM, logic giải mã và phương án one-hot.
- ASIC sign-off, tape-out, chế tạo hoặc kiểm tra sau chế tạo.
