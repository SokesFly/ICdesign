/***************************************************************************************
* Function: 
* Author: SK 
* Company: Ltd.JRLC.SK
* Right : 
* Tel : 
* Last modified: 2022-04-05 15:11
* None: 
* Filename: gen_baudrate_bit.v
* Resverd: 
* Description: 
**************************************************************************************/

module                                  gen_baudrate_bit #(
    parameter                           DLY                 =   1,
    parameter                           BAUDRATE_WIDTH      =   16
    )(
    input  wire                         clk_i           , // Primary clk
    input  wire                         rst_n_i         , // reset
    input  wire [BAUDRATE_WIDTH-1:0]    baudrate_cfg_i  ,
    output wire                         baudrate_en_o   , // baudrate reached.
    output wire                         baudrate_en_n_o
    );

/********************************************************************************
* Declare register used generate baudrate enable.
********************************************************************************/
reg  [BAUDRATE_WIDTH-1:0]               baudrate_cnt_r ;

always@(posedge clk_i or negedge rst_n_i) begin
    if(!rst_n_i) begin
        baudrate_cnt_r <= #DLY {BAUDRATE_WIDTH{1'b0}};
    end
    else if(baudrate_cnt_r == baudrate_cfg_i) begin
        baudrate_cnt_r <= #DLY {BAUDRATE_WIDTH{1'b0}};
    end
    else begin
        baudrate_cnt_r <= #DLY baudrate_cnt_r + {{(BAUDRATE_WIDTH-2){1'b0}}, 1'b1} ;
    end
end

assign      baudrate_en_o   = (baudrate_cfg_i == baudrate_cnt_r) ;
assign      baudrate_en_n_o = ((baudrate_cfg_i >> 1) == baudrate_cnt_r) ;

endmodule
