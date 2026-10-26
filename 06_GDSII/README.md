# F08 · Tầng 06 — GDSII và kết quả vật lý

## Phạm vi và nguồn kết quả

Thư mục `runs/RUN_2026-10-26_04-13-31/` lưu archive LibreLane/OpenROAD của RTL
core `f08_stepper_ctrl`, gồm log và đầu ra cuối của một lần chạy sky130A. Bản tóm
tắt chỉ số được lập tại [`physical_report.md`](physical_report.md).

Các số tổng hợp/STA/công suất trong bảng kết quả đầu [README dự án](../README.md)
được giữ tách biệt với các số liệu sau P&R trong archive này. Chúng thuộc các
điểm đo và giai đoạn khác nhau; không thay thế lẫn nhau.

## Nội dung

| Đường dẫn | Nội dung |
|---|---|
| `runs/RUN_2026-10-26_04-13-31/final/metrics.json` | Metrics tổng hợp từ flow |
| `runs/RUN_2026-10-26_04-13-31/final/gds/f08_stepper_ctrl.gds` | GDS được sinh |
| `runs/RUN_2026-10-26_04-13-31/` | Log các giai đoạn, gồm routing, DRC, LVS và STA |
| `simulation/mo-phong-A01/simulation.log` | Log mô phỏng được lưu cùng archive |

Lệnh chạy lại flow được cung cấp tại
[`../04_IMPLEMENTATION/scripts/04_run_librelane.sh`](../04_IMPLEMENTATION/scripts/04_run_librelane.sh);
flow cần LibreLane và PDK sky130A.
