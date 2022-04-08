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
    parameter           FIFO_DEPTH  = 8,
    parameter           ADDR        = $clog2(FIFO_DEPTH)
    )(
    input wire                      rst_n_i    ,
    input wire                      rd_clk_i   ,
    input wire  [FIFO_WIDTH -1 :0]  rd_data_i  ,
    input wire                      rd_en_i    ,
    input wire                      empty_i    ,
    
    output wire [ADDR-1        :0]  rd_ptr_o   ,
    output wire                     rd_valid_o ,
    output wire [FIFO_WIDTH -1 :0]  rd_vdata_o ,
    output wire [ADDR          :0]  rd_addr_o
    );

reg [ADDR          :0]              rd_addr_r  ;
reg                                 rd_valid_r;
reg [FIFO_WIDTH -1 :0]              rd_vdata_r;

assign      rd_ptr_o    = rd_addr_r[ADDR-1:0];
assign      rd_addr_o   = rd_addr_r  ;
assign      rd_vdata_o  = rd_data_i  ;
assign      rd_valid_o  = (!empty_i && rd_en_i);


always@(posedge rd_clk_i or negedge rst_n_i) begin
    if(!rst_n_i) begin
        rd_addr_r   <= #DLY    {ADDR{1'b0}};
    end
    else if(rd_valid_o) begin
        rd_addr_r   <= #DLY    rd_addr_r + 1'b1;
    end 
    else begin
        rd_addr_r   <= #DLY    rd_addr_r;
    end
end

endmodule
