/***************************************************************************************
* Function: 
* Author: SK 
* Company: Ltd.JRLC.SK
* Right : 
* Tel : 
* Last modified: 2022-03-10 04:03
* None: 
* Filename: sync_fifo.v
* Resverd: 
* Description: 
**************************************************************************************/

module sync_fifo #(
    parameter           WIDTH       = 32,
    parameter           DEPTH       = 16,
    parameter           ELS_SIZE    = $clog2(DEPTH),
    parameter           DLY = 1
)(
    /****** Clocks and reset *******************************************/
    input wire                  clk_i   ,       // input  , clock,both read and write.
    input wire                  rst_n_i ,       // input  , system reset , low valid.

    /****** Write channel **********************************************/
    input wire [WIDTH - 1 : 0]  wdata_i ,       // input  , data will be write in fifo 
    input wire                  wr_en_i ,       // input  , write enable , high valid.

    /****** Read channel ***********************************************/
    output reg [WIDTH - 1 : 0]  rdata_i ,       // output , data will be read frome fifo.
    input wire                  rd_en_i ,       // input  , read enable , high valid.

    /****** Control and status *****************************************/
    output wire         full_o      ,           // output , high, when fifo full, or low.
    output wire         empty_o     ,           // output , high, when fifo empty, or low.
    output reg [ELS_SIZE : 0]   elements_o      // output , elements fifo's storaged.
);

    reg [ELS_SIZE - 1 : 0]         wr_ptr ;
    reg [ELS_SIZE - 1 : 0]         rd_ptr ;
    reg [WIDTH - 1 : 0]         fifo_array [0 : DEPTH - 1] ;
    reg [ELS_SIZE : 0]          i ;

    /****** Write data **********************************************/
    always@(posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i) begin
            for(i = 0; i < DEPTH ; i = i + 1'b1) begin
                fifo_array [i] <= #DLY 'b0 ;
            end
        end else if(wr_en_i) begin
            fifo_array [wr_ptr] <= #DLY wdata_i ;
        end else begin
            fifo_array [wr_ptr] <= #DLY fifo_array [wr_ptr] ;
        end
    end

    always@(posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i) begin
            wr_ptr <= #DLY 'b0 ;
        end else if(wr_en_i && !full_o) begin
            wr_ptr <= #DLY wr_ptr + 1'b1 ;
        end else begin
            wr_ptr <= #DLY wr_ptr ;
        end
    end

    /****** Read data **********************************************/
    always@(posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i) begin
            rdata_i <= #DLY 'b0 ;
        end else if(rd_en_i) begin
            rdata_i <= #DLY fifo_array [rd_ptr] ;
        end else begin
            rdata_i <= #DLY 'b0 ;
        end
    end

    always@(posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i) begin
            rd_ptr <= #DLY 'b0 ;
        end else if(rd_en_i && !empty_o) begin
            rd_ptr <= #DLY rd_ptr + 1'b1 ;
        end else begin
            rd_ptr <= #DLY rd_ptr ;
        end
    end

    /****** counter  *********************************************/
    always@(posedge clk_i or negedge rst_n_i) begin
        if(!rst_n_i) begin
            elements_o <= #DLY 'b0 ;
        end else if((wr_en_i && !full_o) && (rd_en_i && !empty_o)) begin
            elements_o <= #DLY elements_o ;
        end else if(wr_en_i && !full_o) begin
            elements_o <= #DLY elements_o + 1'b1 ;
        end else if(rd_en_i && !empty_o) begin
            elements_o <= #DLY elements_o - 1'b1 ;
        end else begin
            elements_o <= #DLY elements_o ;
        end
    end

    /****** status output ********************************************/
    assign full_o  = (elements_o == DEPTH) ? 1'b1 : 1'b0;
    assign empty_o = (elements_o == 'b0) ? 1'b1 : 1'b0;

endmodule
