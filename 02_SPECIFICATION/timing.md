# F08 · Đặc tả thời gian (Timing)

---

## 1. Bản chất thời gian của khối này

F08 là mạch **Tuần tự**.

Khối có **15 flip-flop**, hoạt động đồng bộ theo cạnh clock.

| Khái niệm | Áp dụng? |
|---|:-:|
| Chu kỳ clock | ✅ |
| Setup / hold | ✅ |
| Đường reg→reg, in→reg, reg→out | ✅ |
| CTS (cây clock) | ✅ ở bước physical design |
| WNS / TNS | ✅ |

## 2. Phương pháp ràng buộc đã dùng

Chế độ: **clock thật của thiết kế**.

File SDC: `04_IMPLEMENTATION/constraints/design.sdc`

```tcl
# Mach TUAN TU: dinh nghia clock that tu cong clock cua thiet ke.
# Chu ky 10 ns va IO delay 1 ns la GIA DINH phan tich khoi diem,
# KHONG phai yeu cau he thong. Phai neu kem moi con so bao cao.
create_clock -name clk -period 10.0 [get_ports clk]
set_input_delay  1.0 -clock clk [all_inputs]
set_output_delay 1.0 -clock clk [all_outputs]
```

## 3. Bốn giả định phải nêu kèm mọi con số

| # | Giả định | Giá trị dùng trong gói này |
|---|---|---|
| G-1 | Chu kỳ clock | `10,0 ns` — **giả định khởi điểm**, chưa phải yêu cầu hệ thống |
| G-2 | Input/output delay | 1,0 ns — giả định khởi điểm cho biên IO |
| G-3 | Thư viện + PVT | `sky130_fd_sc_hd__tt_025C_1v80.lib` (typical · 25 °C · 1,80 V) |
| G-4 | Ký sinh dây (RC) | Có archive sau routing; SPEF/STA trong `06_GDSII/runs/RUN_2026-10-26_05-07-08/final/` |

> ❗ Không được diễn giải "period 10 ns" thành "F08 chạy được ở 100 MHz".
> Tần số tối đa thật phải lấy từ STA sau routing, ở nhiều góc PVT.

## 4. Số liệu thời gian đo được

| Đại lượng | Giá trị |
|---|---:|
| Setup worst slack | 1,71449 ns |
| Hold worst slack | 0,30258 ns |
| Setup / hold violation count | 0 / 0 |
| Timing source | Post-route metrics, across configured corners |

Flow: LibreLane / OpenROAD · Bằng chứng: `06_GDSII/runs/RUN_2026-10-26_05-07-08/final/metrics.json`.
Đường tới hạn `speed_div[2]` → `_172_` và độ trễ `3,48 ns` là số liệu OpenSTA được công bố trong README nguồn; không được gán cho metrics post-route ở trên.

## 5. Nghĩa vụ của tầng ngoài

```
t_clk  ≥  t_ckq  +  t_logic_max  +  t_setup  +  t_skew   (do chinh STA bao cao)
```

---

*Phiên bản: v1.0 · Ngày: 2026-09-24 · Truy vết: REQ-F08-020, AC-12…AC-14.*
