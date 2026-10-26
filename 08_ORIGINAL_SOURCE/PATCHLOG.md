# F08 · Nhật ký vá (PATCHLOG)

**Ngày vá:** 2026-09-24 · **Người duyệt:** giảng viên đã duyệt áp dụng toàn bộ bản vá

## 1. Tóm tắt

| # | File | Loại lỗi | Mô tả một dòng | Ảnh hưởng số liệu |
|---|---|---|---|---|
| P-1 | `05_VERIFICATION/testbench/f08_tb.sv` | **Lỗi cú pháp (testbench)** | `logic [2:0] s_before;` khai báo **sau** câu lệnh trong `initial` — vi phạm IEEE 1800. Chuyển lên phạm vi module (phương án B, §5.2) | Không |
| P-2 | *(top tổng hợp)* | **Sai đối tượng đo** | Top tổng hợp là **phản ví dụ** `f08_bad_direction_reset`, trong khi testbench mô phỏng `f08_stepper_ctrl`. Đổi top tổng hợp sang `f08_stepper_ctrl` | **Có — toàn bộ số liệu thay đổi** |
| P-3 | `04_IMPLEMENTATION/rtl/f08_stepper_ctrl.sv` | **Lỗi thiết kế (mô phỏng ≠ tổng hợp)** | Bỏ 2 dòng `if (half_step && (state === 3'bxxx)) state <= 3'd0;` — mã chết khi mô phỏng nhưng **phá netlist** khi tổng hợp | **Có** |
| P-4 | `05_VERIFICATION/testbench/f08_tb.sv` | Thiếu ca kiểm thử | Thêm kiểm **chuỗi** (INV-4, §5.4) cho nửa bước tiến 0..7 và ca "bước đủ tiến" mà Charter mục 8 đòi | Không |

## 2. Chi tiết từng bản vá

### P-1 — Khai báo biến sau câu lệnh trong khối `initial`

**File:** `05_VERIFICATION/testbench/f08_tb.sv` · **Dòng:** 32 (bản gốc) ·
**Phán xử:** lỗi ở **testbench** (vi phạm LRM), Icarus nghiêm ngặt đúng chuẩn.

**Trước:**
```systemverilog
        dir=1;
        tick();
        logic [2:0] s_before;          // ◀ syntax error / Malformed statement
        s_before = state_dbg;
```

**Sau:** khai báo chuyển lên phạm vi module, ngay dưới `state_dbg` (phương án B, §5.2):
```systemverilog
    logic [3:0] coil;
    logic [2:0] state_dbg;
    logic [2:0] s_before;   // P-1: khai bao o pham vi module (IEEE 1800: trong mot
                            // block thu tuc, khai bao phai dung TRUOC moi cau lenh)
```
và trong `initial` chỉ còn:
```systemverilog
        dir=1;
        tick();
        s_before = state_dbg;
```

**Vì sao chọn B chứ không A:** cả hai đều sửa 2 dòng, nhưng ở phạm vi module `s_before`
xuất hiện trong danh sách tín hiệu của waveform viewer — tiện khi gỡ lỗi.

**Hệ quả:** biên dịch sạch (chỉ còn 4 cảnh báo `sorry: constant selects` vô hại, cùng loại
với F07). Mô phỏng RTL của F08 **chạy lần đầu tiên**.

### P-2 — Module được tổng hợp khác module được mô phỏng

**Phán xử:** sai **đối tượng đo**, không phải lỗi trong một file cụ thể.

**Trước:** top tổng hợp = `f08_bad_direction_reset` — file tự khai ở dòng 1–2 là
`// EDUCATIONAL ANTI-PATTERN.` Testbench thì khởi tạo `f08_stepper_ctrl` làm `dut`.
⟹ mọi số liệu (22 cell · 4 FF · 190,1824 µm²) là của **phản ví dụ**; bộ điều khiển thật
**chưa từng được tổng hợp**.

**Sau:** top tổng hợp = **`f08_stepper_ctrl`** — đúng module mà testbench mô phỏng.

**Vì sao:** `02_SPECIFICATION/functional_spec.md` cảnh báo (a) và (b) đã nêu rõ; cảnh báo
(b) chỉ ra cái bẫy: 4 FF đo được *khớp dải dự đoán 4–6 FF của Charter mục 10* nhưng là 4 FF
của module sai — "một con số khớp dự đoán mà vẫn sai là loại bằng chứng nguy hiểm nhất".

**Hệ quả:** **mọi số liệu vật lý của F08 thay đổi hoàn toàn** — xem §3. Số FF đo được là
**15**, nằm **ngoài** dải 4–6 FF mà Charter mục 10 dự đoán, đúng như cảnh báo (b) đã tiên
liệu (và còn cao hơn con số 11 mà cảnh báo (b) ước tính — lý do ở §3).

**Ghi chú về ranh giới sửa file:** `04_IMPLEMENTATION/scripts/config.json`,
`04_IMPLEMENTATION/scripts/02_run_synth.sh` và `06_GDSII/synthesis/synth.ys` **không được
sửa tay** (PATCH_SPEC §0 — sẽ được sinh lại tự động). Top mới đã được ghi vào trạng thái
của flow (`flow_results.json`, khoá `F08.top`) để lần sinh lại dùng đúng
`f08_stepper_ctrl`. Xác minh trong PATCHLOG này chạy trực tiếp với top mới.

### P-3 — `===` ở dòng 85–86: mã chết khi mô phỏng, phá netlist khi tổng hợp

**File:** `04_IMPLEMENTATION/rtl/f08_stepper_ctrl.sv` · **Dòng:** 85–86 ·
**Phán xử:** lỗi ở **DUT**.

**Trước:**
```systemverilog
            end else begin
                div_count <= div_count + 1'b1;
            end

            if (half_step && (state === 3'bxxx))
                state <= 3'd0;
        end
```

**Sau:** hai dòng đó được **bỏ**, thay bằng chú thích giải thích:
```systemverilog
            end else begin
                div_count <= div_count + 1'b1;
            end

            // P-3: bo "if (half_step && (state === 3'bxxx)) state <= 3'd0;".
            // '===' la so sanh 4 trang thai, khong co nghia trong phan cung.
            // Trong mo phong day la MA CHET (sau reset state khong bao gio la X),
            // nhung Yosys KHONG rut gon no ve 0 nhu du doan: netlist tong hop
            // bi ghi de 'state <= 0' va sai chuoi buoc. Bo di => mo phong khong
            // doi mot chut nao, con netlist thi khop voi RTL.
        end
```

**Vì sao — và đây là chênh lệch so với dự đoán trong hồ sơ.** `functional_spec.md` §6.1 dự
đoán *"Yosys thường rút gọn thành hằng `0`"* nhưng ghi rõ **"Chưa kiểm chứng được vì module
này chưa được tổng hợp"**. Sau khi áp P-2 (tổng hợp đúng module), điều này **đã kiểm chứng
được — và dự đoán sai**.

Bằng chứng: sinh netlist mức cổng từ `f08_stepper_ctrl` rồi chạy **chính testbench đã vá**
trên netlist đó:

| RTL nguồn | Mô phỏng RTL | Mô phỏng mức cổng (netlist Yosys) |
|---|---|---|
| Còn 2 dòng `===` | ✅ `F08 TB completed` | ❌ `FATAL … direction reversal did not move to predecessor`, t=116 |
| Thay 2 dòng đó bằng `if (1'b0)` (thử nghiệm cô lập) | ✅ | ✅ `F08 TB completed` |
| **Sau P-3 (đã bỏ hẳn)** | ✅ `F08 TB completed` | ✅ `F08 TB completed` |

⟹ hai dòng này là một **mô phỏng ≠ tổng hợp** thật sự: câu lệnh nằm **ngoài** chuỗi
`if/else` phía trên nên khi nó "đúng" trong netlist, nó **ghi đè** `state <= state_next`
trong cùng chu kỳ và phá chuỗi bước. Trong mô phỏng nó không bao giờ đúng (sau reset
`state` luôn xác định), nên **bỏ đi không làm đổi một chút nào hành vi mô phỏng** — điều
này đã được xác minh: log mô phỏng RTL trước và sau P-3 giống hệt nhau (`$finish` tại
t=356).

**Hệ quả:** 100 → **101 cell**, 830,7968 → **835,8016 µm²** (số FF không đổi: 15).
Netlist nay **tương đương hành vi** với RTL — chứng minh bằng mô phỏng mức cổng.

### P-4 — Thêm kiểm CHUỖI, không chỉ kiểm DẢI

**File:** `05_VERIFICATION/testbench/f08_tb.sv`, thêm vào cuối khối `initial`.

**Vì sao:** `known_issues.md` §5.4 chỉ rõ hai khoảng trống mà bản vá cú pháp **không** lấp
được: (1) không có ca "bước đủ **tiến**" dù Charter mục 8 đòi *"quay thuận đủ một vòng ở cả
hai chế độ"*; (2) assertion cũ (dòng 27 và 42) chỉ kiểm **dải giá trị** — một FSM nhảy
`0→2→4→6` vẫn qua được, mà "nhảy bước" chính là rủi ro Charter mục 10 nêu.

**Sau (thêm mới):**
```systemverilog
        // P-3 (known_issues §5.4): kiem CHUOI, khong chi kiem DAI.
        // INV-4 - moi nhip dung mot buoc, nua buoc tien 0..7.
        rst_n=0; run=0; tick();
        rst_n=1; half_step=1; dir=1; run=1;
        for (int k = 0; k < 8; k++) begin
            assert(state_dbg == k[2:0])
                else $fatal(1,"nhay buoc (nua buoc) tai k=%0d: state=%0d", k, state_dbg);
            tick();
        end
        assert(state_dbg == 3'd0) else $fatal(1,"nua buoc khong khep vong ve 0");

        // Charter muc 8: quay thuan du mot vong o che do BUOC DU (truoc day khong co ca nao).
        rst_n=0; run=0; tick();
        rst_n=1; half_step=0; dir=1; run=1;
        for (int k = 0; k < 4; k++) begin
            assert(state_dbg == k[2:0])
                else $fatal(1,"nhay buoc (buoc du) tai k=%0d: state=%0d", k, state_dbg);
            tick();
        end
        assert(state_dbg == 3'd0) else $fatal(1,"buoc du khong khep vong ve 0");
        run=0;
```

**Hệ quả:** chính hai ca này là thứ đã **bắt được P-3** ở mô phỏng mức cổng (assertion
"nhảy bước" và "direction reversal" đều nằm trên đường mà `===` phá). Không ảnh hưởng số
liệu vật lý.

## 3. Kết quả xác minh sau khi vá

| Bước | Trước khi vá | Sau khi vá |
|---|---|---|
| Mô hình chuẩn Python | PASS 7 ca | **PASS** — mã thoát 0, không đổi |
| Biên dịch | **COMPILE_FAIL** — `syntax error` + `Malformed statement`, dòng 32 | **PASS** — 0 lỗi, 4 cảnh báo `sorry: constant selects` (vô hại) |
| Mô phỏng RTL | **chưa bao giờ chạy một chu kỳ nào** | **PASS** — `F08 TB completed`, `$finish` tại t=356 |
| Mô phỏng mức cổng | chưa từng chạy | **PASS** — `F08 TB completed`, t=356 (bằng chứng netlist ≡ RTL) |
| Tổng hợp | 22 cell / 4 FF / 190,1824 µm² — **của phản ví dụ `f08_bad_direction_reset`** | **101 cell / 15 FF / 835,8016 µm²** — của `f08_stepper_ctrl` |

**Giải thích 15 FF** (Charter mục 10 dự đoán 4–6; `functional_spec.md` cảnh báo (b) ước
tính 11):

| Nhóm | Số FF | Ghi chú |
|---|---:|---|
| `state[2:0]` | 3 | vị trí trong chuỗi |
| `div_count[7:0]` | 8 | bộ chia tần — **Charter mục 10 không tính tới** |
| Thanh ghi đầu ra của bảng pha | 4 | Yosys `proc_rom` biến `case` trong `phase_decode` thành ROM, rồi `memory_dff` dời thanh ghi địa chỉ sang phía dữ liệu. Tương đương hành vi (đã chứng minh bằng mô phỏng mức cổng), nhưng tốn thêm 4 FF vì `state_dbg` là cổng ra nên 3 FF gốc vẫn phải giữ |

⟹ Dự đoán của Charter mục 10 (4–6 FF) **không đạt** đối với module thật; con số 4 FF trước
đây "khớp" chỉ vì đo nhầm module. Đây đúng là bài học mà cảnh báo (b) muốn dạy.

Yosys 0.33 không báo `ERROR`; 26 cảnh báo đều là cảnh báo thường lệ của `abc`/liberty.

Lệnh đã chạy để xác minh:

```bash
D=.../out/F08_FSM_dieu_khien_dong_co_buoc
T=$(mktemp -d)
LIB=.../sky130hd.lib

# (a) mo hinh chuan Python
python3 $D/05_VERIFICATION/golden_model/reference_model.py

# (b) bien dich + mo phong RTL
iverilog -g2012 -o $T/sim.vvp \
   $D/04_IMPLEMENTATION/rtl/*.sv \
   $D/05_VERIFICATION/testbench/*.sv
cd $T && vvp sim.vvp | tail -20

# (b') mo phong MUC CONG - bang chung netlist ≡ RTL (P-3)
yosys -Q -p "read_verilog -sv $D/04_IMPLEMENTATION/rtl/f08_stepper_ctrl.sv; \
   hierarchy -check -top f08_stepper_ctrl; proc; opt; fsm; opt; memory; opt; \
   techmap; opt; setundef -zero; splitnets; opt_clean -purge; \
   write_verilog -noattr $T/net.v"
sed 's|f08_stepper_ctrl #(.SPEED_DIV_W(8)) dut|f08_stepper_ctrl dut|' \
   $D/05_VERIFICATION/testbench/f08_tb.sv > $T/tb.v
iverilog -g2012 -o $T/gl.vvp $T/net.v /usr/share/yosys/simcells.v $T/tb.v
cd $T && vvp gl.vvp | tail -5

# (c) tong hop - TOP MOI
yosys -Q -p "read_verilog -sv $D/04_IMPLEMENTATION/rtl/*.sv; \
   hierarchy -check -top f08_stepper_ctrl; proc; opt; fsm; opt; memory; opt; \
   techmap; opt; dfflibmap -liberty $LIB; abc -liberty $LIB; setundef -zero; \
   splitnets; opt_clean -purge; stat -liberty $LIB"
```

> Ghi chú: `05_VERIFICATION/golden_model/` của F08 không có file `.sv`, nên glob đó được bỏ.
> Bản `$T/tb.v` chỉ bỏ phần truyền tham số `#(.SPEED_DIV_W(8))` (netlist đã cố định tham
> số) — file testbench trong hồ sơ **không** bị sửa vì việc này.

## 4. Cách quay lui

```bash
cp 08_ORIGINAL_SOURCE/rtl/*            04_IMPLEMENTATION/rtl/
cp 08_ORIGINAL_SOURCE/golden_model/*   05_VERIFICATION/golden_model/
cp 08_ORIGINAL_SOURCE/testbench/*      05_VERIFICATION/testbench/
```
(Lưu ý: quay lui RTL sẽ đưa lại cả hai dòng `===` của P-3, và phải đặt lại top tổng hợp
về `f08_bad_direction_reset` nếu muốn tái lập số liệu cũ.)

## 5. Việc còn lại

Các mục `known_issues.md` §7 số 7–9 và `functional_spec.md` §6.2–§6.3 **chưa vá**, có chủ ý:

- **§6.2 — bước đủ cộng trên 3 bit, kiểm wrap trên 2 bit.** Với `s ∈ [0,3]` hoàn toàn đúng;
  chỉ lạ ở tàn dư `s ∈ [4,7]` sau khi chuyển chế độ, và hữu hạn (về dải hợp lệ sau ≤ 3
  nhịp), lại đã có cổng bảo vệ đầu ra ở dòng 91. Sửa thành mask `{1'b0, state[1:0]+2'd1}`
  là **đổi hành vi ở dải tàn dư** ⇒ cần quyết định của giảng viên, không phải sửa lỗi.
- **§6.3 — bất đồng RTL ↔ mô hình Python ở dải `s ∈ [4,7]`.** Hệ quả trực tiếp của §6.2;
  vá §6.2 thì bất đồng này tự hết. Chưa có bộ so sánh tự động giữa hai mô hình nên chưa
  cấp bách.
- **Cổng `speed_div[7:0]` thừa 8 bit** so với ngân sách chân Charter mục 4 — **thay đổi
  giao diện module**, ngoài phạm vi đợt vá này.
- Bổ sung INV-4 vào `05_VERIFICATION/testbench/properties.sv` dưới dạng SVA (P-4 đã cài
  tương đương bằng kiểm thủ tục trong `f08_tb.sv`).

## 6. Áp dụng lại (2026-09-24)

Một bước sinh tài liệu tự động (`generate2.py`) đã **chép mã nguồn gốc từ `runs/F08/work/`
đè lên** `04_IMPLEMENTATION/rtl/`, `05_VERIFICATION/golden_model/` và
`05_VERIFICATION/testbench/`, xoá sạch bản vá P-1, P-3 và P-4 (P-2 không nằm trong ba thư
mục đó nên sống sót). Lỗi của bộ sinh đã được sửa; các bản vá dưới đây được **áp dụng lại
nguyên văn** theo §2.

| Bản vá | File | Trạng thái |
|---|---|---|
| P-1 | `05_VERIFICATION/testbench/f08_tb.sv` (`s_before` lên phạm vi module) | ✅ áp dụng lại |
| P-2 | top tổng hợp = `f08_stepper_ctrl` | ✅ **không bị mất** — đã kiểm: `flow_results.json` khoá `F08.top` và `06_GDSII/synthesis/synth.ys` đều đang là `f08_stepper_ctrl` |
| P-3 | `04_IMPLEMENTATION/rtl/f08_stepper_ctrl.sv` (bỏ 2 dòng `===`) | ✅ áp dụng lại |
| P-4 | `05_VERIFICATION/testbench/f08_tb.sv` (kiểm chuỗi nửa bước + bước đủ) | ✅ áp dụng lại |

**Kết quả xác minh lần này** (iverilog 12.0 / Yosys 0.33, cùng lệnh ở §3):

| Bước | Kết quả đo lại | Khớp §3? |
|---|---|---|
| Mô hình chuẩn Python | PASS — mã thoát 0 | ✅ |
| Biên dịch | PASS — 0 lỗi, 4 cảnh báo `sorry: constant selects` | ✅ |
| Mô phỏng RTL | PASS — `F08 TB completed`, `$finish` tại t=356 | ✅ |
| Mô phỏng mức cổng | PASS — `F08 TB completed`, t=356 (netlist ≡ RTL, bằng chứng P-3 dựng lại được) | ✅ |
| Tổng hợp | **101 cell / 15 FF (`dfxtp_1`) / 835,8016 µm²**, 0 `ERROR`, 26 cảnh báo | ✅ |

Toàn bộ số liệu **trùng khớp** bảng §3.

**Hai ghi chú về chênh lệch nhỏ:**

1. Trong khối mã P-4 ở §2, dòng chú thích đầu tiên là `// P-3 (known_issues §5.4): …`. Khi
   áp dụng lại, ký tự `§` được viết thành `muc` (`// P-3 (known_issues muc 5.4): …`) cho
   đúng nguyên tắc "chú thích mã nguồn viết không dấu (ASCII)". Chỉ là chú thích, không
   ảnh hưởng hành vi hay số liệu. (Nhãn `P-3` trong chú thích đó vốn là lỗi đánh máy của
   bản vá gốc — đúng ra là `P-4` — được **giữ nguyên** để trung thực với bản đã áp dụng.)
2. `flow_results.json` khoá `F08.cells` hiện vẫn là **100** (số liệu *trước* P-3). Đây là
   file trạng thái của flow, **ngoài ranh giới sửa** của đợt khôi phục này; ghi nhận ở đây
   để lần sinh lại tài liệu cập nhật thành **101**.
