`ifdef F08_SVA
assert_half_state: assert property (@(posedge clk) half_step |-> state_dbg inside {[0:7]});
assert_full_state: assert property (@(posedge clk) !half_step |-> state_dbg inside {[0:3]});
`endif
