# F08 · Phần điều khiển (Control)

F08 là mạch **tuần tự** với cấu trúc điều khiển ba tầng rõ rệt: một bộ chia tần quyết định
*khi nào* bước, một FSM quyết định *đi đâu*, và một bộ giải mã quyết định *cấp dòng cuộn
nào*.

---

## 1. Ba tầng điều khiển

```
 ┌── ① KHI NÀO BƯỚC ──────────────────────────────────────────────┐
 │    run + speed_div + div_count  ──▶  step_tick                  │
 │    (tuần tự, 8 FF)                                              │
 └──────────────────────────┬──────────────────────────────────────┘
                            │ step_tick (1 bit)
 ┌──────────────────────────▼──────────────────────────────────────┐
 │ ── ② ĐI ĐÂU ──                                                  │
 │    dir + half_step + state  ──▶  state_next  ──▶  state         │
 │    (tổ hợp → tuần tự, 3 FF)                                     │
 └──────────────────────────┬──────────────────────────────────────┘
                            │ state[2:0]
 ┌──────────────────────────▼──────────────────────────────────────┐
 │ ── ③ CẤP DÒNG CUỘN NÀO ──                                       │
 │    state + half_step + run  ──▶  coil[3:0]                      │
 │    (TỔ HỢP THUẦN — đường Mealy, in → out)                       │
 └─────────────────────────────────────────────────────────────────┘
```

Ba tầng nối **một chiều**, không có hồi tiếp từ ③ về ① hay ②. Cấu trúc này làm F08 dễ hiểu
hơn F07 (vốn có vòng `grant → ptr → chọn → grant`).

## 2. Bảng tín hiệu điều khiển và tác dụng

| Tín hiệu | Chiều | Tầng | Tác dụng | Dòng RTL |
|---|---|:---:|---|---:|
| `run` | vào | ①③ | **Hai vai:** (a) cho phép bộ chia tần chạy; (b) **ngắt dòng cuộn** ngay lập tức khi hạ | 63, 76, 94 |
| `speed_div[7:0]` | vào | ① | Đặt số chu kỳ clock giữa hai bước. `0` ⟹ bước mỗi chu kỳ | 64, 66 |
| `step_tick` | nội bộ | ①→② | **Nhịp bước** — tín hiệu điều khiển trung tâm | 62–68, 78 |
| `dir` | vào | ② | Chọn hướng `+1` hay `−1`. **Không** làm `state` nhảy | 49, 54 |
| `half_step` | vào | ②③ | **Hai vai:** (a) chọn chuỗi 8 hay 4 trạng thái; (b) chọn bảng giải mã | 48, 91, 94 |
| `state[2:0]` | nội bộ | ②→③ | Vị trí trong chuỗi | 46–58, 94 |
| `div_count[7:0]` | nội bộ | ① | Bộ đếm chia tần | 66, 77, 79, 82 |
| `coil[3:0]` | ra | ③ | Mẫu 4 pha lái driver | 90–95 |
| `state_dbg[2:0]` | ra | — | Quan sát vị trí (gỡ lỗi) | 97 |

### 2.1 `run` đóng hai vai — và hai vai đó có ngữ nghĩa thời gian khác nhau

```systemverilog
// Vai (a): TUẦN TỰ — qua flip-flop
if (!run) div_count <= '0;

// Vai (b): TỔ HỢP — tức thì
coil = run ? phase_decode(state, half_step) : 4'b0000;
```

| Vai | Ngữ nghĩa | Độ trễ |
|---|---|---|
| (a) dừng đếm | Chờ cạnh clock | 1 chu kỳ |
| (b) **ngắt dòng cuộn** | **Tức thì**, không chờ clock | 0 chu kỳ |

Vai (b) là lý do `coil` là đầu ra **Mealy** (`fsm.md` §7). Và đó là lựa chọn **đúng**: ngắt
dòng cuộn là hành động an toàn; chờ một chu kỳ clock là chờ vô ích, và nếu clock dừng thì
chờ mãi mãi. Một `coil` kiểu Moore sẽ giữ dòng cuộn thêm một chu kỳ sau khi `run` hạ — trên
động cơ thật, đó là nhiệt thừa và mô-men giữ không mong muốn.

### 2.2 `half_step` cũng đóng hai vai — và đây là nguồn gốc vùng tàn dư

| Vai | Ở đâu | Hệ quả khi đổi |
|---|---|---|
| Chọn **chuỗi** (8 hay 4 trạng thái) | `always_comb` next-state, dòng 48 | Đổi ngay chu kỳ kế |
| Chọn **bảng giải mã** | `always_comb` coil, dòng 94 | Đổi **tức thì** (tổ hợp) |

Vấn đề: hai vai đổi **không đồng bộ với nhau về ngữ nghĩa**. Khi hạ `half_step` lúc
`state = 5`, bảng giải mã đổi ngay sang bảng bước đủ — nhưng bảng bước đủ chỉ có 4 mục và
`state = 5` không thuộc dải hợp lệ. Đó chính là lý do cổng bảo vệ dòng 91 tồn tại.

## 3. Cổng bảo vệ đầu ra — điều khiển khi trạng thái ngoài dải

```systemverilog
always_comb begin
    if (!half_step && (state > 3'd3))
        coil = 4'b1001;                     // ← cổng bảo vệ
    else
        coil = run ? phase_decode(state, half_step) : 4'b0000;
end
```

| Câu hỏi | Trả lời |
|---|---|
| Nó chống cái gì? | Chống việc giải mã một `state` không thuộc bảng bước đủ. Không có nó, hàm `phase_decode` rơi vào `default: 4'b0000` — **ngắt dòng đột ngột** giữa lúc động cơ đang chạy. |
| Vì sao chọn mẫu `1001`? | Vì `half[0] = full[0] = 1001` — điểm gốc chung của hai chuỗi, và là mẫu **hai cuộn** nên giữ được mô-men. |
| Nó chống được gì? | Mẫu pha vô nghĩa, và mất mô-men đột ngột. |
| Nó **không** chống được gì? | **Mất bước.** Ép `coil = 1001` khi rotor đang ở vị trí ứng với `s=5` là một bước nhảy vật lý. Cổng bảo vệ làm hậu quả **an toàn về điện**, không **đúng về vị trí**. |
| ⚠️ Tác dụng phụ | Điều kiện này đứng **trước** phép kiểm `run`, nên khi `half_step=0`, `state>3` **và** `run=0`, `coil` vẫn bằng `1001` thay vì `0000` — vi phạm INV-5. **Có chủ ý hay sơ suất? Cần thầy xác nhận.** |
| Đã kiểm chưa? | ❌ **Chưa** — mã này chưa từng chạy (`COMPILE_FAIL`). Xem `corner_cases.md` §3.1 CA-BS-2. |

## 4. Bộ chia tần — điều khiển thời gian

```systemverilog
always_comb begin
    step_tick = 1'b0;
    if (run) begin
        if (speed_div == '0)                    step_tick = 1'b1;
        else if (div_count >= speed_div - 1'b1) step_tick = 1'b1;
    end
end
```

| Đặc điểm | Ghi chú |
|---|---|
| Gán mặc định `step_tick = 0` | Chặn suy ra latch — khối tổ hợp đầy đủ |
| Nhánh riêng cho `speed_div == 0` | **Cần thiết**: nếu không, `speed_div - 1` cho `8'hFF` và bộ đếm phải chạy 255 chu kỳ. Chặn ca biên đúng cách. |
| So sánh **hai biến** 8 bit | ⚠️ Đắt hơn hẳn so với hằng (đối chiếu F06: `count >= DB_CYCLES-1` so với hằng số) |
| `div_count` được xoá ở **hai** chỗ | `!run` (dòng 77) và khi `step_tick` (dòng 79) ⟹ không bao giờ tràn |
| Dùng `>=` chứ không `==` | ✅ **An toàn**: nếu `speed_div` bị giảm xuống dưới `div_count` giữa chừng, `==` sẽ **không bao giờ** khớp và bộ đếm chạy tự do; `>=` thoát ngay. |

> Chi tiết cuối là một quyết định phòng thủ tốt và đáng chỉ ra khi dạy: `==` và `>=` cho
> cùng kết quả trong hoạt động bình thường, nhưng khác hẳn khi tham số đổi giữa chừng.

## 5. Quan hệ điều khiển ↔ datapath

Giao diện giữa điều khiển và hai datapath (`datapath.md` §1) rất mỏng:

```
  ĐIỀU KHIỂN                              DATAPATH
  ──────────                              ─────────
  run ──────────── cho phép đếm ─────────▶ div_count
  speed_div ────── ngưỡng ───────────────▶ bộ so sánh
                                              │
  step_tick ◀────── cờ từ datapath A ─────────┘
      │
      └─────────── cho phép ghi ─────────▶ state
  dir, half_step ─ chọn hướng/chuỗi ─────▶ bộ tăng/giảm
                                              │
  run, half_step ─ chọn bảng ────────────▶ bộ giải mã ──▶ coil
```

Toàn bộ thông tin từ datapath A về điều khiển gói trong **1 bit** (`step_tick`) — giống mẫu
FSMD của F06.

## 6. Chiến lược reset

| Hạng mục | Giá trị | Bằng chứng |
|---|---|---|
| Kiểu reset | **Đồng bộ**, tích cực mức thấp | `always_ff @(posedge clk)` không có `or negedge rst_n` (dòng 71) |
| Phủ thanh ghi nào | `state`, `div_count` — **cả 11 FF dự kiến** | dòng 72–74 |
| Trạng thái sau reset | `state = 0`, `div_count = 0` | dòng 73–74 |
| `coil` sau reset | `0000` **nếu `run = 0`**; nếu `run = 1` thì `coil = 1001` ngay (vì `state=0`) | dòng 94 — **tổ hợp**, không chờ clock |
| Chi phí phần cứng | Cổng chèn trên đường `D` của mỗi FF. Ở phản ví dụ: `and2_0 ×1` | netlist |
| Đã kiểm chưa | ❌ **Chưa** — TB dòng 50–52 kiểm reset nhưng TB `COMPILE_FAIL` | `known_issues.md` |

### 6.1 Reset đặt lại bộ đếm, **không** đặt lại trục máy

Đây là điểm quan trọng nhất về reset ở F08, và nó là hệ quả của vòng điều khiển hở:

```
   rst_n = 0  ──▶  state ← 0        (biến đếm trong chip)
                   rotor ở đâu thì ở đó   (thế giới vật lý)
                        ▲
                        └── KHÔNG CÓ cơ chế nào đồng bộ hai thứ này
```

Sau reset, phần mềm nghĩ trục ở vị trí 0; thực tế nó ở vị trí nào thì không ai biết. Mọi
máy in 3D thật vì vậy đều có quy trình **homing** bằng công tắc giới hạn — nằm hoàn toàn
ngoài F08 (Charter mục 3: phản hồi vị trí ngoài phạm vi).

⟹ Nghĩa vụ hợp đồng của tầng ngoài: *sau reset, phải homing trước khi tin vào `state_dbg`.*
Điều này hiện **chưa được ghi ở đâu** trong tầng đặc tả tự sinh. Ghi nhận ở đây và ở
`system_diagram.md` §2.1 nghĩa vụ 5.

## 7. Phần điều khiển của `f08_bad_direction_reset` (module được đo)

```systemverilog
else if (step_tick) begin
    if (dir != dir_d)
        state <= 3'd0;                                    // ← LỖI CỐ Ý
    else if (dir)  state <= (state == 3'd7) ? 3'd0 : state + 1'b1;
    else           state <= (state == 3'd0) ? 3'd7 : state - 1'b1;
    dir_d <= dir;
end
```

| Khác biệt so với `f08_stepper_ctrl` | Hệ quả |
|---|---|
| Có thêm thanh ghi `dir_d` (1 FF) | Nhớ chiều ở nhịp trước — bản thân việc này không sai |
| **Nhánh `if (dir != dir_d) state <= 0`** | ★ Lỗi: đổi chiều làm **mất vị trí**, tới 7 bước |
| `step_tick` là **cổng vào**, không tự sinh | Không có bộ chia tần ⟹ chỉ 4 FF thay vì 11 |
| Không có `half_step`, `run`, `coil` | Không có chế độ, không có giải mã pha, không ngắt được dòng |

**Vì sao nhánh sai đó trông hợp lý:** tác giả muốn "khi đổi chiều thì bắt đầu lại chuỗi
theo hướng mới". Ý tưởng đó đúng cho một **bộ sinh mẫu**, sai cho một **bộ theo dõi vị
trí**. Sự nhầm lẫn giữa hai vai trò này là bản chất của lỗi, và đó là lý do phản ví dụ này
đáng được giữ lại để dạy.

**Điểm dạy học phụ, đọc được từ STA:** nhánh sai đó còn làm `dir` có **fanout 5** và đặt
chuỗi 4 cổng lên đường tới hạn (`dir → … → state[2]`, 1,68 ns — `block_diagram.md` §4.3).
Logic sai vừa sai vừa đắt.

---

*Phiên bản: v1.0 · Ngày: 2026-09-24*
