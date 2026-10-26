# F08 · Tầng 06 — GDSII và kết quả vật lý

## Phạm vi và nguồn kết quả

Thư mục `runs/RUN_2026-10-26_05-07-08/` là archive LibreLane/OpenROAD mới nhất
của RTL core `f08_stepper_ctrl`, gồm log và đầu ra cuối của lần chạy sky130A.
Archive trước `runs/RUN_2026-10-26_04-13-31/` được giữ lại để đối chiếu. Bản tóm
tắt chỉ số được lập tại [`physical_report.md`](physical_report.md).

Các số tổng hợp/STA/công suất trong bảng kết quả đầu [README dự án](../README.md)
được giữ tách biệt với các số liệu sau P&R trong archive này. Chúng thuộc các
điểm đo và giai đoạn khác nhau; không thay thế lẫn nhau.

## Nội dung

| Đường dẫn | Nội dung |
|---|---|
| `runs/RUN_2026-10-26_05-07-08/final/metrics.json` | Metrics của lần chạy mới nhất |
| `runs/RUN_2026-10-26_05-07-08/final/gds/f08_stepper_ctrl.gds` | GDS mới nhất |
| `runs/RUN_2026-10-26_05-07-08/` | Archive đầy đủ: routing, DRC, LVS, STA, SPEF/SDF và final views |
| `simulation/mo-phong-F08/` | Log mô phỏng, phiên bản Icarus và waveform VCD từ cùng GitHub Actions run |
| `runs/RUN_2026-10-26_04-13-31/` | Archive physical trước đó, giữ lại làm lịch sử |

Lệnh chạy lại flow được cung cấp tại
[`../04_IMPLEMENTATION/scripts/04_run_librelane.sh`](../04_IMPLEMENTATION/scripts/04_run_librelane.sh);
flow cần LibreLane và PDK sky130A.
