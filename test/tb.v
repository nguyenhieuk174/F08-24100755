`default_nettype none
`timescale 1ns / 1ps

module tb;
    reg clk = 0;
    reg rst_n = 0;
    reg [7:0] ui_in = 8'd1;
    reg [7:0] uio_in = 8'b00000000;
    reg ena = 1;
    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    tt_um_eee703128_24100755 dut (
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );

    always #5 clk = ~clk;

    task automatic check_step;
        input [2:0] exp_state;
        input [3:0] exp_coil;
        begin
            @(posedge clk);
            #1;
            if (uo_out[6:4] !== exp_state || uo_out[3:0] !== exp_coil) begin
                $display("FAIL: state=%0d coil=%04b expected state=%0d coil=%04b", uo_out[6:4], uo_out[3:0], exp_state, exp_coil);
                $fatal;
            end
        end
    endtask

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);

        #10 rst_n = 1;

        // half-step forward: 0->1->2->3->4->5->6->7->0
        uio_in = 8'b00000111; // dir=1, half_step=1, run=1
        check_step(3'd1, 4'b0001);
        check_step(3'd2, 4'b0011);
        check_step(3'd3, 4'b0010);
        check_step(3'd4, 4'b0110);
        check_step(3'd5, 4'b0100);
        check_step(3'd6, 4'b1100);
        check_step(3'd7, 4'b1000);
        check_step(3'd0, 4'b1001);

        // half-step reverse: 0->7->6->5->4->3->2->1->0
        uio_in[0] = 1'b0; // dir=0
        check_step(3'd7, 4'b1000);
        check_step(3'd6, 4'b1100);
        check_step(3'd5, 4'b0100);
        check_step(3'd4, 4'b0110);
        check_step(3'd3, 4'b0010);
        check_step(3'd2, 4'b0011);
        check_step(3'd1, 4'b0001);
        check_step(3'd0, 4'b1001);

        // full-step forward: 0->1->2->3->0 (state value only; half_step=0)
        uio_in[1] = 1'b0; // half_step=0
        uio_in[0] = 1'b1; // dir=1
        check_step(3'd1, 4'b0011);
        check_step(3'd2, 4'b0110);
        check_step(3'd3, 4'b1100);
        check_step(3'd0, 4'b1001);

        // stop drives coils inactive
        uio_in[2] = 1'b0; // run=0
        @(posedge clk);
        #1;
        if (uo_out[3:0] !== 4'b0000) begin
            $display("FAIL: coils not inactive when run=0");
            $fatal;
        end

        // reset clears state
        rst_n = 0;
        @(posedge clk);
        #1;
        if (uo_out[6:4] !== 3'd0) begin
            $display("FAIL: reset did not clear state");
            $fatal;
        end

        $display("PASS: stepper FSM testbench completed");
        $finish;
    end
endmodule

`default_nettype wire
