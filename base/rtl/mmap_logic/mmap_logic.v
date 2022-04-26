`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/01/24 16:04:13
// Design Name: 
// Module Name: mmap_logic
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mmap_logic(
	input wire clk,
	input wire reset,
	
	input wire rx_tvalid		,
	input wire [63:0] rx_tdata	,

	output wire [0 : 0] 	usr_irq_req,
	input wire 	[0 : 0] 	usr_irq_ack,
	input wire 				msi_enable, 
	input wire [2 : 0] 		msi_vector_width,
	
	output wire clkb           ,
	output wire enb            ,
	output wire [7 : 0] web    ,
	output wire [31 : 0] addrb ,
	output wire [63 : 0] dinb  ,
	input wire [63 : 0] doutb 
);

reg enb_r;
reg [7:0] web_r;
reg [31:0] addrb_r;
reg [63:0] dinb_r;
reg [63:0] doutb_r;

reg usr_irq_req_r;

assign	clkb = clk;
assign	enb = enb_r;
assign  web[7:0] = web_r[7:0];
assign  addrb[31:0] = addrb_r[31:0];
assign  dinb[63:0] = dinb_r[63:0];
assign	usr_irq_req = usr_irq_req_r;

reg [3:0]	state_c;
reg [3:0]	state_n;

localparam	IDLE = 4'h0;
localparam	W_HEADER = 4'h1;
localparam  W_DATA = 4'h2;
localparam	R_DATA = 4'h3;

always@(posedge clk)
begin
	if(!reset)
		state_c <= IDLE;
	else
		state_c <= state_n;
end

always@(*)
begin
	case(state_c[3:0])
		IDLE:begin
			if(rx_tvalid == 1'b1 && rx_tdata[31:0] == 32'hfabc_2330)
				state_n <= W_HEADER;
			else if(rx_tvalid == 1'b1 && rx_tdata[31:0] != 32'hfabc_2330)
				state_n	<= W_DATA;
			else
				state_n <= IDLE;
		end
		
		W_HEADER:begin
			if(rx_tvalid == 1'b1 && rx_tdata[31:0] == 32'hfabc_2330)
				state_n <= W_HEADER;
			else if(rx_tvalid == 1'b1 && rx_tdata[31:0] != 32'hfabc_2330)
				state_n	<= W_DATA;
			else
				state_n <= IDLE;
		end
		
		W_DATA:begin
			if(rx_tvalid == 1'b1 && rx_tdata[31:0] == 32'hfabc_2330)
				state_n <= W_HEADER;
			else if(rx_tvalid == 1'b1 && rx_tdata[31:0] != 32'hfabc_2330)
				state_n	<= W_DATA;
			else
				state_n <= IDLE;
		end
		
		R_DATA:begin
			if(rx_tvalid == 1'b1 && rx_tdata[31:0] == 32'hfabc_2330)
				state_n <= W_HEADER;
			else if(rx_tvalid == 1'b1 && rx_tdata[31:0] != 32'hfabc_2330)
				state_n	<= W_DATA;
			else
				state_n <= IDLE;
		end
		
		default:begin
			if(rx_tvalid == 1'b1 && rx_tdata[31:0] == 32'hfabc_2330)
				state_n <= W_HEADER;
			else if(rx_tvalid == 1'b1 && rx_tdata[31:0] != 32'hfabc_2330)
				state_n	<= W_DATA;
			else
				state_n <= IDLE;
		end
		
	endcase
end

always@(posedge clk)
begin
	if (!reset)
		enb_r <= 1'b0;
	else
		enb_r <= 1'b1;
end

always@(posedge clk)
begin
	if (!reset)
		web_r[7:0] <= 8'h0;
	else
		begin
			if(state_n == W_HEADER)
				web_r[7:0] <= 8'hFF;
			else if(state_n == W_DATA)
				web_r[7:0] <= 8'hFF;
			else
				web_r[7:0] <= 8'h0;
		end
end


always@(posedge clk)
begin
	if (!reset)
		addrb_r[31:0]  <= 32'h0;
	else
		begin
			if(state_n == W_HEADER)
				addrb_r[31:0] <= 32'h0;
			else if(state_n	== W_DATA)
				addrb_r[31:0] <= addrb_r[31:0] + 32'h8;
			else
				addrb_r[31:0] <= addrb_r[31:0];
		end
end


always@(posedge clk)
begin
	if (!reset)
		dinb_r[63:0] <= 64'h0;
	else
		begin
			if(state_n == W_HEADER)
				dinb_r[63:0] <= rx_tdata[63:0];
			else if(state_n == W_DATA)
				dinb_r[63:0] <= rx_tdata[63:0];
			else
				dinb_r[63:0] <= 64'h0;
		end
end

always@(posedge clk)
begin
	if(web[7:0] == 8'hFF && dinb[31:0] == 32'hfabc_2330)
		usr_irq_req_r <= 1'b1;
	else
		usr_irq_req_r <= 1'b0;
end

endmodule

