###############################################################################
# Created by write_sdc
###############################################################################
current_design f08_stepper_ctrl
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name clk -period 10.0000 [get_ports {clk}]
set_propagated_clock [get_clocks {clk}]
set_input_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {dir}]
set_input_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {half_step}]
set_input_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {rst_n}]
set_input_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {run}]
set_input_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {speed_div[0]}]
set_input_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {speed_div[1]}]
set_input_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {speed_div[2]}]
set_input_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {speed_div[3]}]
set_input_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {speed_div[4]}]
set_input_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {speed_div[5]}]
set_input_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {speed_div[6]}]
set_input_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {speed_div[7]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {coil[0]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {coil[1]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {coil[2]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {coil[3]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {state_dbg[0]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {state_dbg[1]}]
set_output_delay 1.0000 -clock [get_clocks {clk}] -add_delay [get_ports {state_dbg[2]}]
###############################################################################
# Environment
###############################################################################
###############################################################################
# Design Rules
###############################################################################
