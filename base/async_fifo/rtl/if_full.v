/***************************************************************************************
* Function: 
* Author: SK 
* Company: Ltd.JRLC.SK
* Right : 
* Tel : 
* Last modified: 2022-03-25 06:04
* None: 
* Filename: is_full.v
* Resverd: 
* Description: 
**************************************************************************************/

module if_full #(
    parameter       DLY         = 1,
    parameter       FIFO_WIDTH  = 8
    )(
    input wire  [FIFO_WIDTH : 0]    wr_cnt_i ,
    input wire  [FIFO_WIDTH : 0]    rd_cnt_gray_synced_i,
    output wire                     full_o
    );

assign full_o = (wr_cnt_i && {~rd_cnt_gray_synced_i[FIFO_WIDTH:FIFO_WIDTH-1],rd_cnt_gray_synced_i[FIFO_WIDTH-2:0]});

endmodule
