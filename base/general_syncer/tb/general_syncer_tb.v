/***************************************************************************************
* Function: 
* Author: SK 
* Company: Ltd.JRLC.SK
* Right : 
* Tel : 
* Last modified: 2022-03-18 04:40
* None: 
* Filename: general_syncer_tb.v
* Resverd: 
* Description: 
**************************************************************************************/
`timescale 1ns/1ps

module general_syncer_tb;
    parameter   DLY             = 0;
    parameter   FIRST_EDGE      = 0;
    parameter   LAST_EDGE       = 0;
    parameter   MID_STAGE_NUM   = 5;
    parameter   DATA_WIDTH      = 1;

    parameter   CLK_PERIOD      = 10;
    parameter   SIM_TIMES       = 500;

    reg                             clk_i;
    reg                             rst_n_i;
    reg [DATA_WIDTH - 1 : 0]        data_unsync_i;
    wire [DATA_WIDTH - 1 : 0]       data_synced_o;

    /*************************************************************************
    * clock and reset generate
    **************************************************************************/
    initial begin
        clk_i =  1'b0;
        forever begin
            #(CLK_PERIOD/2)     clk_i = 1'b0;
            #(CLK_PERIOD/2)     clk_i = 1'b1;
        end
    end

    initial begin
        rst_n_i = 1'b0;
        #(CLK_PERIOD*3 - 3)
        rst_n_i = 1'b1;
    end

    initial begin
        forever begin
            #({$random} % 10)
            data_unsync_i = {$random};
        end
    end

    initial begin
        #(SIM_TIMES*CLK_PERIOD + 1) 
        $finish;
    end

    /*************************************************************************
    * dump
    **************************************************************************/
    initial begin
        $fsdbDumpfile("tb.fsdb");
        $fsdbDumpvars(0, "general_syncer_tb");
        $fsdbDumpMDA(0, "general_syncer_tb");
    end

    /*************************************************************************
    * Dut
    **************************************************************************/
    general_syncer #(
        .DLY            ( DLY           ),
        .FIRST_EDGE     ( FIRST_EDGE    ),
        .LAST_EDGE      ( LAST_EDGE     ),
        .MID_STAGE_NUM  ( MID_STAGE_NUM ),
        .DATA_WIDTH     ( DATA_WIDTH    )
    )u_general_syncer_i(
        .clk_i          ( clk_i         ),
        .rst_n_i        ( rst_n_i       ),
        .data_unsync_i  ( data_unsync_i ),
        .data_synced_o  ( data_synced_o )
    );

endmodule
