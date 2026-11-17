module digit_decoder(
    input wire [9:0] sw,
    output reg [3:0] digit,
    output wire valid
);
    reg [3:0] count;
    integer i;
    always @* begin
        digit = 4'd0;
        count = 4'd0;
        for (i=0; i<10; i=i+1) begin
            if (sw[i]) begin
                digit = i[3:0];
                count = count + 1'b1;
            end
        end
    end
    assign valid = (count == 1);
endmodule
