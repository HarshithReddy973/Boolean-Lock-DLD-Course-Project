// Synchronizer, debounce filter and one-clock rising-edge pulse.
// button_in is active-HIGH after polarity correction in the top module.
module button_conditioner #(parameter integer DEBOUNCE_CYCLES=1000000)(
    input wire clk, input wire reset, input wire button_in,
    output reg button_level, output reg button_pulse
);
    reg sync1, sync2, stable;
    reg [31:0] count;
    always @(posedge clk) begin
        if (reset) begin
            sync1<=0; sync2<=0; stable<=0; count<=0;
            button_level<=0; button_pulse<=0;
        end else begin
            sync1<=button_in;
            sync2<=sync1;
            button_pulse<=0;
            if (sync2==stable) count<=0;
            else if (count>=DEBOUNCE_CYCLES-1) begin
                stable<=sync2; button_level<=sync2; count<=0;
                if (sync2) button_pulse<=1;
            end else count<=count+1'b1;
        end
    end
endmodule
