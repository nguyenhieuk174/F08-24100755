# F08 · Kế hoạch kiểm chứng (Test Plan)

---

## 1. Chiến lược nhiều lớp độc lập

| Lớp | Nội dung | File | Công cụ | Trạng thái |
|---|---|---|---|---|
| L0 | Mô hình chuẩn viết bằng Python, độc lập với RTL | `golden_model/reference_model.py` | CPython 3 | ✅ PASS |
| L1 | Mô hình chuẩn viết bằng SystemVerilog | `golden_model/—` | Icarus Verilog 12.0 (stable) | ⬜ gói nguồn không có |
| L2 | Mô phỏng RTL với testbench tự kiểm | `testbench/f08_tb.sv` | Icarus Verilog 12.0 (GitHub Actions mới nhất); 13.0 (chạy lại cục bộ) | ✅ PASS |
| L3 | Kiểm cấu trúc — số flip-flop phù hợp phân loại | `../06_GDSII/runs/RUN_2026-10-26_05-07-08/final/metrics.json` | LibreLane / Yosys | ✅ 15 FF |
| L4 | Mô phỏng gate-level trên netlist | — | — | ⬜ chưa chạy |
| L5 | Mô phỏng post-layout có back-annotate SDF | — | — | ⬜ chưa chạy |

> Lý do dùng nhiều mô hình chuẩn độc lập: nếu mô hình chuẩn và RTL do cùng một người viết
> theo cùng một cách nghĩ, chúng có thể **cùng sai**. Một mô hình viết bằng ngôn ngữ khác
> (Python) làm giảm rủi ro đó — nguyên tắc *diverse redundancy*.

## 2. Ca kiểm thử bắt buộc theo Charter mục 8

- Quay thuận đủ một vòng ở cả hai chế độ · quay nghịch · đổi chiều giữa chừng · dừng
- Bổ sung ít nhất hai ca tự xây dựng, trong đó có ca biên.

Danh sách thực thi và kết quả: `test_matrix.csv`.

## 3. Tiêu chí PASS/FAIL

| Lớp | Tiêu chí PASS |
|---|---|
| L0 | Mô hình Python chạy hết, không assertion nào sai |
| L2 | Testbench chạy hết, **không** assertion nào vi phạm, không `$fatal` |
| L3 | Số cell tuần tự **> 0** — đúng phân loại **Tuần tự** |
| L4–L5 | Chưa chạy; khi chạy phải đạt như L2 và không có X-propagation |

Bất kỳ một FAIL nào ⟹ tầng đó FAIL. Không có ngưỡng "chấp nhận được".

## 4. Những gì kế hoạch này **không** chứng minh

| Không chứng minh | Vì sao | Cần gì |
|---|---|---|
| Kiến trúc bên trong đúng như đặc tả | Kiểm chứng chức năng mù về cấu trúc | Đọc RTL + netlist |
| Độ trễ đạt yêu cầu | Đánh giá theo timing assumptions; không suy ra tần số hệ thống | Metrics và báo cáo tại `../06_GDSII/` |
| Physical checks | Archive có P&R, DRC, LVS; chưa thay thế gate-level/SDF simulation | `../06_GDSII/physical_report.md` |
| Không có glitch gây hại | Mô phỏng zero-delay không sinh glitch | L5 với SDF |

---

*Phiên bản: v1.0 · Ngày: 2026-09-24 · Truy vết: REQ-F08-010…013.*
