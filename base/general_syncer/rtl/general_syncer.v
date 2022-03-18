/***************************************************************************************
* Function: 
* Author: SK 
* Company: Ltd.JRLC.SK
* Right : 
* Tel : 
* Last modified: 2022-03-17 05:12
* None: 
* Filename: general_syncer.v
* Resverd: 
* Description: 
**************************************************************************************/

`timescale 1ns/1ps

module general_syncer #(
    parameter   DLY             = 1,
    parameter   FIRST_EDGE      = 1, // (1 => negedge ) || (0 => posedge)
    parameter   LAST_EDGE       = 1, // (1 => negedge ) || (0 => posedge)
    parameter   MID_STAGE_NUM   = 3, // stage number of middle register(s), MID_STAGE_NUM >= 0
    parameter   DATA_WIDTH      = 1  // data bus width
)(
    input wire                       clk_i,
    input wire                       rst_n_i,
    input wire [DATA_WIDTH - 1 : 0]  data_unsync_i,
    output reg [DATA_WIDTH - 1 : 0]  data_synced_o
);

    reg [DATA_WIDTH - 1 : 0]        first_reg;
    reg [DATA_WIDTH - 1 : 0]        last_reg;
    reg [DATA_WIDTH - 1 : 0]        mid_regs [0 : MID_STAGE_NUM - 1];

    generate
        if(FIRST_EDGE == 0) begin
            always@(posedge clk_i or negedge rst_n_i) begin
                if(!rst_n_i) begin
                    first_reg <= #DLY   {DATA_WIDTH{1'b0}};
                end else begin
                    first_reg <= #DLY   data_unsync_i;
                end
            end
        end else begin
            always@(negedge clk_i or posedge rst_n_i) begin
                if(!rst_n_i) begin
                    first_reg <= #DLY   {DATA_WIDTH{1'b0}};
                end else begin
                    first_reg <= #DLY   data_unsync_i;
                end
            end
        end
    endgenerate

    genvar i;
    generate
        for(i = 0; i < MID_STAGE_NUM; i = i + 1) begin
            always@(posedge clk_i or negedge rst_n_i) begin
                if(!rst_n_i) begin
                   mid_regs[i] <= #DLY {DATA_WIDTH{1'b0}};
                end else if(i == 0) begin
                   mid_regs[i] <= #DLY first_reg;
                end else begin
                   mid_regs[i] <= #DLY mid_regs[i - 1];
                end
            end
        end
    endgenerate

    generate
        if(LAST_EDGE == 0) begin
            always@(posedge clk_i or negedge rst_n_i) begin
                if(!rst_n_i) begin
                    last_reg <= #DLY   {DATA_WIDTH{1'b0}};
                end else begin
                    last_reg  <= #DLY   mid_regs[MID_STAGE_NUM - 1];
                end
            end
        end else begin
            always@(negedge clk_i or posedge rst_n_i) begin
                if(!rst_n_i) begin
                    last_reg <= #DLY   {DATA_WIDTH{1'b0}};
                end else begin
                    last_reg  <= #DLY   mid_regs[MID_STAGE_NUM - 1];
                end
            end
        end
    endgenerate

    assign  data_synced_o = last_reg ^ mid_regs[MID_STAGE_NUM - 1] ;

endmodule
