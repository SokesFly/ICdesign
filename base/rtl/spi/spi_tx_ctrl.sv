module                                  spi_tx_ctrl #(
    parameter                           DLY          = 1,
    parameter                           SPI_TX_DWIDE = 32,
    parameter                           FIFO_WIDTH   = 32,
    parameter                           FIFO_DEPTH   = 32
    )(
    input  wire                         clk_i       ,  // Primary clock
    input  wire                         rstn_i      ,  // System reset async

    // FIFO data input
    input  wire [SPI_TX_DWIDE-1    :0]  wdata_i     ,  // Data write to fifo
    input  wire                         wr_en_i     ,  // Data enable fifo
    output wire                         empty_o     ,  // FIFO empty_o
    output wire                         full_o      ,  // FIFO full_o

    // SPI Mode select 
    input  wire                         cpol_i      ,
    input  wire                         cpoa_i      ,

    output wire                         sdo_o       ,  // PHY sdo
    output wire                         spi_bus_clk ,  // spi bus clock

    // Ctrl && Status
    input  wire [31                :0]  transmit_len_i  , // Length of bytes with once transmit
    input  wire                         tx_ctrl_st_i    , // Submit once transmit
    output wire                         tx_ctrl_eot_o   , // This task transmit done
    );

typedef enum bit [3:0] {
    SPI_TX_IDLE,
    SPI_TX_READY,
    SPI_TX_TRANSMIT,
    SPI_TX_EOT
    } tx_ctrl_fsm_cs, tx_ctrl_fsm_ns;

// Decalre inner register for stat length has been transmit
reg  [31            :0]                 length_send_cnt ;

// Read data from fifo 
reg   [SPI_TX_DWIDE-1:0]                rd_data_r       ;
reg                                     rd_en_r         ;

// Declare spi tx phy signals
reg   [SPI_TX_DWIDE-1:0]                tx_data_r       ;
reg                                     tx_vld_r        ;
wire                                    tx_eot          ;
wire  [SPI_TX_DWIDE-1:0]                tx_data         ;
wire                                    tx_vld          ;
wire                                    tx_rdy          ;

// TX-FSM status controll signals
wire                                    to_spi_tx_idle      ;
wire                                    to_spi_tx_ready     ;
wire                                    to_spi_tx_transmit  ;
wire                                    to_spi_tx_eot       ;

// assign fifo read signals
assign                                  rd_en_i = rd_en_r ;

// TX-FSM status transfer
always@(posedge clk_i or negedge rstn_i) begin
    if(!rstn_i) begin
        tx_ctrl_fsm_cs  <= #DLY SPI_TX_IDLE;
    end
    else begin
        tx_ctrl_fsm_cs  <= tx_ctrl_fsm_ns;
    end
end

// TX-FSM status jump
assign          to_spi_tx_ready    = (tx_ctrl_fsm_cs == SPI_TX_IDLE) && tx_ctrl_st_i && tx_rdy;
assign          to_spi_tx_transmit = (tx_ctrl_fsm_cs == SPI_TX_READY);
assign          to_spi_tx_eot      = (tx_ctrl_fsm_cs == SPI_TX_TRANSMIT) && (transmit_len_i ==  length_send_cnt);
assign          to_spi_tx_idle     = (tx_ctrl_fsm_cs == SPI_TX_EOT);

always@(ctrl_fsm_cs or to_ctrl_idle or to_spi_tx_transmit or to_spi_tx_eot ) begin
    case(ctrl_fsm_cs)
        // SPI tx ctrl idle status
        SPI_TX_IDLE:        begin
                                if(to_spi_tx_transmit) begin
                                    tx_ctrl_fsm_ns <= #DLY SPI_TX_TRANSMIT;
                                end
                                else begin
                                    tx_ctrl_fsm_ns <= #DLY SPI_TX_IDLE;
                                end
                            end

        // SPI tx ctrl ready data status
        SPI_TX_READY:       begin
                                if(to_spi_tx_ready) begin
                                    tx_ctrl_fsm_ns <= #DLY SPI_TX_TRANSMIT;
                                end
                                else begin
                                    tx_ctrl_fsm_ns <= #DLY SPI_TX_READY;
                                end
                            end

        // SPI tx Transmit status
        SPI_TX_TRANSMIT:    begin
                                if(to_spi_tx_eot) begin
                                    tx_ctrl_fsm_ns <= #DLY SPI_TX_EOT;
                                end
                                else begin
                                    tx_ctrl_fsm_ns <= #DLY SPI_TX_TRANSMIT;
                                end
                            end

        // SPI tx end of once transmit
        SPI_TX_EOT:         begin
                                if(to_spi_tx_transmit) begin
                                    tx_ctrl_fsm_ns <= #DLY SPI_TX_IDLE;
                                end
                                else begin
                                    tx_ctrl_fsm_ns <= #DLY SPI_TX_EOT;
                                end
                            end
    endcase
end

// TX-FSM output , read fifo data
always@(posedge clk_i or negedge rstn_i) begin
    if(!rstn_i) begin
        rd_en_r <= #DLY 1'b0;
    end
    else if(tx_ctrl_fsm_cs == SPI_TX_IDLE && tx_ctrl_fsm_ns == SPI_TX_READY) begin
        rd_en_r <= #DLY 1'b1;
    end
    else begin
        rd_en_r <= #DLY 1'b0;
    end
end

always@(posedge clk_i or negedge rstn_i) begin
    if(!rstn_i) begin
        rd_data_r  <= #DLY 'd0;
    end
    else if(tx_ctrl_fsm_cs == SPI_TX_READY && tx_ctrl_fsm_ns == SPI_TX_TRANSMIT) begin
        rd_data_r  <= #DLY rd_data_o;
    end
end

// TX-FSM output , call spi tx to transmit
always@(posedge clk_i or negedge rstn_i) begin
    if(!rstn_i) begin
        tx_vld_r <= #DLY 1'b0;
        tx_data_r <= #DLY 'd0;
    end
    else if(tx_ctrl_fsm_cs == SPI_TX_TRANSMIT && tx_ctrl_fsm_ns == SPI_TX_TRANSMIT) begin
        tx_vld_r <= #DLY 1'b0;
        tx_data_r <= #DLY tx_data_r;
    end
    else begin
        tx_vld_r <= #DLY 1'b0;
        tx_data_r <= #DLY 'd0;
    end
end

// TX-FSM output, transmit length sum

// Instance TX sync fifo
sync_fifo                       #(
    .DLY                        (DLY            ),
    .WIDTH                      (SPI_TX_DWIDE   ),
    .DEPTH                      (32             )
    )
    u_sync_fifo_tx_i
    (
    .clk_i                      (clk_i          ),
    .rst_n_i                    (rstn_i         ),
    .wdata_i                    (wdata_i        ),
    .wr_en_i                    (wr_en_i        ),
    .rdata_o                    (rdata_o        ),
    .rd_en_i                    (rd_en_i        ),
    .full_o                     (full_o         ),
    .empty_o                    (empty_o        ),
    .elements_o                 (elements_o     )
}

spi_tx                          #(
    .DLY                        (DLY            ),
    .SPI_TX_WIDTH               (SPI_TX_DWIDE   ),
    )(
    .clk                        (clk_i          ),
    .rstn                       (rstn_i         ),
    .cpol                       (cpol_i         ),
    .cpoa                       (cpoa_i         ),
    .length                     (VLD_LEN        ),
    .tx_data                    (tx_data        ),
    .tx_vld                     (tx_vld         ),
    .tx_rdy                     (tx_rdy         ),
    .tx_eot                     (tx_eot         ),
    .sdo                        (sdo            ),
    .spi_bus_clk                (spi_bus_clk    ),
    );

endmodule
