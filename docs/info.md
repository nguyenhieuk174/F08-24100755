# F08 — FSM điều khiển động cơ bước

## Thông tin dự án

| Trường | Giá trị |
|---|---|
| Tác giả | Nguyễn Xuân Hiếu · 24100755 |
| Mã đề | F08 |
| Mô tả | Đề F08 yêu cầu thiết kế FSM điều khiển động cơ bước, hướng đến ứng dụng điều khiển trục quay của máy in 3D mini. |
| Ngôn ngữ | Verilog |
| Kích thước Tiny Tapeout | 1×1 tile |
| Tần số clock khai báo | 0 Hz trong `info.yaml`; chưa có tần số mục tiêu được khai báo. |
| Top module khai báo | `tt_um_eee703128_24100755` |
| Source file khai báo | `project.v` |
| RTL core | `f08_stepper_ctrl` |

## Thiết kế này làm gì

RTL core điều khiển chuỗi kích cuộn cho động cơ bước. Mạch nhận `clk`, reset mức thấp `rst_n`, lệnh chạy `run`, chiều quay `dir`, chế độ `half_step` và bộ chia tốc độ `speed_div`; đầu ra gồm bốn tín hiệu cuộn dây `coil[3:0]` và trạng thái debug `state_dbg[2:0]`. Khi dừng, các đầu ra cuộn dây được đưa về 0.

## Cách hoạt động

FSM dùng chung một thanh ghi trạng thái 3 bit: chế độ nửa bước quay qua 8 trạng thái, còn chế độ bước đủ quay qua 4 trạng thái. `dir` chọn chiều tăng hoặc giảm trạng thái; bộ đếm `speed_div` tạo khoảng cách giữa các bước. Bộ giải mã pha ánh xạ trạng thái thành mẫu điều khiển bốn cuộn dây.

## Cách kiểm thử

Testbench kiểm tra reset, giới hạn trạng thái ở cả hai chế độ, quay vòng chuỗi bước, đảo chiều khi đang chạy và đầu ra cuộn dây khi dừng. Bản testbench dành cho GitHub Actions còn phát dòng `PASS` để workflow xác nhận kết quả mô phỏng.

## Kết quả RTL-to-GDS

Archive LibreLane/OpenROAD cho RTL core `f08_stepper_ctrl` có GDS và kết quả P&R, DRC, LVS. Metrics ghi nhận 148 standard-cell instances, 15 flip-flop, 0 route DRC errors và không có khác biệt LVS. Run ID và log nằm trong [`06_GDSII/`](../06_GDSII/).

## Ánh xạ chân

`tt_um_eee703128_24100755` dùng cấu hình chân sau:

| Nhóm chân | Ánh xạ |
|---|---|
| `ui[7:0]` | `speed_div[7:0]` |
| `uo[0:3]` | `coil[0:3]` |
| `uo[4:6]` | `state_dbg[0:2]` |
| `uo[7]` | không dùng |
| `uio[0]` | `dir` |
| `uio[1]` | `half_step` |
| `uio[2]` | `run` |
| `uio[3:7]` | không dùng |

## Giới hạn và trạng thái tích hợp

- `src/project.v` có wrapper `tt_um_eee703128_24100755` và ánh xạ các chân TinyTapeout sang RTL core; `clock_hz` vẫn để 0 vì chưa có tần số mục tiêu được chốt. Giá trị này không được thay bằng giả định 10 ns trong SDC.
- Tên top module trong `info.yaml` khớp với wrapper trong `src/project.v`; cần xác nhận quy ước `clock_hz` của luồng tích hợp trước khi dùng metadata cho build.
- Kết quả P&R/DRC/LVS là bằng chứng flow cho RTL core, không phải ASIC sign-off, tape-out, chế tạo hay kiểm tra sau chế tạo; gate-level/SDF simulation cũng chưa chạy.
