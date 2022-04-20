module          spi_tx_tb();

parameter       DLY     = 1;
parameter       PERIOD  = 20;
parameter       DATA_LEN= 4;
parameter       DATA_VLD= $clog2(DATA_LEN);
parameter       WIDTH   = DATA_LEN + DATA_VLD;

reg                     clk_r   ;
reg                     rstn_r  ;
wire                    clk_o   ;
reg                     cpol    ;
reg                     cpoa    ;
reg  [WIDTH-1:0]        tx_data ;
reg                     tx_vld  ;
wire                    tx_rdy  ;
wire                    tx_eot  ;
wire                    sdo     ;

wire                    spi_bus_clk;
wire                    bit_half_en ;

initial begin
    clk_r       =  1'b0;
    forever begin
        #(PERIOD/2) clk_r = 1'b0;
        #(PERIOD/2) clk_r = 1'b1;
    end
end

initial begin
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars(0, "spi_tx_tb");
    $fsdbDumpMDA(0, "spi_tx_tb.");
end

initial begin
    rstn_r = 1'b0;
    #(PERIOD*10)
    rstn_r = 1'b1;
    #(PERIOD*2888)
    $finish;
end

initial begin
    @(posedge rstn_r) begin
        cpol = 'd1;
        cpoa = 'd1;
    end
end

always@(posedge clk_r or negedge rstn_r) begin
    if(!rstn_r) begin
        tx_data <= #DLY 'd0;
    end
    else if(tx_rdy) begin
        tx_data <= #DLY {{DATA_VLD{1'b1}}, {$random}};
    end
    else begin
        tx_data <= #DLY 'd0;
    end
end

always@(posedge clk_r or negedge rstn_r) begin
    if(!rstn_r) begin
        tx_vld  <= #DLY 'd0;
    end
    else if(tx_rdy) begin
        tx_vld <= #DLY 'd1;
    end
    else begin
        tx_vld  <= #DLY 'd0;
    end
end

spi_tx           #(
    .DLY         (DLY        ),
    .SPI_TX_WIDTH(DATA_LEN   )
    )
    u_spi_tx_i
    (
    .clk         (clk_r      ),
    .rstn        (rstn_r     ),
    .cpol        (cpol       ),
    .cpoa        (cpoa       ),
    .length      (DATA_LEN -1),
    .tx_data     (tx_data    ),
    .tx_vld      (tx_vld     ),
    .tx_rdy      (tx_rdy     ),
    .tx_eot      (tx_eot     ),
    .sdo         (sdo        ),
    .spi_bus_clk (spi_bus_clk)
    );

// declare fifo wire


endmodule
