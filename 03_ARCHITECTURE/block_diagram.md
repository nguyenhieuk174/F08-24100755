# F08 · Sơ đồ khối bên trong (Block Diagram)

> §1–§3 vẽ `f08_stepper_ctrl` (thiết kế đúng, **chưa được tổng hợp** — sơ đồ suy từ mã).
> §4 vẽ `f08_bad_direction_reset` (module **được tổng hợp** — sơ đồ đọc từ netlist thật).

---

## 1. `f08_stepper_ctrl` — bốn khối con

Vẽ theo đúng `04_IMPLEMENTATION/rtl/f08_stepper_ctrl.sv`, `SPEED_DIV_W = 8`.

```
 ┌──────────────────────────────────────────────────────────────────────────────┐
 │                          f08_stepper_ctrl                                     │
 │                                                                               │
 │  speed_div[7:0] ─┐                                                            │
 │                  ▼                                                            │
 │  run ──┬──▶ ┌────────────────────────────────┐                                │
 │        │    │ ① BỘ CHIA TẦN                  │                                │
 │        │    │   div_count[7:0]  (8 FF)       │                                │
 │        │    │   so sánh: div_count>=sd-1     │                                │
 │        │    │   nhánh riêng: sd==0 ⟹ tick=1  │                                │
 │        │    └──────────────┬─────────────────┘                                │
 │        │                   │ step_tick                                        │
 │        │                   ▼                                                  │
 │  dir ──┼──▶ ┌────────────────────────────────┐                                │
 │        │    │ ② LOGIC CHUYỂN TRẠNG THÁI      │      ┌───────────────────┐     │
 │ half   │    │   (always_comb, dòng 45)       │      │ ③ THANH GHI       │     │
 │ _step ─┼──▶ │   half_step ? ±1 mod 8         │─────▶│    VỊ TRÍ         │     │
 │        │    │             : ±1 với wrap [1:0]│ next │  state[2:0] (3 FF)│──┐  │
 │        │    └────────────────────────────────┘      └─────────┬─────────┘  │  │
 │        │                    ▲                                 │            │  │
 │        │                    └──────── hồi tiếp ───────────────┘            │  │
 │        │                                                                    │  │
 │        │    ┌───────────────────────────────────────────────────────────────┘  │
 │        │    │                                                                  │
 │        ▼    ▼                                                                  │
 │    ┌──────────────────────────────────────────┐                                │
 │    │ ④ BỘ GIẢI MÃ PHA  (always_comb, dòng 90) │                                │
 │    │                                          │                                │
 │    │   if (!half_step && state>3)             │                                │
 │    │        coil = 1001      ← cổng bảo vệ    │──────────────────────────▶ coil[3:0]
 │    │   else coil = run ? bảng_tra : 0000      │                                │
 │    │                                          │                                │
 │    │   bảng nửa bước: 8 mục × 4 bit           │                                │
 │    │   bảng bước đủ : 4 mục × 4 bit (dùng     │                                │
 │    │                  state[1:0])             │                                │
 │    └──────────────────────────────────────────┘                                │
 │                                                                                │
 │    state ──────────────────── assign ─────────────────────────────▶ state_dbg[2:0]
 │                                                                                │
 │  clk ──▶ (① và ③ dùng chung clk)     rst_n ──▶ (reset ĐỒNG BỘ, chèn vào D)     │
 └───────────────────────────────────────────────────────────────────────────────┘

   Ô nhớ dự kiến:  3 (state) + 8 (div_count) = 11 FF
   ⚠️ Charter mục 10 dự đoán 4–6 FF — vì Charter KHÔNG tính bộ chia tần.
```

> ⚠️ Con số 11 FF là **suy từ mã**, **không phải đo**. `f08_stepper_ctrl` chưa từng được
> tổng hợp (`synth.ys` dòng 5 đặt top là `f08_bad_direction_reset`).

### 1.1 Bộ chia tần chiếm 8 trên 11 flip-flop

Đây là quan sát cấu trúc quan trọng nhất của §1, và nó là câu trả lời một phần cho Charter
mục 9:

```
   ┌──────────────────────────────────────────────┐
   │  div_count[7:0]  ████████  8 FF   (73 %)     │ ← chỉ để ĐẾM THỜI GIAN
   │  state[2:0]      ███       3 FF   (27 %)     │ ← toàn bộ CHỨC NĂNG FSM
   └──────────────────────────────────────────────┘
```

**Phần "thông minh" của F08 chỉ tốn 3 flip-flop; phần đếm thời gian tốn 8.** Giống hệt cấu
trúc F06 (bộ đếm N chiếm phần lớn FF). Đây là mẫu chung của các khối điều khiển có tham số
thời gian: **chức năng rẻ, thời gian đắt**.

## 2. Bảng ánh xạ cấu trúc RTL → phần cứng dự kiến

| Dòng RTL | Cấu trúc | Phần cứng dự kiến |
|---|---|---|
| 14 | `logic [2:0] state, state_next` | **3 FF** + dây tổ hợp |
| 15 | `logic [7:0] div_count` | **8 FF** — phụ thuộc parameter `SPEED_DIV_W` |
| 18–43 | `function phase_decode` | **Bảng tra tổ hợp** — 2 `case` lồng trong `if (hs)`. Yosys dựng thành mạng cổng, **không** thành ROM |
| 45–59 | `always_comb` next-state | Bộ tăng/giảm 3 bit + 4 bộ so sánh hằng + mux theo `(half_step, dir)` |
| 50, 52 | `state ± 3'd1` với wrap 8 | Bộ tăng/giảm 3 bit — wrap **tự nhiên** khi tràn 3 bit, nên hai phép kiểm `== 7` / `== 0` thực ra **dư** |
| 55, 57 | `state ± 3'd1` với wrap kiểm trên `state[1:0]` | ⚠️ Cộng trên 3 bit, kiểm trên 2 bit ⟹ nguồn gốc **vùng tàn dư** |
| 61–69 | `always_comb` step_tick | Bộ so sánh 8 bit với **biến** `speed_div` (không phải hằng) — **đắt hơn** so sánh với hằng |
| 64 | `speed_div == '0` | Cổng NOR 8 đầu vào |
| 71–88 | `always_ff` | Mux next-state cho `state` và `div_count` + chèn reset đồng bộ |
| 82 | `div_count + 1'b1` | **Chuỗi carry 8 tầng** — ứng viên đường tới hạn |
| 85–86 | `state === 3'bxxx` | ⚠️ **Không tổng hợp được theo nghĩa thông thường** — xem `fsm.md` §6.3 |
| 90–95 | `always_comb` coil | Bảng tra + mux `run` + cổng bảo vệ `state > 3` |
| 97 | `assign state_dbg = state` | **Dây thuần** — 0 cell |

### 2.1 Hai chỗ tốn kém bất ngờ

| Chỗ | Vì sao đắt hơn vẻ ngoài |
|---|---|
| `div_count >= speed_div - 1'b1` (dòng 66) | So sánh **hai biến** 8 bit. Khác hẳn F06 (`count >= DB_CYCLES-1`, so với **hằng số**, `abc` tối giản rất sâu). So hai biến cần một bộ trừ/so sánh đầy đủ. |
| `phase_decode` với hai bảng (dòng 18–43) | Nhìn như một "bảng tra" nhưng không có ROM trong thiết kế — Yosys dựng thành **logic tổ hợp**. 8 mục × 4 bit + 4 mục × 4 bit, chọn bởi `hs`: mỗi bit `coil` là một hàm 4 biến (`state[2:0]`, `hs`). Xem `tradeoff.md` §5. |

## 3. Khối con nào nằm trên đường tới hạn — dự đoán cho `f08_stepper_ctrl`

**Chưa trả lời được bằng số** — STA hiện có chạy trên phản ví dụ. Dự đoán từ cấu trúc, để
kiểm lại sau khi tổng hợp đúng top:

| Ứng viên | Độ sâu | Lập luận |
|---|---|---|
| `div_count → +1 → div_count` | 8 tầng carry | Dài nhất về số tầng |
| `speed_div → so sánh 8 bit → step_tick → mux → state` | so sánh hai biến + mux | ⚠️ **Ứng viên mạnh nhất**: so hai biến đắt, và kết quả còn phải đi qua mux next-state |
| `dir → next-state → state` | vài cổng | Nông |
| `state → phase_decode → coil` | hàm 4 biến | Nông, nhưng là đường **in→out** (Mealy) nên cần ràng buộc riêng |

⟹ Dự đoán: đường tới hạn là `speed_div → step_tick → state`, **không** phải bộ tăng
`div_count`. Dự đoán này **có thể sai** — `abc` hay gộp bộ so sánh và bộ tăng. Phải đối
chiếu STA thật sau khi đổi top.

## 4. `f08_bad_direction_reset` — mạch ĐƯỢC TỔNG HỢP (nguồn của mọi số liệu)

Đọc từ `06_GDSII/synthesis/netlist.v` và `synth_stat.txt` — đây là số thật.

```
 ┌───────────────────────────────────────────────────────────────────┐
 │           f08_bad_direction_reset  (22 cell · 190,1824 µm²)       │
 │                                                                   │
 │  dir ──┬──────────────▶ ┌──────────────────────┐                  │
 │        │                │ SO SÁNH CHIỀU        │                  │
 │        │   ┌──────────▶ │  dir != dir_d        │                  │
 │        │   │            │  (xnor2_1 ×2,        │                  │
 │        │   │            │   xor2_1 ×1)         │                  │
 │        │   │            └──────────┬───────────┘                  │
 │        │   │                       │ "đổi chiều"                  │
 │        │   │                       ▼                              │
 │        │   │            ┌──────────────────────────────┐          │
 │        │   │            │ MUX NEXT-STATE 3 NHÁNH       │          │
 │        │   │            │  đổi chiều → 0               │          │
 │        │   │  state ───▶│  dir=1     → state+1 (wrap 7)│          │
 │        │   │   ▲        │  dir=0     → state−1 (wrap 0)│          │
 │        │   │   │        │ (or3_1, a21oi_1×2, nand3_1×3,│          │
 │        │   │   │        │  o221ai_1, mux2i_1, o21ai_0…)│          │
 │        │   │   │        └──────────┬───────────────────┘          │
 │        │   │   │                   │                              │
 │  step  │   │   │                   ▼                              │
 │  _tick─┼───┼───┼──▶ (cho phép ghi)  ┌──────────────┐              │
 │        │   │   │                    │ state[2:0]   │              │
 │  rst_n─┼───┼───┼──▶ (and2_0 chèn)   │ _37_ _38_ _39│──┬─────────▶ state[2:0]
 │        │   │   └────────────────────┴──────────────┘  │           │
 │        │   │                                          │           │
 │        │   │                    ┌──────────────┐      │           │
 │        └───┼───────────────────▶│ dir_d  _36_  │      │           │
 │            │                    └──────┬───────┘      │           │
 │            └───────────────────────────┘              │           │
 │  clk ─────────────────────────────────────────────────┘           │
 └───────────────────────────────────────────────────────────────────┘
```

### 4.1 Bảng cell thật

| Cell | SL | Vai trò dự đoán |
|---|---:|---|
| `dfxtp_1` | 4 | `state[2:0]` + `dir_d` |
| `nand3_1` | 3 | Logic wrap (`state == 7`, `state == 0`) và điều kiện ghi |
| `a21oi_1` | 2 | Mux next-state — **2 cell nằm trên đường tới hạn** |
| `clkinv_1` | 2 | Đảo (tăng/giảm) |
| `nand2_1` | 2 | Logic điều kiện |
| `xnor2_1` | 2 | **So sánh `dir != dir_d`** + bộ tăng/giảm |
| `xor2_1` | 1 | như trên |
| `or3_1` | 1 | **Trên đường tới hạn** — gom điều kiện |
| `o221ai_1` | 1 | **Trên đường tới hạn** — mux phức hợp |
| `a21boi_0`, `and2_0`, `mux2i_1`, `o21ai_0` | 1 mỗi loại | Mux + chèn reset đồng bộ |
| **Tổng** | **22** | |

### 4.2 Đường tới hạn — số THẬT

`06_GDSII/sta/timing_report_max.txt`, slack **8,25 ns (MET)**:

```
  dir ──▶ _31_(or3_1) ──▶ _33_(a21oi_1) ──▶ _34_(o221ai_1) ──▶ _35_(a21oi_1) ──▶ _39_/D
  1.00      +0.29           +0.15             +0.13             +0.11          = 1.68 ns
  (input                                                                          ▲
   delay                                                                          │
   giả định)                                                        ★ _39_ = state[2]
```

| # | Instance | Cell | Delay | Fanout |
|---:|---|---|---:|---:|
| 1 | `_31_` | `or3_1` | 0,29 ns | 1 (`dir` có fanout **5**) |
| 2 | `_33_` | `a21oi_1` | 0,15 ns | 2 |
| 3 | `_34_` | `o221ai_1` | 0,13 ns | 1 |
| 4 | `_35_` | `a21oi_1` | 0,11 ns | 1 |
| 5 | `_39_` | `dfxtp_1` | — | endpoint = `state[2]` |

### 4.3 Phát hiện đáng chú ý nhất của F08

> **Đường tới hạn bắt đầu từ `dir` — tức từ chính tín hiệu mà module này xử lý SAI.**

`dir` có **fanout 5** (STA ghi rõ ở dòng `5 0.01 0.00 0.00 1.00 v dir (in)`) vì nó được
dùng ở ba chỗ: so sánh với `dir_d`, chọn hướng tăng/giảm, và ghi lại vào `dir_d`. Chính
cái **nhánh so sánh thừa** — nhánh tạo ra lỗi mất bước — làm `dir` phải lái thêm tải và đặt
chuỗi 4 cổng lên đường tới hạn.

Nói cách khác: ở phản ví dụ này, **logic sai vừa gây lỗi chức năng vừa là đường chậm
nhất**. `f08_stepper_ctrl` không có `dir_d`, không có phép so sánh đó, nên `dir` chỉ có
fanout nhỏ hơn và đường này biến mất.

⟹ Một bài học gọn: *cấu trúc sai thường không chỉ sai — nó còn đắt.* Nhưng phải nói rõ
giới hạn: **chưa so được bằng số**, vì `f08_stepper_ctrl` chưa được tổng hợp.

### 4.4 Đọc con số 1,68 ns cho đúng

| Thành phần | Giá trị |
|---|---:|
| `set_input_delay` **giả định** (`design.sdc`) | 1,00 ns |
| **Logic thật (4 cell)** | **0,68 ns** |
| Required (10,00 − 0,07 library setup) | 9,93 ns |
| **Slack** | **8,25 ns (MET)** |

60 % của "1,68 ns" là giả định của người ràng buộc. Trong ba đề F06–F08, F08 có tỷ lệ logic
thật cao nhất (0,68 ns so với 0,26 ns của F06 và 0,42 ns của F07) — hợp lý, vì mạch này có
chuỗi mux sâu nhất.

---

*Phiên bản: v1.0 · Ngày: 2026-09-24*
