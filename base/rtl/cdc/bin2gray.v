/***************************************************************************************
* Function: 
* Author: SK 
* Company: Ltd.JRLC.SK
* Right : 
* Tel : 
* Last modified: 2022-03-25 05:03
* None: 
* Filename: bin2gray.v
* Resverd: 
* Description: 
**************************************************************************************/

module  bin2gray #(
    parameter           DLY        = 1,
    parameter           WIDTH      = 8
    )(
    input wire  [WIDTH-1 :0]    bin_i  ,
    output wire [WIDTH-1 :0]    gray_o 
    );

assign gray_o = bin_i ^ {1'b0, bin_i[WIDTH-1 : 1]};

endmodule
