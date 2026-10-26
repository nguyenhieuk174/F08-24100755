# F08 · Báo cáo kiểm chứng (Verification Report)

> 🔧 **ĐỀ NÀY ĐÃ ĐƯỢC VÁ LỖI**
>
> Mô phỏng ban đầu không đạt. Lỗi đã được chẩn đoán, vá và **xác minh lại bằng
> công cụ thật**. Mọi số liệu trong hồ sơ là số liệu **sau khi vá**.
>
> * Mã nguồn gốc: [`08_ORIGINAL_SOURCE/`](08_ORIGINAL_SOURCE/) — giữ nguyên, quay lui được
> * Nhật ký vá: [`08_ORIGINAL_SOURCE/PATCHLOG.md`](08_ORIGINAL_SOURCE/PATCHLOG.md)
> * Chẩn đoán đầy đủ: [`05_VERIFICATION/known_issues.md`](05_VERIFICATION/known_issues.md)



**Run GitHub Actions:** `RUN_2026-10-26_04-13-31` · **Phiên bản báo cáo:** v1.1

---

## 1. Điều kiện tạo ra bằng chứng

> Charter mục 6: *"Mỗi khẳng định đi kèm bằng chứng **và điều kiện tạo ra bằng chứng đó**."*

| Hạng mục | Giá trị |
|---|---|
| Hệ điều hành | Ubuntu 22.04 LTS (x86-64) |
| Công cụ mô phỏng | Hồ sơ nguồn ghi Icarus 12.0; lần chạy lại testbench dùng Icarus 13.0 (`-g2012`) |
| Top module | `f08_stepper_ctrl` |
| RTL core của hồ sơ | `04_IMPLEMENTATION/rtl/f08_stepper_ctrl.sv` |
| Wrapper tích hợp | `src/project.v` |
| Mô hình chuẩn | `05_VERIFICATION/golden_model/` |
| Testbench hiện tại | `05_VERIFICATION/testbench/f08_tb.sv` |
| Lệnh chạy testbench hiện tại | `bash 04_IMPLEMENTATION/scripts/01_run_sim.sh` |
| Physical flow | LibreLane / OpenROAD, `sky130A`, `sky130_fd_sc_hd` |
| Artifact archive | `06_GDSII/` |

## 2. Kết quả tổng hợp

| Lớp | Nội dung | Kết quả |
|---|---|---|
| L0 | Mô hình chuẩn Python | ✅ **PASS** |
| L2 | Mô phỏng RTL | ✅ PASS — [`simulation.log`](simulation.log) |
| L3 | Kiểm cấu trúc — số flip-flop | ✅ đo được **15** FF, phân loại Charter là **Tuần tự** |
| L4 | Mô phỏng gate-level | ⬜ chưa chạy |
| L5 | Mô phỏng post-layout (SDF) | ⬜ chưa chạy |

## 3. Trích log mô phỏng

```
F08 TB completed
05_VERIFICATION/testbench/f08_tb.sv:116: $finish called at 486 (1s)
```

Log đầy đủ của lần chạy lại hiện tại: [`simulation.log`](simulation.log).

## 4. Kiểm cấu trúc — số flip-flop

Trích metrics do LibreLane sinh: [`metrics.json`](../06_GDSII/runs/RUN_2026-10-26_04-13-31/final/metrics.json).

| Chỉ số | Giá trị |
|---|---:|
| Standard-cell instances | **148** |
| Tổng instances (kể cả filler, tap và repair) | **485** |
| Cell tuần tự (flip-flop / latch) | **15** |
| Diện tích standard cell | **1362,56 µm²** |
| Diện tích core / die | **2499,9 / 4553,21 µm²** |
| Setup / hold worst slack | **1,71449 / 0,30258 ns** |
| Power total estimate | **1,82346e-04 W** |


✅ Đúng phân loại **Tuần tự** của Charter — có ô nhớ đồng bộ theo clock.


## 5. Trả lời câu hỏi kỹ thuật của Charter (mục 2)

> 1. Chuỗi bước đủ (4 trạng thái) và nửa bước (8 trạng thái) dùng chung thanh ghi trạng thái hay riêng?
> 2. Đổi chiều giữa chừng — FSM phải làm gì để không nhảy bước?
> 3. Số ô nhớ dự đoán, và phần nào dành cho vị trí trong chuỗi?
> Sinh viên được phép thay bằng câu hỏi của mình, miễn là cụ thể và trả lời được bằng bằng chứng — không viết “tìm hiểu về…”.

Phần trả lời dựa trên số liệu đo được nằm ở:

- Câu về **giao diện / tín hiệu**: `02_SPECIFICATION/interface.md`
- Câu về **thời gian / tần số**: `02_SPECIFICATION/timing.md` và `06_GDSII/physical_report.md`
- Câu về **diện tích / tài nguyên**: `06_GDSII/physical_report.md`
- Phân tích bản chất và cơ chế: `implementation-notes_F08.md`

## 6. Những gì báo cáo này **chưa** chứng minh

| Chưa chứng minh | Vì sao |
|---|---|
| Kiến trúc bên trong đúng như mô tả | Kiểm chứng chức năng mù về cấu trúc — phải đọc RTL và netlist |
| Độ trễ lan truyền đạt yêu cầu | Mô phỏng hành vi là zero-delay |
| Hành vi của netlist sau place & route | Chưa chạy gate-level/SDF simulation |
| Kết quả physical có phải ASIC sign-off? | Không; DRC/LVS clear trong archive không đồng nghĩa sign-off. Xem `07_TRACEABILITY/limitations.md`. |
| Không có glitch gây hại | Mô phỏng zero-delay không sinh glitch |

Danh sách đầy đủ: `07_TRACEABILITY/limitations.md`.

Archive physical có kết quả DRC/LVS clear; đây là kết quả khác lớp với L4/L5 và
không thay thế mô phỏng gate-level hoặc SDF. README nguồn vẫn đánh dấu P&R chưa
chạy; điểm không khớp với archive được ghi tại `07_TRACEABILITY/limitations.md`.

---

*Truy vết: REQ-F08-001, REQ-F08-003, REQ-F08-010…013.*
