# F08 · Phân tích đánh đổi (Trade-off)

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
| Cell | ⬜ **chưa đo** | ⬜ chưa đo | **22** |
| Flip-flop | ⬜ chưa đo — *suy từ mã: 11* | ⬜ — *suy từ mã: 5 + chia tần* | **4** |
| Diện tích | ⬜ | ⬜ | **190,1824 µm²** |
| Đường tới hạn | ⬜ | ⬜ | `dir → _31_ → _33_ → _34_ → _35_ → _39_` |
| Data arrival | ⬜ | ⬜ | **1,68 ns** (gồm 1,00 ns input delay giả định) |
| Slack | ⬜ | ⬜ | **8,25 ns (MET)**, WNS/TNS = 0,00/0,00 |
| Công suất | ⬜ | ⬜ | **2,19e-05 W** — tuần tự 82,7 %, tổ hợp 17,3 % |
| Đổi chiều đúng? | ✅ | ✅ | ❌ **mất tới 7 bước** |
| Có `coil`, `run`, `half_step`? | ✅ | ❌ | ❌ |

> 👉 **Cột duy nhất có số là cột của một mạch SAI, và nó cũng là mạch thiếu ba trên năm
> nhóm cổng mà Charter mục 4 yêu cầu.** Không có một con số nào trong hồ sơ F08 thuộc về
> bộ điều khiển động cơ bước thật.

### 2.2 Cái bẫy 4 flip-flop

Charter mục 10: *"Dấu hiệu làm đúng: 3 ô nhớ vị trí (8 trạng thái nửa bước) + vài bit chế
độ ≈ 4–6 ô nhớ."*

| | |
|---|---|
| Đo được | **4 FF** |
| Dải Charter | 4–6 |
| Kết luận vội | "✅ khớp — làm đúng" |
| Sự thật | 4 FF đó = `state[2:0]` + `dir_d` của **phản ví dụ** |
| `f08_stepper_ctrl` thật sự cần | 3 (`state`) + 8 (`div_count`) = **11 FF** — **ngoài** dải Charter |
| Vì sao Charter dự đoán thiếu | Charter **không tính bộ chia tần** `speed_div` — mà bộ đó chiếm **73 %** số FF |

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
| `SPEED_DIV_W = 8` cố định | Tham số nhỏ hơn, hoặc `speed_div` là hằng | ❌ 8 FF là **73 %** số FF. Nếu ứng dụng chỉ cần chia tới 16, `SPEED_DIV_W = 4` tiết kiệm **4 FF**. |
| `===` ở dòng 85–86 | Bỏ hẳn, hoặc đưa vào `` `ifdef SIMULATION `` | ❌ Không tổng hợp được theo nghĩa thông thường; là mã chết. Nên dọn. `fsm.md` §6.3. |

## 4. Bốn việc cần đo để biến §2–§3 từ giả thuyết thành kết luận

| # | Việc | Lệnh | Trả lời được câu nào |
|---|---|---|---|
| **0** | ⚠️ **Vá lỗi cú pháp testbench, chạy được mô phỏng** | `known_issues.md` §5 | **Điều kiện tiên quyết** — không có bước này thì mọi bước sau vô nghĩa |
| 1 | Tổng hợp **đúng** `f08_stepper_ctrl` | sửa `synth.ys` dòng 5 → `hierarchy -check -top f08_stepper_ctrl`, chạy `02_run_synth.sh` | Toàn bộ cột **A** ở §2.1; Charter mục 2 câu 3 |
| 2 | Tổng hợp `f08_bad_dual_state_register` | như trên với top khác | Cột **B**; **Charter mục 9** phần so mã hoá |
| 3 | Chạy lại với `SPEED_DIV_W` = 4 và 8 | thêm `chparam -set SPEED_DIV_W 4` | Tách chi phí bộ chia tần khỏi chi phí FSM |
| 4 | Thử `phase_decode` viết bằng biểu thức tổ hợp thay vì `case` | sửa bản sao RTL, so `synth_stat.txt` | **Charter mục 9** phần "bảng tra hay logic tổ hợp rẻ hơn" |

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

### 5.2 Đối chiếu số flip-flop — ⬜ **CHƯA ĐO**

| Nguồn | Số FF |
|---|---:|
| Charter mục 10 dự đoán | 4–6 |
| **Đo được** (nhưng của **phản ví dụ**) | **4** |
| `f08_stepper_ctrl` suy từ mã | 3 + 8 = **11** |
| Trong đó: FSM vị trí | **3** (27 %) |
| Trong đó: bộ chia tần | **8** (73 %) |

**Nhận xét sẽ phải kiểm bằng số:** phần "thông minh" của F08 chỉ tốn **3 FF**; phần đếm
thời gian tốn **8**. Charter dự đoán sai dải vì không tính bộ chia tần — và đó chính là
điểm đáng nói nhất khi trả lời câu này.

### 5.3 Bảng tra hay logic tổ hợp rẻ hơn — ⬜ **CHƯA ĐO**, nhưng phân tích được

Trước hết phải làm rõ một hiểu nhầm: **trong RTL hiện tại KHÔNG có "bảng tra" theo nghĩa
phần cứng.** Hàm `phase_decode` viết bằng `case`, nhưng Yosys dựng nó thành **mạng cổng tổ
hợp**, không thành ROM. `synth_stat.txt` của phản ví dụ ghi `Number of memories: 0` —
và với `f08_stepper_ctrl` cũng sẽ như vậy.

Vậy câu hỏi thật sự là: **ROM thật (macro) hay logic tổ hợp?**

| | **Logic tổ hợp** (hiện tại) | **ROM macro** |
|---|---|---|
| Kích thước bài toán | 8 mục × 4 bit = **32 bit** | như trên |
| Hiện thực | Mỗi bit `coil` là một hàm 4 biến (`state[2:0]`, `half_step`) ⟹ 4 hàm nhỏ, `abc` tối giản rất sâu | Một macro 32 bit + logic địa chỉ |
| Chi phí | Vài cổng mỗi bit | **Một macro** — overhead cố định lớn hơn nhiều so với 32 bit dữ liệu |
| Đổi bảng sau khi tape-out | ❌ không | ❌ cũng không (ROM cứng) |
| Kết luận dự kiến | ✅ **Logic tổ hợp thắng rõ** ở quy mô này | Chỉ đáng khi bảng **hàng trăm mục** |

**Một cấu trúc thứ ba đáng bàn** — thanh ghi dịch one-hot (kiến trúc C ở §2): giải mã pha
gần như **miễn phí** (mỗi bit one-hot ánh xạ thẳng sang mẫu), đổi lại **8 FF** thay vì 3.
Đây là đánh đổi FF ↔ logic tổ hợp thuần tuý, và là phương án duy nhất trong bảng có thể
thắng A về **timing** (không có bộ tăng, chỉ có phép dịch).

⟹ **Câu trả lời đầy đủ cho Charter mục 9 cần ba con số:** diện tích của A, của A-với-ROM,
và của C. Hiện có **không con số nào**. Cách lấy: việc 1 và việc 4 ở §4.

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
