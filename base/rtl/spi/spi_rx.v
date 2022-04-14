
module                              spi_rx #(
    parameter                       DLY         = 1,
    parameter                       FIFO_WIDTH  = 32
    )(
    input  wire                     clk_i       ,  //  spi controller clock
    input  wire                     rst_n_i     ,  //  reset 
    input  wire                     cpol        ,  // 0, clock keep low state ; 1 , clock keep high state , when bus idle
    input  wire                     cpoa        ,  // 0, first edge DAQ, 1, second edge DAQ
    output wire [FIFO_WIDTH-1   :0] rx_rdata_o  ,  // data recv from sdi
    output wire                     rx_vld_o    ,  // data vld 
    input  wire                     rx_rdy_i    ,  // data ready
    input  wire                     bit_en      ,  // bit enabel ,from clock gen
    output wire                     clk_gen     ,  // generate bit enable
    input  wire                     sdi            // physical rx.
    );

endmodule
