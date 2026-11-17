`timescale 1ns/1ps
module tb_combination_lock;
    reg clk=0, reset=0, enter_pulse=0;
    reg [9:0] switches=0;
    wire [3:0] digit; wire valid;
    wire locked_led,unlocked_led,error_led,lockout_led,invalid_led;
    wire [31:0] display_data; wire [2:0] state_debug; wire [1:0] attempts_debug;
    always #5 clk=~clk;
    digit_decoder dec(switches,digit,valid);
    combination_lock_core #(.ERROR_CYCLES(4),.LOCKOUT_CYCLES(8)) dut(
        .clk(clk),.reset(reset),.enter_pulse(enter_pulse),.digit(digit),
        .digit_valid(valid),.locked_led(locked_led),.unlocked_led(unlocked_led),
        .error_led(error_led),.lockout_led(lockout_led),.invalid_led(invalid_led),
        .display_data(display_data),.state_debug(state_debug),
        .attempts_debug(attempts_debug));
    task submit_digit(input integer n);
        begin switches=10'b1<<n; @(negedge clk); enter_pulse=1;
        @(negedge clk); enter_pulse=0; @(negedge clk); end
    endtask
    task wait_error_clear; integer k; begin
        for(k=0;k<7;k=k+1) @(negedge clk); end endtask
    initial begin
        $dumpfile("combination_lock.vcd"); $dumpvars(0,tb_combination_lock);
        reset=1; repeat(2) @(negedge clk); reset=0;
        submit_digit(1); submit_digit(3); submit_digit(2); submit_digit(4);
        if(!unlocked_led) $fatal(1,"Correct password did not unlock");
        $display("PASS: correct password unlocks");
        reset=1; @(negedge clk); reset=0;
        switches=0; @(negedge clk); enter_pulse=1;
        @(negedge clk); enter_pulse=0;
        if(!invalid_led) $fatal(1,"Zero-hot input not flagged");
        $display("PASS: zero-hot selection flagged"); wait_error_clear;
        switches=10'b0000000011; @(negedge clk); enter_pulse=1;
        @(negedge clk); enter_pulse=0;
        if(!invalid_led) $fatal(1,"Multi-hot input not flagged");
        $display("PASS: multi-hot selection flagged"); wait_error_clear;
        submit_digit(9);
        if(!error_led || attempts_debug!=1) $fatal(1,"Wrong digit handling failed");
        $display("PASS: wrong digit increments attempts"); wait_error_clear;
        submit_digit(8); wait_error_clear; submit_digit(7);
        if(!lockout_led) $fatal(1,"Third wrong attempt did not lock out");
        $display("PASS: third wrong attempt triggers lockout");
        repeat(10) @(negedge clk);
        if(!locked_led || attempts_debug!=0) $fatal(1,"Lockout timeout failed");
        $display("PASS: lockout expires and attempts reset");
        $display("ALL TESTS PASSED"); $finish;
    end
endmodule
