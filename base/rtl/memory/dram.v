/*
* This module just for simulation,it can not be used to systhysis
*/

`timescale 1ns/1ps

module                                  sram #(
    parameter                           WRITE_WIDTH     =   4,
    parameter                           READ_WIDTH      =   16,
    parameter                           DEPTH           =   8,
    parameter                           WRITE_ADDR      =   (READ_WIDTH - WRITE_WIDTH) ? ($clog2(DEPTH) + $clog2(READ_WIDTH/WRITE_WIDTH)) : $clog2(DEPTH),
    parameter                           READ_ADDR       =   (WRITE_WIDTH - READ_WIDTH) ? ($clog2(DEPTH) + $clog2(WRITE_WIDTH/READ_ADDR)) : $clog2(DEPTH)
    )(
    input  wire [WRITE_ADDR-1   :0]     wr_addr_i   ,   // write address in
    input  wire [WRITE_WIDTH-1  :0]     wr_data_i   ,   // write data in
    input  wire                         wr_en_i     ,   // write enable in
 
    input  wire [READ_ADDR-1    :0]     raddr_i     ,   // read address
    input  wire                         rd_en_i     ,   // read enable
    output wire [READ_WIDTH-1   :0]     rd_data_o       // output data.
    );

generate 
    if(WRITE_WIDTH == READ_WIDTH) begin : SAME_WIDTH

        reg [WRITE_WIDTH-1]             mem [0 :WRITE_ADDR-1];

        always@(wr_addr_i or wr_data_i or wr_en_i) begin : WRITE_DATA
            if(wr_en_i) begin
                mem[wr_addr_i] <= wr_addr_i;
            end
        end

        always@(rd_addr_i or rd_en_i) begin
            if(rd_en_i) begin
                assign  rd_data_o = mem[rd_addr_i];
            end
        end

    end
    else if(WRITE_WIDTH > READ_WIDTH) begin : WRITE_MORE

    end
    else if(WRITE_WIDTH < READ_WIDTH) begin : READ_MOE
    end
endgenerate

endmodule 
