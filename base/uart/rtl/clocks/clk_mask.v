/***************************************************************************************
* Function: 
* Author: SK 
* Company: Ltd.JRLC.SK
* Right : 
* Tel : 
* Last modified: 2022-04-05 08:58
* None: 
* Filename: clk_mask.v
* Resverd: 
* Description: 
**************************************************************************************/
`timescale  1ns/1ps

module  clk_mask (
    input  wire         clk_i       ,       // input clk
    input  wire         enable      ,       // clk mask
    output wire         clk_o               // output clk
    );

assign      clk_o   = enable ? 1'b0 : clk_i ;

endmodule

