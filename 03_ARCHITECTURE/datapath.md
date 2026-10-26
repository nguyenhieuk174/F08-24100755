# F08 · Đường dữ liệu (Datapath)

> **Cập nhật:** mô phỏng RTL hiện PASS và kiểm tra chuỗi đã có trong
> `05_VERIFICATION/testbench/f08_tb.sv`. Mục 4 phía dưới là phân tích lịch sử của module
> phản ví dụ `f08_bad_direction_reset`, không phải số đo của RTL core hiện tại. Số liệu
> hiện hành được tách theo giai đoạn tại `06_GDSII/physical_report.md`.

---

## 1. F08 có **hai** datapath nhỏ, tách biệt hoàn toàn

Khác F07 (gần như không có datapath), F08 có hai đường số học độc lập chạy song song:

```
 ┌── DATAPATH A · ĐẾM THỜI GIAN ──────────────────────────────────────┐
 │                                                                     │
 │   div_count[7:0] ──┬──▶ + 1 ──▶ mux ──▶ div_count      (8 FF)       │
 │                    │                                                │
 │                    └──▶ so sánh  >= speed_div − 1 ──▶ step_tick     │
 │                                        ▲                            │
 │                              speed_div[7:0] (cổng vào, 8 bit)       │
 └─────────────────────────────────┬───────────────────────────────────┘
                                   │ step_tick (1 bit) — CẦU NỐI DUY NHẤT
 ┌─────────────────────────────────▼───────────────────────────────────┐
 │ ── DATAPATH B · ĐẾM VỊ TRÍ ──                                       │
 │                                                                     │
 │   state[2:0] ──┬──▶ ± 1 (wrap) ──▶ mux ──▶ state       (3 FF)       │
 │                │           ▲                                        │
 │                │       dir, half_step                               │
 │                │                                                    │
 │                └──▶ bảng tra phase_decode ──▶ coil[3:0]             │
 └─────────────────────────────────────────────────────────────────────┘
```

**Hai datapath RTL chỉ giao nhau qua 1 bit `step_tick`.** Đây là một sự tách bạch sạch sẽ:
A đếm *thời gian*, B đếm *vị trí*, và A chỉ nói với B một câu "đến giờ rồi".
RTL có 11 thanh ghi trạng thái/bộ đếm; báo cáo tổng hợp ghi 15 FF, gồm thêm 4 FF
đầu ra giải mã pha.

Sự tách bạch này có hệ quả kiểm chứng: có thể kiểm B (chuỗi bước) **hoàn toàn độc lập** với
A bằng cách đặt `speed_div = 0` (bước mỗi chu kỳ). Đó chính là cách mô hình chuẩn Python
làm — `next_state()` không có khái niệm thời gian.

## 2. Bảng các đường dữ liệu — `f08_stepper_ctrl`

| Đường | Độ rộng | Từ | Đến | Bản chất |
|---|---:|---|---|---|
| `speed_div[7:0]` | 8 | cổng vào | bộ so sánh 8 bit | **Tham số thời gian** ⚠️ Charter mục 4 **không cấp chân** cho nó |
| `div_count[7:0]` | 8 | FF | bộ tăng + bộ so sánh | **Datapath A** — 8 FF trong 15 FF tổng hợp được báo cáo |
| `step_tick` | 1 | tổ hợp | cho phép ghi `state` | **Cầu nối A → B** |
| `dir`, `half_step`, `run` | 1 mỗi | cổng vào | next-state logic + bộ giải mã | **Điều khiển** — và `run`/`half_step` đi **thẳng ra `coil`** (Mealy) |
| `state[2:0]` | 3 | FF | bộ tăng/giảm + bảng tra + cổng ra | ★ **Trạng thái vật lý duy nhất có ý nghĩa** |
| `state_next[2:0]` | 3 | tổ hợp | mux ghi `state` | Kết quả bước kế |
| `coil[3:0]` | 4 | bảng tra (tổ hợp) | cổng ra | **Đầu ra Mealy** — lái driver công suất |
| `state_dbg[2:0]` | 3 | `assign state` | cổng ra | Dây thuần, 0 cell |

### 2.1 Vì sao `state` chỉ 3 bit mà mang toàn bộ ý nghĩa vật lý

`state` là **vị trí của rotor trong chuỗi điện**. Ba bit đó ánh xạ 1-1 sang một góc quay
vật lý. Mọi bit khác trong thiết kế (`div_count`) chỉ là bộ đếm thời gian — mất nó thì động
cơ chạy sai tốc độ; mất `state` thì động cơ **mất vị trí**, và vì vòng điều khiển là vòng
hở (`system_diagram.md` §1.1), mất vị trí là **mất vĩnh viễn**.

⟹ Thứ tự ưu tiên kiểm chứng phải phản ánh điều này: mọi invariant về `state` quan trọng hơn
mọi invariant về `div_count`. Testbench hiện kiểm chuỗi nửa bước tiến và bước đủ tiến; các
trường hợp chuyển chế độ khi `state ∈ [4,7]` vẫn cần ca riêng.

## 3. Đồ thị phụ thuộc

```
  mức 0   speed_div[7:0] ──┐   div_count[7:0] ──┬──┐   state[2:0] ──┬──┐  dir,half_step,run
          (cổng vào)       │   (từ FF)          │  │   (từ FF)      │  │   (cổng vào)
                           ▼                    ▼  │                │  │        │
  mức 1..8   ┌─────────────────────────────────────┴─┐   ┌──────────┘  │        │
             │ SO SÁNH 8 BIT:  div_count >= sd − 1   │   │ BỘ TĂNG/GIẢM│        │
             │ (so HAI BIẾN — đắt)                   │   │ 3 bit + wrap│◀───────┤
             └──────────────────┬────────────────────┘   └──────┬──────┘        │
                                │ step_tick                     │ state_next    │
                                ▼                               ▼               │
  mức 9..10        ┌────────────────────────────────────────────────┐           │
                   │  MUX GHI state  (step_tick && run && rst_n)     │           │
                   └───────────────────┬────────────────────────────┘           │
                                       ▼                                        │
  đích                          [FF state[2:0]]                                 │
                                                                                │
  ── nhánh song song, KHÔNG qua FF (ĐƯỜNG MEALY) ───────────────────────────────┤
                                                                                │
  mức 1..3   state[2:0] ──▶ ┌──────────────────────────────────────┐◀───────────┘
                            │ BẢNG TRA phase_decode + cổng bảo vệ  │
                            │ + mux theo run                       │
                            └──────────────────┬───────────────────┘
                                               ▼
  đích (cổng ra)                          coil[3:0]   ★ in → out, KHÔNG qua FF
```

### Độ sâu logic của từng đích (ước lượng từ RTL — **chưa đo**)

| Đích | Độ sâu ước lượng | Ghi chú |
|---|---|---|
| `div_count[7]` | ≈8 (cuối chuỗi carry) | Dài nhất về **số tầng** |
| `state[*]` | ≈so sánh 8 bit + mux ≈10 | ⚠️ **Ứng viên đường tới hạn** — nối tiếp sau bộ so sánh |
| `coil[*]` | ≈3–4 (hàm 4 biến) | Nông, **nhưng là đường in→out** — cần ràng buộc `set_max_delay` riêng |
| `state_dbg[*]` | 0 | Dây thuần |

> 🔎 **Dự đoán cần kiểm bằng STA:** endpoint tới hạn của `f08_stepper_ctrl` nhiều khả năng
> là `state`, **không** phải `div_count`, vì `state` nằm **nối tiếp sau** bộ so sánh 8 bit
> hai biến vốn đã sâu. Đây là dự đoán **có thể sai** — `abc` hay gộp bộ so sánh và bộ tăng.

## 4. Đối chiếu với STA thật — và vì sao chưa đối chiếu được

| | |
|---|---|
| Đường tới hạn **dự đoán** cho `f08_stepper_ctrl` | `speed_div` → so sánh 8 bit → `step_tick` → mux → `state` |
| Đường tới hạn **STA đo được** | `dir` → `_31_(or3_1)` → `_33_(a21oi_1)` → `_34_(o221ai_1)` → `_35_(a21oi_1)` → `_39_(state[2])`, **1,68 ns**, slack **8,25 ns** |
| So sánh được không? | ❌ **KHÔNG** |

Lý do: `synth.ys` dòng 5 đặt top là `f08_bad_direction_reset`. Đường đo được là của **phản
ví dụ**, trong đó:

- **không có** `div_count`, **không có** `speed_div`, **không có** bộ so sánh 8 bit;
- **có** `dir_d` và phép so sánh `dir != dir_d` — thứ **không tồn tại** trong thiết kế đúng;
- **không có** `coil`, nên không có đường Mealy nào để ràng buộc.

⟹ **Dự đoán đường tới hạn của F08 hiện chưa được kiểm chứng.** ⬜ chưa chạy.

### Cần gì để kiểm chứng

1. Sửa `06_GDSII/synthesis/synth.ys` dòng 5 → `hierarchy -check -top f08_stepper_ctrl`.
2. Chạy `bash 04_IMPLEMENTATION/scripts/02_run_synth.sh` rồi `03_run_sta.tcl`.
3. Bổ sung ràng buộc cho đường Mealy: `set_max_delay` từ `run`/`half_step` tới `coil` —
   `design.sdc` hiện chỉ có `set_input_delay`/`set_output_delay`, đủ cho đường qua FF nhưng
   **không** mô tả đúng đường tổ hợp in→out.
4. Chạy thêm hai lần với `SPEED_DIV_W = 4` và `8` để tách chi phí của bộ chia tần.

Bước 4 cũng là dữ liệu cần cho Charter mục 9 (số FF theo cách mã hoá).

## 5. Đường tới hạn THẬT của mạch đang được đo

Để không bỏ trống mục "đối chiếu STA", phân tích đầy đủ đường thật đang có
(`f08_bad_direction_reset`):

| Chặng | Cell | Delay | Tích luỹ |
|---|---|---:|---:|
| input external delay (**giả định**) | — | 1,00 ns | 1,00 |
| `dir` → `_31_/C` | dây (fanout **5**) | 0,00 | 1,00 |
| `_31_/C → _31_/X` | `or3_1` | **0,29** | 1,29 |
| `_33_/A1 → _33_/Y` | `a21oi_1` | 0,15 | 1,44 |
| `_34_/B1 → _34_/Y` | `o221ai_1` | 0,13 | 1,57 |
| `_35_/B1 → _35_/Y` | `a21oi_1` | 0,11 | **1,68** |
| → `_39_/D` (`state[2]`) | dây | 0,00 | 1,68 |

Required: `10,00 − 0,07 (library setup) = 9,93` ⟹ **slack 8,25 ns (MET)**,
WNS/TNS = 0,00/0,00.

**Đọc được gì:**

1. **Logic thật chiếm 0,68 ns**; 1,00 ns là `set_input_delay` giả định (60 % con số).
2. **Cổng đầu tiên đắt nhất (0,29 ns)** vì `dir` có **fanout 5** — điện dung tải lớn làm
   slew xấu, delay tăng. Bốn cổng sau rẻ dần (0,15 → 0,13 → 0,11) khi fanout giảm về 1.
   Đây là minh hoạ sạch về ảnh hưởng của fanout lên delay, đọc được ngay trong một báo cáo.
3. **Đường tới hạn bắt đầu từ chính tín hiệu bị xử lý sai.** `dir` có fanout 5 vì nó được
   dùng ba chỗ, trong đó có **nhánh so sánh `dir != dir_d`** tạo ra lỗi mất bước. Logic sai
   vừa gây lỗi chức năng vừa là đường chậm nhất.
4. **Endpoint là `state[2]`** — bit cao nhất của vị trí, đúng bit chịu ảnh hưởng nhiều nhất
   của phép "nhảy về 0".

## 6. Chi phí theo tham số — phân tích cấu trúc (chưa có số đo)

Hai tham số làm diện tích F08 co giãn:

| Tham số | Ảnh hưởng | FF |
|---|---|---:|
| `SPEED_DIV_W` | Bề rộng `div_count` **và** bề rộng bộ so sánh hai biến | `= SPEED_DIV_W` |
| Số trạng thái (4 hay 8) | Bề rộng `state` | 2 hoặc **3** |

| Cấu hình | FF cho `state` | FF cho `div_count` | Tổng dự kiến |
|---|---:|---:|---:|
| Chỉ bước đủ, `SPEED_DIV_W=4` | 2 | 4 | **6** |
| Chỉ bước đủ, `SPEED_DIV_W=8` | 2 | 8 | **10** |
| Cả hai chế độ, `SPEED_DIV_W=4` | 3 | 4 | **7** |
| **Cả hai chế độ, `SPEED_DIV_W=8`** (hiện tại) | 3 | 8 | **11** |
| Hai thanh ghi riêng (`f08_bad_dual_state_register`) + `SPEED_DIV_W=8` | 5 | 8 | **13** |

**Nhận xét suy từ cấu trúc, cần đo để xác nhận:**

1. Cho phép **cả hai chế độ** chỉ tốn thêm **1 FF** (2 → 3 bit) — rất rẻ, vì hai chuỗi dùng
   chung thanh ghi. Đây là câu trả lời cấu trúc cho Charter mục 2 câu 1.
2. Chi phí **thật sự** nằm ở bộ chia tần: `SPEED_DIV_W` từ 4 lên 8 tốn **+4 FF**, gấp bốn
   lần cái giá của việc thêm chế độ nửa bước.
3. Dùng **hai thanh ghi riêng** tốn **+2 FF** so với dùng chung, và đánh mất quan hệ
   `full[k] = half[2k]` (`fsm.md` §5.2).

> Mọi con số trong bảng là **suy từ mã**, **không phải đo**. Con số duy nhất đo được là
> **4 FF** của phản ví dụ — và nó không nằm trong bảng này vì phản ví dụ không có bộ chia
> tần, không có chế độ nửa bước, không có `coil`.

---

*Phiên bản: v1.0 · Ngày: 2026-09-24*
