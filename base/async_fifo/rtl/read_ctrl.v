/***************************************************************************************
* Function: 
* Author: SK 
* Company: Ltd.JRLC.SK
* Right : 
* Tel : 
* Last modified: 2022-03-25 05:35
* None: 
* Filename: read_ctrl.v
* Resverd: 
* Description: 
**************************************************************************************/

module read_ctrl    #(
    parameter           DLY         = 1,
    parameter           FIFO_WIDTH  = 8,
    parameter           FIFO_DEPTH  = 8
    )(
    input wire                      rst_n_i    ,
    input wire                      rd_clk_i   ,
    input wire                      rd_en_i    ,
    input wire                      empty_i    ,
    
    output wire [FIFO_DEPTH-1:0]    rd_ptr_o   ,
    output wire                     rd_valid_o ,
    output wire [FIFO_DEPTH  :0]    rd_cnt_o
    );

reg [FIFO_DEPTH-1:0]                rd_ptr_r  ;
reg [FIFO_DEPTH  :0]                rd_cnt_r  ;
reg                                 rd_valid_r;

assign      rd_ptr_o    = rd_ptr_r;
assign      rd_cnt_o    = rd_cnt_r;
assign      rd_valid_o  = rd_valid_r;

always@(posedge rd_clk_i or negedge rst_n_i) begin
    if(!rst_n_i) begin
        rd_ptr_r    <= #DLY    {(FIFO_DEPTH-1){1'b0}};
        rd_cnt_r    <= #DLY    {FIFO_DEPTH{1'b0}};
        rd_valid_r  <= #DLY    1'b0;
    end else if(!empty_i && rd_en_i) begin
        rd_ptr_r    <= #DLY    rd_ptr_r + 1'b1;
        rd_cnt_r    <= #DLY    rd_cnt_r + 1'b1;
        rd_valid_r  <= #DLY    1'b1;
    end begin
        rd_ptr_r    <= #DLY    {(FIFO_DEPTH-1){1'b0}};
        rd_cnt_r    <= #DLY    {FIFO_DEPTH{1'b0}};
        rd_valid_r  <= #DLY    1'b0;
    end
end

endmodule
