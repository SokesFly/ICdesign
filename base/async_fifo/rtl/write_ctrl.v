/***************************************************************************************
* Function: 
* Author: SK 
* Company: Ltd.JRLC.SK
* Right : 
* Tel : 
* Last modified:	2022-03-25 05:18
* None: 
* Filename:		write_ctrl.v
* Resverd: 
* Description: 
**************************************************************************************/

module write_ctrl #(
parameter           DLY         = 1,
parameter           FIFO_WIDTH  = 8,
parameter           FIFO_DEPTH  = 8
)(
input wire                      wr_clk_i  ,
input wire                      rst_n_i   ,
input wire                      wr_en_i   ,
input wire                      full_o    ,

output wire [FIFO_DEPTH-1 : 0]  wr_ptr_o  ,
output wire                     wr_valid_o,
output wire [FIFO_DEPTH :0]     wr_cnt_o  
);

reg                       wr_valid_r ;
reg [FIFO_DEPTH   :0]     wr_cnt_r   ;

/********************************************************************************
* assign signals
********************************************************************************/
assign      wr_valid_o = wr_valid_r ;
assign      wr_ptr_o   = wr_ptr_r[FIFO_DEPTH-1:0] ;
assign      wr_cnt_o   = wr_cnt_r   ;



/********************************************************************************
* counting
********************************************************************************/
always@(posedge wr_clk_i or negedge rst_n_i) begin
    if(!rst_n_i) begin
        wr_cnt_r    <= #DLY {FIFO_DEPTH{1'b0}} ;
        wr_ptr_r    <= #DLY {(FIFO_DEPTH-1){1'b0}} ;
        wr_valid_r  <= #DLY 1'b0 ;
    end else if(!full_o && wr_en_i) begin
        wr_cnt_r    <= #DLY wr_cnt_r + 1'b1 ;
        wr_valid_r  <= #DLY 1'b1 ;
    end begin
        wr_cnt_r    <= #DLY wr_cnt_r ;
        wr_valid_r  <= #DLY 1'b0 ;
    end
end

endmodule
