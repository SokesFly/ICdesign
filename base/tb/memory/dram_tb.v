`timescale 1ns/1ps

module                      dram_tb();

parameter                   DLY             = 1;
parameter                   CLK_PERIOD_A    = 10;
parameter                   CLK_PERIOD_B    = 28;
parameter                   WRITE_WIDTH     = 8;
parameter                   READ_WIDTH      = 8;
parameter                   DEPTH           = 4;
parameter                   ADDR            = (READ_WIDTH - WRITE_WIDTH) ? 
                                              ($clog2(DEPTH) + $clog2(READ_WIDTH/WRITE_WIDTH)) :  
                                              ($clog2(DEPTH) + $clog2(WRITE_WIDTH/READ_WIDTH));

// Declare clock register
wire                         pa_clk_i    ;
wire                         pb_clk_i    ;
// Declare reset register
wire                         pa_rstn_i   ;
wire                         pb_rstn_i   ;
// Declare port a channel write & read register 
wire  [ADDR-1        :0]     pa_addr_i   ;
wire                         pa_wr_en_i  ;
wire  [WRITE_WIDTH-1 :0]     pa_wr_data_i;
wire                         pa_rd_en_i  ;
wire [READ_WIDTH-1  :0]      pa_rd_data_o;
// Declare port b channel write & read register 
wire  [ADDR-1        :0]     pb_addr_i   ;
wire                         pb_wr_en_i  ;
wire  [WRITE_WIDTH-1 :0]     pb_wr_data_i;
wire                         pb_rd_en_i  ;
wire [READ_WIDTH-1  :0]      pb_rd_data_o;

// Declare clock register
reg                          pa_clk_r    ;
reg                          pb_clk_r    ;
// Declare reset register
reg                          pa_rstn_r   ;
reg                          pb_rstn_r   ;
// Declare port a channel write & read register 
reg  [ADDR-1        :0]      pa_addr_r   ;
reg                          pa_wr_en_r  ;
reg  [WRITE_WIDTH-1 :0]      pa_wr_data_r;
reg                          pa_rd_en_r  ;
// Declare port b channel write & read register 
reg  [ADDR-1        :0]      pb_addr_r   ;
reg                          pb_wr_en_r  ;
reg  [WRITE_WIDTH-1 :0]      pb_wr_data_r;
reg                          pb_rd_en_r  ;

//  assign register to wire
assign      pa_clk_i        =   pa_clk_r    ;
assign      pa_rstn_i       =   pa_rstn_r   ;
assign      pa_addr_i       =   pa_addr_r   ;
assign      pa_wr_en_i      =   pa_wr_en_r  ;
assign      pa_wr_data_i    =   pa_wr_data_r;
assign      pa_rd_en_i      =   pa_rd_en_r  ;
assign      pb_clk_i        =   pb_clk_r    ;
assign      pb_rstn_i       =   pb_rstn_r   ;
assign      pb_wr_en_i      =   pb_wr_en_r  ;
assign      pb_addr_i       =   pb_addr_r   ;
assign      pb_wr_data_i    =   pb_wr_data_r;
assign      pb_rd_en_i      =   pb_rd_en_r  ;

//  generate port a cloks
initial begin
    pa_clk_r    = 1'b0;
    forever begin
        #(CLK_PERIOD_A/2)   pa_clk_r = 1'b1;
        #(CLK_PERIOD_A/2)   pa_clk_r = 1'b0;
    end
end

//  generate port a cloks
initial begin
    pb_clk_r    = 1'b0;
    forever begin
        #(CLK_PERIOD_B/2)   pb_clk_r = 1'b1;
        #(CLK_PERIOD_B/2)   pb_clk_r = 1'b0;
    end
end

initial begin
    pa_rstn_r               =  1'b0;
    #(CLK_PERIOD_A*3 + 2)
    pa_rstn_r               =  1'b1;
end

initial begin
    pb_rstn_r               =  1'b0;
    #(CLK_PERIOD_A*3 + 2)
    pb_rstn_r               =  1'b1;
end


// fsdb dump
initial begin
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars(0, "dram_tb");
    $fsdbDumpMDA(0, "dram_tb.");
end

always@(posedge pa_clk_i or pa_rstn_i) begin
    if(!pa_rstn_i) begin
        pa_wr_en_r <= #DLY 1'b0;
    end
    else begin
        pa_wr_en_r <= #DLY 1'b1;
    end
end

always@(posedge pa_clk_i or pa_rstn_i) begin
    if(!pa_rstn_i) begin
        pa_wr_data_r <= #DLY {WRITE_WIDTH{1'b0}};
    end
    else begin
        pa_wr_data_r <= #DLY pa_wr_data_r + 'd1;
    end
end

always@(posedge pa_clk_i or pa_rstn_i) begin
    if(!pa_rstn_i) begin
        pa_addr_r <= #DLY {WRITE_WIDTH{1'b0}};
    end
    else if(pa_addr_r == {ADDR{1'b1}}) begin
        pa_addr_r <= #DLY {WRITE_WIDTH{1'b0}};
    end
    else begin
        pa_addr_r <= #DLY pa_addr_r + 'd1;
    end 
end

always@(posedge pa_clk_i or pa_rstn_i) begin
    if(!pa_rstn_i) begin
        pa_rd_en_r <= #DLY 1'b0;
    end
    else if({$random} % 4 == 2'b01) begin
        pa_rd_en_r <= #DLY 1'b1;
    end
    else begin
        pa_rd_en_r <= #DLY 1'b0;
    end
end

// end of sim
initial begin
    #(CLK_PERIOD_A*2000) 
    $finish;
end

dram                        #(
    .WRITE_WIDTH            (WRITE_WIDTH ),
    .READ_WIDTH             (READ_WIDTH  ),
    .DEPTH                  (DEPTH       )
    )
    u_dram_i
    (
    .pa_clk_i               (pa_clk_i    ),
    .pa_rstn_i              (pa_rstn_i   ),
    .pa_addr_i              (pa_addr_i   ),
    .pa_wr_en_i             (pa_wr_en_i  ),
    .pa_wr_data_i           (pa_wr_data_i),
    .pa_rd_en_i             (pa_rd_en_i  ),
    .pa_rd_data_o           (pa_rd_data_o),
    .pb_clk_i               (pb_clk_i    ),
    .pb_rstn_i              (pb_rstn_i   ),
    .pb_wr_en_i             (pb_wr_en_i  ),
    .pb_addr_i              (pb_addr_i   ),
    .pb_wr_data_i           (pb_wr_data_i),
    .pb_rd_en_i             (pb_rd_en_i  ),
    .pb_rd_data_o           (pb_rd_data_o)
    );

endmodule
