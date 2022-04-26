`timescale 1ns / 1ps
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

module                          mmap_logic_tb();

parameter                       DLY  = 1;

//Clock and reset declare
reg                             clk_r     ;
reg                             rstn_r    ;

// IRQ 
wire                            usr_irq_req         ;
reg                             usr_irq_ack_r       ;
reg                             msi_enable_r        ;
reg  [2 :0]                     msi_vector_width_r  ;

reg                             rx_tvalid_r         ;
reg  [63:0]                     rx_tdata_r          ;

wire                            clkb_o              ;
wire                            enb_o               ;
wire [7 :0]                     web_o               ;
wire [31:0]                     addrb_o             ;
wire [63:0]                     din_o               ;
wire [63:0]                     dout_o              ;

// Declare data counter
reg  [12:0]                     cnt_r               ;

//Generate clock and reset
initial begin
    clk_r = 1'b0;
    forever begin
        #5  clk_r = 1'b0;
        #5  clk_r = 1'b1;
    end
end

initial begin
    rstn_r = 1'b0;
    #22 
    rstn_r = 1'b1;
end

// initial input register veribles
initial begin
    usr_irq_ack_r = 1'b0;
    msi_enable_r  = 1'b0;
    msi_vector_width_r = 3'b000;
    cnt_r         = 'd0;
end

assign      dout_o  = 'd0;

//Dump vcs wavmfrom
initial begin
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars(0, "mmap_logic_tb");
    $fsdbDumpMDA (0, "mmap_logic_tb");
end

// EOS
initial begin
    #(5*10000) 
    $finish;
end


// Generate data.
always@(posedge clk_r or negedge rstn_r) begin
    if(!rstn_r) begin
        cnt_r <= #DLY   'd0;
    end
    else begin
        cnt_r <= #DLY cnt_r + 'd1;
    end
end

always@(posedge clk_r or negedge rstn_r) begin
    if(!rstn_r) begin
        rx_tvalid_r <= #DLY 'd0;
    end
    else if(cnt_r >= 'd4096) begin
        rx_tvalid_r <= #DLY 'd0;
    end
    else begin
        rx_tvalid_r <= #DLY 'd1;
    end
end


always@(posedge clk_r or negedge rstn_r) begin
    if(!rstn_r) begin
        rx_tdata_r <= #DLY 'd0;
    end
    else if(cnt_r >= 'd4096) begin
        rx_tdata_r <= #DLY 'd0;
    end
    else if(cnt_r == 'd0) begin
        rx_tdata_r <= #DLY 64'hfabc_2330;
    end
    else begin
        rx_tdata_r <= #DLY {$random};
    end
end


mmap_logic                      u_mmap_logic_i (
    .clk              (clk_r             ),
    .reset            (rstn_r            ),
    .rx_tvalid        (rx_tvalid_r       ),
    .rx_tdata         (rx_tdata_r        ),
    .usr_irq_req      (usr_irq_req       ),
    .usr_irq_ack      (usr_irq_ack_r     ),
    .msi_enable       (msi_enable_r      ),
    .msi_vector_width (msi_vector_width_r),
    .clkb             (clkb_o            ),
    .enb              (enb_o             ),
    .web              (web_o             ),
    .addrb            (addrb_o           ),
    .dinb             (dinb_o            ),
    .doutb            (doutb_o           )
    );



endmodule
