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
    parameter       FIFO_DEPTH  = 8,
    parameter       SIZE        = $clog2(FIFO_DEPTH)
    )(
    input wire  [SIZE :0]    wr_addr_gray_i ,
    input wire  [SIZE :0]    rd_addr_gray_synced_i,
    output wire                     full_o
    );

assign full_o = (wr_addr_gray_i == {~rd_addr_gray_synced_i[SIZE : SIZE-1],rd_addr_gray_synced_i[SIZE - 2:0]});

endmodule
