# F08 · Sự cố đã biết và phán xử (Known Issues)

## Trạng thái: ✅ ĐÃ ÁP DỤNG (2026-09-24)

Nhật ký chi tiết: [`08_ORIGINAL_SOURCE/PATCHLOG.md`](../08_ORIGINAL_SOURCE/PATCHLOG.md).

| Bản vá | Nội dung | Trạng thái |
|---|---|---|
| P-1 (§5.2, phương án B) | `logic [2:0] s_before;` chuyển lên phạm vi module | ✅ đã áp dụng |
| P-2 (§7 việc số 6) | **Đổi top tổng hợp sang `f08_stepper_ctrl`** — đúng module mà testbench mô phỏng | ✅ đã áp dụng |
| P-3 (**mới — không có trong bản vá đã soạn**) | Bỏ 2 dòng `if (half_step && (state === 3'bxxx)) state <= 3'd0;` ở RTL | ✅ đã áp dụng |
| P-4 (§5.4, §7 việc số 4 và 5) | Thêm kiểm **chuỗi** (INV-4) cho nửa bước tiến, và ca "bước đủ tiến" của Charter mục 8 | ✅ đã áp dụng |

**Phát hiện mới trong lúc vá — §6.1 của `functional_spec.md` dự đoán SAI.** Ở đó ghi
*"Yosys thường rút gọn `===` thành hằng 0"* kèm chú "chưa kiểm chứng được vì module này
chưa được tổng hợp". Sau khi áp P-2, đã kiểm chứng được: Yosys **không** rút gọn về 0.
Netlist sinh từ RTL còn nguyên 2 dòng đó **trượt testbench** ở mô phỏng mức cổng
(`FATAL … direction reversal did not move to predecessor`, t=116), trong khi mô phỏng RTL
lại PASS — một ca **mô phỏng ≠ tổng hợp** thật sự. P-3 bỏ hẳn 2 dòng (là **mã chết** trong
mô phỏng, nên log mô phỏng RTL trước và sau P-3 giống hệt nhau).

**Kết quả xác minh bằng công cụ thật (2026-09-24):**

| Bước | Trước khi vá | Sau khi vá |
|---|---|---|
| `python3 reference_model.py` | PASS 7 ca | **PASS**, không đổi |
| `iverilog -g2012` | **COMPILE_FAIL** (`syntax error`, dòng 32) | **PASS** — 0 lỗi, 4 cảnh báo `sorry:` vô hại |
| `vvp sim.vvp` (RTL) | **0 chu kỳ** | **PASS** — `F08 TB completed`, `$finish` tại t=356 |
| Mô phỏng mức cổng | chưa từng chạy | **PASS** — t=356 (bằng chứng netlist ≡ RTL) |
| `yosys` (sky130hd) | 22 cell / 4 FF / 190,1824 µm² — **của phản ví dụ** | **101 cell / 15 FF / 835,8016 µm²** — của `f08_stepper_ctrl` |

Bảng §4 ("F08 hiện KHÔNG CÓ bằng chứng hành vi nào trên RTL") nay **đã lỗi thời**: L2 đạt,
và có thêm bằng chứng mức cổng. Cái bẫy "4 FF khớp dải Charter mục 10" cũng đã lộ: module
thật có **15 FF** (3 `state` + 8 `div_count` + 4 thanh ghi đầu ra bảng pha do Yosys
`proc_rom`/`memory_dff` sinh ra) — **ngoài** dải 4–6 FF mà Charter dự đoán.

**Còn lại chưa vá (có chủ ý):** §7 việc số 7 đã được vá bởi P-3; việc số 8, 9 (tàn dư
`s ∈ [4,7]` và bất đồng RTL ↔ Python ở dải đó) là **đổi hành vi**, cần quyết định riêng —
xem PATCHLOG §5.

Phần chẩn đoán bên dưới **giữ nguyên** làm tài liệu dạy học.

---

**Trạng thái mô phỏng RTL (trước khi vá): `COMPILE_FAIL`** — Icarus Verilog **không biên dịch được**
testbench. Không có `simulation.log`; mô phỏng **chưa bao giờ chạy một chu kỳ nào**.

---

## 1. Thông báo lỗi — trích nguyên văn

`05_VERIFICATION/iverilog_compile.log` (toàn bộ file, đúng 2 dòng):

```
/…/runs/F08/work/f08_tb.sv:32: syntax error
/…/runs/F08/work/f08_tb.sv:32: error: Malformed statement
```

`05_VERIFICATION/simulation.log`: **không tồn tại** trong thư mục hồ sơ
(`brief/F08.md` mục "12 dong cuoi simulation.log" ghi `(khong co)`).

## 1.1 Dòng 32 của `f08_tb.sv` — nguyên văn ngữ cảnh

```systemverilog
19:    initial begin
20:        clk=0; rst_n=0; run=0; dir=1; half_step=1; speed_div=8'd1;
21:        repeat(2) tick();
22:        rst_n=1;
23:
24:        // Start half-step sequence.
25:        run=1;
26:        repeat(8) tick();
27:        assert(state_dbg <= 3'd7) else $fatal(1,"invalid half-step state");
28:
29:        // Direction reversal from a non-zero state must be adjacent, not reset.
30:        dir=1;
31:        tick();
32:        logic [2:0] s_before;          // ◀◀◀ DÒNG GÂY LỖI
33:        s_before = state_dbg;
34:        dir=0;
35:        tick();
36:        assert(state_dbg == ((s_before==0)?7:s_before-1))
37:            else $fatal(1,"direction reversal did not move to predecessor");
```

---

## 2. Phán xử: **LỖI Ở TESTBENCH** (vi phạm LRM), **cộng thêm** khác biệt độ nghiêm ngặt giữa các công cụ

| Khả năng | Phán xử | Lý do |
|---|:---:|---|
| Lỗi trong **DUT** (`f08_stepper_ctrl.sv`) | ❌ **Không** | Lỗi là `syntax error` **trong file testbench**, ở giai đoạn phân tích cú pháp. DUT chưa được đụng tới. Không có DUT nào có thể gây ra lỗi này. |
| Lỗi trong **mô hình chuẩn** (`reference_model.py`) | ❌ **Không** | Python chạy riêng, PASS cả 7 ca (`python_reference_run.log`). Không liên quan tới trình biên dịch Verilog. |
| Lỗi trong **testbench** (`f08_tb.sv`) | ✅ **ĐÚNG — đây là lỗi** | Khai báo biến đặt **sau** câu lệnh trong cùng một block — vi phạm IEEE 1800 (§3) |
| **Giới hạn công cụ** (Icarus Verilog) | ⚠️ **Đồng thời đúng, nhưng là yếu tố phụ** | Icarus nghiêm ngặt đúng LRM; VCS/Questa/Verilator thường **chấp nhận** cách viết này như một mở rộng. Đây là lý do lỗi "lọt" được vào gói. |

> **Cách phát biểu chính xác nhất:** *mã testbench vi phạm chuẩn ngôn ngữ; một số công cụ
> tha thứ, Icarus thì không.* Đổ hết cho "Icarus không hỗ trợ" là **sai** — cách viết đó
> không hợp lệ theo LRM ngay từ đầu.

---

## 3. Vì sao dòng 32 sai — lập luận từ chuẩn ngôn ngữ

### 3.1 Quy tắc

IEEE 1800 (SystemVerilog LRM), phần về khối thủ tục: **trong một block, mọi khai báo biến
phải đứng TRƯỚC câu lệnh đầu tiên.** Quy tắc này thừa hưởng từ Verilog-2001 và được giữ
nguyên trong SystemVerilog cho các block thủ tục.

Trong `f08_tb.sv`, khối `initial begin … end` có các câu lệnh từ dòng 20, rồi mới tới khai
báo ở dòng 32. Trình phân tích cú pháp của Icarus, khi đang ở trạng thái "đọc câu lệnh",
gặp từ khoá `logic` — một từ khoá chỉ hợp lệ ở vị trí khai báo — và báo `syntax error` rồi
`Malformed statement`.

### 3.2 Vì sao một số công cụ lại chấp nhận

C99 và C++ cho phép khai báo xen giữa câu lệnh, và nhiều trình biên dịch HDL thương mại bổ
sung mở rộng tương tự cho tiện. Mở rộng này **không** nằm trong LRM. Hệ quả thực tế: mã
chạy được trên máy tác giả nhưng hỏng trên công cụ khác — đúng tình huống đang xảy ra.

### 3.3 Bằng chứng rằng đây là lỗi vị trí, không phải lỗi kiểu dữ liệu

Cùng câu khai báo `logic [2:0] s_before;` đặt ở dòng 20 (ngay đầu block) sẽ biên dịch
bình thường. Kiểu `logic`, bề rộng `[2:0]`, tên biến — tất cả đều hợp lệ. **Chỉ vị trí sai.**

Thêm một bằng chứng gián tiếp: `f07_tb.sv` (cùng gói, cùng phong cách viết) **không** có
khai báo nào ở giữa block, và nó biên dịch trót lọt — chỉ sinh cảnh báo `sorry:`, không
sinh `syntax error`.

---

## 4. Hậu quả: F08 hiện KHÔNG CÓ bằng chứng hành vi nào trên RTL

Đây là hậu quả nghiêm trọng hơn bản thân lỗi cú pháp, và phải nói rõ:

| Lớp kiểm chứng | Trạng thái F08 |
|---|---|
| L0 — mô hình chuẩn Python | ✅ PASS 7 ca |
| **L2 — mô phỏng RTL** | ❌ **KHÔNG BIÊN DỊCH ĐƯỢC** — 0 chu kỳ chạy |
| L3 — kiểm cấu trúc (số FF) | ⚠️ có số, nhưng của **phản ví dụ** (xem `functional_spec.md` cảnh báo (a)) |
| L4 — gate-level | ⬜ chưa chạy |
| L5 — post-layout | ⬜ chưa chạy |

⟹ **Không một dòng nào của `f08_stepper_ctrl.sv` từng được thực thi.** Mọi phát biểu về
hành vi của nó trong hồ sơ này đều là **phân tích mã tĩnh**, không phải bằng chứng thực
nghiệm. Đặc biệt:

- Chưa chứng minh được chuỗi nửa bước 8 trạng thái chạy đúng trên RTL.
- Chưa chứng minh được đổi chiều **không** làm mất bước — mà đây chính là rủi ro chính
  Charter mục 10 nêu.
- Chưa chứng minh được `coil` về `0000` khi `run = 0`.
- Chưa chứng minh được bộ chia tần `speed_div` hoạt động.

So với F07 (chạy được 156 đơn vị thời gian, 11 assertion PASS trước khi dừng), **F08 ở tình
trạng xấu hơn nhiều** — dù nhìn qua bảng tổng hợp thì cả hai đều chỉ là "một ô đỏ".

---

## 5. Bản vá tối thiểu đề xuất

> ⚠️ **BẢN VÁ NÀY CHƯA ĐƯỢC ÁP DỤNG.** RTL, testbench và mô hình chuẩn trong hồ sơ **giữ
> nguyên bản gốc của thầy**. Cần thầy duyệt trước khi sửa.

### 5.1 Phương án A — di chuyển khai báo lên đầu block (sửa 2 dòng)

```diff
--- a/05_VERIFICATION/testbench/f08_tb.sv
+++ b/05_VERIFICATION/testbench/f08_tb.sv
@@ -19,6 +19,7 @@
     initial begin
+        logic [2:0] s_before;        // khai bao PHAI dung truoc moi cau lenh
         clk=0; rst_n=0; run=0; dir=1; half_step=1; speed_div=8'd1;
         repeat(2) tick();
         rst_n=1;
@@ -29,7 +30,6 @@
         // Direction reversal from a non-zero state must be adjacent, not reset.
         dir=1;
         tick();
-        logic [2:0] s_before;
         s_before = state_dbg;
```

### 5.2 Phương án B — khai báo ở phạm vi module (sửa 2 dòng, dễ đọc hơn)

```diff
@@ -5,6 +5,7 @@
     logic [3:0] coil;
     logic [2:0] state_dbg;
+    logic [2:0] s_before;
@@ -32,1 +33,0 @@
-        logic [2:0] s_before;
```

Phương án B có lợi thế phụ: `s_before` xuất hiện trong danh sách tín hiệu của waveform
viewer, tiện khi gỡ lỗi.

### 5.3 Kết quả dự kiến sau khi vá — và vì sao phải **chạy mới biết**

Truy vết bằng tay chuỗi kích thích của testbench trên `f08_stepper_ctrl` (clock chu kỳ 10,
cạnh lên tại `t = 5, 15, …`, `speed_div = 1` ⟹ `step_tick = run` mỗi chu kỳ):

| Giai đoạn | Cạnh | Kỳ vọng |
|---|---|---|
| Reset | 1–2 | `state = 0` |
| Nửa bước tiến ×8 | 3–10 | `state`: 1,2,3,4,5,6,7,**0** — assert dòng 27 (`state ≤ 7`) đúng hiển nhiên |
| `dir=1`, 1 nhịp | 11 | `state = 1`; `s_before = 1` |
| `dir=0`, 1 nhịp | 12 | `state = 0` = `s_before − 1` ⟹ assert dòng 36 **kỳ vọng PASS** |
| Bước đủ lùi ×8 (từ `state=0`) | 13–20 | `0→3→2→1→0→3→2→1→0` ⟹ assert dòng 42 (`state ≤ 3`) **kỳ vọng PASS** |
| `run=0`, 1 nhịp | 21 | `coil = 0000` ⟹ assert dòng 47 **kỳ vọng PASS** |
| Reset, 1 nhịp | 22 | `state = 0`, `coil = 0` ⟹ assert dòng 52 **kỳ vọng PASS** |

⟹ **Dự đoán: sau khi vá, testbench chạy hết và PASS.** Nhưng đây là **suy luận từ mã, chưa
chạy**. Không được ghi vào hồ sơ là "PASS" cho tới khi có `simulation.log` thật.

### 5.4 Hai khoảng trống mà bản vá KHÔNG lấp được

Ngay cả khi vá xong và PASS, testbench vẫn **không** kiểm hai thứ quan trọng nhất:

| Khoảng trống | Vì sao quan trọng |
|---|---|
| **Không có ca "bước đủ TIẾN"** (`dir=1` với `half_step=0`) | Chuỗi `0→1→2→3→0` chưa bao giờ được chạy. Charter mục 8 yêu cầu *"Quay thuận đủ một vòng ở cả hai chế độ"* — hiện chỉ có nửa bước tiến và bước đủ **lùi**. |
| **Không có INV-4** (mỗi nhịp đúng một bước) | Assertion dòng 27 và 42 chỉ kiểm **dải giá trị**, không kiểm **chuỗi**. Một FSM nhảy `0→2→4→6` vẫn qua cả hai assertion. Mà "nhảy bước" chính là rủi ro Charter mục 10 nêu. |

Đề xuất bổ sung (chi tiết ở `corner_cases.md` §3.1):

```systemverilog
// Kiem CHUOI, khong chi kiem DAI
half_step=1; dir=1; run=1;
for (int k = 0; k < 8; k++) begin
    assert(state_dbg == k[2:0])
        else $fatal(1, "nhay buoc tai k=%0d: state=%0d", k, state_dbg);
    tick();
end
```

---

## 6. Giá trị dạy học của lỗi này

1. **`COMPILE_FAIL` nặng hơn `FAIL` rất nhiều, dù bảng tổng hợp nhìn giống nhau.** Một lỗi
   assertion (như F07) vẫn để lại bằng chứng: F07 chạy 156 đơn vị thời gian và có 11
   assertion PASS. `COMPILE_FAIL` để lại **con số không**. Khi đọc bảng trạng thái hồ sơ,
   phải phân biệt hai loại đỏ này.

2. **"Chạy được trên máy tôi" không phải bằng chứng.** Cách viết ở dòng 32 được nhiều công
   cụ thương mại chấp nhận. Chỉ khi đổi sang Icarus mới lộ. Bài học: mã HDL nên tuân LRM
   chứ không nên dựa vào mở rộng của một công cụ — nhất là mã dùng để **dạy**, vì sinh viên
   sẽ chạy trên đủ loại môi trường.

3. **Đọc thông báo lỗi cho đúng tầng.** `syntax error` xảy ra ở giai đoạn **phân tích cú
   pháp**, trước cả khi elaborate. Kết luận "DUT sai" từ một lỗi cú pháp trong testbench là
   không thể — nhưng là phản xạ rất phổ biến.

4. **Một lỗi hai dòng có thể xoá sạch cả tầng kiểm chứng.** Lỗi này không làm mạch sai, nó
   làm **không ai biết mạch đúng hay sai**. Chi phí thật của nó không phải hai dòng mã mà là
   toàn bộ bằng chứng hành vi của F08.

5. **Dải giá trị ≠ chuỗi giá trị.** §5.4 cho thấy ngay cả testbench đã vá vẫn có điểm mù
   lớn. Một FSM nhảy bước `0→2→4→6` qua được mọi assertion hiện có. Đây là bài học về
   **thiết kế assertion**, và nó đáng giá hơn bản thân lỗi cú pháp.

---

## 7. Trạng thái và việc cần làm

| # | Việc | Ai | Trạng thái |
|---|---|---|---|
| 1 | Duyệt phán xử ở §2 | Giảng viên | ⬜ chờ |
| 2 | Áp dụng bản vá §5.1 hoặc §5.2 | Sau khi duyệt | ⬜ **chưa áp dụng** |
| 3 | Chạy `01_run_sim.sh`, sinh `simulation.log` thật | — | ⬜ |
| 4 | Bổ sung ca "bước đủ tiến" (Charter mục 8 yêu cầu) | — | ⬜ |
| 5 | Bổ sung INV-4 kiểm **chuỗi** (§5.4) | — | ⬜ |
| 6 | Đổi top tổng hợp sang `f08_stepper_ctrl` (xem `functional_spec.md` cảnh báo (a)) | Giảng viên | ⬜ |
| 7 | Quyết định về `===` ở dòng 85–86 của RTL (`functional_spec.md` §6.1) | Giảng viên | ⬜ |
| 8 | Quyết định về tàn dư `state ∈ [4,7]` khi đổi chế độ (`functional_spec.md` §6.2) | Giảng viên | ⬜ |
| 9 | Quyết định về bất đồng RTL ↔ mô hình Python ở dải `[4,7]` (`functional_spec.md` §6.3) | Giảng viên | ⬜ |

> Nhắc lại: **RTL và testbench của thầy chưa bị sửa một dòng nào.** Mọi thay đổi ở §5 là
> đề xuất.

---

*Phiên bản: v1.0 · Ngày: 2026-09-24*
