/***************************************************************************************
* Function: 
* Author: SK 
* Company: Ltd.JRLC.SK
* Right : 
* Tel : 
* Last modified: 2022-03-26 04:15
* None: 
* Filename: async_fifo_tb.v
* Resverd: 
* Description: 
**************************************************************************************/

`timescale 1ns/1ps

module async_fifo_tb;

parameter       DLY         = 1;
parameter       WRITE_WIDTH = 8;
parameter       READ_WIDTH  = 8;
parameter       FIFO_WIDTH  = 8;
parameter       FIFO_DEPTH  = 32;

parameter       CLK_PERIOD_WR   = 10;
parameter       CLK_PERIOD_RD   = 20;

reg                         rst_n_i     ;

/********************************************************************************
* declare write channel
********************************************************************************/
reg                         wr_clk_i    ;
reg [FIFO_WIDTH - 1: 0]     wr_data_i   ;
reg                         wr_en_i     ;

/********************************************************************************
* declare read channel
********************************************************************************/
reg                         rd_clk_i    ;
wire [FIFO_WIDTH - 1: 0]    rd_data_o   ;
reg                         rd_en_i     ;


/********************************************************************************
* declare output status.
********************************************************************************/
wire                        empty_o     ;
wire                        full_o      ;


/********************************************************************************
* declare fsm
********************************************************************************/
reg                         clk ;
reg [7:0]                   cs  ;
reg [7:0]                   ns  ;
wire [7:0]                  cs_wr_synced;
wire [7:0]                  cs_rd_synced;

localparam                  IDLE                    = 8'b0000_0001;
localparam                  ONLY_PUSH               = 8'b0000_0010;
localparam                  ONLY_POP                = 8'b0000_0100;
localparam                  PUSH_POP_SYNC           = 8'b0000_1000;
localparam                  PUSH_FAST_POP_SLOW      = 8'b0001_0000;
localparam                  PUSH_SLOW_POP_FAST      = 8'b0010_0000;
localparam                  COMPLETE                = 8'b0100_0000;


/********************************************************************************
* generate test clokc
********************************************************************************/
initial begin
    clk = 1'b0;
    forever begin
        #(CLK_PERIOD_RD/2)  clk = 1'b0;
        #(CLK_PERIOD_RD/2)  clk = 1'b1;
    end
end

/********************************************************************************
* FSM
********************************************************************************/
always@(posedge clk or rst_n_i) begin
    if(!rst_n_i) begin
        cs <= #DLY  8'h00;
    end else begin
        cs <= #DLY  ns;
    end
end

always@(empty_o or full_o or cs) begin
    case(cs) 
        IDLE:               begin
                                ns = ONLY_PUSH;
                            end

        ONLY_PUSH:          begin
                                if(full_o) begin
                                    ns = ONLY_POP;
                                end
                                else begin
                                    ns = ONLY_PUSH;
                                end
                            end

        ONLY_POP:           begin
                                if(empty_o) begin
                                    ns = PUSH_FAST_POP_SLOW;
                                end
                                else begin
                                    ns = ONLY_POP;
                                end
                            end

        PUSH_FAST_POP_SLOW: begin
                                if(full_o) begin
                                    ns = PUSH_SLOW_POP_FAST;
                                end
                                else begin
                                    ns = PUSH_FAST_POP_SLOW;
                                end
                            end

        PUSH_SLOW_POP_FAST: begin
                                if(empty_o) begin
                                    ns = COMPLETE;
                                end
                                else begin
                                    ns = PUSH_SLOW_POP_FAST;
                                end
                            end

        COMPLETE:       begin
                            if(full_o) begin
                                ns = IDLE;
                            end
                            else begin
                                ns = COMPLETE;
                            end
                        end

        default:        begin
                            ns = IDLE;
                        end

    endcase
end


/********************************************************************************
* FSM output.
********************************************************************************/
always@(posedge wr_clk_i or negedge rst_n_i) begin
    if(!rst_n_i) begin
        wr_data_i <= #DLY {WRITE_WIDTH{1'b0}};
    end 
    else if(cs_wr_synced == ONLY_PUSH) begin
        wr_data_i <= #DLY {$random};
    end 
    else if(cs_wr_synced == PUSH_FAST_POP_SLOW) begin
        if(({$random} % 2) == 'd1) begin
            wr_data_i <= #DLY {$random};
        end
        else begin
            wr_data_i <= #DLY {WRITE_WIDTH{1'b0}};
        end
    end
    else if(cs_wr_synced == PUSH_SLOW_POP_FAST) begin
        if(({$random} % 8) == 'd1) begin
            wr_data_i <= #DLY {$random};
        end
        else begin
            wr_data_i <= #DLY {WRITE_WIDTH{1'b0}};
        end
    end
    else begin
        wr_data_i <= #DLY {WRITE_WIDTH{1'b0}};
    end
end

always@(posedge wr_clk_i or negedge rst_n_i) begin
    if(!rst_n_i) begin
        wr_en_i <= #DLY 1'b0;
    end 
    else if(cs_wr_synced == ONLY_PUSH) begin
        wr_en_i <= #DLY 1'b1;
    end 
    else if(cs_wr_synced == PUSH_FAST_POP_SLOW) begin
        if(({$random} % 2) == 'd1) begin
            wr_en_i <= #DLY 1'b1;
        end
        else begin
            wr_en_i <= #DLY 1'b0;
        end
    end 
    else if(cs_wr_synced == PUSH_SLOW_POP_FAST) begin
        if(({$random} % 8) == 'd1) begin
            wr_en_i <= #DLY 1'b1;
        end
        else begin
            wr_en_i <= #DLY 1'b0;
        end
    end
    else begin
        wr_en_i <= #DLY 1'b0;
    end
end

always@(posedge wr_clk_i or negedge rst_n_i) begin
    if(!rst_n_i) begin
        rd_en_i <= #DLY 1'b0;
    end 
    else if(cs_rd_synced == ONLY_POP) begin
        rd_en_i <= #DLY 1'b1;
    end 
    else if(cs_rd_synced == PUSH_FAST_POP_SLOW) begin
        if(({$random} % 6) == 'd1) begin
            rd_en_i <= #DLY 1'b1;
        end
        else begin
            rd_en_i <= #DLY 1'b0;
        end
    end 
    else if(cs_rd_synced == PUSH_SLOW_POP_FAST) begin
        if(({$random} % 2) == 'd1) begin
            rd_en_i <= #DLY 1'b1;
        end
        else begin
            rd_en_i <= #DLY 1'b0;
        end
    end
    else begin
        rd_en_i <= #DLY 1'b0;
    end
end

/********************************************************************************
* sim finsih
********************************************************************************/
initial begin
    forever begin
        if(ns == COMPLETE) begin
            #(CLK_PERIOD_WR * 10)
            $finish;
        end
        else begin
            #(CLK_PERIOD_WR * 10)
            $display("Simulation in progress ...");
        end
    end
end


/********************************************************************************
* dump
********************************************************************************/
initial begin
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars(0, "async_fifo_tb");
    $fsdbDumpMDA (0, "async_fifo_tb");
end

/********************************************************************************
* generate write and read clock
********************************************************************************/

initial begin
    wr_clk_i    = 1'b0;
    forever begin
        #(CLK_PERIOD_WR/2)     wr_clk_i = 1'b0;
        #(CLK_PERIOD_WR/2)     wr_clk_i = 1'b1;
    end
end

initial begin
    rd_clk_i    = 1'b0;
    forever begin
        #(CLK_PERIOD_RD/2)     rd_clk_i = 1'b0;
        #(CLK_PERIOD_RD/2)     rd_clk_i = 1'b1;
    end
end

/********************************************************************************
* generate reset signals 
********************************************************************************/
initial begin
    rst_n_i   = 1'b0;
    #(CLK_PERIOD_WR*10)
    rst_n_i = 1'b0;
    #(CLK_PERIOD_WR%3 )
    rst_n_i = 1'b1;
end


/********************************************************************************
* DUT: async fifo
********************************************************************************/
async_fifo          #(
    .DLY            (DLY            ),
    .WRITE_WIDTH    (WRITE_WIDTH    ),
    .READ_WIDTH     (READ_WIDTH     ),
    .FIFO_WIDTH     (FIFO_WIDTH     ),
    .FIFO_DEPTH     (FIFO_DEPTH     )
    )
    u_async_fifo_i
    (
    .rst_n_i        (rst_n_i        ),

    .wr_clk_i       (wr_clk_i       ),
    .wr_data_i      (wr_data_i      ),
    .wr_en_i        (wr_en_i        ),
    
    .rd_clk_i       (rd_clk_i       ),
    .rd_data_o     (rd_data_o      ),
    .rd_en_i        (rd_en_i        ),

    .full_o         (full_o         ),
    .empty_o        (empty_o        )
    );

/********************************************************************************
* DUT: general syncer for wr
********************************************************************************/
general_syncer      #(
    .DLY            (1              ),
    .FIRST_EDGE     (0              ),
    .LAST_EDGE      (0              ),
    .MID_STAGE_NUM  (2              ),
    .DATA_WIDTH     (8              )
    )
    u_general_syncer_wr_i
    (
    .clk_i          (wr_clk_i       ),
    .rst_n_i        (rst_n_i        ),
    .data_unsync_i  (cs             ),
    .data_synced_o  (cs_wr_synced   )
    );


/********************************************************************************
* DUT: general syncer for rd
********************************************************************************/
general_syncer      #(
    .DLY            (1              ),
    .FIRST_EDGE     (0              ),
    .LAST_EDGE      (0              ),
    .MID_STAGE_NUM  (2              ),
    .DATA_WIDTH     (8              )
    )
    u_general_syncer_rd_i
    (
    .clk_i          (rd_clk_i       ),
    .rst_n_i        (rst_n_i        ),
    .data_unsync_i  (cs             ),
    .data_synced_o  (cs_rd_synced   )
    );

endmodule

