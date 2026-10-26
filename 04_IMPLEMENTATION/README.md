# F08 · Tầng 04 — Hiện thực (Implementation)

---

## 1. Nội dung thư mục

```
04_IMPLEMENTATION/
├── rtl/               f08_bad_direction_reset.sv, f08_bad_dual_state_register.sv, f08_stepper_ctrl.sv, f08_stepper_ctrl_wrapper.sv
├── constraints/       design.sdc
├── scripts/           01_run_sim.sh · 02_run_synth.sh · 03_run_sta.tcl
│                      04_run_librelane.sh · config.json · config_librelane.json
└── README.md
```

**Top module:** `f08_stepper_ctrl`
**Bằng chứng chọn top:** `hierarchy -check -top f08_stepper_ctrl` trong script tổng hợp; testbench instantiates cùng module.
**Wrapper TinyTapeout:** `tt_um_eee703128_24100755` trong `src/project.v`.
**Module đối chiếu:** `f08_bad_direction_reset`, `f08_bad_dual_state_register`.

## 2. Thứ tự chạy

```bash
python3 05_VERIFICATION/golden_model/reference_model.py     # ✅ PASS
bash 04_IMPLEMENTATION/scripts/01_run_sim.sh                # ✅ PASS
bash 04_IMPLEMENTATION/scripts/02_run_synth.sh              # ✅ PASS
sta -no_splash -exit 04_IMPLEMENTATION/scripts/03_run_sta.tcl   # ✅ PASS
bash 04_IMPLEMENTATION/scripts/04_run_librelane.sh          # ⬜ cần PDK sky130A
```

Mỗi script tự kiểm tra công cụ và **dừng có thông báo** nếu thiếu, thay vì tạo kết quả giả.

## 3. Sửa đổi đã áp dụng

Nguồn gốc được giữ nguyên tại `08_ORIGINAL_SOURCE/`. Các chỉnh sửa trên bản làm việc
được ghi tại [`08_ORIGINAL_SOURCE/PATCHLOG.md`](../08_ORIGINAL_SOURCE/PATCHLOG.md):

- Sửa vị trí khai báo biến trong testbench để Icarus biên dịch được.
- Đặt top tổng hợp là `f08_stepper_ctrl`, cùng top với testbench.
- Bỏ nhánh so sánh `===` không tổng hợp đúng.
- Bổ sung kiểm chuỗi tiến/lùi và các ca biên quay nghịch/bộ chia.

Testbench hiện chạy PASS; bằng chứng lần chạy mới nhất ở `05_VERIFICATION/simulation.log`.

## 4. Môi trường đã dùng để sinh bằng chứng

| Công cụ | Phiên bản |
|---|---|
| Mô phỏng trong hồ sơ | Icarus Verilog 12.0 (stable); lần chạy lại cục bộ dùng 13.0 |
| Tổng hợp | Yosys 0.33 (git sha1 2584903a060) |
| STA + công suất | OpenSTA 3.1.0 |
| Liberty | `sky130_fd_sc_hd__tt_025C_1v80.lib` (typical · 25 °C · 1,80 V) |
| LibreLane + sky130A | Archive run có GDS, DRC/LVS và metrics trong `../06_GDSII/` |

## 5. Cài đặt công cụ trên WSL Ubuntu

```bash
sudo apt update && sudo apt install -y iverilog yosys gtkwave
# OpenSTA: can cmake swig tcl-dev flex bison libeigen3-dev libgtest-dev + CUDD 3.0.0
pip install librelane volare && volare enable --pdk sky130 <commit>
export PDK_ROOT=$HOME/.volare
```

Gọn hơn: dùng **OSS CAD Suite** (`source <oss-cad-suite>/environment`) — có sẵn iverilog,
yosys, OpenSTA, OpenROAD, KLayout, Magic, Netgen.

---

*Phiên bản: v1.0 · Ngày: 2026-09-24*
