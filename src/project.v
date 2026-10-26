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

module tt_um_eee703128_<MSSV> (
    input  wire [7:0] ui_in,    // 8 chân vào riêng
    output wire [7:0] uo_out,   // 8 chân ra riêng
    input  wire [7:0] uio_in,   // 8 chân hai chiều — chiều vào
    output wire [7:0] uio_out,  // 8 chân hai chiều — chiều ra
    output wire [7:0] uio_oe,   // 1 = chân tương ứng là đầu ra
    input  wire       ena,      // luôn bằng 1 khi thiết kế được chọn
    input  wire       clk,      // xung nhịp hệ thống
    input  wire       rst_n     // reset, TÍCH CỰC MỨC THẤP
);

    // ══════════════════ PHẦN CỦA EM — BẮT ĐẦU ══════════════════
    //
    // Ví dụ mẫu dưới đây là case threshold_alarm của học phần (tuần 8–10):
    //     alarm = 1 khi sample >= threshold
    // Nó KHÔNG nằm trong 80 đề — chỉ để em thấy cách nối chân.
    //
    // Ánh xạ chân của ví dụ này:
    //     ui_in [7:0] = sample
    //     uio_in[7:0] = threshold
    //     uo_out[0]   = alarm
    //     uo_out[7:1] = 0  (phải gán, không được để hở)

    wire [7:0] sample    = ui_in;
    wire [7:0] threshold = uio_in;
    wire       alarm     = (sample >= threshold);

    assign uo_out  = {7'b0, alarm};
    assign uio_out = 8'b0;      // ví dụ này không dùng chân hai chiều làm đầu ra
    assign uio_oe  = 8'b0;      // ...nên toàn bộ để ở chiều VÀO

    // ══════════════════ PHẦN CỦA EM — KẾT THÚC ══════════════════

    // Chống cảnh báo "tín hiệu khai báo mà không dùng".
    // Nếu đề của em là mạch tổ hợp thì clk và rst_n sẽ không được dùng —
    // dòng này giữ cho công cụ không kêu. Đề tuần tự thì bỏ clk, rst_n ra khỏi đây.
    wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule

`default_nettype wire
