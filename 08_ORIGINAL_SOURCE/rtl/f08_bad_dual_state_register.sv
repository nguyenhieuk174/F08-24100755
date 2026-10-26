// EDUCATIONAL ALTERNATIVE.
// Separate full-step and half-step sequence registers.
// Included to discuss why the mentor scaffold prefers a shared state register.

module f08_bad_dual_state_register(
    input logic clk,
    input logic rst_n,
    input logic step_tick,
    input logic dir,
    input logic half_step,
    output logic [2:0] state
);
    logic [1:0] full_state;
    logic [2:0] half_state;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            full_state <= 2'd0;
            half_state <= 3'd0;
        end else if (step_tick) begin
            if (half_step)
                half_state <= dir ? ((half_state==7)?0:half_state+1)
                                  : ((half_state==0)?7:half_state-1);
            else
                full_state <= dir ? ((full_state==3)?0:full_state+1)
                                  : ((full_state==0)?3:full_state-1);
        end
    end

    always_comb
        state = half_step ? half_state : {1'b0,full_state};

endmodule
