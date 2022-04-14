
module                              spi_tx #(
    parameter                       DLY         = 1,
    parameter                       DATA_LEN    = 32,
    parameter                       DATA_VLD    = $clog2(DATA_LEN),
    parameter                       FIFO_WIDTH  = DATA_LEN + DATA_VLD
    )(
    input  wire                     clk_i       ,  // spi controller clock.
    input  wire                     rst_n_i     ,  // reset
    input  wire                     cpol        ,  // 0, clock keep low state ; 1 , clock keep high state , when bus idle
    input  wire                     cpoa        ,  // 0, first edge DAQ, 1, second edge DAQ
    input  wire [FIFO_WIDTH-1:0]    tx_data_i   ,  // data from up level, will push to fifo
    input  wire                     tx_vld_i    ,  // data valid 
    output wire                     tx_rdy_o    ,  // invert fifo full
    input  wire                     bit_en      ,  // bit enable, from clock gen.
    output wire                     clk_en      ,  // start generate bus clock
    output wire                     sdo
    );

// declare fifo wire
wire [FIFO_WIDTH-1   :0]            wdata_i     ;
wire                                wr_en_i     ;
wire                                full_o      ;
wire                                empty_o     ;
wire                                rd_en_i     ;
wire                                rdata_o     ;
wire                                elements_o  ;

// define fsm register  
reg  [2                :0]          spi_tx_flow_fsm     ;
reg                                 spi_tx_start        ;
reg  [DATA_VLD-1       :0]          spi_tfr_cnt         ;
reg                                 sdo_buf_r           ;

wire                                go_idle             ;
wire                                go_tfr              ;
wire                                go_stop             ;

localparam                          IDLE     = 3'b001     ;
localparam                          TFR      = 3'b010     ;
localparam                          STOP     = 3'b100     ;

// FIFO link with IF
assign                              wdata_i  = tx_data_i ;
assign                              wr_en_i  = tx_vld_i  ;
assign                              tx_rdy_o = ~full_o   ;

assign                              go_tfr   = ((spi_tx_flow_fsm            == IDLE) && spi_tx_start);
assign                              go_stop  = ((spi_tx_flow_fsm            == TFR ) && bit_en && (spi_tfr_cnt == rdata_o[37:32]));
assign                              go_idle  = ((spi_tx_flow_fsm            == STOP) && bit_en);
assign                              clk_en   = spi_tx_start;

assign                              rd_en_i  = (!empty_o && spi_tx_flow_fsm == IDLE);


// FSM jump
always@(posedge clk_i or negedge rst_n_i) begin
    if(!rst_n_i) begin
        spi_tx_flow_fsm <= #DLY IDLE ;
    end else begin
        case(spi_tx_flow_fsm)
            IDLE:               begin
                                    if(go_tfr) begin
                                        spi_tx_flow_fsm <= #DLY TFR;
                                    end
                                    else begin
                                        spi_tx_flow_fsm <= #DLY IDLE;
                                    end
                                end
            TFR:                begin
                                    if(go_stop) begin
                                        spi_tx_flow_fsm <= #DLY STOP;
                                    end
                                    else begin
                                        spi_tx_flow_fsm <= #DLY TFR;
                                    end
                                end
            STOP:               begin
                                    if(go_idle) begin
                                        spi_tx_flow_fsm <= #DLY IDLE;
                                    end
                                    else begin
                                        spi_tx_flow_fsm <= #DLY STOP;
                                    end
                                end
        endcase
    end
end

// Just do cpol == 0 and cpoa == 0
generate 
    if(cpol == 0 && cpoa == 0) begin : SPI_MODE_0
        // generate start 
        always@(posedge clk_i or negedge rst_n_i) begin
            if(!rst_n_i) begin
                spi_tx_start <= #DLY 1'b0;
            end
            else if(rd_en_i) begin
                spi_tx_start <= #DLY 1'b1;
            end
            else begin
                spi_tx_start <= #DLY 1'b0;
            end
        end

        always@(posedge clk_i or negedge rst_n_i) begin
            if(!rst_n_i) begin
                spi_tfr_cnt <= #DLY {DATA_VLD{1'b0}};
            end
            else if(spi_tx_flow_fsm == TFR && bit_en) begin
                spi_tfr_cnt <= #DLY spi_tfr_cnt + 'd1;
            end
            else begin
                spi_tfr_cnt <= #DLY {DATA_VLD{1'b0}};
            end
        end

        always@(posedge clk_i or negedge rst_n_i) begin
            if(!rst_n_i) begin
                sdo_buf_r <= #DLY 1'b0;
            end
            else if(spi_tx_flow_fsm == TFR && bit_en) begin
                sdo_buf_r <= rdata_o[spi_tfr_cnt];
            end
        end

    end
    else if(cpol == 0 && cpoa == 1) begin : SPI_MODE_1
    end
    else if(cpol == 1 && cpoa == 0) begin : SPI_MODE_2
    end
    else if(cpol == 1 && cpoa == 1) begin : SPI_MODE_3
    end

endgenerate

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
