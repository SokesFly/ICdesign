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
	parameter		CLK_PERIOD	= 10;
	parameter		SIM_TIMES	= 200;

	/*** clock and reset *********************************/
	reg 			clk_i  	;
	reg 			rst_n_i ;

	/*** write data **************************************/
	reg [7:0]		wdata_i ;
	reg				wr_en_i	;

	/*** read data ***************************************/
	wire [7:0]		rdata_i	;
	reg 			rd_en_i ;

	wire			full_o	;
	wire 			empty_o	;
	wire [3:0]		elements_o ;

	/*** gen clk ****************************************/
	initial begin
		#0 clk_i	= 1'b0;
		#CLK_PERIOD	
		forever begin
			#(CLK_PERIOD/2)	clk_i = 1'b1;
			#(CLK_PERIOD/2)	clk_i = 1'b0;
		end
	end

	/*** gen rst ****************************************/
	initial begin
		#0  rst_n_i = 1'b1;
		#5  rst_n_i = 1'b0;
		#18 rst_n_i = 1'b1;
	end

	/*** gen data ***************************************/
	always@(posedge clk_i or negedge rst_n_i) begin
		if(!rst_n_i) begin
			wdata_i <= 8'h0;
		end else begin
			wdata_i <= {$random};
		end
	end

	/*** wr ena ****************************************/
	initial begin
		@(posedge rst_n_i)
		wr_en_i = 1'b1;
	end

	/*** rd ena ****************************************/
	initial begin
		@(posedge rst_n_i)
		rd_en_i = 1'b1;
	end

	/*** end sim ***************************************/
	initial begin
		repeat(SIM_TIMES) begin
			@(posedge clk_i);
		end
		$finish;
	end

	/*** dump db ***************************************/
	initial begin
		$fsdbDumpfile("tb.fsdb");
		$fsdbDumpvars(0, "sync_fifo_tb");
	end


	/*** dut ********************************************/
	sync_fifo u_sync_fifo_i(
		.clk_i	( clk_i   ),
		.rst_n_i( rst_n_i ),
		.wdata_i( wdata_i ),
		.wr_en_i( wr_en_i ),
		.rdata_i( rdata_i ),
		.rd_en_i( rd_en_i ),
		.full_o	( full_o  ),
		.empty_o( empty_o ),
		.elements_o( elements_o )
	);

endmodule
