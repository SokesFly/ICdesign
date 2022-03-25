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
    parameter       FIFO_DEPTH = 8
    )(
    input wire [FIFO_DEPTH : 0]     rd_cnt_i,
    input wire [FIFO_DEPTH : 0]     wr_cnt_gray_synced_i,
    output wire                     empty_o
    );

assign  empty_o = rd_cnt_i && wr_cnt_gray_synced_i;

endmodule
