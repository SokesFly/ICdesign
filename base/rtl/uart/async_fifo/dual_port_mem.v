/***************************************************************************************
* Function: 
* Author: SK 
* Company: Ltd.JRLC.SK
* Right : 
* Tel : 
* Last modified: 2022-03-25 04:35
* None: 
* Filename: dual_port_mem.v
* Resverd: 
* Description: 
**************************************************************************************/

module  dual_port_mem #(
    parameter           DLY        = 1         ,
    parameter           FIFO_WIDTH = 8         ,
    parameter           FIFO_DEPTH = 8         ,
    parameter           ADDR       = $clog2(FIFO_DEPTH)
    )(
    input wire                      rst_n_i    ,
    /********************************************************************************
    * write channel
    ********************************************************************************/
    input wire                      wr_clk_i   ,
    input wire [FIFO_WIDTH-1 :0]    wr_data_i  ,
    input wire [ADDR-1       :0]    wr_ptr_i   ,
    input wire                      wr_valid_i ,
    
    /********************************************************************************
    * read channel
    ********************************************************************************/
    input wire                      rd_clk_i   ,
    output wire [FIFO_WIDTH-1:0]    rd_data_o  ,
    input wire  [ADDR-1      :0]    rd_ptr_i   ,
    input wire                      rd_valid_i  
    );

reg [ADDR        :0]                i;
/********************************************************************************
* Declare memory  array
********************************************************************************/
reg [FIFO_WIDTH-1:0]                rd_data_r ;
reg [FIFO_WIDTH-1:0]                array [0 : FIFO_DEPTH-1];

assign                              rd_data_o = rd_data_r ;

/********************************************************************************
* write data
********************************************************************************/
always@(posedge wr_clk_i or negedge rst_n_i) begin
    if(!rst_n_i) begin
        for(i = 0; i < ADDR; i = i + 1) begin
            array[i] <= #DLY {FIFO_WIDTH{1'b0}};
        end
    end 
    else if(wr_valid_i) begin
        array[wr_ptr_i] <= #DLY wr_data_i;
    end
end

/********************************************************************************
* read data
********************************************************************************/
always@(posedge rd_clk_i or negedge rst_n_i) begin
    if(!rst_n_i) begin
        rd_data_r <= #DLY {FIFO_WIDTH{1'b0}};
    end 
    else if(rd_valid_i) begin
        rd_data_r <= #DLY array[rd_ptr_i];
    end
end

endmodule
