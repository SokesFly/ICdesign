/* =============================================================================
#     FileName: gray2bin.v
#         Desc: Change gray to binary
#       Author: ChainJJ
#        Email: 1406072501@QQ.com
#     HomePage: CHinA
#      Version: 0.0.1
#   LastChange: 2022-04-25 23:25:21
#      History:
============================================================================= */

// File simulation format
`timescale 1ns/1ps

module                          gray2bin #(
    parameter                   DLY    = 1,
    parameter                   WIDTH  = 8
    )(
    input  wire [WIDTH-1 :0]    gray_i  ,
    output wire [WIDTH-1 :0]    bin_o
    );

genvar i;
generate
    for(i = 0 ; i < WIDTH; i = i + 1) begin : GRAY_2_BINARY
        assign  bin_o[i] = ^ gray_i[WIDTH-1:i];
    end
endgenerate

endmodule

