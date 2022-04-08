###################################################################

# Created by write_sdc on Fri Mar 25 12:08:58 2022

###################################################################
set sdc_version 2.1

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current mA
set_load -pin_load 0.025 [get_ports rst_n_sync_i]
set_load -pin_load 0.025 [get_ports rst_n_synced_o]
create_clock [get_ports clk_i]  -period 3  -waveform {0 1.5}
set_clock_latency -max 0.3  [get_clocks clk_i]
set_clock_latency -source -max 0.7  [get_clocks clk_i]
set_clock_uncertainty -setup 0.15  [get_clocks clk_i]
set_clock_transition -max -rise 0.12 [get_clocks clk_i]
set_clock_transition -max -fall 0.12 [get_clocks clk_i]
set_clock_transition -min -rise 0.12 [get_clocks clk_i]
set_clock_transition -min -fall 0.12 [get_clocks clk_i]
