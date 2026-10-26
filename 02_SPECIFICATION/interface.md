# F08 · Giao diện (Interface)

---

## 1. Ánh xạ chân theo Charter (mục 4)

> Theo danh mục đề: uio_in[0]=chiều · uio_in[1]=nửa bước · uio_in[2]=chạy · uo_out[3:0]=bốn pha · uo_out[6:4]=vị trí trong chuỗi
> Ngân sách chân: 3 bit vào + 7 bit ra = 10 trên 24 chân.
> Ánh xạ chân đã khả thi, không phải đổi gì.
> Một ô Tiny Tapeout có đúng 24 chân: ui_in 8 chỉ vào, uo_out 8 chỉ ra, uio 8 chọn chiều từng chân. uio_in và uio_out là cùng một bộ chân vật lý.

## 2. Bảng giao diện đã CHỐT — module `f08_stepper_ctrl`

Bảng dưới đây **đọc trực tiếp từ RTL** (`04_IMPLEMENTATION/rtl/`), không phải chép tay,
nên luôn nhất quán với mã nguồn.

| Tín hiệu | Chiều | Độ rộng (bit) | Vai trò | Mức tích cực / giả định |
|---|---|---:|---|---|
| `clk` | input | 1 | clock | |
| `rst_n` | input | 1 | reset (đồng bộ hoá trạng thái) | |
| `run` | input | 1 | dữ liệu vào | |
| `dir` | input | 1 | dữ liệu vào | |
| `half_step` | input | 1 | dữ liệu vào | |
| `speed_div[SPEED_DIV_W-1:0]` | input | ? | dữ liệu vào | |
| `coil[3:0]` | output | 4 | kết quả ra | |
| `state_dbg[2:0]` | output | 3 | kết quả ra | |

**Tổng hợp:** 6 cổng vào (5 bit) · 2 cổng ra (7 bit).

**Clock:** `clk`

**Reset:** `rst_n`

## 3. Ngân sách chân Tiny Tapeout

| Hạng mục | Số bit |
|---|---:|
| Tổng bit vào | **5** |
| Tổng bit ra | **7** |
| **Tổng cộng** | **12** |
| Ô Tiny Tapeout có | **24** |
| **Chênh lệch** | **12 chân còn dư** |

> Nhắc lại cấu trúc chân Tiny Tapeout: một ô có đúng 24 chân — `ui_in` 8 chỉ vào,
> `uo_out` 8 chỉ ra, `uio` 8 chọn chiều từng chân; **`uio_in` và `uio_out` là cùng một bộ
> chân vật lý**.

> ✅ Ngân sách chân **đủ**: tổng số bit logic nằm trong 24 chân vật lý, không cần
> nạp nhiều nhịp và không phải hy sinh tín hiệu nào.

## 4. Điều kiện hợp lệ của đầu vào

| Điều kiện | Ai bảo đảm |
|---|---|
| Các cổng vào không chứa `X`/`Z` khi lấy mẫu | Tầng ngoài |
| Tín hiệu vào đồng bộ với `clk` hoặc đã qua bộ đồng bộ | Tầng ngoài |
| Chuỗi reset được giữ đủ dài trước khi bắt đầu hoạt động | Tầng ngoài |

---

*Phiên bản: v1.0 · Ngày: 2026-09-24 · Truy vết: REQ-F08-002, AC-1.*
