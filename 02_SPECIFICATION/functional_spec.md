# F08 · Đặc tả chức năng (Functional Spec)

> ## ⚠️ CẢNH BÁO ĐẦU FILE — TOP MODULE SAI · THIẾU CỔNG CHARTER MỤC 4 · **CHƯA THOẢ**
>
> **(a) Module được tổng hợp là PHẢN VÍ DỤ, không phải bộ điều khiển động cơ bước.**
> `brief/F08.md` và `06_GDSII/synthesis/synth.ys` dòng 5 cho thấy top module đưa vào Yosys
> là `f08_bad_direction_reset`. Chính file RTL đó tự khai ở dòng 1–2:
>
> ```systemverilog
> // EDUCATIONAL ANTI-PATTERN.
> // Direction change incorrectly resets the sequence to state zero.
> ```
>
> ⟹ **Mọi số liệu tổng hợp / STA / công suất của F08 (22 cell · 4 FF · 190,1824 µm² ·
> 1,68 ns · 2,19e-05 W) là của phản ví dụ.** Bộ điều khiển thật `f08_stepper_ctrl` **chưa
> từng được tổng hợp**.
>
> **(b) Cái bẫy nguy hiểm nhất của hồ sơ F08:** Charter mục 10 ghi *"Dấu hiệu làm đúng:
> 3 ô nhớ vị trí (8 trạng thái nửa bước) + vài bit chế độ ≈ 4–6 ô nhớ"*. Đo được **đúng 4
> FF** — **khớp dải dự đoán**. Nhưng 4 FF đó là `state[2:0]` + `dir_d` của **phản ví dụ**,
> không phải của FSM thật. `f08_stepper_ctrl` sẽ có 3 (`state`) + 8 (`div_count`) = **11 FF**
> — **ngoài** dải Charter. Một con số khớp dự đoán mà **vẫn sai** là loại bằng chứng nguy
> hiểm nhất: nó không kích hoạt nghi ngờ.
>
> **(c) Đối chiếu Charter mục 4 với từng module:**
>
> | Charter mục 4 chốt | `f08_stepper_ctrl` (thật) | `f08_bad_direction_reset` (**được tổng hợp**) |
> |---|---|---|
> | `uio_in[0]` = chiều | ✅ `dir` | ✅ `dir` |
> | `uio_in[1]` = nửa bước | ✅ `half_step` | ❌ **không có** |
> | `uio_in[2]` = chạy | ✅ `run` | ❌ **không có** |
> | `uo_out[3:0]` = bốn pha | ✅ `coil[3:0]` | ❌ **không có** |
> | `uo_out[6:4]` = vị trí trong chuỗi | ✅ `state_dbg[2:0]` | ✅ `state[2:0]` |
> | *(không có trong Charter)* | ⚠️ `speed_div[7:0]` — **8 bit thừa**, ngân sách chân Charter chỉ cấp 3 bit vào | ⚠️ `step_tick` — thay cho bộ chia tần nội bộ |
>
> ⟹ **`f08_stepper_ctrl` gần như thoả Charter mục 4** (chỉ thừa `speed_div`), còn module
> **được đo** thì thiếu 3 trên 5 nhóm cổng. **REQ-F08-002 CHƯA THOẢ** đối với top hiện tại.
>
> **Ngân sách chân nếu dùng `f08_stepper_ctrl`:** 3 (`run`,`dir`,`half_step`) + 8
> (`speed_div`) = 11 bit vào; 4 (`coil`) + 3 (`state_dbg`) = 7 bit ra ⟹ 18/24 chân. Vẫn đủ,
> nhưng Charter mục 4 **không** cấp phát 8 bit cho `speed_div` — cần thầy quyết định.
>
> **Hồ sơ không tự sửa RTL** (SPEC §0.2, §3).
>
> ---
>
> ### ⚠️ Cảnh báo thứ hai — mô phỏng KHÔNG BIÊN DỊCH ĐƯỢC
>
> `05_VERIFICATION/iverilog_compile.log` báo `syntax error` tại `f08_tb.sv:32`. Không có
> `simulation.log` — mô phỏng **chưa bao giờ chạy**. Phán xử đầy đủ ở
> **`05_VERIFICATION/known_issues.md`**. Tóm tắt: **lỗi ở TESTBENCH**, vi phạm quy tắc LRM
> về vị trí khai báo biến. **Toàn bộ tầng 05 của F08 hiện không có bằng chứng hành vi nào
> trên RTL** — chỉ có mô hình chuẩn Python.

---

## 1. Bài toán: định nghĩa chính xác

Động cơ bước lưỡng cực bốn pha quay bằng cách cấp dòng cho các cuộn dây theo một **chuỗi
tuần hoàn**. Mỗi lần đổi sang mẫu kế tiếp trong chuỗi, rotor quay đúng một bước góc.

Khối F08 **không** điều khiển dòng, **không** sinh mô-men. Nó chỉ làm ba việc:

1. Giữ **vị trí hiện tại trong chuỗi** (đây là trạng thái duy nhất có ý nghĩa vật lý).
2. Tiến hoặc lùi vị trí đó mỗi khi có nhịp bước.
3. **Giải mã** vị trí thành mẫu bốn pha.

Hai chế độ:

| Chế độ | Số bước/vòng điện | Mô-men | Độ mịn |
|---|---|---|---|
| **Bước đủ** (full step) | 4 | cao hơn | thô |
| **Nửa bước** (half step) | 8 | thấp hơn ở các bước lẻ | mịn gấp đôi |

Độ khó thật của đề nằm ở một câu của Charter mục 10: *"Đổi chiều bằng cách đảo thứ tự bảng
mà quên vị trí hiện tại → mất bước."* Rotor **ở đâu thì ở đó**; đổi chiều là đổi **hướng đi
tiếp**, không phải nhảy về đầu chuỗi. Một FSM làm sai chỗ này sẽ khiến trục máy in 3D lệch
vị trí vĩnh viễn — và lỗi tích luỹ, không tự sửa.

## 2. Đặc tả hành vi đúng (độc lập với hiện thực)

Ký hiệu: `s` = vị trí trong chuỗi; `H` = `half_step`; `D` = `dir`; `n = H ? 8 : 4`.

### 2.1 Quy tắc chuyển vị trí

> **Khi có nhịp bước:** `s' = (s + (D ? +1 : −1)) mod n`.
> **Khi không có nhịp bước:** `s' = s`.
> **Đổi `D` KHÔNG làm `s` thay đổi** — nó chỉ đổi dấu của bước kế tiếp.

Câu cuối là toàn bộ nội dung câu hỏi Charter mục 2 số 2.

### 2.2 Bảng giải mã pha

| `s` | Nửa bước `coil[3:0]` | Bước đủ `coil[3:0]` |
|---:|:---:|:---:|
| 0 | `1001` | `1001` |
| 1 | `0001` | `0011` |
| 2 | `0011` | `0110` |
| 3 | `0010` | `1100` |
| 4 | `0110` | — |
| 5 | `0100` | — |
| 6 | `1100` | — |
| 7 | `1000` | — |

**Quan hệ then chốt giữa hai bảng:** `full[k] = half[2k]`.

```
  nửa bước:  1001  0001  0011  0010  0110  0100  1100  1000
              ▲           ▲           ▲           ▲
  bước đủ:   1001        0011        0110        1100
             (k=0)       (k=1)       (k=2)       (k=3)
```

Bước đủ là **tập con chẵn** của nửa bước. Các mẫu lẻ của nửa bước (`0001`, `0010`, `0100`,
`1000`) chỉ có **một** cuộn được cấp dòng — đó là lý do mô-men ở các bước lẻ thấp hơn.
Quan hệ này là bằng chứng cho thấy hai bảng **nhất quán vật lý** và cùng mô tả một vòng
điện; nếu vi phạm, đổi chế độ giữa chừng sẽ làm rotor giật.

### 2.3 Định nghĩa từng đầu ra

| Đầu ra | Định nghĩa |
|---|---|
| `uo_out[3:0]` = `coil` | `run ? bảng[s][H] : 4'b0000`. Khi dừng, **mọi cuộn ngắt dòng**. |
| `uo_out[6:4]` = `s` | Vị trí hiện tại — dùng để quan sát và gỡ lỗi |

### 2.4 Trạng thái sau reset và độ trễ

| Hạng mục | Giá trị | Bằng chứng RTL (`f08_stepper_ctrl`) |
|---|---|---|
| Sau reset | `s = 0`, `div_count = 0` | dòng 72–74 |
| `coil` sau reset | `0000` (vì `run` thường bằng 0) | dòng 94 |
| Nhịp bước → `s` đổi | **1 chu kỳ clock** | dòng 78–80 |
| `s` đổi → `coil` đổi | **0 chu kỳ** — tổ hợp | dòng 90–95 |
| Chu kỳ giữa hai bước | `speed_div` chu kỳ clock (`speed_div = 0` ⟹ mỗi chu kỳ một bước) | dòng 62–68 |

## 3. Ràng buộc cấu trúc bắt buộc

| RB | Nội dung | RTL `f08_stepper_ctrl` |
|---|---|---|
| RB-1 | Phải là **FSM** tường minh, có thanh ghi vị trí | ✅ `logic [2:0] state, state_next` + hai khối `always_comb` + một `always_ff` |
| RB-2 | **Đổi chiều không được làm mất vị trí** | ✅ `state_next` là hàm thuần của `(state, dir, half_step)`; không có nhánh nào ép `state ← 0` khi `dir` đổi |
| RB-3 | Charter mục 2 câu 1 hỏi **chung hay riêng thanh ghi** cho hai chế độ | ✅ **CHUNG** — một `state[2:0]` duy nhất cho cả 4 và 8 trạng thái. Phương án riêng có trong gói: `f08_bad_dual_state_register.sv` |
| RB-4 | Đầu ra phải ngắt dòng khi dừng | ✅ `coil = run ? … : 4'b0000` (dòng 94) |
| RB-5 | Phải có bộ chia tần để đặt tốc độ | ✅ `div_count` + `speed_div` (dòng 61–69) — **nhưng Charter mục 4 không cấp chân cho `speed_div`** |

## 4. Tính chất bất biến (invariants)

| ID | Phát biểu | Dạng kiểm |
|---|---|---|
| **INV-1** | Ở chế độ nửa bước, `s ∈ [0,7]`. | `properties.sv` dòng 2 (`half_step \|-> state_dbg inside {[0:7]}`) — **hiển nhiên đúng** vì `s` là 3 bit; assertion này **không có giá trị phát hiện lỗi** |
| **INV-2** | Ở chế độ bước đủ, `s ∈ [0,3]`. | `properties.sv` dòng 3. **Có giá trị thật** — nhưng RTL **vi phạm tạm thời** khi vừa chuyển chế độ (xem §5) |
| **INV-3** | Đổi `dir` mà **không** có nhịp bước ⟹ `s` không đổi. | `assert property (@(posedge clk) (dir != $past(dir)) && !step_tick \|-> state_dbg == $past(state_dbg));` ❌ chưa có |
| **INV-4** | Mỗi nhịp bước làm `s` đổi **đúng 1 đơn vị** (theo modulo). | `assert property (step_tick \|=> (state_dbg == $past(next_expected)));` ❌ chưa có — **đây là invariant quan trọng nhất** và nó thiếu |
| **INV-5** | `run = 0` ⟹ `coil = 0000`. | ✅ kiểm trong TB dòng 47 (nhưng TB chưa chạy được) |
| **INV-6** | Hai mẫu pha liên tiếp khác nhau đúng **một bit** ở chế độ nửa bước. | Kiểm được từ bảng §2.2: `1001→0001` (1 bit), `0001→0011` (1 bit)… ❌ chưa có assertion |
| **INV-7** | `full[k] = half[2k]` — hai bảng nhất quán. | ✅ mô hình Python `test_phase_coverage()` kiểm gián tiếp (8 mẫu nửa bước phân biệt, 4 mẫu bước đủ phân biệt) |
| **INV-8** | `div_count < speed_div` tại mọi thời điểm. | ❌ chưa có |

> **Nhận xét về chất lượng assertion hiện có:** `properties.sv` chỉ có 2 property, một trong
> đó (INV-1) **tự động đúng** vì kiểu dữ liệu là 3 bit — nó không thể FAIL, nên không phát
> hiện được gì. Invariant quan trọng nhất của đề (INV-4: mỗi nhịp đúng một bước, không nhảy
> bước) **không có**. Đây là khoảng trống kiểm chứng đáng kể, vì "nhảy bước" chính là rủi ro
> chính mà Charter mục 10 nêu.

## 5. Điều kiện biên và hành vi không xác định

| Ca | Đặc tả yêu cầu | RTL `f08_stepper_ctrl` làm gì | Đánh giá |
|---|---|---|---|
| Đổi `dir` giữa chừng | `s` **giữ nguyên**, bước kế đi ngược | `state_next` không đọc lịch sử `dir` ⟹ đúng | ✅ |
| Đổi `dir` ở `f08_bad_direction_reset` | như trên | `if (dir != dir_d) state <= 3'd0;` ⟹ **mất vị trí** | ❌ đúng như tên gọi phản ví dụ |
| **Chuyển nửa bước → bước đủ khi `s ∈ [4,7]`** | **KHÔNG ĐẶC TẢ** | `state_next` bước đủ dùng `state[1:0]` để kiểm wrap nhưng cộng/trừ trên **cả 3 bit**: từ `s=5` tiến → `6`, rồi `7`, rồi (`7[1:0]=3`) → `0`. Mất tới 3 nhịp mới về dải hợp lệ. | ⚠️ **Vi phạm INV-2 tạm thời**. RTL có **cổng bảo vệ đầu ra** (dòng 91): `if (!half_step && state > 3'd3) coil = 4'b1001;` — giữ cuộn ở mẫu an toàn trong lúc đó. |
| `speed_div = 0` | Bước mỗi chu kỳ clock | Nhánh riêng `if (speed_div == '0) step_tick = 1'b1;` (dòng 64) | ✅ có xử lý |
| `run` hạ giữa chừng | Giữ `s`, ngắt dòng | `div_count <= 0`, `state` giữ; `coil = 0` | ✅ |
| `run` lên lại | Tiếp tục từ `s` cũ | `state` không bị reset | ✅ — **không mất bước** |
| Đổi `speed_div` khi `div_count` đang đếm | **KHÔNG ĐẶC TẢ** | Nếu `speed_div` giảm xuống dưới `div_count`, điều kiện `div_count >= speed_div-1` thoả ngay ⟹ bước sớm một lần rồi ổn định | ⚠️ ghi nhận, không phải lỗi |
| `state` mang giá trị `X` | — | Dòng 85–86: `if (half_step && (state === 3'bxxx)) state <= 3'd0;` | ❌ **MÃ CÓ VẤN ĐỀ** — xem §6 |

## 6. Ba chỗ trong RTL cần thầy xem lại

Ghi nhận, **không tự sửa**:

### 6.1 Toán tử `===` không tổng hợp được (dòng 85–86)

```systemverilog
if (half_step && (state === 3'bxxx))
    state <= 3'd0;
```

| Vấn đề | Chi tiết |
|---|---|
| `===` là toán tử **so sánh 4 trạng thái** | Không có ý nghĩa trong phần cứng — silicon không có giá trị `X` |
| Trong mô phỏng | Sau reset, `state` không bao giờ là `X` ⟹ điều kiện **không bao giờ đúng** ⟹ **mã chết** |
| Khi tổng hợp | Yosys thường rút gọn thành hằng `0`; một số tool báo lỗi. **Chưa kiểm chứng được** vì module này chưa được tổng hợp |
| Vị trí câu lệnh | Nằm **ngoài** chuỗi `if/else` phía trên ⟹ nếu đúng, nó **ghi đè** lệnh gán `state <= state_next` trong cùng chu kỳ |

### 6.2 Bước đủ cộng trên 3 bit nhưng kiểm wrap trên 2 bit (dòng 54–57)

```systemverilog
if (dir) state_next = (state[1:0] == 2'd3) ? 3'd0 : state + 3'd1;
else     state_next = (state[1:0] == 2'd0) ? 3'd3 : state - 3'd1;
```

Với `s ∈ [0,3]` hoàn toàn đúng. Với `s ∈ [4,7]` (tàn dư sau khi chuyển chế độ) hành vi lạ
nhưng **hữu hạn** — về dải hợp lệ sau ≤3 nhịp. Cổng bảo vệ đầu ra ở dòng 91 che được hậu quả.
Cách viết sạch hơn là mask: `state_next = {1'b0, (state[1:0] + 2'd1)}`.

### 6.3 Mô hình chuẩn Python **không** mô hình hoá tàn dư này

```python
def next_state(state, direction, half_step):
    n = 8 if half_step else 4
    return (state + (1 if direction else -1)) % n     # ← modulo 4: s luôn trong [0,3]
```

Với `s = 5`, chế độ bước đủ, `dir=1`: Python cho `(5+1) % 4 = 2`; RTL cho `6`.
**Hai mô hình bất đồng ở dải `s ∈ [4,7]`.** Không phải "mô hình chuẩn sai" — nó mô hình hoá
đặc tả lý tưởng; RTL mô hình hoá một hiện thực có tàn dư. Nhưng sự bất đồng này **phải được
ghi nhận**, vì nếu sau này có bộ so sánh tự động giữa hai mô hình thì đây là chỗ sẽ báo lỗi
đầu tiên. Xem `corner_cases.md` §3.1.

---

*Phiên bản: v1.0 · Ngày: 2026-09-24*
