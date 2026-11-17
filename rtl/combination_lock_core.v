// Password FSM: 1-3-2-4. Invalid switch patterns do not count as failures.
module combination_lock_core #(
    parameter integer ERROR_CYCLES=25000000,
    parameter integer LOCKOUT_CYCLES=500000000
)(
    input wire clk, input wire reset, input wire enter_pulse,
    input wire [3:0] digit, input wire digit_valid,
    output reg locked_led, output reg unlocked_led,
    output reg error_led, output reg lockout_led, output reg invalid_led,
    output reg [31:0] display_data,
    output reg [2:0] state_debug, output reg [1:0] attempts_debug
);
    localparam [2:0] ST_LOCKED=0, ST_ERROR=1, ST_OPEN=2,
                     ST_LOCKOUT=3, ST_INVALID=4;
    reg [2:0] state, position;
    reg [3:0] d0,d1,d2,d3;
    reg [31:0] timer;
    reg [1:0] attempts;

    always @* begin
        locked_led=(state==ST_LOCKED);
        unlocked_led=(state==ST_OPEN);
        error_led=(state==ST_ERROR);
        lockout_led=(state==ST_LOCKOUT);
        invalid_led=(state==ST_INVALID);
        state_debug=state;
        attempts_debug=attempts;
        display_data={4'hF,4'hF,2'b00,attempts,4'hF,d3,d2,d1,d0};
    end

    always @(posedge clk) begin
        if (reset) begin
            state<=ST_LOCKED; position<=0; attempts<=0; timer<=0;
            d0<=4'hF; d1<=4'hF; d2<=4'hF; d3<=4'hF;
        end else begin
            case (state)
                ST_LOCKED: if (enter_pulse) begin
                    if (!digit_valid) begin state<=ST_INVALID; timer<=0; end
                    else begin
                        case (position)
                            0: if (digit==1) begin d0<=digit; position<=1; end
                               else begin
                                   attempts<=attempts+1'b1; position<=0;
                                   d0<=4'hF; d1<=4'hF; d2<=4'hF; d3<=4'hF;
                                   state<=(attempts==2)?ST_LOCKOUT:ST_ERROR; timer<=0;
                               end
                            1: if (digit==3) begin d1<=digit; position<=2; end
                               else begin
                                   attempts<=attempts+1'b1; position<=0;
                                   d0<=4'hF; d1<=4'hF; d2<=4'hF; d3<=4'hF;
                                   state<=(attempts==2)?ST_LOCKOUT:ST_ERROR; timer<=0;
                               end
                            2: if (digit==2) begin d2<=digit; position<=3; end
                               else begin
                                   attempts<=attempts+1'b1; position<=0;
                                   d0<=4'hF; d1<=4'hF; d2<=4'hF; d3<=4'hF;
                                   state<=(attempts==2)?ST_LOCKOUT:ST_ERROR; timer<=0;
                               end
                            3: if (digit==4) begin d3<=digit; position<=4; state<=ST_OPEN; end
                               else begin
                                   attempts<=attempts+1'b1; position<=0;
                                   d0<=4'hF; d1<=4'hF; d2<=4'hF; d3<=4'hF;
                                   state<=(attempts==2)?ST_LOCKOUT:ST_ERROR; timer<=0;
                               end
                            default: position<=0;
                        endcase
                    end
                end
                ST_ERROR, ST_INVALID: begin
                    if (timer>=ERROR_CYCLES-1) begin timer<=0; state<=ST_LOCKED; end
                    else timer<=timer+1'b1;
                end
                ST_OPEN: state<=ST_OPEN;
                ST_LOCKOUT: begin
                    if (timer>=LOCKOUT_CYCLES-1) begin
                        timer<=0; attempts<=0; position<=0; state<=ST_LOCKED;
                    end else timer<=timer+1'b1;
                end
                default: begin state<=ST_LOCKED; timer<=0; position<=0; end
            endcase
        end
    end
endmodule
