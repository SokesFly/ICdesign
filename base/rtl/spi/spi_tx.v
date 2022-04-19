
module                                  spi_tx #(
    parameter                           DLY                 = 1,
    parameter                           SPI_TX_WIDTH        = 32,           // SPI tx transimit width.
    parameter                           LENGTH_TRANSMIT     = $clog2(32)    // Length of data will be send.
    )(
    // Input clock & reset
    input  wire                         clk         ,   // Primary clock
    input  wire                         rstn        ,   // System reset

    // SPI mode select
    input  wire                         cpol        ,   // Mode :[CPOL:CPOA]
    input  wire                         cpoa        ,   // Mode :[CPOL:CPOA]

    // SPI Tx data input interface
    input  wire [LENGTH_TRANSMIT-1  :0] length      ,    // Length of data valid
    input  wire [SPI_TX_WIDTH-1     :0] tx_data     ,    // Data will be sennd to sdo
    input  wire                         tx_vld      ,    // This just keep one primary clock cycle
    output wire                         tx_rdy      ,    // Output 1, when flow fsm be WATING

    // SPI status output
    output wire                         tx_eot      ,    // Once done of transimit, output 1, when cnt eq length

    // SPI physical-link
    output wire                         sdo         ,    // SPI MOSI or SDO
    output wire                         spi_bus_clk      // SPI BUS clock
    );

reg [LENGTH_TRANSMIT-1  :0] length_cnt      ;   // Transmit length

// SPI Tx
wire                        ritmo           ;   // SPI bus's ritmo in primary clock domain
wire                        ritmo_half      ;   // SPI bus's ritmo in primary clock domain
wire                        bus_clock_req   ;   // Generate spi clock from clk_en is high
wire                        clock_gen_bit   ;

// SPI physical output buf
reg                         sdo_obuf        ;

// Tx flow FSM register
reg [1:0]                   tx_fsm_cs ;
reg [1:0]                   tx_fsm_ns ;

// SPI send data buffer
reg [SPI_TX_WIDTH-1     :0] sdo_buf   ;
// FSM Jump control singal
reg                         wait_state    ;
wire                        transmit_state;
// FSM status 
localparam                  TX_WAITING      = 2'b01;
localparam                  TX_TRANSMITING  = 2'b10;

// FSM ctrl 
assign                      transmit_state = tx_vld ;
always@(posedge clk or negedge rstn) begin
    if(!rstn) begin
        sdo_buf <= #DLY 'd0;
    end
    else if(tx_vld && tx_fsm_cs == TX_WAITING) begin
        sdo_buf  <= #DLY tx_data;
    end
end

always@(posedge clk or negedge rstn) begin
    if(!rstn) begin
        wait_state <= #DLY 'd0;
    end
    else if((length_cnt == length) && (length_cnt != 0) && tx_fsm_cs == TX_TRANSMITING) begin
        wait_state <= #DLY 'd1;
    end
    else begin
        wait_state <= #DLY 'd0;
    end
end

// FSM-Shift
always@(posedge clk or negedge rstn) begin
    if(!rstn) begin
        tx_fsm_cs <= #DLY TX_WAITING;
    end
    else begin
        tx_fsm_cs <= #DLY tx_fsm_ns;
    end
end

// FSM-Jump
// input list sync with clk
always@(tx_fsm_cs or transmit_state or wait_state) begin
    case(tx_fsm_cs)
        // waiting data coming
        TX_WAITING:         begin
                                if(transmit_state) begin
                                    tx_fsm_ns <= #DLY TX_TRANSMITING;
                                end
                                else begin
                                    tx_fsm_ns <= #DLY TX_WAITING;
                                end
                            end
        // spi data transmit
        TX_TRANSMITING:     begin
                                if(wait_state) begin
                                    tx_fsm_ns <= #DLY TX_WAITING;
                                end
                                else begin
                                    tx_fsm_ns <= #DLY TX_TRANSMITING;
                                end
                            end
        default:            begin
                                tx_fsm_ns <= #DLY TX_WAITING;
                            end
    endcase
end

// FSM-Output, Moore FSM

// Output spi_rdy
assign      tx_rdy = (tx_fsm_cs == TX_WAITING && tx_fsm_ns == TX_WAITING);

// Output tx_ext
assign      tx_eot  = (tx_fsm_cs == TX_TRANSMITING && tx_fsm_ns == TX_WAITING);

// Output bus_clock_req
assign      bus_clock_req = (tx_fsm_cs == TX_TRANSMITING) && (tx_fsm_ns != TX_WAITING);
assign      clock_gen_bit = (tx_fsm_cs == TX_TRANSMITING) && (tx_fsm_ns != TX_WAITING);

// Output cnt
always@(posedge clk or negedge rstn) begin
    if(!rstn) begin
        length_cnt  <= #DLY 'd0;
    end
    else if(tx_fsm_cs == TX_TRANSMITING && tx_fsm_ns != TX_WAITING && ritmo) begin
        length_cnt  <=  #DLY 'd1 + length_cnt;
    end
    else if(tx_fsm_cs == TX_WAITING) begin
        length_cnt  <= #DLY 'd0;
    end
end

// FSM-Output sdo
always@(posedge clk or negedge rstn) begin
    if(!rstn) begin
        sdo_obuf  <= #DLY 1'b0;
    end
    else if(tx_fsm_cs == TX_TRANSMITING && ritmo) begin
        sdo_obuf  <= #DLY sdo_buf[length_cnt];  // LSB
    end
end

assign          sdo = sdo_obuf ;

clock_bit_gen           #(
    .DLY                (DLY            ),
    .WIDTH              (8              )
    )
    u_clock_bit_gen_i
    (
    .clk_i              (clk            ),
    .rstn_i             (clock_gen_bit  ),
    .period             (10             ),
    .bit_en             (ritmo          ),
    .bit_half_en        (ritmo_half     )
    );

clock_div               #(
    .DLY                (DLY            ),
    .WIDTH              (4              )
    )(
    .clk_i              (clk            ),
    .rst_n_i            (rstn           ),
    .gen                (bus_clock_req  ),
    .period             (10             ),
    .clk_o              (spi_bus_clk    )
    );

endmodule
