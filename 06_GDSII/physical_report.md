# F08 · Báo cáo tổng hợp và vật lý

## 1. Tóm tắt theo README dự án

Các số liệu sau đây là số liệu được công bố ở bảng kết quả của
[README dự án](../README.md), không phải ước lượng Charter:

| Chỉ số | Giá trị | Công cụ / giai đoạn |
|---|---:|---|
| Số cell | 101 | Yosys 0.33 |
| Flip-flop | 15 | Yosys 0.33 |
| Diện tích | 835,8016 µm² | Yosys 0.33 |
| Đường tới hạn | `speed_div[2]` → `_172_` | OpenSTA 3.1.0 |
| Độ trễ | 3,48 ns | OpenSTA 3.1.0 |
| Công suất ước lượng | 7.10e-05 W | OpenSTA 3.1.0 |

Các giá trị này được chép theo README nguồn. Báo cáo pre-route chi tiết không
được lưu riêng trong thư mục output cục bộ; các script trong
`../04_IMPLEMENTATION/scripts/` là đường chạy lại được cung cấp.

## 2. Archive LibreLane/OpenROAD

Ngoài các số ở bảng trên, archive
[`runs/RUN_2026-10-26_04-13-31/`](runs/RUN_2026-10-26_04-13-31/) chứa một lần
chạy physical design riêng cho `f08_stepper_ctrl`, với cấu hình LibreLane,
sky130A và `sky130_fd_sc_hd`.

| Chỉ số trong archive | Giá trị |
|---|---:|
| Standard-cell instances | 148 |
| Tổng instances | 485 |
| Flip-flop | 15 |
| Diện tích standard cell | 1362,56 µm² |
| Diện tích core / die | 2499,9 / 4553,21 µm² |
| Setup / hold worst slack | 1,71449 / 0,30258 ns |
| Công suất tổng ước lượng | 1,82346e-04 W |
| Route DRC errors | 0 |
| Magic / KLayout DRC errors | 0 / 0 |
| LVS device / net differences | 0 / 0 |

Bằng chứng chính:

- Metrics: [`final/metrics.json`](runs/RUN_2026-10-26_04-13-31/final/metrics.json)
- GDS: [`final/gds/f08_stepper_ctrl.gds`](runs/RUN_2026-10-26_04-13-31/final/gds/f08_stepper_ctrl.gds)
- STA post-route: `55-openroad-stapostpnr/`
- Routing: `44-openroad-detailedrouting/`
- DRC: `64-magic-drc/` và `65-klayout-drc/`
- LVS: `70-netgen-lvs/`

Các số liệu ở mục 1 và mục 2 đến từ các giai đoạn/cấu hình báo cáo khác nhau.
Không dùng chúng như thể cùng một lần đo; đặc biệt không suy ra tần số hệ thống
từ slack hoặc độ trễ khi chưa có yêu cầu tần số của hệ thống.

## 3. Trạng thái và giới hạn

Archive có đầu ra GDS, log P&R, DRC và LVS. Bảng trạng thái ở README nguồn vẫn
ghi P&R là chưa chạy; sự khác biệt này được giữ nguyên để không sửa nội dung
file nguồn và được ghi rõ là điểm cần đối chiếu khi chốt bản nộp. Archive chứng
minh có một lần chạy được lưu, nhưng không tự chứng minh ASIC sign-off, khả năng
sản xuất, tape-out hay kiểm tra silicon.

Gate-level simulation và post-layout simulation có SDF chưa được chứng minh
bằng các log trong `05_VERIFICATION/`; các báo cáo STA vật lý không thay thế hai
lớp kiểm chứng đó. Xem [`../07_TRACEABILITY/limitations.md`](../07_TRACEABILITY/limitations.md).
