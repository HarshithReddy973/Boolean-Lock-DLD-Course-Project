// Four-digit multiplexed display. seg_n[0:6]=a..g, [7]=dp.
// Segment and digit-enable outputs are active-LOW. value[3:0] is rightmost.
module sevenseg_scan4 #(parameter integer REFRESH_DIV=25000)(
    input wire clk, input wire [15:0] value,
    output reg [7:0] seg_n, output reg [3:0] an_n
);
    reg [31:0] refresh_count=0;
    reg [1:0] digit_sel=0;
    reg [3:0] nibble;
    always @(posedge clk) begin
        if (refresh_count>=REFRESH_DIV-1) begin
            refresh_count<=0; digit_sel<=digit_sel+1'b1;
        end else refresh_count<=refresh_count+1'b1;
    end
    always @* begin
        case(digit_sel)
            0: begin nibble=value[3:0]; an_n=4'b1110; end
            1: begin nibble=value[7:4]; an_n=4'b1101; end
            2: begin nibble=value[11:8]; an_n=4'b1011; end
            default: begin nibble=value[15:12]; an_n=4'b0111; end
        endcase
        case(nibble)
            0:seg_n=8'b11000000; 1:seg_n=8'b11111001;
            2:seg_n=8'b10100100; 3:seg_n=8'b10110000;
            4:seg_n=8'b10011001; 5:seg_n=8'b10010010;
            6:seg_n=8'b10000010; 7:seg_n=8'b11111000;
            8:seg_n=8'b10000000; 9:seg_n=8'b10010000;
            10:seg_n=8'b10001000; 11:seg_n=8'b10000011;
            12:seg_n=8'b11000110; 13:seg_n=8'b10100001;
            14:seg_n=8'b10000110; default:seg_n=8'b11111111;
        endcase
    end
endmodule
