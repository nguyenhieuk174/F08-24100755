# F08 · Giản đồ thời gian (Timing Diagram)

> F08 là mạch **tuần tự** ⟹ dùng giản đồ dạng sóng theo chu kỳ clock.
>
> ## ⚠️ CẢNH BÁO BẮT BUỘC ĐỌC TRƯỚC
>
> **Các dạng sóng minh họa trong file này là suy luận từ mã nguồn; chúng không được vẽ
> trực tiếp từ VCD.**
>
> Testbench tạo VCD tại `05_VERIFICATION/waveforms/f08_tb.vcd`; GitHub Actions tải file
> này lên cùng log kiểm thử dưới dạng artifact. Các bảng dưới đây vẫn là kỳ vọng theo
> từng cạnh, không phải biểu diễn trực tiếp từ VCD. Xem `05_VERIFICATION/known_issues.md`
> để biết chẩn đoán lịch sử.
>
> Các bảng dưới đây là **dự đoán có cơ sở** về giá trị theo từng cạnh và có thể đối chiếu
> với VCD và log mô phỏng. Assertion PASS không xác nhận mọi diễn giải trong giản đồ.
>
> Ngoài ra, ngay cả khi chạy được thì đó vẫn là mô phỏng **hành vi (zero-delay)**: không có
> `t_ckq`, không có độ trễ cổng, không có glitch — mà `coil` là đầu ra **Mealy** nên nó
> **có** khả năng glitch thật. Chỉ L5 (post-layout + SDF) mới thấy.

---

## 1. Kỳ vọng cho kịch bản của testbench (sau khi vá lỗi cú pháp)

Suy từ `f08_tb.sv` chạy trên `f08_stepper_ctrl`, `speed_div = 8'd1` ⟹
`step_tick = run` **mỗi chu kỳ** (vì `div_count >= speed_div − 1 = 0` luôn đúng).
Clock chu kỳ 10, cạnh lên tại `t = 5, 15, 25, …`; `tick()` = `@(posedge clk); #1`.

### 1.1 Giai đoạn nửa bước tiến (cạnh #3 → #10)

```
 cạnh #     1     2     3     4     5     6     7     8     9    10
 t (ns)     5    15    25    35    45    55    65    75    85    95
          ─┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬──
 clk     ─┘└────┘└────┘└────┘└────┘└────┘└────┘└────┘└────┘└────┘└──

 rst_n   ──┐                                                      
         0 └──── 1 ───────────────────────────────────────────────────
 run     ───────┐
         0      └──── 1 ─────────────────────────────────────────────
 half     │←───────────────── 1 (nửa bước) ────────────────────────→
 _step
 dir      │←───────────────── 1 (tiến) ───────────────────────────→

 step                 ┌─────────────────────────────────────────────
 _tick     0     0    └─ 1 (mỗi chu kỳ, vì speed_div=1) ────────────

 state     0     0     1     2     3     4     5     6     7     0
                                                                 ▲
                                                          VÒNG KHÉP KÍN

 coil    0000  0000  0001  0011  0010  0110  0100  1100  1000  1001
                ▲      ▲                                          ▲
           run=0 ⟹ 0  bảng nửa bước: half[1]=0001 …          half[0]=1001

 assert                                                           ✅ dòng 27
                                                           (state<=7 — luôn đúng,
                                                            không phát hiện được gì)
```

**Chú ý cột `coil` tại cạnh #2:** `run` vẫn bằng 0 nên `coil = 0000` — và điều này xảy ra
**tổ hợp**, ngay khi `run` được đặt lên 1 tại `t = 16`, `coil` nhảy sang `half[0] = 1001`
**trước** cạnh #3. Dạng sóng ở trên vẽ giá trị **sau** mỗi cạnh nên không thể hiện điều đó;
xem §3 về đường Mealy.

### 1.2 Giai đoạn đổi chiều — ca quyết định của đề (cạnh #11 → #12)

```
 cạnh #    11    12
 t (ns)   105   115
          ─┬─────┬──
 clk     ─┘└────┘└──

 dir      1  │← 0 (đổi chiều tại t=116... thực ra tại t=106 trong TB)
          ───┴──────

 state     1     0
           ▲     ▲
     s_before=1  s' = s_before − 1 = 0     ★ TIỀN NHIỆM, KHÔNG PHẢI RESET

 coil    0001  1001
         half[1] half[0]

 assert          ✅ dòng 36:  state_dbg == ((s_before==0) ? 7 : s_before-1)
```

**Đây là ca quan trọng nhất của F08**, và cách testbench viết nó rất đúng: nó **lưu
`s_before`** rồi so với *tiền nhiệm*, thay vì so với một hằng số. Nhờ vậy ca này đúng bất
kể vị trí hiện tại là bao nhiêu.

**Đối chiếu với phản ví dụ trên cùng kích thích:**

```
                    cạnh 11   cạnh 12
  f08_stepper_ctrl:    1    ──▶   0      ← đi tới TIỀN NHIỆM (đúng)
  f08_bad_direction_reset: 1 ──▶  0      ← nhảy về GỐC (trùng hợp cũng bằng 0!)
```

> ⚠️ **Testbench hiện tại KHÔNG phân biệt được hai mạch ở ca này**, vì `s_before = 1` nên
> "tiền nhiệm" (`1−1 = 0`) và "gốc" (`0`) **trùng nhau**. Nếu đổi chiều tại `s = 5` thì
> mạch đúng cho `4`, mạch sai cho `0` — lúc đó mới phân biệt được.
>
> Mô hình Python làm đúng: `test_direction_change()` kiểm tại `s = 5` (→ `4`) và `s = 2`
> (→ `1`). **Testbench nên làm theo.** Đây là một khoảng trống thật, bổ sung vào
> `corner_cases.md` §3.1.

### 1.3 Giai đoạn bước đủ lùi (cạnh #13 → #20)

```
 cạnh #    13    14    15    16    17    18    19    20
 t (ns)   125   135   145   155   165   175   185   195
          ─┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬──
 half     │← 0 (bước đủ) ──────────────────────────────→
 _step
 dir      │← 0 (lùi) ─────────────────────────────────→

 state     3     2     1     0     3     2     1     0
           ▲                       ▲
      wrap dưới: 0 → 3        wrap lại
      (vì state[1:0]==0 ⟹ 3'd3)

 coil    1100  0110  0011  1001  1100  0110  0011  1001
         full[3] full[2] full[1] full[0]

 assert                                              ✅ dòng 42 (state<=3)
```

Vì `state = 0` khi chuyển sang chế độ bước đủ, **vùng tàn dư `[4,7]` không bao giờ được
kích hoạt** trong kịch bản này. Cổng bảo vệ `coil = 1001` (RTL dòng 91) là **mã chưa từng
chạy** — xem `corner_cases.md` §3.1 CA-BS-2.

### 1.4 Dừng và reset (cạnh #21 → #22)

```
 cạnh #    21    22
 t (ns)   205   215
          ─┬─────┬──
 run      1 │← 0
          ──┴───────
 rst_n    1 │← 0 (tại t=206)
          ──┴───────

 state     0     0      (run=0 ⟹ state giữ; reset ⟹ state ← 0)
 coil    0000  0000     ★ coil về 0 NGAY khi run hạ — tổ hợp, không chờ cạnh

 assert    ✅ dòng 47   ✅ dòng 52
          (coil==0)    (state==0 && coil==0)
```

## 2. Bảng kỳ vọng đầy đủ theo chu kỳ

| Cạnh | t | `run` | `half_step` | `dir` | `state` sau | `coil` sau | Dòng TB |
|---:|---:|:---:|:---:|:---:|---:|:---:|---|
| 1 | 5 | 0 | 1 | 1 | 0 | `0000` | reset (dòng 20–21) |
| 2 | 15 | 0 | 1 | 1 | 0 | `0000` | reset; `rst_n←1`, `run←1` tại t=16 |
| 3 | 25 | 1 | 1 | 1 | **1** | `0001` | `repeat(8) tick()` dòng 26 |
| 4 | 35 | 1 | 1 | 1 | 2 | `0011` | ″ |
| 5 | 45 | 1 | 1 | 1 | 3 | `0010` | ″ |
| 6 | 55 | 1 | 1 | 1 | 4 | `0110` | ″ |
| 7 | 65 | 1 | 1 | 1 | 5 | `0100` | ″ |
| 8 | 75 | 1 | 1 | 1 | 6 | `1100` | ″ |
| 9 | 85 | 1 | 1 | 1 | 7 | `1000` | ″ |
| 10 | 95 | 1 | 1 | 1 | **0** | `1001` | ″ · ✅ assert dòng 27 |
| 11 | 105 | 1 | 1 | 1 | 1 | `0001` | `dir=1; tick()` dòng 30–31 · `s_before←1` |
| 12 | 115 | 1 | 1 | **0** | **0** | `1001` | `dir=0; tick()` · ✅ assert dòng 36 |
| 13 | 125 | 1 | **0** | 0 | **3** | `1100` | `half_step=0; repeat(8)` dòng 40–41 |
| 14 | 135 | 1 | 0 | 0 | 2 | `0110` | ″ |
| 15 | 145 | 1 | 0 | 0 | 1 | `0011` | ″ |
| 16 | 155 | 1 | 0 | 0 | 0 | `1001` | ″ |
| 17 | 165 | 1 | 0 | 0 | 3 | `1100` | ″ |
| 18 | 175 | 1 | 0 | 0 | 2 | `0110` | ″ |
| 19 | 185 | 1 | 0 | 0 | 1 | `0011` | ″ |
| 20 | 195 | 1 | 0 | 0 | **0** | `1001` | ″ · ✅ assert dòng 42 |
| 21 | 205 | **0** | 0 | 0 | 0 (giữ) | **`0000`** | `run=0; tick()` · ✅ assert dòng 47 |
| 22 | 215 | 0 | 0 | 0 | 0 | `0000` | `rst_n=0; tick()` · ✅ assert dòng 52 |

**Dự đoán: sau khi vá lỗi cú pháp, testbench chạy hết 22 cạnh và PASS**
(`$finish` ≈ `t = 216`). ⬜ **Chưa xác nhận** — phải chạy mới biết.

## 3. Đường Mealy — điều mà giản đồ theo cạnh clock KHÔNG thể hiện

`coil` là đầu ra **tổ hợp** từ `(state, run, half_step)` — `fsm.md` §7.1. Nghĩa là nó đổi
**giữa** hai cạnh clock khi `run` hoặc `half_step` đổi:

```
                 cạnh N                      cạnh N+1
                    │                            │
 clk       ─────────┘└───────────────────────────┘└──────

 run       ────────────────┐
                    1      └──── 0 ────────────────────
                           ▲
 coil      ──── 0110 ──────┼──── 0000 ─────────────────
                           ▲
                           └── ĐỔI NGAY, KHÔNG CHỜ CẠNH CLOCK
                               (đây là đặc trưng Mealy)

 state     ──── 4 ─────────────────── 4 (giữ, vì run=0) ──
                    ▲ state KHÔNG đổi — chỉ coil đổi
```

| Hệ quả | Đánh giá |
|---|---|
| Ngắt dòng cuộn **tức thì** khi hạ `run` | ✅ **Đúng và cần thiết** — an toàn cho động cơ |
| Có thể có **glitch** khi `half_step` đổi | ⚠️ Zero-delay không thấy; gate-level mới thấy |
| Cần ràng buộc `set_max_delay` từ `run`/`half_step` tới `coil` | ⚠️ `design.sdc` hiện **chỉ có** `set_input_delay`/`set_output_delay` — không mô tả đúng đường in→out |
| Độ lệch giữa 4 bit `coil` sau routing | ⚠️ Có thể tạo mẫu pha trung gian không hợp lệ vài trăm ps |

⟹ **Giản đồ theo cạnh clock về bản chất không diễn tả được phần Mealy của F08.** Muốn
thấy, phải mô phỏng với độ phân giải nhỏ hơn chu kỳ clock, và phải có độ trễ cổng (L4/L5).

## 4. Độ trễ đầu vào → đầu ra

| Đường | Độ trễ | Nguồn |
|---|---|---|
| `step_tick` → `state` đổi | **1 chu kỳ** | RTL dòng 78–80 |
| `state` đổi → `coil` đổi | **0 chu kỳ** (tổ hợp) | RTL dòng 90–95 |
| `run` hạ → `coil = 0000` | **0 chu kỳ** ★ | RTL dòng 94 — Mealy |
| `run` lên → `state` bắt đầu tiến | **1 chu kỳ** (với `speed_div ≤ 1`) | RTL dòng 78 |
| `dir` đổi → hướng bước đổi | **nhịp bước kế tiếp**; `state` **không** đổi ngay | RTL dòng 49, 54 |
| Chu kỳ giữa hai bước | `speed_div` chu kỳ (`0` ⟹ mỗi chu kỳ) | RTL dòng 62–68 |
| `rst_n` hạ → `state = 0` | **1 chu kỳ** (reset đồng bộ) | RTL dòng 72–74 |
| Một vòng điện đầy đủ | **8** nhịp (nửa bước) hoặc **4** nhịp (bước đủ) | — |

## 5. Những gì giản đồ này **không** chứng minh

| Không chứng minh | Vì sao |
|---|---|
| Hành vi RTL | Mô phỏng PASS; log ở `05_VERIFICATION/simulation.log` |
| Chuỗi bước đủ / nửa bước tiến | Được kiểm từng trạng thái trong testbench |
| Vùng tàn dư `s ∈ [4,7]` khi đổi sang bước đủ | Chưa có ca riêng; vẫn là khoảng trống |
| Bộ chia tần với `speed_div ≠ 1` | `speed_div=2` đã kiểm; giá trị lớn hơn chưa bao phủ |
| Không nhảy bước (INV-4) | Chuỗi tiến và lùi hiện được so từng trạng thái |
| Đổi chiều tại biên | Wrap lùi từ state 0 về state 7 đã kiểm; đảo chiều ở các vị trí khác chưa bao phủ hết |
| Glitch trên `coil` | Zero-delay không sinh glitch; cần L5 + SDF |
| Netlist tương đương RTL | Chưa chạy gate-level; archive có netlist nhưng chưa có log so sánh |
| Tần số hoạt động | Chu kỳ 10 ns là giả định, không phải clock target; cần timing budget của hệ thống |

---

*Phiên bản: v1.0 · Ngày: 2026-09-24*
