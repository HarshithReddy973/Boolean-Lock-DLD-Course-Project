# Implementation Guide

## 1. Target
- Board: RealDigital Boolean, FPGA Spartan-7 `xc7s50csga324-1`
- Clock: 100 MHz (pin F14)
- Vivado design top: `boolean_lock_top`; simulation top: `tb_combination_lock`

## 2. Input/output map
| Item | Function |
|---|---|
| SW0 … SW9 | Select digit 0 … 9. Exactly **one** switch must be ON before ENTER. SW10–SW15 unused |
| BTN0 | Reset |
| BTN1 | Enter |
| BTN2, BTN3 | Unused |
| LED0 / LED1 | Locked / Unlocked |
| LED2 | Wrong digit (250 ms) |
| LED3 | Lockout (5 s) |
| LED4 | Invalid switch selection (250 ms) |
| Display D0 | Digits entered so far (blank = not entered) |
| Display D1 | Attempt counter (0–3) |

Segments and digit enables are active-LOW. The RTL assumes buttons read HIGH when pressed; if a board reads LOW, set `BUTTON_ACTIVE_LOW` to `1` in `rtl/boolean_lock_top.v`.

## 3. Functional behaviour
- Password is **1-3-2-4**. The correct sequence opens the lock; LED1 stays on until reset.
- A wrong valid digit clears the partial sequence, increments the attempt counter and lights LED2 briefly.
- The third wrong attempt starts a 5 s lockout (LED3). When it expires, attempts reset.
- Zero-hot or multi-hot switch input lights LED4 briefly; it does not count as a failure and keeps partial progress.
- Reset clears all progress, the attempt counter and any lockout.

Timing at 100 MHz: debounce 1,000,000 cycles (10 ms); error 25,000,000 cycles (250 ms); lockout 500,000,000 cycles (5 s).

## 4. Create the Vivado project
1. **Create Project → RTL Project**; do not specify sources yet.
2. Select part `xc7s50csga324-1`.
3. **Add Sources → Design Sources:** all five files in `rtl/`.
4. **Add Sources → Constraints:** `constraints/boolean_lock.xdc`.
5. **Add Sources → Simulation Sources:** `sim/tb_combination_lock.v`.
6. Set `boolean_lock_top` as Top (design) and `tb_combination_lock` as Top (simulation).

## 5. Simulate
1. Flow Navigator → **Run Simulation → Run Behavioral Simulation**.
2. Add and inspect: `clk`, `reset`, `switches`, `digit`, `valid`, `enter_pulse`, `state_debug`, `attempts_debug` and the five LED signals.
3. Run until the Tcl console shows `ALL TESTS PASSED`. Save a waveform screenshot as `docs/images/waveform.png`.
4. If `$fatal` is rejected in the `.v` testbench, change the file type to SystemVerilog.

The testbench uses short timer values and is not part of the bitstream.

## 6. Build the bitstream
1. **Run Synthesis** and resolve any errors.
2. **Run Implementation**.
3. Open the utilization and timing summaries and record them in the report.
4. **Generate Bitstream**. Copy `boolean_lock_top.bit` from `<project>.runs/impl_1/` to `bitstream/`.

## 7. Program the board
1. Connect a micro-USB cable to the port labelled **PROG UART**, switch the board on and check that the EXTP jumper is set to **USB**.
2. Vivado → **Hardware Manager → Open Target → Auto Connect**.
3. **Program Device** and select `boolean_lock_top.bit`.
4. Press BTN0 once to reset.

## 8. Demonstration checklist
| Test | Steps | Expected |
|---|---|---|
| Reset | Press BTN0 | LED0 on, display blank, attempts 0 |
| Correct password | SW1 + ENTER, SW3 + ENTER, SW2 + ENTER, SW4 + ENTER (one switch on at a time) | LED1 on |
| Wrong digit | Enter any wrong digit | LED2 for 250 ms, attempt count rises |
| Invalid selection | No switch, or two switches, then ENTER | LED4 for 250 ms |
| Lockout | Three wrong digits | LED3 for 5 s, then LED0 |
| Re-lock | Press BTN0 after unlocking | Back to LED0 |

## 9. GitHub checklist
- [ ] `rtl/`, `sim/`, `constraints/` unchanged from the files that were simulated and implemented
- [ ] `docs/images/waveform.png` and `docs/images/board_demo.jpg` added
- [ ] `bitstream/boolean_lock_top.bit` added (delete `bitstream/README.txt`)
- [ ] `docs/Project_Report.docx` completed (names, Vivado numbers, figures)
- [ ] `README.md` image links resolve
