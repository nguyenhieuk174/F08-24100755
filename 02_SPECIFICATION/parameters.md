# F08 · Tham số và cấu hình (Parameters)

---

## 1. Tham số thiết kế chốt từ Charter

| Tham số | Giá trị | Có được đổi không | Nguồn |
|---|---|---|---|
| Loại mạch | **Tuần tự** | ❌ | Charter metadata |
| Nhóm đề | F · Máy trạng thái hữu hạn (FSM) | ❌ | Charter metadata |
| Độ khó | Trung bình | — | Charter metadata |
| Quy mô ước lượng | ~150–220 cell · 1×1 tile | — | Charter metadata |
| Top module | `f08_stepper_ctrl` | ❌ | RTL |
| Số flip-flop mong đợi | > 0 | ❌ | Charter mục 10 |

## 2. Môi trường công cụ đã dùng để sinh bằng chứng

| Hạng mục | Giá trị |
|---|---|
| Hệ điều hành | Ubuntu 22.04 LTS (x86-64) |
| Mô phỏng | **Icarus Verilog 12.0 (stable)** (cờ `-g2012`) |
| Tổng hợp | **Yosys 0.33 (git sha1 2584903a060)** |
| STA + công suất | **OpenSTA 3.1.0** |
| Thư viện standard cell | `sky130_fd_sc_hd` |
| File Liberty | `sky130_fd_sc_hd__tt_025C_1v80.lib` |
| Góc PVT | **typical · 25 °C · 1,80 V** |
| Nguồn Liberty | OpenROAD-flow-scripts · flow/platforms/sky130hd/lib/ |
| PDK cho P&R | **sky130A** (đã chạy trong GitHub Actions) |
| Flow P&R | **LibreLane / OpenROAD** (có archive; xem `06_GDSII/`) |

> ⚠️ Mọi con số cell, diện tích, timing, công suất trong hồ sơ này gắn chặt với **đúng** tổ
> hợp trên. Đổi bất kỳ thành phần nào thì số liệu đổi theo. Charter mục 6 yêu cầu nêu
> **điều kiện tạo ra bằng chứng** — bảng này chính là điều kiện đó.
>
> **Không so sánh chéo** số liệu giữa các đề nếu chúng chạy trên môi trường khác nhau.

## 3. Số liệu đo được

| Chỉ số | Giá trị | Nguồn |
|---|---:|---|
| Standard-cell instances sau P&R | 148 | `06_GDSII/runs/RUN_2026-10-26_04-13-31/final/metrics.json` |
| Tổng instances (gồm filler/tap/repair) | 485 | như trên |
| Flip-flop | 15 | như trên |
| Diện tích standard cell | 1362,56 µm² | như trên |
| Diện tích core / die | 2499,9 / 4553,21 µm² | như trên |
| Setup / hold worst slack | 1,71449 / 0,30258 ns | như trên |
| Công suất tổng ước lượng | 1,82346e-04 W | như trên |
| Route DRC errors | 0 | như trên |
| Flow errors | 0 | như trên |

## 4. Cấu hình máy đọc được

Xem `04_IMPLEMENTATION/scripts/config_librelane.json`; archive log nằm trong `06_GDSII/runs/`.

README nguồn đánh dấu P&R là chưa chạy trong bảng trạng thái; hiện có archive
LibreLane riêng. Xem `07_TRACEABILITY/limitations.md` để không gộp hai trạng thái.

---

*Phiên bản: v1.0 · Ngày: 2026-09-24*
