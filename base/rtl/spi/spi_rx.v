
module                              spi_rx #(
    parameter                       DLY         = 1,
    parameter                       DATA_LEN    = 32,
    parameter                       FIFO_VLD    = $clog2(DATA_LEN),
    parameter                       FIFO_WIDTH  = DATA_LEN + DATA_VLD
    )(
    input  wire                     clk_i       ,  //  spi controller clock
    input  wire                     rst_n_i     ,  //  reset 
    input  wire                     cpol        ,  // 0, clock keep low state ; 1 , clock keep high state , when bus idle
    input  wire                     cpoa        ,  // 0, first edge DAQ, 1, second edge DAQ
    output wire [FIFO_WIDTH-1   :0] rx_rdata_o  ,  // data recv from sdi
    output wire                     rx_vld_o    ,  // data vld 
    input  wire                     rx_rdy_i    ,  // data ready
    input  wire                     rx_enable_i ,  // enable spi recv
    input  wire                     bit_en      ,  // bit enabel ,from clock gen
    output wire                     clk_gen     ,  // generate bit enable
    input  wire                     spi_bus_clk ,  // spi bus clock.
    output wire                     rx_eot      ,  // rx recv complete
    input  wire                     sdi            // physical rx
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
wire                                rd_en_i     ;
wire                                rdata_o     ;
wire                                elements_o  ;

// define fsm register
reg  [2              :0]            spi_rx_flow_fsm   ;

localparam                          IDLE    = 3'b001;
localparam                          TFR     = 3'b010;
localparam                          STOP    = 3'b100;

reg                                 spi_rx_tfr_end    ;
reg                                 sdi_buf_r         ;

wire                                rise_edge         ;

wire                                go_idle           ;
wire                                go_tfr            ;
wire                                go_stop           ;

assign                              go_tfr  = (spi_rx_flow_fsm == IDLE) && rise_edge && rx_enable_i;
assign                              go_stop = (spi_rx_flow_fsm == TFR ) && bit_en && spi_rx_tfr_end) && rx_enable_i;
assign                              go_idle = (spi_rx_flow_fsm == STOP) && bit_en && rx_enable_i;

assign                              wdata_i = wdata_r ;
assign                              wr_en_i = wr_en_r ;
assign                              rd_en_i = rx_rdy_i;
assign                              rx_rdata_o = rdata_o;

// generate rise  edge
assign                              rise_edge = (sdi  && !sdi_buf_r);
assign                              clk_en    = rise_edge ;

// detect clock disable
always@(posedge clk_i or negedge) begin
    if(!rst_n_i) begin
        spi_rx_tfr_end <= 1'b0;
    end
    else if(bit_en && (!spi_bus)) begin
        spi_rx_tfr_end <= 1'b1;
    end
    else begin
        spi_rx_tfr_end <= 1'b0;
    end
end

always@(posedge clk_i or negedge rst_n_i) begin
    if(!rst_n_i) begin
        sdi_buf_r <= #DLY 1'b0;
    end
    else begin
        sdi_buf_r <= #DLY spi_bus_clk;
    end
end

// fsm jump
always@(posedge clk_i or negedge rst_n_i) begin
    if(!rst_n_i) begin
        spi_rx_flow_fsm <= #DLY  IDLE;
    end
    else begin
        case(spi_rx_flow_fsm)
            IDLE:               begin
                                    if(go_tfr) begin 
                                        spi_rx_flow_fsm <= #DLY  TFR;
                                    end 
                                    else begin
                                        spi_rx_flow_fsm <= #DLY  IDL;
                                    end
                                end
            TFR:                begin
                                    if(go_stop) begin 
                                        spi_rx_flow_fsm <= #DLY  STOP;
                                    end 
                                    else begin
                                        spi_rx_flow_fsm <= #DLY  TFR;
                                    end
                                end
            STOP:               begin
                                    if(go_tfr) begin 
                                        spi_rx_flow_fsm <= #DLY  IDLE;
                                    end 
                                    else begin
                                        spi_rx_flow_fsm <= #DLY  STOP;
                                    end
                                end
        endcase
    end
end

// fsm output , record current tfr's bit number.
always@(posedge clk_i or negedge rst_n_i) begin
    if(!rst_n_i) begin
        spi_rx_tfr_cnt <= #DLY {TFR_RX_CNT{1'b0}};
    end
    else if(spi_rx_flow_fsm == TFR && bit_en && spi_bus_clk) begin
        spi_rx_tfr_cnt <= spi_rx_tfr_cnt + 'd1;
    end
    else begin
        spi_rx_tfr_cnt <= #DLY {TFR_RX_CNT{1'b0}};
    end
end

// fsm output , generate write fifo enable signale.
always@(posedge clk_i or negedge rst_n_i) begin
    if(!rst_n_i) begin
        wr_en_r <= #DLY 1'b0;
    end
    else if((spi_rx_flow_fsm == STOP && bit_en && ~spi_bus_clk) || (spi_rx_tfr_cnt == {TFR_RX_CNT{1'b1}}) begin
        wr_en_r <= #DLY 1'b1;
    end
    else begin
        wr_en_r <= #DLY 1'b0;
    end
end

// fsm output , write spi data to 
always@(posedge clk_i or negedge rst_n_i) begin
    if(!rst_n_i) begin
        wdata_r <= #DLY {FIFO_WIDTH{1'b0}};
    end
    else if(wr_en_i) begin
        wdata_r <= #DLY {spi_rx_tfr_cnt[TFR_RX_CNT-1, 0], wdata_r[DATA_LEN-1:0]};
    end
    else if((spi_rx_flow_fsm == TFR)  && bit_en && spi_bus_clk) begin
        wdata_r <= #DLY {sdi, wdata_r[DATA_LEN-1:1]};
    end
    else begin
        wdata_r <= #DLY {FIFO_WIDTH{1'b0}};
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
