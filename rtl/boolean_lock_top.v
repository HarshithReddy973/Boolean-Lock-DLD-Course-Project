// RealDigital Boolean board top-level.
// SW[9:0]: one-hot digit input; BTN0 reset; BTN1 enter.
// Set BUTTON_ACTIVE_LOW=1 if pressed buttons read logic 0 on your board.
module boolean_lock_top #(
    parameter integer DEBOUNCE_CYCLES=1000000,
    parameter integer ERROR_CYCLES=25000000,
    parameter integer LOCKOUT_CYCLES=500000000,
    parameter integer BUTTON_ACTIVE_LOW=0
)(
    input wire clk, input wire [15:0] sw, input wire [3:0] btn,
    output wire [15:0] led,
    output wire [7:0] D0_SEG, output wire [3:0] D0_AN,
    output wire [7:0] D1_SEG, output wire [3:0] D1_AN
);
    wire reset_pressed, enter_pressed, enter_level, enter_pulse;
    wire [3:0] digit;
    wire digit_valid;
    wire l_locked,l_open,l_error,l_lockout,l_invalid;
    wire [31:0] display_data;
    wire [2:0] state_debug;
    wire [1:0] attempts_debug;

    assign reset_pressed=BUTTON_ACTIVE_LOW ? ~btn[0] : btn[0];
    assign enter_pressed=BUTTON_ACTIVE_LOW ? ~btn[1] : btn[1];

    button_conditioner #(.DEBOUNCE_CYCLES(DEBOUNCE_CYCLES)) enter_filter(
        .clk(clk),.reset(reset_pressed),.button_in(enter_pressed),
        .button_level(enter_level),.button_pulse(enter_pulse));
    digit_decoder decoder(.sw(sw[9:0]),.digit(digit),.valid(digit_valid));
    combination_lock_core #(.ERROR_CYCLES(ERROR_CYCLES),
        .LOCKOUT_CYCLES(LOCKOUT_CYCLES)) core(
        .clk(clk),.reset(reset_pressed),.enter_pulse(enter_pulse),
        .digit(digit),.digit_valid(digit_valid),
        .locked_led(l_locked),.unlocked_led(l_open),.error_led(l_error),
        .lockout_led(l_lockout),.invalid_led(l_invalid),
        .display_data(display_data),.state_debug(state_debug),
        .attempts_debug(attempts_debug));

    assign led={11'b0,l_invalid,l_lockout,l_error,l_open,l_locked};
    sevenseg_scan4 display0(.clk(clk),.value(display_data[15:0]),
        .seg_n(D0_SEG),.an_n(D0_AN));
    sevenseg_scan4 display1(.clk(clk),.value(display_data[31:16]),
        .seg_n(D1_SEG),.an_n(D1_AN));
endmodule
