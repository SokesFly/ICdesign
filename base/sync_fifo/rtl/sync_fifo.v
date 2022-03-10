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

module sync_fifo(
	/****** Clocks and reset *******************************************/
	input wire			clk_i	,		// input  , clock,both read and write.
	input wire			rst_n_i	,		// input  , system reset , low valid.

	/****** Write channel **********************************************/
	input wire [7:0]	wdata_i	,		// input  , data will be write in fifo 
	input wire			wr_en_i	,		// input  , write enable , high valid.

	/****** Read channel ***********************************************/
	output reg [7:0]	rdata_i	,		// output , data will be read frome fifo.
	input wire			rd_en_i	,		// input  ,	read enable , high valid.		

	/****** Control and status *****************************************/
	output wire			full_o		,	// output , high, when fifo full, or low.
	output wire			empty_o 	,	// output , high, when fifo empty, or low.
	output reg [3:0]	elements_o   	// output , elements fifo's storaged.
);
	parameter			DLY	= 1;
	
	reg [2:0]			wr_ptr ;
	reg [2:0]			rd_ptr ;
	reg [7:0]			fifo_array [0:15] ;
	
	/****** Write data **********************************************/
	always@(posedge clk_i or negedge rst_n_i) begin
		if(!rst_n_i) begin
			fifo_array [0] <= #DLY 8'h0 ;
		end else if(wr_en_i) begin
			fifo_array [wr_ptr] <= #DLY wdata_i ;
		end else begin
			fifo_array [wr_ptr] <= #DLY fifo_array [wr_ptr] ;
		end
	end

	always@(posedge clk_i or negedge rst_n_i) begin
		if(!rst_n_i) begin
			wr_ptr <= #DLY 3'd0 ;
		end else if(wr_en_i && !full_o) begin
			wr_ptr <= #DLY wr_ptr + 1'b1 ;
		end else begin
			wr_ptr <= #DLY wr_ptr ;
		end
	end

	/****** Read data **********************************************/
	always@(posedge clk_i or negedge rst_n_i) begin
		if(!rst_n_i) begin
			rdata_i <= #DLY 8'h0 ;
		end else if(rd_en_i) begin
			rdata_i <= #DLY fifo_array [rd_ptr] ;
		end else begin
			rdata_i <= #DLY 8'h0 ;
		end
	end

	always@(posedge clk_i or negedge rst_n_i) begin
		if(!rst_n_i) begin
			rd_ptr <= #DLY 3'd0 ;
		end else if(rd_en_i && !empty_o) begin
			rd_ptr <= #DLY rd_ptr + 1'b1 ;
		end else begin
			rd_ptr <= #DLY rd_ptr ;
		end
	end

	/****** counter  *********************************************/
	always@(posedge clk_i or negedge rst_n_i) begin
		if(!rst_n_i) begin
			elements_o <= #DLY 4'h0 ;
		end else if((wr_en_i && !full_o) && (rd_en_i && !empty_o)) begin
			elements_o <= #DLY elements_o ;
		end else if(wr_en_i && !full_o) begin
			elements_o <= #DLY elements_o + 4'h1 ;
		end else if(rd_en_i && !empty_o) begin
			elements_o <= #DLY elements_o - 4'h1 ;
		end else begin
			elements_o <= #DLY elements_o ;
		end
	end

	/****** status output ********************************************/
	assign full_o  = (elements_o == 4'hF) ? 1'b1 : 1'b0;
	assign empty_o = (elements_o == 4'h0) ? 1'b1 : 1'b0; 
	
endmodule
