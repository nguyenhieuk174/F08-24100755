# F08 · Chỉ mục bằng chứng

## 1. Kiểm chứng chức năng

| Bằng chứng | Đường dẫn | Tạo bằng |
|---|---|---|
| Mô hình chuẩn | `05_VERIFICATION/golden_model/reference_model.py` và `python_reference_run.log` | CPython 3 |
| RTL testbench | `05_VERIFICATION/testbench/f08_tb.sv` | Icarus Verilog 12.0 (`-g2012`) |
| Kết quả testbench | `05_VERIFICATION/simulation.log` | `04_IMPLEMENTATION/scripts/01_run_sim.sh` |
| Waveform VCD | `05_VERIFICATION/waveforms/f08_tb.vcd` | `04_IMPLEMENTATION/scripts/01_run_sim.sh`; GitHub Actions artifact `mo-phong-F08` |
| Danh sách ca | `05_VERIFICATION/test_matrix.csv` | Đối chiếu ca Charter với kết quả đã chạy |

## 2. Tổng hợp, timing và power

Các số tổng hợp/STA/công suất được tóm tắt tại [README dự án](../README.md) và
[`../06_GDSII/physical_report.md`](../06_GDSII/physical_report.md). Các số này
phải được đọc kèm công cụ, thư viện, PVT và giai đoạn đo tương ứng; không gộp
metrics sau P&R vào bảng pre-route.

## 3. Physical-flow archive

Archive LibreLane/OpenROAD:
[`../06_GDSII/runs/RUN_2026-10-26_04-13-31/`](../06_GDSII/runs/RUN_2026-10-26_04-13-31/).
Metrics JSON, GDS và log DRC/LVS/STA được liệt kê trong
[`../06_GDSII/physical_report.md`](../06_GDSII/physical_report.md).

## 4. Điều kiện và giới hạn

- RTL simulation là mô phỏng chức năng, không có delay vật lý.
- STA cần đọc cùng SDC và thư viện/corner tương ứng; chu kỳ trong SDC là giả định
  phân tích, không phải yêu cầu clock của hệ thống.
- GDS/DRC/LVS trong archive chỉ ghi nhận kết quả của flow đã lưu.
- Giới hạn chi tiết và các điểm cần xác nhận được ghi tại
  [`limitations.md`](limitations.md).

## 5. Chạy lại

Từ thư mục gốc:

```bash
python3 05_VERIFICATION/golden_model/reference_model.py
bash 04_IMPLEMENTATION/scripts/01_run_sim.sh
bash 04_IMPLEMENTATION/scripts/02_run_synth.sh
sta -no_splash -exit 04_IMPLEMENTATION/scripts/03_run_sta.tcl
bash 04_IMPLEMENTATION/scripts/04_run_librelane.sh
```

Lệnh LibreLane cần PDK sky130A. Các script sẽ báo lỗi nếu thiếu công cụ hoặc
đầu vào thay vì tạo số liệu giả.
