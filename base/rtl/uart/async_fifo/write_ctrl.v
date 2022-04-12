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
    parameter           FIFO_DEPTH  = 8,
    parameter           ADDR        = $clog2(FIFO_DEPTH)
    )(
    input wire                      wr_clk_i  ,
    input wire                      rst_n_i   ,
    input wire  [FIFO_WIDTH -1 :0]  wr_data_i ,
    input wire                      wr_en_i   ,
    input wire                      full_o    ,
    
    output wire [ADDR-1        :0]  wr_ptr_o  ,
    output wire                     wr_valid_o,
    output wire [FIFO_WIDTH -1 :0]  wr_vdata_o,
    output wire [ADDR          :0]  wr_addr_o
    );

reg [ADDR   :0]             wr_addr_r   ;

/********************************************************************************
* assign signals
********************************************************************************/
assign      wr_ptr_o   = wr_addr_r[ADDR-1:0] ;
assign      wr_addr_o  = wr_addr_r           ;
assign      wr_vdata_o = wr_data_i           ;
assign      wr_valid_o = (!full_o && wr_en_i);

/********************************************************************************
* Addres manager
********************************************************************************/
always@(posedge wr_clk_i or negedge rst_n_i) begin
    if(!rst_n_i) begin
        wr_addr_r    <= #DLY {(ADDR + 1){1'b0}} ;
    end 
    else if(wr_valid_o) begin
        wr_addr_r    <= #DLY wr_addr_r + 1'b1 ;
    end 
    else begin
        wr_addr_r    <= #DLY wr_addr_r ;
    end
end

endmodule
