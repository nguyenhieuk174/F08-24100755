// ─────────────────────────────────────────────────────────────────────────────
//  EEE703128 — Bài kiểm tra số 2 · KHUNG MẪU
//
//  ĐỌC TRƯỚC KHI SỬA
//  1. Đổi <MSSV> trong tên module thành mã số sinh viên của em.
//     Tên module PHẢI bắt đầu bằng  tt_um_  thì chuỗi công cụ mới nhận.
//  2. Giữ nguyên danh sách cổng. KHÔNG thêm, KHÔNG bớt, KHÔNG đổi tên.
//     Kể cả khi đề của em không dùng clk và rst_n, vẫn phải khai báo chúng.
//  3. Viết thiết kế của em vào chỗ ghi "PHẦN CỦA EM".
//  4. Phần dưới cùng là VÍ DỤ MẪU đã chạy được: case threshold_alarm của học phần.
//     Đọc nó để hiểu cách nối chân, rồi xoá đi và viết đề của mình.
//
//  Quy ước bắt buộc của chuỗi công cụ:
//    · `default_nettype none  ở đầu và `default_nettype wire ở cuối
//    · rst_n tích cực mức THẤP (rst_n = 0 nghĩa là đang reset)
//    · Mọi chân ra phải được gán giá trị, không được để hở
//    · uio_oe[i] = 1 nghĩa là chân hai chiều thứ i làm ĐẦU RA
// ─────────────────────────────────────────────────────────────────────────────
`default_nettype none

module f08_stepper_ctrl #(
    parameter integer SPEED_DIV_W = 8
)(
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire                     run,
    input  wire                     dir,
    input  wire                     half_step,
    input  wire [SPEED_DIV_W-1:0]   speed_div,
    output reg  [3:0]               coil,
    output reg  [2:0]               state_dbg
);

    reg [2:0] state, state_next;
    reg [SPEED_DIV_W-1:0] div_count;
    reg step_tick;

    function automatic [3:0] phase_decode;
        input [2:0] s;
        input       hs;
        begin
            if (hs) begin
                case (s)
                    3'd0: phase_decode = 4'b1001;
                    3'd1: phase_decode = 4'b0001;
                    3'd2: phase_decode = 4'b0011;
                    3'd3: phase_decode = 4'b0010;
                    3'd4: phase_decode = 4'b0110;
                    3'd5: phase_decode = 4'b0100;
                    3'd6: phase_decode = 4'b1100;
                    3'd7: phase_decode = 4'b1000;
                    default: phase_decode = 4'b0000;
                endcase
            end else begin
                case (s[1:0])
                    2'd0: phase_decode = 4'b1001;
                    2'd1: phase_decode = 4'b0011;
                    2'd2: phase_decode = 4'b0110;
                    2'd3: phase_decode = 4'b1100;
                    default: phase_decode = 4'b0000;
                endcase
            end
        end
    endfunction

    always @* begin
        state_next = state;

        if (half_step) begin
            if (dir)
                state_next = (state == 3'd7) ? 3'd0 : state + 3'd1;
            else
                state_next = (state == 3'd0) ? 3'd7 : state - 3'd1;
        end else begin
            if (dir)
                state_next = (state[1:0] == 2'd3) ? 3'd0 : state + 3'd1;
            else
                state_next = (state[1:0] == 2'd0) ? 3'd3 : state - 3'd1;
        end
    end

    always @* begin
        step_tick = 1'b0;
        if (run) begin
            if (speed_div == {SPEED_DIV_W{1'b0}})
                step_tick = 1'b1;
            else if (div_count >= (speed_div - 1'b1))
                step_tick = 1'b1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= 3'd0;
            div_count <= {SPEED_DIV_W{1'b0}};
        end else begin
            if (!run) begin
                div_count <= {SPEED_DIV_W{1'b0}};
            end else if (step_tick) begin
                div_count <= {SPEED_DIV_W{1'b0}};
                state     <= state_next;
            end else begin
                div_count <= div_count + 1'b1;
            end
        end
    end

    always @* begin
        if (!half_step && (state > 3'd3))
            coil = 4'b1001;
        else
            coil = run ? phase_decode(state, half_step) : 4'b0000;
    end

    always @* begin
        state_dbg = state;
    end

endmodule

module tt_um_eee703128_24100755 (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    wire run = uio_in[2];
    wire dir = uio_in[0];
    wire half_step = uio_in[1];
    wire [7:0] speed_div = ui_in;
    wire [3:0] coil;
    wire [2:0] state_dbg;

    f08_stepper_ctrl #(
        .SPEED_DIV_W(8)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .run(run),
        .dir(dir),
        .half_step(half_step),
        .speed_div(speed_div),
        .coil(coil),
        .state_dbg(state_dbg)
    );

    assign uo_out[0] = coil[0];
    assign uo_out[1] = coil[1];
    assign uo_out[2] = coil[2];
    assign uo_out[3] = coil[3];
    assign uo_out[4] = state_dbg[0];
    assign uo_out[5] = state_dbg[1];
    assign uo_out[6] = state_dbg[2];
    assign uo_out[7] = 1'b0;

    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule

`default_nettype wire
