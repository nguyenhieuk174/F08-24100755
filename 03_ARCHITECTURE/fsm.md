# F08 · Máy trạng thái hữu hạn (FSM)

> F08 chứa **ba** FSM trong ba file RTL, và chúng khác nhau ở đúng những điểm Charter hỏi:
>
> | Module | FSM | Vai trò trong hồ sơ |
> |---|---|---|
> | `f08_stepper_ctrl` | 8 trạng thái, **một** thanh ghi dùng chung cho cả hai chế độ | Thiết kế chính — RTL testbench hiện PASS |
> | `f08_bad_dual_state_register` | **hai** thanh ghi riêng (2 bit + 3 bit) | Phương án thay thế để so sánh (Charter mục 2 câu 1) |
> | `f08_bad_direction_reset` | 8 trạng thái + `dir_d` | **Phản ví dụ**, không phải top của báo cáo hiện hành |
>
> §1–§7 phân tích `f08_stepper_ctrl`. §8 phân tích phản ví dụ. §9 so hai cách mã hoá.
> Các trạng thái chạy/đo cũ trong nội dung dưới đây là lịch sử; metrics hiện hành có tại
> `06_GDSII/physical_report.md`.

---

## 1. Bằng chứng có FSM

| Bằng chứng | Trích |
|---|---|
| Thanh ghi trạng thái tường minh | `logic [2:0] state, state_next;` (dòng 14) |
| Logic chuyển trạng thái tách riêng | `always_comb` tính `state_next` (dòng 45–59) |
| Thanh ghi trạng thái cập nhật đồng bộ | `state <= state_next;` trong `always_ff` (dòng 80) |
| Logic giải mã đầu ra tách riêng | `always_comb` tính `coil` (dòng 90–95) |
| Netlist xác nhận **cho phản ví dụ** | `_37_ .Q(state[0])`, `_38_ .Q(state[1])`, `_39_ .Q(state[2])`, `_36_ .Q(dir_d)` |

> Đây là cấu trúc **ba khối kinh điển**: next-state logic (tổ hợp) → state register (tuần
> tự) → output logic (tổ hợp). Nhiều tài liệu gọi là "three-process FSM". `f08_stepper_ctrl`
> viết đúng khuôn mẫu này; F06 và F07 thì gộp next-state vào trong `always_ff`.

## 2. Sơ đồ trạng thái ASCII — chế độ **nửa bước** (8 trạng thái)

`T` = có nhịp bước (`step_tick = 1`). Không có `T` thì mọi trạng thái **tự lặp**.
`D` = `dir`.

```
                           T & D=1  (tiến)
             ┌──────▶───────▶───────▶───────▶───────▶───────▶───────▶──────┐
             │                                                             │
        ╔════════╗     ╔════════╗     ╔════════╗     ╔════════╗            │
   ┌───▶║  s=0   ║────▶║  s=1   ║────▶║  s=2   ║────▶║  s=3   ║────┐       │
   │    ║  1001  ║     ║  0001  ║     ║  0011  ║     ║  0010  ║    │       │
   │    ╚════════╝     ╚════════╝     ╚════════╝     ╚════════╝    │       │
   │        ▲              ▲              ▲              ▲          ▼       │
   │        └──────◀───────┴──────◀───────┴──────◀───────┘      ╔════════╗  │
   │                    T & D=0  (lùi)                          ║  s=4   ║  │
   │                                                            ║  0110  ║  │
   │    ╔════════╗     ╔════════╗     ╔════════╗                ╚════════╝  │
   └────║  s=7   ║◀────║  s=6   ║◀────║  s=5   ║◀───────────────────┘       │
        ║  1000  ║     ║  1100  ║     ║  0100  ║                            │
        ╚════════╝     ╚════════╝     ╚════════╝                            │
             ▲                                                              │
             └──────────────────────────────────────────────────────────────┘
                              (vòng khép kín 7 → 0 khi tiến)

   Mỗi trạng thái còn có một cạnh TỰ LẶP:  !T  /  s' = s   (giữ vị trí khi chưa tới nhịp)
   Reset (đồng bộ):  bất kỳ trạng thái nào  ──▶  s = 0
```

**Đọc sơ đồ:** đây là một **vòng tròn đơn thuần** — không có nhánh, không có trạng thái
chờ, không có trạng thái lỗi. Toàn bộ "độ thông minh" của FSM nằm ở hai chỗ: **hướng đi**
(`dir`) và **nhịp** (`step_tick`).

Quan trọng: `dir` **không** xuất hiện trong bất kỳ lệnh gán `state ← 0` nào. Đó chính là
cơ chế bảo đảm đổi chiều không làm mất bước.

## 3. Sơ đồ trạng thái ASCII — chế độ **bước đủ** (4 trạng thái) và vùng tàn dư

```
        ┌──────── T & D=1 (tiến) ────────┐
        │                                │
   ╔════════╗   ╔════════╗   ╔════════╗   ╔════════╗
   ║  s=0   ║──▶║  s=1   ║──▶║  s=2   ║──▶║  s=3   ║──┐
   ║  1001  ║   ║  0011  ║   ║  0110  ║   ║  1100  ║  │
   ╚════════╝◀──╚════════╝◀──╚════════╝◀──╚════════╝  │
        ▲            T & D=0 (lùi)                    │
        └───────────────────────────────────────────◀─┘

 ─────────────────────────────────────────────────────────────────────────────
  VÙNG TÀN DƯ — chỉ tới được khi CHUYỂN từ nửa bước sang bước đủ lúc s ∈ [4,7]

   ╔════════╗   ╔════════╗   ╔════════╗   ╔════════╗
   ║  s=4   ║──▶║  s=5   ║──▶║  s=6   ║──▶║  s=7   ║───── T&D=1 ────▶ s=0
   ╚════╤═══╝   ╚════════╝   ╚════════╝   ╚════════╝                (vì 7[1:0]=3)
        │
        └── T & D=0 ──▶ s=3   (vì 4[1:0]=0 ⟹ state_next = 3'd3)

   coil trong vùng này:  cổng bảo vệ dòng 91 ép  coil = 4'b1001
                         (KHÔNG dùng bảng tra — xem §6.2)
```

**Vùng tàn dư là trạng thái bất hợp lệ thật của F08** — khác hẳn F06 (không có trạng thái
bất hợp lệ) và F07 (`ptr=3` không tới được). Ở F08, vùng này **tới được bằng kích thích ở
cổng vào**: chỉ cần hạ `half_step` khi `s ≥ 4`.

## 4. Bảng chuyển trạng thái đầy đủ

Đọc từ `always_comb` dòng 45–59 và `always_ff` dòng 71–88.

### 4.1 Logic chuyển trạng thái (`state_next`)

| # | `half_step` | `dir` | Điều kiện trên `state` | `state_next` | Dòng |
|---:|:---:|:---:|---|---|---:|
| N1 | 1 | 1 | `state == 7` | `0` | 50 |
| N2 | 1 | 1 | `state != 7` | `state + 1` | 50 |
| N3 | 1 | 0 | `state == 0` | `7` | 52 |
| N4 | 1 | 0 | `state != 0` | `state − 1` | 52 |
| N5 | 0 | 1 | `state[1:0] == 3` | `0` | 55 |
| N6 | 0 | 1 | `state[1:0] != 3` | `state + 1` | 55 |
| N7 | 0 | 0 | `state[1:0] == 0` | `3` | 57 |
| N8 | 0 | 0 | `state[1:0] != 0` | `state − 1` | 57 |

**Kiểm đầy đủ:** 2 (`half_step`) × 2 (`dir`) = 4 tổ hợp, mỗi tổ hợp có 2 nhánh loại trừ
nhau ⟹ phủ hết. Cộng gán mặc định `state_next = state;` ở dòng 46 ⟹ **không suy ra latch**.

> ⚠️ Chú ý N5–N8: điều kiện wrap kiểm trên `state[1:0]` (2 bit) nhưng phép cộng/trừ thực
> hiện trên **cả 3 bit**. Đây là nguồn gốc của vùng tàn dư ở §3. Xem `functional_spec.md`
> §6.2.

### 4.2 Logic cập nhật thanh ghi (`always_ff`)

| # | `rst_n` | `run` | `step_tick` | `state'` | `div_count'` | Dòng |
|---:|:---:|:---:|:---:|---|---|---:|
| S1 | **0** | — | — | **`0`** | `0` | 72–74 |
| S2 | 1 | **0** | — | **giữ** | `0` | 76–77 |
| S3 | 1 | 1 | **1** | **`state_next`** | `0` | 78–80 |
| S4 | 1 | 1 | **0** | **giữ** | `div_count + 1` | 81–82 |
| S5 | 1 | — | — | *(ghi đè)* `0` nếu `half_step && state === 3'bxxx` | — | 85–86 |

Hàng **S5** là dòng có vấn đề — xem §6.3.

### 4.3 Logic sinh nhịp bước (`step_tick`)

| # | `run` | `speed_div` | Điều kiện | `step_tick` | Dòng |
|---:|:---:|---|---|:---:|---:|
| K1 | 0 | — | — | **0** | 62 |
| K2 | 1 | `== 0` | — | **1** (bước mỗi chu kỳ) | 64–65 |
| K3 | 1 | `> 0` | `div_count >= speed_div − 1` | **1** | 66–67 |
| K4 | 1 | `> 0` | `div_count < speed_div − 1` | **0** | mặc định dòng 62 |

### 4.4 Logic giải mã đầu ra (`coil`)

| # | `run` | `half_step` | `state` | `coil` | Dòng |
|---:|:---:|:---:|---|---|---:|
| C1 | — | 0 | `> 3` | **`1001`** (cổng bảo vệ) | 91–92 |
| C2 | 0 | — | — | **`0000`** | 94 |
| C3 | 1 | 1 | `0..7` | bảng nửa bước `phase_decode(state, 1)` | 94, 22–33 |
| C4 | 1 | 0 | `0..3` | bảng bước đủ `phase_decode(state, 0)` | 94, 34–42 |

> ⚠️ Chú ý thứ tự ưu tiên: **C1 đứng trước C2**. Nghĩa là khi `half_step=0` và `state > 3`,
> `coil = 1001` **kể cả khi `run = 0`**. Đây là một vi phạm nhỏ của INV-5 (`run=0 ⟹
> coil=0000`) trong đúng vùng tàn dư. Có chủ ý (giữ cuộn ở mẫu an toàn) hay sơ suất — **cần
> thầy xác nhận**. Chưa mô phỏng được nên chưa quan sát được.

## 5. Mã hoá trạng thái — và trả lời Charter mục 2 câu 1

```systemverilog
logic [2:0] state;     // MỘT thanh ghi duy nhất cho CẢ HAI chế độ
```

| Đặc điểm | Giá trị |
|---|---|
| Kiểu mã hoá | **Nhị phân**, và **mã hoá chính là vị trí trong chuỗi** |
| Bề rộng | 3 bit ⟹ **3 flip-flop** |
| Nửa bước dùng | **8/8** giá trị |
| Bước đủ dùng | **4/8** giá trị (chỉ `0..3`) — còn **4 mã thừa** |
| Có `typedef enum`? | ❌ **Không** — khác F06 và F07 |

### 5.1 Vì sao **không** dùng `typedef enum` lại hợp lý ở đây

F06 và F07 dùng `enum` vì trạng thái của chúng là các **khái niệm** (`STABLE_LOW`, `IDLE`).
Ở F08, trạng thái là một **con số có ý nghĩa số học**: vị trí thứ `k` trong chuỗi. Các phép
`state + 1`, `state - 1`, `state[1:0]` chỉ có nghĩa khi mã hoá là nhị phân liên tiếp. Đặt
tên `STEP_0 … STEP_7` rồi vẫn cộng trừ trên chúng sẽ **gây hiểu nhầm** rằng mã hoá có thể
đổi tuỳ ý — trong khi không thể.

⟹ **Mã hoá ở F08 là một phần của đặc tả, không phải chi tiết hiện thực.** Yosys **không
được phép** tái mã hoá `state` (lệnh `fsm` sẽ không nhận ra đây là FSM vì không có `case`
trên toàn bộ state). Đây là khác biệt bản chất so với F06/F07.

### 5.2 Charter mục 2 câu 1 — *"dùng chung thanh ghi trạng thái hay riêng?"*

**`f08_stepper_ctrl` dùng CHUNG.** Bằng chứng: một khai báo `logic [2:0] state` duy nhất;
cả N1–N4 (nửa bước) và N5–N8 (bước đủ) đều ghi vào cùng thanh ghi đó.

Gói RTL có sẵn phương án **riêng** để so sánh — `f08_bad_dual_state_register.sv`:

```systemverilog
logic [1:0] full_state;      // 2 FF
logic [2:0] half_state;      // 3 FF
…
always_comb state = half_step ? half_state : {1'b0, full_state};
```

| | **Chung** (`f08_stepper_ctrl`) | **Riêng** (`f08_bad_dual_state_register`) |
|---|---|---|
| FF cho vị trí | **3** | **5** (2 + 3) |
| Logic chuyển trạng thái | 1 bộ, có mux theo `half_step` | 2 bộ độc lập + 1 mux đầu ra |
| Đổi chế độ giữa chừng | ⚠️ sinh **vùng tàn dư** `s ∈ [4,7]` (§3) | ✅ mỗi chế độ giữ vị trí riêng, không tàn dư |
| Đổi chế độ rồi đổi lại | Vị trí **đã bị chuyển đổi** | **Khôi phục** vị trí cũ của chế độ đó |
| Quan hệ vật lý giữa hai chế độ | ✅ giữ được (`full[k] = half[2k]`) | ❌ **mất** — hai vị trí trôi độc lập, rotor có thể nhảy khi đổi chế độ |
| Cell / diện tích | ⬜ **chưa đo** | ⬜ **chưa đo** |

> 👉 Tên file gọi phương án riêng là *"bad"*, nhưng ghi chú đầu file lại viết
> *"EDUCATIONAL ALTERNATIVE … Included to discuss why the mentor scaffold prefers a shared
> state register"* — tức đây là **phương án thay thế để thảo luận**, không phải phản ví dụ
> sai hoàn toàn. Nó **tốn hơn 2 FF** và **mất quan hệ vật lý giữa hai chế độ** — lý do chính
> để chọn dùng chung. Đổi lại, nó **không có vùng tàn dư**.
>
> Cả hai module **chưa được tổng hợp** (top là `f08_bad_direction_reset`), nên con số cell
> để so sánh ⬜ chưa có. Đây là phần chính của Charter mục 9 chưa trả lời được.

## 6. Xử lý trạng thái bất hợp lệ

### 6.1 Ở chế độ nửa bước — không có trạng thái bất hợp lệ

3 bit, 8 giá trị, dùng cả 8. Giống F06: không tồn tại mã ngoài tập hợp lệ.

### 6.2 Ở chế độ bước đủ — có 4 mã bất hợp lệ, xử lý ở **bộ giải mã đầu ra**

```systemverilog
always_comb begin
    if (!half_step && (state > 3'd3))
        coil = 4'b1001;                        // ← cổng bảo vệ
    else
        coil = run ? phase_decode(state, half_step) : 4'b0000;
end
```

| Câu hỏi | Trả lời |
|---|---|
| `state ∈ [4,7]` ở chế độ bước đủ có tới được không? | **CÓ** — chỉ cần hạ `half_step` khi `s ≥ 4`. Khác F06/F07, đây là trạng thái bất hợp lệ **tới được bằng kích thích cổng vào**. |
| Xử lý ở đâu? | Ở **bộ giải mã đầu ra**, không phải ở logic chuyển trạng thái. Đây là lựa chọn kiến trúc đáng bàn. |
| Có tự phục hồi không? | **Có, sau ≤3 nhịp bước.** Tiến: `4→5→6→7→0`. Lùi: `4→3` ngay. |
| Trong lúc đó `coil` bằng gì? | `4'b1001` — mẫu hợp lệ của cả hai bảng (`half[0] = full[0] = 1001`). Chọn mẫu này là hợp lý: nó là mẫu hai-cuộn, giữ mô-men, và là điểm gốc chung của hai chuỗi. |
| Rotor có bị giật không? | **Có thể.** Ép `coil = 1001` trong khi rotor đang ở vị trí ứng với `s=5` là một bước nhảy vật lý. Cổng bảo vệ chống được *mẫu pha vô nghĩa*, **không** chống được *mất bước*. |
| Vì sao không xử lý ở logic chuyển trạng thái? | Nếu thêm `if (!half_step) state_next = {1'b0, state[1:0]};` thì FSM về dải hợp lệ **ngay lập tức** thay vì sau ≤3 nhịp, nhưng bước nhảy vị trí cũng lớn hơn. Cả hai cách đều mất bước; cách hiện tại mất **chậm và ít** hơn. **Cần thầy quyết định** — ghi nhận, không tự sửa. |

### 6.3 Dòng 85–86 — "xử lý trạng thái X" không hợp lệ

```systemverilog
if (half_step && (state === 3'bxxx))
    state <= 3'd0;
```

| Vấn đề | Chi tiết |
|---|---|
| `===` so sánh **4 trạng thái** | Không tồn tại trong phần cứng; silicon không có giá trị `X` |
| Trong mô phỏng | Sau reset `state` không bao giờ là `X` ⟹ **mã chết** |
| Vị trí | Nằm **ngoài** chuỗi `if/else` ở trên ⟹ nếu đúng, nó **ghi đè** `state <= state_next` |
| Khi tổng hợp | Yosys thường rút gọn về hằng `0`; một số tool báo lỗi. **Chưa kiểm chứng được** — module này chưa được tổng hợp |
| Cách đúng để phòng vệ trạng thái lạ | Ở đây **không cần**: nửa bước dùng hết 8 mã. Nếu muốn phòng vệ `X` cho mô phỏng, dùng `` `ifdef SIMULATION `` + `assert`, không đưa vào mã tổng hợp được. |

**Ghi nhận cho thầy, không tự sửa.**

## 7. Moore hay Mealy — kèm bằng chứng

**`f08_stepper_ctrl` là máy MEALY** đối với `coil`, và **MOORE** đối với `state_dbg`.
Một module, hai loại đầu ra — rất tiện để dạy.

### 7.1 `coil` là đầu ra Mealy — bằng chứng

```systemverilog
always_comb begin
    if (!half_step && (state > 3'd3))  coil = 4'b1001;
    else  coil = run ? phase_decode(state, half_step) : 4'b0000;
end
```

`coil` được tính trong **`always_comb`**, và biểu thức đọc **`run`** và **`half_step`** —
cả hai đều là **cổng vào trực tiếp**.

| Định nghĩa | Thoả? |
|---|---|
| **Mealy:** đầu ra là hàm của (trạng thái, **đầu vào hiện tại**) | ✅ — `coil = f(state, run, half_step)` |
| **Moore:** đầu ra chỉ là hàm của trạng thái | ❌ — hạ `run` giữa chu kỳ làm `coil` đổi **ngay**, không chờ cạnh clock |

**Thí nghiệm kiểm chứng (chưa chạy được):** trong testbench, hạ `run` tại `#3` sau cạnh lên
rồi quan sát `coil`. Nếu Mealy, `coil` về `0000` **ngay lập tức**. ⬜ Không chạy được vì
testbench `COMPILE_FAIL` — xem `known_issues.md`.

### 7.2 `state_dbg` là đầu ra Moore

```systemverilog
assign state_dbg = state;
```

Nối thẳng từ thanh ghi ra cổng, không qua logic nào ⟹ Moore thuần.

### 7.3 Hệ quả của việc `coil` là Mealy

| Hệ quả | Đánh giá |
|---|---|
| `coil` về `0000` **ngay** khi hạ `run` | ✅ **Tốt và cần thiết** — ngắt dòng cuộn là hành động an toàn, càng nhanh càng tốt. Chờ một chu kỳ clock là chờ vô ích. |
| `coil` **có thể glitch** khi `half_step` đổi | ⚠️ Glitch trên đường lái cuộn động cơ: vô hại nếu tầng driver có bộ lọc, **có hại** nếu driver phản ứng theo cạnh |
| Có đường tổ hợp in→out | ⚠️ Phải ràng buộc timing từ `run`/`half_step` tới `coil` bằng `set_max_delay`, không chỉ `set_input_delay` |
| Không tốn FF cho đầu ra | ✅ 4 bit `coil` không cần 4 FF |

> **Đối chiếu ba đề trong nhóm F — một bảng rất đáng dạy:**
>
> | Đề | Đầu ra | Loại | Vì sao chọn vậy |
> |---|---|---|---|
> | F06 | `filtered_level`, `press_pulse` | **Moore** | Chống glitch, dễ timing; +1 chu kỳ chấp nhận được |
> | F07 | `grant`, `busy` | **Moore** | Glitch trên `grant` gây **tranh chấp bus** — không thể chấp nhận |
> | F08 | `coil` | **Mealy** | Ngắt dòng cuộn phải **tức thì**; glitch ít nguy hiểm hơn (tải là cuộn cảm, lọc tự nhiên) |
>
> Ba đề, ba lựa chọn khác nhau, và mỗi lựa chọn đúng **vì bối cảnh ứng dụng**, không phải vì
> một quy tắc chung. Đây là câu hỏi bảo vệ tốt cho cả nhóm F.

## 8. `f08_bad_direction_reset` — FSM được tổng hợp

```systemverilog
always_ff @(posedge clk) begin
    if (!rst_n) begin state <= 3'd0; dir_d <= 1'b1; end
    else if (step_tick) begin
        if (dir != dir_d)
            state <= 3'd0;                                    // ← LỖI CỐ Ý
        else if (dir)
            state <= (state == 3'd7) ? 3'd0 : state + 1'b1;
        else
            state <= (state == 3'd0) ? 3'd7 : state - 1'b1;
        dir_d <= dir;
    end
end
```

### 8.1 Sơ đồ trạng thái — cạnh phá hỏng mọi thứ

```
        ╔════════╗    ╔════════╗    ╔════════╗          ╔════════╗
   ┌───▶║  s=0   ║───▶║  s=1   ║───▶║  s=2   ║─ … ─────▶║  s=7   ║───┐
   │    ╚════════╝    ╚════╤═══╝    ╚════╤═══╝          ╚════╤═══╝   │
   │         ▲             │             │                   │       │
   │         └─────────────┴─────────────┴───────────────────┘       │
   │            ★ T & (dir != dir_d)  /  s' = 0                      │
   │              "ĐỔI CHIỀU → NHẢY VỀ GỐC"  ── TỪ MỌI TRẠNG THÁI    │
   │                                                                  │
   └──────────────────────────────────────────────────────────────────┘
```

Mọi trạng thái đều có một cạnh đi thẳng về `s=0` khi `dir` đổi. Về mặt FSM, `s=0` trở thành
một **hố hút** (sink) cho mọi thao tác đổi chiều.

### 8.2 Hậu quả vật lý

| Vị trí rotor trước khi đổi chiều | `state` sau khi đổi chiều | Sai lệch |
|---:|---:|---|
| `s=1` | `0` | 1 bước |
| `s=4` | `0` | **4 bước** |
| `s=7` | `0` | **7 bước** (hoặc 1 bước theo chiều kia) |

Và sai lệch này **tích luỹ**: mỗi lần đổi chiều lại mất thêm. Trên trục máy in 3D, sau vài
chục lần đảo chiều, vị trí thật và vị trí mà phần mềm nghĩ đã lệch hẳn. Rotor **không** tự
sửa được vì F08 không có phản hồi vị trí (Charter mục 3: ngoài phạm vi).

Đây chính xác là rủi ro Charter mục 10 nêu: *"Đổi chiều bằng cách đảo thứ tự bảng mà quên
vị trí hiện tại → mất bước."*

### 8.3 Mã hoá và Moore/Mealy của phản ví dụ

| | |
|---|---|
| Ô nhớ | **4 FF** đo được: `state[2:0]` (netlist `_37_ _38_ _39_`) + `dir_d` (`_36_`) |
| `dir_d` là gì | **Thanh ghi dịch 1 tầng** nhớ chiều ở nhịp trước — giống `previous` của F06 |
| Đầu ra `state` | `Q` của FF nối thẳng ra cổng ⟹ **MOORE** |
| Trạng thái bất hợp lệ | Không có — 3 bit, 8 mã, dùng hết |
| Có `coil` không | ❌ **Không** — module này không giải mã pha |

### 8.4 Vì sao con số 4 FF là một cái bẫy

Charter mục 10: *"Dấu hiệu làm đúng: 3 ô nhớ vị trí + vài bit chế độ ≈ 4–6 ô nhớ."*

Đo được **đúng 4 FF** ⟹ **khớp dải dự đoán** ⟹ người đọc vội sẽ kết luận "làm đúng".

Nhưng 4 FF đó là `state[2:0]` + `dir_d` của **phản ví dụ**. `f08_stepper_ctrl` sẽ có
**3** (`state`) + **8** (`div_count`, vì `SPEED_DIV_W = 8`) = **11 FF** — **ngoài** dải
Charter, vì Charter không tính tới bộ chia tần.

> 📌 **Bài học phương pháp quan trọng nhất của F08:** một con số **khớp dự đoán** mà vẫn
> **sai** thì nguy hiểm hơn một con số lệch rõ ràng — nó không kích hoạt nghi ngờ. Muốn
> tránh, phải kiểm **danh tính** của cái được đo (top module trong `synth.ys`) trước khi
> kiểm **giá trị** của nó.

## 9. Đối chiếu ba cách mã hoá trong cùng một hồ sơ

| | `f08_stepper_ctrl` | `f08_bad_dual_state_register` | `f08_bad_direction_reset` |
|---|---|---|---|
| Thanh ghi vị trí | 1 × 3 bit | 2 × (2 + 3) bit | 1 × 3 bit |
| Thanh ghi phụ | `div_count` 8 bit | — | `dir_d` 1 bit |
| FF dự kiến | **11** (3 + 8) | **5** (+ logic chia tần nếu thêm) | **4** (đo được) |
| Đổi chiều đúng? | ✅ | ✅ | ❌ **mất bước** |
| Đổi chế độ đúng? | ⚠️ có vùng tàn dư | ✅ không tàn dư | ⬛ không có chế độ |
| Quan hệ `full[k]=half[2k]`? | ✅ giữ | ❌ mất | ⬛ — |
| Giải mã pha? | ✅ có | ❌ không | ❌ không |
| **Đã được tổng hợp?** | ❌ | ❌ | ✅ **← chính là top** |
| **Đã được mô phỏng?** | ⚠️ TB không biên dịch được | ❌ | ❌ |

> Bảng này là bức tranh trung thực nhất về trạng thái hồ sơ F08: **module đúng chưa từng
> được tổng hợp, và cũng chưa từng chạy được một chu kỳ mô phỏng nào.**

---

*Phiên bản: v1.0 · Ngày: 2026-09-24*
