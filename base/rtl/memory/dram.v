/*
* This module just for simulation,it can not be used to systhysis
*/

`timescale 1ns/1ps

module                                  dram #(
    parameter                           DLY             =  1,
    parameter                           WRITE_WIDTH     =  4,
    parameter                           READ_WIDTH      =  16,
    parameter                           DEPTH           =  8,
    parameter                           ADDR            =  (READ_WIDTH - WRITE_WIDTH) ? 
                                                           ($clog2(DEPTH) + $clog2(READ_WIDTH/WRITE_WIDTH)) :  
                                                           ($clog2(DEPTH) + $clog2(WRITE_WIDTH/READ_WIDTH))
    )(
    input  wire                         pa_clk_i        ,   // port a clock input.
    input  wire                         pa_rstn_i       ,   // port a reset input.
    input  wire [ADDR-1         :0]     pa_addr_i       ,   // port a address in
    input  wire                         pa_wr_en_i      ,   // port a write enable in
    input  wire [WRITE_WIDTH-1  :0]     pa_wr_data_i    ,   // port a write data in
    input  wire                         pa_rd_en_i      ,   // port a read enable in
    output wire [READ_WIDTH-1   :0]     pa_rd_data_o    ,   // port a read data output
 
    input  wire                         pb_clk_i        ,   // port b clock input.
    input  wire                         pb_rstn_i       ,   // port b reset input.
    input  wire [ADDR-1         :0]     pb_addr_i       ,   // port b address in.
    input  wire                         pb_wr_en_i      ,   // port b write enablein.
    input  wire [WRITE_WIDTH-1  :0]     pb_wr_data_i    ,   // port b write data in.
    input  wire                         pb_rd_en_i      ,   // port b write enable in.
    output wire [READ_WIDTH-1   :0]     pb_rd_data_o        // port b read data output
    );

generate 
    if(WRITE_WIDTH == READ_WIDTH) begin : SAME_WIDTH
        reg [WRITE_WIDTH-1]                     mem [0 :ADDR-1];
        reg  [ADDR-1        :0]                 mem_init_r  ;
        reg                                     pa_read_r   ;
        reg  [READ_WIDTH-1  :0]                 pa_out_buf_r;
        reg                                     pb_read_r   ;
        reg  [READ_WIDTH-1  :0]                 pb_out_buf_r;

        // declare write 
        always@(pa_rstn_i or pb_rstn_i) begin
            if(!pa_rstn_i || !pb_rstn_i) begin
                for(mem_init_r = 'd0; mem_init_r < ADDR; mem_init_r = mem_init_r + 'd1) begin
                    mem[mem_init_r] <= #DLY {WRITE_WIDTH{1'b0}};
                end
            end
            else if(pa_wr_en_i) begin
                mem[pa_addr_i] <= #DLY pa_wr_data_i;
            end
            else if(pb_wr_en_i) begin
                mem[pb_addr_i] <= #DLY pb_wr_data_i;
            end
        end

        // port a read
        assign  pa_rd_data_o = pa_read_r ? pa_out_buf_r : 'd0;
        always@(posedge pa_clk_i or negedge pa_rstn_i) begin
            if(!pa_rstn_i) begin
                pa_read_r   <= #DLY 1'b0;
                pa_out_buf_r<= #DLY {READ_WIDTH{1'b0}};
            end
            else if(pa_rd_en_i) begin
                pa_read_r   <= #DLY 1'b1;
                pa_out_buf_r<= #DLY mem[pa_addr_i];
            end
            else begin
                pa_read_r   <= #DLY 1'b0;
                pa_out_buf_r<= #DLY {READ_WIDTH{1'b0}};
            end
        end

        // port a read
        assign  pb_rd_data_o = pb_read_r ? pb_out_buf_r : 'd0;
        always@(posedge pb_clk_i or negedge pb_rstn_i) begin
            if(!pb_rstn_i) begin
                pb_read_r   <= #DLY 1'b0;
                pb_out_buf_r<= #DLY {READ_WIDTH{1'b0}};
            end
            else if(pb_rd_en_i) begin
                pb_read_r   <= #DLY 1'b1;
                pb_out_buf_r<= #DLY mem[pb_addr_i];
            end
            else begin
                pb_read_r   <= #DLY 1'b0;
                pb_out_buf_r<= #DLY {READ_WIDTH{1'b0}};
            end
        end

    end
    else if(WRITE_WIDTH > READ_WIDTH) begin : WRITE_MORE
    end
    else if(WRITE_WIDTH < READ_WIDTH) begin : READ_MOE
    end

endgenerate

endmodule 
