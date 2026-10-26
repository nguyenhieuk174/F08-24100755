#!/usr/bin/env bash
# =====================================================================
#  F08 · Buoc 1 — Mo phong chuc nang (Icarus Verilog)
#  Chay tu THU MUC GOC cua du an:
#      bash 04_IMPLEMENTATION/scripts/01_run_sim.sh
# =====================================================================
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"; cd "$ROOT"
OUT=05_VERIFICATION
mkdir -p "$OUT/waveforms"

command -v iverilog >/dev/null || { echo "[LOI] thieu 'iverilog' (sudo apt install iverilog)"; exit 2; }

iverilog -V | head -1 | tee "$OUT/tool_versions.txt"

iverilog -g2012 -o "$OUT/sim.vvp" \
    04_IMPLEMENTATION/rtl/f08_bad_direction_reset.sv \
    04_IMPLEMENTATION/rtl/f08_bad_dual_state_register.sv \
    04_IMPLEMENTATION/rtl/f08_stepper_ctrl.sv \
    04_IMPLEMENTATION/rtl/f08_stepper_ctrl_wrapper.sv \
    05_VERIFICATION/testbench/f08_tb.sv \
    05_VERIFICATION/testbench/properties.sv

(cd "$OUT" && vvp sim.vvp) | tee "$OUT/simulation.log"
if [[ ! -s "$OUT/waveforms/f08_tb.vcd" ]]; then
    echo "[LOI] Khong tao duoc waveform: $OUT/waveforms/f08_tb.vcd" >&2
    exit 1
fi

echo
echo "Bang chung: $OUT/simulation.log"
echo "Waveform  : $OUT/waveforms/f08_tb.vcd"
