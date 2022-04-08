/***************************************************************************************
* Function: 
* Author: SK 
* Company: Ltd.JRLC.SK
* Right : 
* Tel : 
* Last modified: 2022-03-25 06:18
* None: 
* Filename: if_empy.v
* Resverd: 
* Description: 
**************************************************************************************/

module if_empty #(
    parameter       FIFO_DEPTH  = 8,
    parameter       SIZE        = $clog2(FIFO_DEPTH)
    )(
    input wire [SIZE : 0]     rd_addr_gray_i,
    input wire [SIZE : 0]     wr_addr_gray_synced_i,
    output wire               empty_o
    );

assign  empty_o = (rd_addr_gray_i == wr_addr_gray_synced_i);

endmodule
