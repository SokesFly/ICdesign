/***************************************************************************************
* Function: 
* Author: SK 
* Company: Ltd.JRLC.SK
* Right : 
* Tel : 
* Last modified: 2022-03-10 05:19
* None: 
* Filename: sync_fifo_tb.v
* Resverd: 
* Description: 
**************************************************************************************/

module sync_fifo_tb();
    parameter       WIDTH       = 8 ;
    parameter       DEPTH       = 16;
    parameter       ELS_SIZE    = $clog2(DEPTH);
    parameter       CLK_PERIOD  = 10;
    parameter       SIM_TIMES   = 20000;

    /*** clock and reset *********************************/
    reg                     clk_i   ;
    reg                     rst_n_i ;

    /*** write data **************************************/
    reg [WIDTH - 1 : 0]     wdata_i ;
    reg                     wr_en_i ;

    /*** read data ***************************************/
    wire [WIDTH - 1 : 0]    rdata_o ;
    reg                     rd_en_i ;

    wire                    full_o  ;
    wire                    empty_o ;
    wire [ELS_SIZE : 0]     elements_o ;

    /*** flow control delcare  ***************************/
    reg [WIDTH - 1 : 0]     wdata      ;
    reg [WIDTH - 1 : 0]     rdata      ;
    wire                    flow       ;
    wire                    flow_write ;
    wire                    flow_read  ;
    wire                    flow       ;
    reg [15 : 0]            write_flag ;
    reg [15 : 0]            read_flag  ;
    reg [0 : 0]             flow_flag  ;
    reg [15 : 0]            sim_times  ;

    assign                  flow_write = ( full_o   ) ? 1'b1 : 1'b0 ;
    assign                  flow_read  = ( empty_o  ) ? 1'b1 : 1'b0 ;
    assign                  flow       = ( !full_o && !empty_o ) ? 1'b1 : 1'b0 ;

    always@(posedge clk_i) begin
        if(flow) begin
            flow_flag <= {$random} % 2 ;
        end
    end


    always@(posedge clk_i) begin
        if(flow_write) begin
            write_flag <= {$random} % 16 ;
        end else if(flow_flag == 1'b1) begin
            write_flag <= {$random} % 3 ;
        end else begin
            write_flag <= {$random} % 7 ;
        end
    end

    always@(posedge clk_i) begin
        if(flow_read) begin
            read_flag <= {$random} % 16 ;
        end else begin
            read_flag <= {$random} % 5 ;
        end
    end

    /*** gen clk ****************************************/
    initial begin
        #0 clk_i    = 1'b0;
        #CLK_PERIOD 
        forever begin
            #(CLK_PERIOD/2) clk_i = 1'b1;
            #(CLK_PERIOD/2) clk_i = 1'b0;
        end
    end

    /*** gen rst ****************************************/
    initial begin
        #5  rst_n_i = 1'b0;
        #18 rst_n_i = 1'b1;
    end

    /*** gen data ***************************************/
    initial begin
        @(posedge rst_n_i) begin
            forever begin
                @(posedge clk_i) begin
                    if(write_flag == 16'h1) begin
                        wdata = {$random} ;
                        $display("%t, push data %x.", $time, wdata) ;
                        push ( wdata ) ;
                    end
                end
            end
        end
    end

    initial begin
        @(posedge rst_n_i) begin
            forever begin
                @(posedge clk_i) begin
                    if(read_flag == 16'h1) begin
                        pop ( rdata );
                        $display("%t, pop data %x.", $time, rdata) ;
                    end
                end
            end
        end
    end

    /*** end sim ****************************************/
    initial begin
        @(posedge rst_n_i) begin
            sim_times = 16'h0  ;
            repeat (SIM_TIMES) begin
                @(posedge clk_i )
                $display("%t", $time) ;
                sim_times = sim_times + 16'h1 ;
            end
            $finish;
        end
    end

    task push ;
        input [WIDTH - 1 : 0] push_data_i ;
        @(negedge clk_i) begin
            wr_en_i = 1'b1 ;
        end
        @(negedge clk_i) begin
            wdata_i = push_data_i;
        end
        wr_en_i = 1'b0 ;
    endtask

    task pop ;
        output reg [WIDTH - 1 : 0] pop_data_i ;
        @(negedge clk_i) begin
            rd_en_i     = 1'b1 ;
        end
        @(negedge clk_i) begin
            pop_data_i  = rdata_o ;
        end
        rd_en_i = 1'b0 ;
    endtask

    /*** dump db ***************************************/
    initial begin
        $fsdbDumpfile("tb.fsdb");
        $fsdbDumpvars(0, "sync_fifo_tb");
        $fsdbDumpMDA (0, "sync_fifo_tb.");
    end

    /*** dut ********************************************/
    sync_fifo #(
        .WIDTH  ( WIDTH   ),
        .DEPTH  ( DEPTH   ),
        .DLY    ( 1       )
    )u_sync_fifo_i(
        .clk_i  ( clk_i   ),
        .rst_n_i( rst_n_i ),
        .wdata_i( wdata_i ),
        .wr_en_i( wr_en_i ),
        .rdata_o( rdata_o ),
        .rd_en_i( rd_en_i ),
        .full_o ( full_o  ),
        .empty_o( empty_o ),
        .elements_o( elements_o )
    );

endmodule
