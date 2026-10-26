module f08_tb;
    logic clk, rst_n, run, dir, half_step;
    logic [7:0] speed_div;
    logic [3:0] coil;
    logic [2:0] state_dbg;
    logic [2:0] s_before;   // P-1: khai bao o pham vi module (IEEE 1800: trong mot
                            // block thu tuc, khai bao phai dung TRUOC moi cau lenh)

    f08_stepper_ctrl #(.SPEED_DIV_W(8)) dut(
        .clk(clk), .rst_n(rst_n), .run(run), .dir(dir),
        .half_step(half_step), .speed_div(speed_div),
        .coil(coil), .state_dbg(state_dbg)
    );

    always #5 clk = ~clk;

    task automatic tick;
        begin @(posedge clk); #1; end
    endtask

    initial begin
        $dumpfile("waveforms/f08_tb.vcd");
        $dumpvars(0, f08_tb);

        clk=0; rst_n=0; run=0; dir=1; half_step=1; speed_div=8'd1;
        repeat(2) tick();
        rst_n=1;

        // Start half-step sequence.
        run=1;
        repeat(8) tick();
        assert(state_dbg <= 3'd7) else $fatal(1,"invalid half-step state");

        // Direction reversal from a non-zero state must be adjacent, not reset.
        dir=1;
        tick();
        s_before = state_dbg;
        dir=0;
        tick();
        assert(state_dbg == ((s_before==0)?7:s_before-1))
            else $fatal(1,"direction reversal did not move to predecessor");

        // Full-step reverse traverses 0, 3, 2, 1 and wraps to 0.
        rst_n=0; run=0; tick();
        rst_n=1; half_step=0; dir=0; run=1;
        for (int k = 0; k < 4; k++) begin
            assert(state_dbg == ((4-k) % 4))
                else $fatal(1,"full-step reverse sequence failed at k=%0d", k);
            tick();
        end
        assert(state_dbg == 3'd0) else $fatal(1,"full-step reverse did not wrap");

        // Half-step reverse traverses 0, 7, ..., 1 and wraps to 0.
        rst_n=0; run=0; tick();
        rst_n=1; half_step=1; dir=0; run=1;
        for (int k = 0; k < 8; k++) begin
            assert(state_dbg == ((8-k) % 8))
                else $fatal(1,"half-step reverse sequence failed at k=%0d", k);
            tick();
        end
        assert(state_dbg == 3'd0) else $fatal(1,"half-step reverse did not wrap");

        // Stop drives coils inactive in the scaffold.
        run=0;
        tick();
        assert(coil==4'b0000) else $fatal(1,"stop output not inactive");

        // Reset.
        rst_n=0;
        tick();
        assert(state_dbg==0 && coil==0) else $fatal(1,"reset failure");

        // P-3 (known_issues muc 5.4): kiem CHUOI, khong chi kiem DAI.
        // INV-4 - moi nhip dung mot buoc, nua buoc tien 0..7.
        rst_n=0; run=0; tick();
        rst_n=1; half_step=1; dir=1; run=1;
        for (int k = 0; k < 8; k++) begin
            assert(state_dbg == k[2:0])
                else $fatal(1,"nhay buoc (nua buoc) tai k=%0d: state=%0d", k, state_dbg);
            tick();
        end
        assert(state_dbg == 3'd0) else $fatal(1,"nua buoc khong khep vong ve 0");

        // Charter muc 8: quay thuan du mot vong o che do BUOC DU (truoc day khong co ca nao).
        rst_n=0; run=0; tick();
        rst_n=1; half_step=0; dir=1; run=1;
        for (int k = 0; k < 4; k++) begin
            assert(state_dbg == k[2:0])
                else $fatal(1,"nhay buoc (buoc du) tai k=%0d: state=%0d", k, state_dbg);
            tick();
        end
        assert(state_dbg == 3'd0) else $fatal(1,"buoc du khong khep vong ve 0");

        // Custom boundary: reverse from state 0 wraps to state 7.
        rst_n=0; run=0; tick();
        rst_n=1; half_step=1; dir=0; speed_div=8'd0; run=1;
        tick();
        assert(state_dbg == 3'd7)
            else $fatal(1,"reverse wrap from state 0 failed");

        // Custom divider boundary: speed_div=2 advances once every two clocks.
        rst_n=0; run=0; tick();
        rst_n=1; half_step=1; dir=1; speed_div=8'd2; run=1;
        tick();
        assert(state_dbg == 3'd0)
            else $fatal(1,"speed_div=2 advanced too early");
        tick();
        assert(state_dbg == 3'd1)
            else $fatal(1,"speed_div=2 did not advance on second clock");
        tick();
        assert(state_dbg == 3'd1)
            else $fatal(1,"speed_div=2 advanced too early on next interval");
        tick();
        assert(state_dbg == 3'd2)
            else $fatal(1,"speed_div=2 did not advance on next interval");
        run=0;

        $display("F08 TB completed");
        $finish;
    end
endmodule
