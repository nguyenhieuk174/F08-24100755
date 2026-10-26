# F08 · Ca biên và ca góc (Corner Cases)

> **Cập nhật sau khi vá:** testbench RTL hiện biên dịch và PASS. Các đoạn phân tích bên
> dưới giữ lại chẩn đoán lịch sử trước khi vá; các câu khẳng định rằng RTL chưa
> chạy hoặc mọi ca đều FAIL không còn là trạng thái hiện tại. Kết quả mới nhất ở
> `05_VERIFICATION/test_matrix.csv` và `05_VERIFICATION/simulation.log`.

## Trạng thái ca kiểm thử hiện tại

| Ca | Bằng chứng RTL hiện tại |
|---|---|
| Nửa bước tiến đủ vòng, kiểm từng trạng thái | `testbench/f08_tb.sv`; PASS |
| Bước đủ tiến đủ vòng, kiểm từng trạng thái | `testbench/f08_tb.sv`; PASS |
| Đổi chiều và dừng/reset | `testbench/f08_tb.sv`; PASS |
| Biên quay nghịch từ state 0 về state 7 | Ca tự xây dựng; PASS |
| Biên bộ chia `speed_div=2` | Ca tự xây dựng; PASS |
| Gate-level và post-layout/SDF | Chưa chạy; không có bằng chứng |

---

## 1. Ca bắt buộc của Charter mục 8

| Ca (Charter) | Lý do kỹ thuật — nó bắt lỗi gì | Có trong TB? | Đã chạy? |
|---|---|---|:---:|
| **Quay thuận đủ một vòng ở cả hai chế độ** | Bắt lỗi bảng pha thiếu mục, wrap sai, hoặc nhảy bước. Cần **cả hai** chế độ vì hai bảng tra khác nhau. | ⚠️ **CHỈ CÓ NỬA BƯỚC** (dòng 25–27). **Thiếu hẳn bước đủ tiến** — xem §1.1 | ❌ |
| **Quay nghịch** | Bắt lỗi logic giảm và wrap dưới (`0 → 7` hoặc `0 → 3`). | ✅ bước đủ lùi (dòng 40–42); nửa bước lùi 1 nhịp (dòng 34–35) | ❌ |
| **Đổi chiều giữa chừng** | **Ca quyết định của đề.** Charter mục 10: *"Đổi chiều bằng cách đảo thứ tự bảng mà quên vị trí hiện tại → mất bước."* | ✅ dòng 29–37 — và viết đúng cách: lưu `s_before` rồi so với *tiền nhiệm*, không so với hằng số | ❌ |
| **Dừng** | Bắt lỗi `coil` không ngắt dòng khi `run = 0` — nguy hiểm thật: cuộn giữ dòng khi máy dừng sẽ nóng. | ✅ dòng 44–47 | ❌ |

### 1.1 Khoảng trống lớn nhất: **không có ca bước đủ TIẾN**

Truy vết kích thích của testbench:

| Dòng TB | `half_step` | `dir` | Chuỗi được chạy |
|---|:---:|:---:|---|
| 25–26 | 1 | 1 | **nửa bước tiến** ✅ |
| 30–31 | 1 | 1 | nửa bước tiến, 1 nhịp |
| 34–35 | 1 | **0** | **nửa bước lùi**, 1 nhịp |
| 40–41 | **0** | 0 | **bước đủ lùi** ✅ |
| — | **0** | **1** | ❌ **BƯỚC ĐỦ TIẾN — KHÔNG BAO GIỜ CHẠY** |

Chuỗi `0 → 1 → 2 → 3 → 0` ở chế độ bước đủ, tức nhánh **N5/N6** của bảng chuyển trạng thái
(`fsm.md` §4.1), **chưa từng được kích hoạt**. Đây là vi phạm trực tiếp Charter mục 8
(*"Quay thuận đủ một vòng ở **cả hai** chế độ"*).

Hậu quả cụ thể: nếu dòng 55 của RTL viết nhầm điều kiện wrap (ví dụ `state[1:0] == 2'd2`
thay vì `2'd3`), **không ca nào hiện có phát hiện được**.

### 1.2 Khoảng trống thứ hai: assertion kiểm **dải**, không kiểm **chuỗi**

```systemverilog
27:  assert(state_dbg <= 3'd7) else $fatal(1,"invalid half-step state");
42:  assert(state_dbg <= 3'd3) else $fatal(1,"invalid full-step state");
```

| Assertion | Vấn đề |
|---|---|
| Dòng 27 | `state_dbg` là **3 bit** ⟹ `state_dbg <= 7` **luôn đúng**, không thể FAIL. Assertion này **không có giá trị phát hiện lỗi nào**. |
| Dòng 42 | Có giá trị thật (kiểm `state ≤ 3`), nhưng chỉ kiểm **sau 8 nhịp**, không kiểm từng nhịp. |

Một FSM nhảy bước `0 → 2 → 4 → 6 → 0` **qua được cả hai assertion**. Mà "nhảy bước" chính
là rủi ro Charter mục 10 nêu. Cùng vấn đề với `properties.sv`:

```systemverilog
assert_half_state: assert property (@(posedge clk) half_step |-> state_dbg inside {[0:7]});
```

⟹ cũng luôn đúng. **Invariant quan trọng nhất của đề (INV-4: mỗi nhịp đúng một bước) không
tồn tại ở bất kỳ đâu trong gói.**

## 2. Ca tự xây dựng đã có (chỉ ở mô hình Python)

| Ca | Ở đâu | Lý do kỹ thuật | Đã chạy? |
|---|---|---|:---:|
| Bước đủ tiến, 2 vòng | `test_full_forward()` | `[0,1,2,3,0,1,2,3]` — ca mà TB **thiếu** | ✅ Python |
| Bước đủ lùi, 2 vòng | `test_full_reverse()` | `[0,3,2,1,0,3,2,1]` — kiểm wrap dưới | ✅ Python |
| Nửa bước tiến, 2 vòng | `test_half_forward()` | 16 nhịp, kiểm chuỗi **đầy đủ** `range(8)*2` — đây là ca kiểm **chuỗi** mà TB thiếu | ✅ Python |
| Nửa bước lùi, 2 vòng | `test_half_reverse()` | `[0,7,6,5,4,3,2,1]×2` | ✅ Python |
| Đổi chiều giữa chừng | `test_direction_change()` | `s=5, dir=0 → 4` và `s=2, dir=0 → 1` — kiểm **tiền nhiệm**, không phải reset | ✅ Python |
| Phủ bảng pha | `test_phase_coverage()` | 8 mẫu nửa bước **phân biệt nhau**, 4 mẫu bước đủ phân biệt. Bắt lỗi chép nhầm bảng thành hai mục giống nhau. | ✅ Python |
| Biểu diễn trạng thái chung | `test_shared_state()` | Kiểm `max(FULL) < 8` — trả lời Charter mục 2 câu 1 ở mức mô hình | ✅ Python |

> 👉 **Mô hình Python phủ tốt hơn testbench SystemVerilog** — nó có cả bước đủ tiến, và nó
> kiểm **chuỗi** chứ không chỉ dải. Nghịch lý: lớp kiểm chứng *độc lập* lại mạnh hơn lớp
> kiểm chứng *chính*, và lớp chính thì **chưa chạy được**. Việc cần làm rõ ràng: chuyển
> chiến lược của mô hình Python sang testbench.

## 3. Phân loại ca theo tiêu chí kỹ thuật riêng của F08

F08 có **bốn** trục độc lập:

**Trục A — chế độ:** `nửa bước (8 trạng thái)` · `bước đủ (4 trạng thái)`
**Trục B — chiều:** `tiến` · `lùi` · `đổi chiều giữa chừng`
**Trục C — vị trí khi xảy ra sự kiện:** `s=0 (biên dưới)` · `s giữa chuỗi` · `s=n−1 (biên trên)`
**Trục D — nhịp:** `speed_div=0` · `speed_div=1` · `speed_div>1` · `run=0`

### Ma trận phủ thật sự

| Tình huống | Ca nào phủ | Trạng thái |
|---|---|---|
| Nửa bước tiến, chuỗi đầy đủ | TB dòng 26 (dải) + Python `test_half_forward` (chuỗi) | ⚠️ chỉ Python kiểm chuỗi |
| Nửa bước lùi | TB dòng 34–35 (1 nhịp) + Python | ⚠️ TB chỉ 1 nhịp |
| **Bước đủ tiến** | **chỉ** Python | ❌ **TB THIẾU** |
| Bước đủ lùi | TB dòng 40–42 + Python | ⚠️ TB chỉ kiểm dải |
| Đổi chiều tại `s` giữa chuỗi | TB dòng 29–37 (tại `s=1`) + Python (tại `s=5`, `s=2`) | ⚠️ TB chỉ tại `s=1` |
| **Đổi chiều tại `s=0`** (wrap) | — | ❌ **THIẾU** |
| **Đổi chiều tại `s=7`** (biên trên) | — | ❌ **THIẾU** |
| `run=0` ⟹ `coil=0` | TB dòng 44–47 | ❌ chưa chạy |
| `run=0` rồi `run=1` lại — giữ vị trí | — | ❌ **THIẾU** |
| `speed_div = 0` (bước mỗi chu kỳ) | — | ❌ **THIẾU** — nhánh riêng RTL dòng 64 là **mã chưa từng chạy** |
| `speed_div > 1` (chia tần thật) | — | ❌ **THIẾU** — TB cố định `speed_div = 1` |
| **Chuyển chế độ khi `s ∈ [4,7]`** | — | ❌ **THIẾU** — xem §3.1 |
| Cổng bảo vệ `coil = 1001` (RTL dòng 91) | — | ❌ **THIẾU** — mã chưa từng chạy |
| `state === 3'bxxx` (RTL dòng 85) | — | ⬛ **không thể phủ** — xem `fsm.md` §6.3 |

### 3.1 Ba ca **còn thiếu** cần bổ sung (có lý do, có ca biên)

| Ca đề xuất | Vì sao cần | Kích thích |
|---|---|---|
| **CA-BS-1 · Bước đủ tiến, kiểm CHUỖI từng nhịp** | Charter mục 8 yêu cầu *"quay thuận đủ một vòng ở cả hai chế độ"*, TB chỉ có nửa bước tiến. Và phải kiểm **chuỗi**, không kiểm dải — nếu không thì FSM nhảy bước vẫn PASS. | `half_step=0; dir=1; run=1;` rồi vòng lặp `for k in 0..3`: `assert(state_dbg == k)` trước mỗi `tick()`; lặp 2 vòng để kiểm wrap. |
| **CA-BS-2 · Chuyển chế độ khi `s ∈ [4,7]`** ★ **ca biên** | Đây là **vùng tàn dư** — trạng thái bất hợp lệ duy nhất của F08 **tới được bằng kích thích cổng vào** (`fsm.md` §3). Cổng bảo vệ `coil = 1001` (RTL dòng 91) là **mã chưa từng chạy**. Đồng thời đây là chỗ RTL và mô hình Python **bất đồng** (`functional_spec.md` §6.3) — nên nó vừa là ca kiểm thử vừa là câu hỏi đặc tả cần thầy trả lời. | `half_step=1; dir=1;` chạy 5 nhịp tới `s=5`; hạ `half_step=0`; kiểm `coil == 4'b1001`; chạy tiếp và kiểm `s` về dải `[0,3]` sau **≤3** nhịp. |
| **CA-BS-3 · Bộ chia tần với `speed_div = 0` và `speed_div = 4`** | TB cố định `speed_div = 1`, nên nhánh `if (speed_div == '0)` (RTL dòng 64) và nhánh đếm thật (`div_count` tăng, dòng 82) **chưa từng chạy**. `speed_div = 0` là **ca biên dưới**: một giá trị dễ gây chia-cho-không nếu viết `speed_div - 1` mà quên chặn. | `speed_div=0`: kiểm `s` tăng **mỗi** chu kỳ. `speed_div=4`: kiểm `s` chỉ đổi **4 chu kỳ một lần**, và `div_count` không vượt 3. |

### 3.2 Ca thứ tư đáng cân nhắc: đổi chiều ở hai biên

| Ca | Vì sao | Kỳ vọng |
|---|---|---|
| Đổi chiều tại `s = 0`, nửa bước | Ép nhánh wrap dưới `(state==0) ? 7` ngay tại thời điểm đổi chiều — hai cơ chế cùng lúc | `s: 0 → 7` |
| Đổi chiều tại `s = 7`, nửa bước | Ép nhánh wrap trên và chiều ngược | `s: 7 → 6` |

Hai ca này rẻ và bắt được một lớp lỗi mà ca đổi chiều ở giữa chuỗi không bắt được.

## 4. Ca **KHÔNG áp dụng** cho F08 — và vì sao

| Ca thường gặp | Vì sao không áp dụng | Bằng chứng |
|---|---|---|
| **Vi bước** (microstepping) | Charter mục 3: *"Ngoài phạm vi. Vi bước, điều khiển dòng, gia tốc, phản hồi vị trí."* Vi bước cần DAC/PWM điều biên dòng — F08 chỉ phát mẫu bật/tắt 4 bit. | Charter mục 3 |
| **Điều khiển dòng** (current chopping) | Ngoài phạm vi. F08 không có đầu ra tương tự, không có phản hồi dòng. | Charter mục 3 |
| **Gia tốc / đường cong tốc độ** | Ngoài phạm vi. `speed_div` là hằng trong mỗi lần chạy; F08 không có bộ sinh profile. | Charter mục 3 |
| **Phản hồi vị trí** (encoder) | Ngoài phạm vi. **Quan trọng:** vì không có phản hồi, mọi bước bị mất là **mất vĩnh viễn** — đây là lý do lỗi của `f08_bad_direction_reset` nghiêm trọng đến vậy. | Charter mục 3 |
| Mất bước do quá tải cơ | Hiện tượng **vật lý**, nằm ngoài ranh giới khối số. F08 chỉ bảo đảm **chuỗi logic** đúng. | `system_diagram.md` §2 |
| Tràn số / bão hoà | `state` 3 bit wrap tự nhiên; `div_count` bị xoá mỗi nhịp nên không tràn (cần INV-8 để chắc). | `fsm.md` §4 |
| Ca glitch/timing | Mô phỏng zero-delay. Đáng chú ý: `coil` là **Mealy** nên **có** khả năng glitch thật — nhưng chỉ L5 mới thấy. | `fsm.md` §7.3 |

## 5. Ca phải bổ sung khi chuyển sang gate-level / post-layout

| Lớp | Ca mới | Vì sao chỉ xuất hiện ở lớp đó |
|---|---|---|
| **L2 (trước hết)** | **Toàn bộ ca hiện có** | ⚠️ F08 chưa chạy được **một chu kỳ nào**. Vá lỗi cú pháp là việc số 1; mọi lớp sau đều vô nghĩa nếu L2 chưa chạy. |
| **L4 — gate-level** | Chạy lại mọi ca trên netlist | Hiện `netlist.v` là của **`f08_bad_direction_reset`** — chạy testbench của `f08_stepper_ctrl` lên đó **không kết nối được** (khác hẳn danh sách cổng). Phải đổi top tổng hợp trước. |
| **L4** | **Glitch trên `coil`** khi `half_step`/`run` đổi | `coil` là đầu ra **Mealy** (`fsm.md` §7.1). Ở RTL zero-delay không bao giờ thấy glitch; ở gate-level có độ trễ cổng thì thấy. Quan trọng vì `coil` lái transistor công suất. |
| **L4** | `===` ở RTL dòng 85 tổng hợp thành gì | Chưa biết Yosys xử lý ra sao — chỉ tổng hợp thật mới trả lời. Nếu nó sinh logic thật thì đó là cell lãng phí; nếu bị xoá thì phải xác nhận không ảnh hưởng `state_next`. |
| **L4** | X-propagation sau reset | Reset **đồng bộ** + `dfxtp_1` không chân reset ⟹ trước cạnh clock đầu, `state` ở `X` thật ⟹ `coil` có thể lan `X` ra chân lái cuộn. |
| **L5 — post-layout + SDF** | Setup/hold trên đường `dir → state[2]` | Đây là **đường tới hạn thật** đo được của phản ví dụ (`dir → _39_`, 1,68 ns). Với `f08_stepper_ctrl`, đường tới hạn có thể khác — ⬜ chưa đo. |
| **L5** | **Độ lệch (skew) giữa 4 bit `coil`** | Bốn bit `coil` phải đổi "cùng lúc". Sau routing, chênh lệch độ trễ giữa 4 dây tạo ra mẫu pha trung gian không hợp lệ trong vài trăm ps. Với cuộn cảm thường vô hại, nhưng phải kiểm nếu driver phản ứng theo cạnh. |

---

*Phiên bản: v1.0 · Ngày: 2026-09-24*
