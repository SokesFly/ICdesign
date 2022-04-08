###################################################################

# Created by write_sdc on Sun Mar 27 13:10:27 2022

###################################################################
set sdc_version 2.1

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current mA
set_load -pin_load 0.025 [get_ports rst_n_i]
create_clock [get_ports wr_clk_i]  -period 3  -waveform {0 1.5}
set_clock_latency -max 0.3  [get_clocks wr_clk_i]
set_clock_latency -source -max 0.7  [get_clocks wr_clk_i]
set_clock_uncertainty -setup 0.15  [get_clocks wr_clk_i]
set_clock_transition -max -rise 0.12 [get_clocks wr_clk_i]
set_clock_transition -max -fall 0.12 [get_clocks wr_clk_i]
set_clock_transition -min -rise 0.12 [get_clocks wr_clk_i]
set_clock_transition -min -fall 0.12 [get_clocks wr_clk_i]
create_clock [get_ports rd_clk_i]  -period 9  -waveform {0 4.5}
set_clock_latency -max 0.3  [get_clocks rd_clk_i]
set_clock_latency -source -max 0.7  [get_clocks rd_clk_i]
set_clock_uncertainty -setup 0.15  [get_clocks rd_clk_i]
set_clock_transition -max -rise 0.12 [get_clocks rd_clk_i]
set_clock_transition -max -fall 0.12 [get_clocks rd_clk_i]
set_clock_transition -min -rise 0.12 [get_clocks rd_clk_i]
set_clock_transition -min -fall 0.12 [get_clocks rd_clk_i]
