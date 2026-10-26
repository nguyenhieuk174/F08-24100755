// ─────────────────────────────────────────────────────────────────────────────
//  Testbench mẫu — EEE703128 Bài kiểm tra số 2
//
//  Testbench này làm ba việc, và báo cáo của em cần cả ba:
//    1. Sinh kích thích đầu vào theo các ca kiểm thử của đề
//    2. So kết quả thu được với kết quả MONG ĐỢI (tự tính tay trước)
//    3. Ghi file .vcd để mở bằng GTKWave / Surfer và chụp waveform đưa vào báo cáo
//
//  Chạy thử trên máy (nếu có Icarus Verilog):
//      iverilog -g2012 -o tb.out test/tb.v src/project.v && vvp tb.out
//
//  Không cài được cũng không sao — chuỗi công cụ trên GitHub chạy hộ.
// ─────────────────────────────────────────────────────────────────────────────
`default_nettype none
`timescale 1ns / 1ps

module tb;

    reg  [7:0] ui_in, uio_in;
    reg        ena, clk, rst_n;
    wire [7:0] uo_out, uio_out, uio_oe;

    integer so_ca  = 0;   // đã chạy bao nhiêu ca
    integer so_sai = 0;   // sai bao nhiêu ca

    tt_um_eee703128_<MSSV> dut (
        .ui_in(ui_in), .uo_out(uo_out),
        .uio_in(uio_in), .uio_out(uio_out), .uio_oe(uio_oe),
        .ena(ena), .clk(clk), .rst_n(rst_n)
    );

    // Xung nhịp 10 ns (100 MHz). Đề tổ hợp không dùng nhưng cứ để chạy.
    initial clk = 0;
    always #5 clk = ~clk;

    // ── Nhiệm vụ kiểm một ca ──────────────────────────────────────────────
    // Sửa hai tham số cho khớp đề của em.
    task kiem;
        input [7:0] a;          // giá trị đưa vào ui_in
        input [7:0] b;          // giá trị đưa vào uio_in
        input [7:0] mong_doi;   // giá trị MONG ĐỢI ở uo_out — tự tính tay
        input [255:0] ten;      // tên ca kiểm thử (tối đa 32 ký tự)
        begin
            ui_in  = a;
            uio_in = b;
            #10;                            // chờ mạch ổn định
            so_ca = so_ca + 1;
            if (uo_out === mong_doi)
                $display("  ✓ %0s | ui=%0d uio=%0d -> uo=%0d", ten, a, b, uo_out);
            else begin
                so_sai = so_sai + 1;
                $display("  ✗ %0s | ui=%0d uio=%0d -> uo=%0d  (MONG ĐỢI %0d)",
                         ten, a, b, uo_out, mong_doi);
            end
        end
    endtask

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);

        ena = 1; rst_n = 0; ui_in = 0; uio_in = 0;
        #20 rst_n = 1;          // nhả reset
        #10;

        $display("");
        $display("=== CA KIEM THU ===");

        // ══════════════════ CA KIỂM THỬ CỦA EM — BẮT ĐẦU ══════════════════
        // Các ca dưới đây kiểm ví dụ mẫu threshold_alarm (alarm = sample >= threshold).
        // Xoá đi và thay bằng các ca ở cột "Ca kiểm thử tối thiểu" của đề em.
        // Nhớ thêm ít nhất hai ca do em tự nghĩ — rubric tiêu chí 2 có tính điểm phần này.

        kiem(  0,   0, 8'd1, "bang nhau o 0    ");   // 0 >= 0   -> alarm = 1
        kiem(  0,   1, 8'd0, "duoi nguong      ");   // 0 >= 1   -> alarm = 0
        kiem(200, 120, 8'd1, "tren nguong      ");   // 200>=120 -> alarm = 1
        kiem(120, 120, 8'd1, "dung bien        ");   // 120>=120 -> alarm = 1
        kiem(119, 120, 8'd0, "duoi bien 1 don vi");  // 119>=120 -> alarm = 0
        kiem(255,   0, 8'd1, "gia tri lon nhat ");   // 255>=0   -> alarm = 1
        kiem(  0, 255, 8'd0, "nguong lon nhat  ");   // 0 >= 255 -> alarm = 0

        // ══════════════════ CA KIỂM THỬ CỦA EM — KẾT THÚC ══════════════════

        $display("");
        $display("=== KET QUA: %0d ca, %0d sai ===", so_ca, so_sai);
        if (so_sai == 0) $display("TAT CA CA KIEM THU DEU DAT");
        else             $display("CON %0d CA SAI — sua RTL roi chay lai", so_sai);
        $display("");
        #20 $finish;
    end

endmodule

`default_nettype wire
