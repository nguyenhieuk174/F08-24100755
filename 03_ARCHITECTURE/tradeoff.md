# F08 · Phân tích đánh đổi (Trade-off)

> **Cập nhật đo lường:** kết quả hiện tại thuộc `f08_stepper_ctrl`, không phải
> `f08_bad_direction_reset`. README nguồn nêu 101 cell / 15 FF / 835,8016 µm²;
> archive LibreLane nêu 148 standard-cell instances / 15 FF. Xem
> `06_GDSII/physical_report.md` để phân biệt giai đoạn và giới hạn.

---

## 1. Ràng buộc phạm vi phải đọc trước

Charter mục 3 liệt vào **ngoài phạm vi**: *"Vi bước, điều khiển dòng, gia tốc, phản hồi vị
trí"*, cộng ràng buộc chung (analog transistor, physical design tự làm, sign-off, tape-out).

⟹ Các kiến trúc thay thế ở §2 chỉ **so sánh trên giấy**. **Không** thay kiến trúc trong RTL
của thầy. Mọi khuyến nghị ở đây là **đề xuất chờ duyệt**.

## 2. Bảng so sánh: cách lưu vị trí trong chuỗi

Đây là đánh đổi trung tâm mà Charter mục 2 câu 1 hỏi thẳng.

| # | Kiến trúc | Ô nhớ vị trí | Độ phức tạp | Khi nào nên dùng |
|---|---|---:|---|---|
| **A** | **Một thanh ghi chung 3 bit** *(`f08_stepper_ctrl`)* | **3** | Trung bình — 1 bộ tăng/giảm + mux theo `half_step` | ✅ **Mặc định đúng.** Giữ được quan hệ vật lý `full[k] = half[2k]` giữa hai chế độ |
| **B** | **Hai thanh ghi riêng** (2 bit + 3 bit) *(`f08_bad_dual_state_register`)* | **5** | Trung bình — 2 bộ tăng/giảm độc lập + mux đầu ra | Khi hai chế độ là **hai chuyển động độc lập** — không phải trường hợp động cơ bước |
| **C** | **Thanh ghi dịch one-hot 8 bit** (ring counter) | **8** | Rất thấp — chỉ dịch trái/phải, không có bộ tăng | Khi muốn **giải mã pha gần như miễn phí** (mỗi bit one-hot ánh xạ thẳng sang mẫu). Đắt FF, rẻ logic. |
| **D** | **Đếm + bảng tra ROM** | 3 | Thấp ở logic, cần macro ROM | Khi chuỗi pha **rất dài** hoặc cần lập trình lại. Với 8 mục × 4 bit, ROM **đắt hơn** logic tổ hợp. |

### 2.1 So bằng số thật — chỉ có một cột có số, và cột đó thuộc về module khác

| Chỉ số | **A** `f08_stepper_ctrl` | **B** `f08_bad_dual_state_register` | `f08_bad_direction_reset` (**được đo**) |
|---|---:|---:|---:|
| Cell | **101** (README nguồn) | ⬜ chưa đo | **22** (số liệu lịch sử) |
| Flip-flop | **15** | ⬜ chưa đo | **4** (số liệu lịch sử) |
| Diện tích | **835,8016 µm²** (README nguồn) | ⬜ | **190,1824 µm²** (số liệu lịch sử) |
| Đường tới hạn | `speed_div[2]` → `_172_` (README nguồn) | ⬜ | `dir → _31_ → _33_ → _34_ → _35_ → _39_` (lịch sử) |
| Độ trễ / slack | **3,48 ns** (README nguồn) | ⬜ | **1,68 ns / 8,25 ns** (số liệu lịch sử) |
| Công suất | **7.10e-05 W** (README nguồn) | ⬜ | **2,19e-05 W** (số liệu lịch sử) |
| Đổi chiều đúng? | ✅ | ✅ | ❌ **mất tới 7 bước** |
| Có `coil`, `run`, `half_step`? | ✅ | ❌ | ❌ |

> Số liệu A thuộc thiết kế hiện tại theo README nguồn. Archive LibreLane sau P&R có
> metrics riêng tại `06_GDSII/physical_report.md`; cột phản ví dụ chỉ có ý nghĩa lịch sử.

### 2.2 Cái bẫy 4 flip-flop

Charter mục 10: *"Dấu hiệu làm đúng: 3 ô nhớ vị trí (8 trạng thái nửa bước) + vài bit chế
độ ≈ 4–6 ô nhớ."*

| | |
|---|---|
| Đo được của thiết kế hiện tại | **15 FF** |
| Dải Charter | 4–6 |
| Kết luận vội | "✅ khớp — làm đúng" |
| Sự thật | 4 FF trong phép đo cũ thuộc về `state[2:0]` + `dir_d` của **phản ví dụ** |
| `f08_stepper_ctrl` đo được | **15 FF**: 3 `state` + 8 `div_count` + 4 bit đầu ra giải mã pha |
| Vì sao vượt dự đoán | Bộ chia tần và ánh xạ đầu ra pha làm tăng tổng FF so với ước lượng Charter |

> 📌 **Một con số khớp dự đoán mà vẫn sai thì nguy hiểm hơn một con số lệch rõ ràng** — nó
> không kích hoạt nghi ngờ. Quy tắc rút ra: **kiểm danh tính của cái được đo (top module
> trong `synth.ys`) trước khi kiểm giá trị của nó.**

### 2.3 So A với B — trả lời Charter mục 2 câu 1

| Tiêu chí | **A · chung** | **B · riêng** |
|---|---|---|
| FF cho vị trí | **3** | **5** (+2) |
| Đổi chế độ khi `s ∈ [0,3]` | ✅ liền mạch | ✅ |
| Đổi chế độ khi `s ∈ [4,7]` | ⚠️ **vùng tàn dư** — mất ≤3 nhịp để về dải hợp lệ | ✅ không tàn dư |
| Đổi chế độ rồi đổi lại | Vị trí **đã bị chuyển đổi** | **Khôi phục** vị trí cũ của chế độ đó |
| Quan hệ `full[k] = half[2k]` | ✅ **giữ được** | ❌ **mất** — hai vị trí trôi độc lập |
| Rotor có nhảy khi đổi chế độ? | Có thể, ≤3 bước, **hữu hạn và dự đoán được** | Có thể, **tuỳ ý** — vì hai thanh ghi không liên quan gì tới nhau |

**Vì sao A vẫn thắng dù có vùng tàn dư:** trong động cơ bước, hai chế độ **không** là hai
chuyển động độc lập — chúng là **cùng một vòng điện** nhìn ở hai độ phân giải. Bảng bước đủ
là tập con chẵn của bảng nửa bước (`functional_spec.md` §2.2). Dùng hai thanh ghi riêng là
mô hình hoá sai bản chất vật lý: hai con số trôi độc lập, và khi đổi chế độ rotor có thể
nhảy một khoảng **tuỳ ý**, không chặn trên được.

A có lỗi nhỏ hơn và **có chặn trên** (≤3 bước); B có lỗi **không chặn trên được**.

## 3. Đánh đổi bên trong kiến trúc A

| Lựa chọn trong RTL | Phương án khác | Giá / lợi |
|---|---|---|
| `coil` là **đầu ra Mealy** (tổ hợp) | Đăng ký `coil` (4 FF, Moore) | ✅ Ngắt dòng cuộn **tức thì** khi hạ `run` — an toàn. ✅ −4 FF. ❌ Có thể glitch; cần `set_max_delay` cho đường in→out. |
| `state_dbg` là `assign` thuần | Đăng ký riêng | ✅ 0 cell. Đây là tín hiệu gỡ lỗi, không cần chống glitch. |
| Wrap bước đủ kiểm trên `state[1:0]` | Mask: `state_next = {1'b0, state[1:0] + 2'd1}` | ❌ Cách hiện tại sinh **vùng tàn dư**. ✅ Mask sẽ về dải hợp lệ **ngay**, nhưng bước nhảy vị trí lớn hơn. Cả hai đều mất bước; hiện tại mất **chậm và ít hơn**. |
| Cổng bảo vệ `coil = 1001` khi `state > 3` | Để `phase_decode` rơi vào `default: 0000` | ✅ Giữ mô-men, tránh ngắt dòng đột ngột. ⚠️ Tác dụng phụ: vi phạm INV-5 khi `run = 0` (`control.md` §3). |
| `div_count` so với **biến** `speed_div` | Bộ đếm **giảm** nạp `speed_div`, so với 0 | ❌ So hai biến 8 bit **đắt**. ✅ So với 0 chỉ cần một cổng NOR 8 đầu vào. Đây là tối ưu **rõ ràng** và chưa được dùng. |
| Dùng `>=` chứ không `==` | `div_count == speed_div - 1` | ✅ An toàn khi `speed_div` giảm giữa chừng; `==` sẽ làm bộ đếm chạy tự do. |
| `SPEED_DIV_W = 8` cố định | Tham số nhỏ hơn, hoặc `speed_div` là hằng | ❌ Bộ đếm chiếm 8 FF trong 15 FF tổng hợp. Nếu ứng dụng chỉ cần chia tới 16, `SPEED_DIV_W = 4` có thể tiết kiệm **4 FF**. |
| Nhánh `===` ở bản gốc | Đã bỏ trong patch P-3 | ✅ Không còn trong RTL làm việc; chi tiết lịch sử ở `08_ORIGINAL_SOURCE/PATCHLOG.md`. |

## 4. Việc còn cần đo để so sánh kiến trúc

| # | Việc | Lệnh | Trả lời được câu nào |
|---|---|---|---|
| 1 | Tổng hợp biến thể hai thanh ghi với cùng giao diện | Tạo bản so sánh giữ nguyên bộ chia/đầu ra, chỉ thay cách lưu state | So sánh công bằng A/B |
| 2 | Tổng hợp biến thể giải mã bằng logic tổ hợp | Giữ nguyên các cổng và ràng buộc | Charter mục 9: chi phí giải mã |
| 3 | So sánh ROM/macro nếu thư viện có hỗ trợ | Cùng PDK, corner, constraints | Đối chiếu với logic tổ hợp |
| 4 | Tổng hợp biến thể one-hot | Cùng giao diện và chức năng | Định lượng đánh đổi FF/diện tích/timing |

> ⚠️ Lưu ý cho việc 2: `f08_bad_dual_state_register` **không có** `coil`, `run`, `speed_div`.
> So trực tiếp với `f08_stepper_ctrl` sẽ **không công bằng** — cùng cái bẫy đã gặp ở F07
> (`F07/tradeoff.md` §4.1). Muốn tách riêng giá của "hai thanh ghi riêng", phải viết một
> biến thể của `f08_stepper_ctrl` chỉ đổi phần lưu trạng thái, giữ nguyên mọi thứ khác.

## 5. Câu Charter mục 9 — phân tích trong lúc chờ số đo

> *"Chế độ nửa bước có 8 trạng thái, bước đủ có 4. Nêu cách mã hoá trạng thái của mình và
> đối chiếu số flip-flop trong báo cáo; bàn xem dùng bảng tra hay dùng logic tổ hợp thì rẻ
> hơn."*

### 5.1 Cách mã hoá — ✅ trả lời được ngay từ mã

**Một thanh ghi nhị phân 3 bit dùng chung**, và **mã hoá chính là vị trí trong chuỗi**:
`state = k` ⟺ rotor ở bước thứ `k`. Bước đủ dùng 4 trên 8 mã (`0..3`); nửa bước dùng cả 8.

Không dùng `typedef enum` — có lý do: trạng thái ở F08 là một **con số có ý nghĩa số học**
(`state ± 1`, `state[1:0]`), không phải một **khái niệm**. Mã hoá vì vậy là **một phần của
đặc tả**, không phải chi tiết hiện thực; Yosys **không được phép** tái mã hoá.
Xem `fsm.md` §5.1.

### 5.2 Đối chiếu số flip-flop — **ĐÃ ĐO**

| Nguồn | Số FF |
|---|---:|
| Charter mục 10 dự đoán | 4–6 |
| Số FF đo được của F08 | **15** |
| Trong đó: FSM vị trí | **3** |
| Trong đó: bộ chia tần | **8** |
| Trong đó: đầu ra giải mã pha | **4** |

**Nhận xét:** vị trí dùng 3 bit và bộ chia tần dùng 8 bit; phép tổng hợp báo 15 FF do
còn 4 FF đầu ra giải mã pha. So sánh các kiến trúc khác cần đo bằng cùng cấu hình.

### 5.3 Bảng tra hay logic tổ hợp rẻ hơn — **chưa so sánh biến thể**

Hàm `phase_decode` được mô tả bằng `case`. Kết quả Yosys hiện báo tổng cộng 15 FF; hồ sơ
sự cố ghi nhận 4 bit đầu ra bảng pha được ánh xạ thành FF. Chưa có phép đo biến thể ROM
macro hoặc logic tổ hợp viết lại trên cùng cấu hình.

Vậy câu hỏi thật sự là: **ROM thật (macro) hay logic tổ hợp?**

| | **Logic tổ hợp** (hiện tại) | **ROM macro** |
|---|---|---|
| Kích thước bài toán | 8 mục × 4 bit = **32 bit** | như trên |
| Hiện thực | Mỗi bit `coil` là một hàm 4 biến (`state[2:0]`, `half_step`) ⟹ 4 hàm nhỏ, `abc` tối giản rất sâu | Một macro 32 bit + logic địa chỉ |
| Chi phí | Vài cổng mỗi bit | **Một macro** — overhead cố định lớn hơn nhiều so với 32 bit dữ liệu |
| Đổi bảng sau khi tape-out | ❌ không | ❌ cũng không (ROM cứng) |
| Kết luận hiện tại | Chưa có kết luận đo được; đây là giả thuyết cần kiểm bằng cùng PDK/toolchain | Chỉ đánh giá sau khi đo macro cụ thể |

**Một cấu trúc thứ ba đáng bàn** — thanh ghi dịch one-hot (kiến trúc C ở §2): giải mã pha
gần như **miễn phí** (mỗi bit one-hot ánh xạ thẳng sang mẫu), đổi lại **8 FF** thay vì 3.
Đây là đánh đổi FF ↔ logic tổ hợp thuần tuý, và là phương án duy nhất trong bảng có thể
thắng A về **timing** (không có bộ tăng, chỉ có phép dịch).

⟹ Có số liệu cho thiết kế A, nhưng chưa có số đo công bằng cho A-với-ROM và C. Chỉ kết
luận phương án nào rẻ hơn sau khi tổng hợp chúng với cùng toolchain và cấu hình.

## 6. Những đánh đổi **KHÔNG được phép** trong đề này

| Đánh đổi | Vì sao cấm | Nguồn |
|---|---|---|
| Thêm **vi bước** (microstepping) | Charter mục 3 — ngoài phạm vi. Cần DAC/PWM điều biên dòng, không phải mẫu bật/tắt 4 bit | Charter mục 3 |
| Thêm **điều khiển dòng** | Ngoài phạm vi | Charter mục 3 |
| Thêm **gia tốc / đường cong tốc độ** | Ngoài phạm vi — thuộc bộ sinh quỹ đạo tầng ngoài | Charter mục 3 |
| Thêm **phản hồi vị trí** (encoder) | Ngoài phạm vi. **Và chính vì thiếu nó mà mọi bước mất là mất vĩnh viễn** | Charter mục 3 |
| Dùng `f08_bad_direction_reset` làm thiết kế chính | Mất tới **7 bước** mỗi lần đổi chiều — vi phạm `functional_spec.md` §2.1 | `fsm.md` §8.2 |
| Bỏ `run` khỏi biểu thức `coil` để "đơn giản hoá" | Cuộn giữ dòng khi máy dừng ⟹ nóng, tốn điện, mô-men giữ không mong muốn | `functional_spec.md` INV-5 |
| Bỏ chế độ nửa bước để tiết kiệm 1 FF | Charter mục 4 chốt `uio_in[1] = nửa bước` — hợp đồng giao diện. Và chỉ tốn **1 FF** | Charter mục 4 |
| **Sửa RTL để "chữa" `===` ở dòng 85 hay vùng tàn dư** | Hồ sơ chỉ **ghi nhận** và **đề xuất**, không tự sửa | SPEC §0.2, §3 |
| **Sửa DUT vì testbench không biên dịch được** | Lỗi nằm ở testbench (`syntax error` trong file TB), DUT chưa hề được đụng tới | `known_issues.md` §2 |
| Ghi "F08 đã được kiểm chứng" | ❌ **Mô phỏng chưa bao giờ chạy** — 0 chu kỳ | `known_issues.md` §4 |
| Ghi "F08 tốn 22 cell / 190,1824 µm²" | Đó là số của **phản ví dụ**, không phải của bộ điều khiển | §2.1 |
| Tuyên bố tần số từ slack 8,25 ns | Chưa có ký sinh dây, một góc PVT; và là số của module khác | `02_SPECIFICATION/timing.md` §3 |
| Tự tối ưu netlist bằng tay | Ngoài phạm vi chung | Charter mục 3 |

---

*Phiên bản: v1.0 · Ngày: 2026-09-24*
