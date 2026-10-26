// EDUCATIONAL ANTI-PATTERN.
// Direction change incorrectly resets the sequence to state zero.

module f08_bad_direction_reset(
    input logic clk,
    input logic rst_n,
    input logic step_tick,
    input logic dir,
    output logic [2:0] state
);
    logic dir_d;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            state <= 3'd0;
            dir_d <= 1'b1;
        end else if (step_tick) begin
            if (dir != dir_d)
                state <= 3'd0;  // wrong: creates a sequence jump
            else if (dir)
                state <= (state == 3'd7) ? 3'd0 : state + 1'b1;
            else
                state <= (state == 3'd0) ? 3'd7 : state - 1'b1;
            dir_d <= dir;
        end
    end
endmodule
