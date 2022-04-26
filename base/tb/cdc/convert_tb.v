/* =============================================================================
#     FileName: convert_tb.v
#         Desc: Test for bin2gray & gray2bin
#       Author: ChainJJ
#        Email: 1406072501@QQ.com
#     HomePage: CHinA
#      Version: 0.0.1
#   LastChange: 2022-04-26 03:27:24
#      History:
============================================================================= */

module                      convert_tb ();

parameter                   DLY        = 1;
parameter                   CLK_PERIOD = 20;
parameter                   WIDTH      = 8;

// Declare clock & reset signals
reg                         clk_reg     ;
reg                         rstn_reg    ;

// Declare data 
reg  [WIDTH-1    :0]        data_binary  ;
reg  [WIDTH-1    :0]        data_binary_o;
wire [WIDTH-1    :0]        gray        ;

// Dump waveform
initial begin
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars(0, "convert_tb");
end

// Gen clk
initial begin
    clk_reg = 1'b0;
    forever begin
        #(CLK_PERIOD/2) clk_reg = 1'b0;
        #(CLK_PERIOD/2) clk_reg = 1'b1;
    end
end

// Gen reset
initial begin
    rstn_reg = 1'b0 ;
    @(CLK_PERIOD*2/3) 
    rstn_reg = 1'b1 ;
end

// EOS
initial begin
    #(CLK_PERIOD*4000)
    $finish;
end

// DUT bin2gray
bin2gray                    #(
    .DLY                    (DLY            ),
    .WIDTH                  (WIDTH          )
    )
    dut_bin2gray_i
    (
    .bin_i                  (data_binary    ),
    .gray_o                 (gray           )
    );


gray2bin                    #(
    .DLY                    (DLY            ),
    .WIDTH                  (WIDTH          )
    )
    dut_gray2bin_i
    (
    .gray_i                 (gray           ),
    .bin_o                  (data_binary_o  )
    );

endmodule
