
module                              spi_rx #(
    parameter                       DLY         = 1,
    parameter                       FIFO_WIDTH  = 32
    )(
    input  wire                     clk_i       ,  //  spi controller clock
    input  wire                     rst_n_i     ,  //  reset 
    input  wire                     cpol        ,  // 0, clock keep low state ; 1 , clock keep high state , when bus idle
    input  wire                     cpoa        ,  // 0, first edge DAQ, 1, second edge DAQ
    output wire [FIFO_WIDTH-1   :0] rx_rdata_o  ,  // data recv from sdi
    output wire                     rx_vld_o    ,  // data vld 
    input  wire                     rx_rdy_i    ,  // data ready
    input  wire                     bit_en      ,  // bit enabel ,from clock gen
    output wire                     clk_gen     ,  // generate bit enable
    input  wire                     sdi            // physical rx.
    );

parameter                           TFR_RX_CNT  = $clog2(FIFO_WIDTH);
reg  [TFR_RX_CNT-1   :0]            spi_rx_tfr_cnt ;

// declare fifo wire
reg  [FIFO_WIDTH-1   :0]            wdata_r     ;
wire [FIFO_WIDTH-1   :0]            wdata_i     ;
reg                                 wr_en_r     ;
wire                                wr_en_i     ;
wire                                full_o      ;
wire                                empty_o     ;
reg                                 rd_en_r     ;
wire                                rd_en_i     ;
wire                                rdata_o     ;
wire                                elements_o  ;

// define fsm register
reg  [2              :0]            spi_rx_flow_fsm   ;

localparam                          IDLE    = 3'b001;
localparam                          TFR     = 3'b010;
localparam                          STOP    = 3'b100;

reg                                 sdi_buf_r         ;

wire                                rise_edge         ;

wire                                go_idle           ;
wire                                go_tfr            ;
wire                                go_stop           ;

assign                              go_tfr  = (spi_rx_flow_fsm == IDLE) && rise_edge;
assign                              go_stop = (spi_rx_flow_fsm == TFR ) && bit_en && (spi_rx_tfr_cnt == {TFR_RX_CNT{1'b1}});
assign                              go_stop = (spi_rx_flow_fsm == STOP) && bit_en;

assign                              wdata_i = wdata_r ;
assign                              wr_en_i = wr_en_r ;
assign                              rd_en_i = rd_en_r ;

// generate rise  edge
assign                              rise_edge = (sdi  && !sdi_buf_r);

always@(posedge clk_i or negedge rst_n_i) begin
    if(!rst_n_i) begin
        sdi_buf_r <= #DLY 1'b0;
    end
    else begin
        sdi_buf_r <= #DLY sdi;
    end
end

always@(posedge clk_i or negedge rst_n_i) begin
    if(!rst_n_i) begin
        spi_rx_flow_fsm <= #DLY  IDLE;
    end
    else begin
        case(spi_rx_flow_fsm)
            
        endcase
    end
end

    
sync_fifo                           #(
    .DLY                            ( DLY       ),
    .WIDTH                          ( FIFO_WIDTH),
    .DEPTH                          ( 16        )
    )
    u_sync_fifo_spi_tx_i
    (
    .clk_i                          (clk_i     ),
    .rst_n_i                        (rst_n_i   ),
    .wdata_i                        (wdata_i   ),
    .wr_en_i                        (wr_en_i   ),
    .rdata_o                        (rdata_o   ),
    .rd_en_i                        (rd_en_i   ),
    .full_o                         (full_o    ),
    .empty_o                        (empty_o   ),
    .elements_o                     (elements_o)
    );

endmodule
