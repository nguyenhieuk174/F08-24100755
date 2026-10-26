// Mentor wrapper only. Official F08 pin mapping must replace this interface.
module f08_stepper_ctrl_wrapper #(
    parameter integer SPEED_DIV_W = 8
)(
    input  logic                   clk,
    input  logic                   rst_n,
    input  logic                   run,
    input  logic                   dir,
    input  logic                   half_step,
    input  logic [SPEED_DIV_W-1:0] speed_div,
    output logic [3:0]             coil,
    output logic [2:0]             state_dbg
);
    f08_stepper_ctrl #(.SPEED_DIV_W(SPEED_DIV_W)) dut (
        .clk(clk),
        .rst_n(rst_n),
        .run(run),
        .dir(dir),
        .half_step(half_step),
        .speed_div(speed_div),
        .coil(coil),
        .state_dbg(state_dbg)
    );
endmodule
