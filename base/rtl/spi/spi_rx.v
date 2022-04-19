
module                              spi_rx #(
    parameter                       DLY              = 1,
    parameter                       SPI_RX_WIDTH     = 32,
    parameter                       LENGTH_RECEIVE   = $clog2(SPI_RX_WIDTH)
    )(
    // Input primay clock and reset
    input  wire                         clk             ,    // Primary clock
    input  wire                         rstn            ,    // System reset
    // SPI Mode configure
    input  wire                         cpol            ,    // Mode : [CPOL:CPOA]
    input  wire                         cpoa            ,    // Mode : [CPOL:CPOA]

    // SPI data with up level
    input  wire                         rx_rdy          ,    // Ready to recv data from spi_rx
    input  wire [LENGTH_RECEIVE-1   :0] length     ,
    output wire [SPI_RX_WIDTH-1     :0] rx_rdata        ,    // Parallel output data recvfrom MOSI
    output wire                         rx_vld          ,    // Data valid indicate

    // SPI Physical link
    input  wire                         spi_bus_clk     ,    // SPI bus clock
    input  wire                         sdi             ,    // SDI or MISO 

    // SPI Status indicate
    output wire                         rx_interrupt         // Recv interrupt with length
    );

// Detect wire
wire                                    spi_bus_pedge   ;

// Declare output signal
reg  [SPI_RX_WIDTH-1  :0]               rx_data_obuf        ;
reg                                     rx_vld_obuf         ;
reg                                     rx_interrupt_obuf   ;

// Declare receive counter
reg  [LENGTH_RECEIVE-1:0]               length_cnt     ;
// FSM register
reg  [1               :0]               rx_fsm_cs       ;    // Current state
reg  [1               :0]               rx_fsm_ns       ;    // Next state

// FSM jum singal
wire                                    to_rx_receive   ;
wire                                    to_rx_waiting   ;
// FSM status description
localparam                              RX_WAITING    = 2'b01;
localparam                              RX_RECEIVING  = 2'b10;

// sdi ibuf
reg                                     spi_clk_ibuf    ;

// sdi buffer
always@(posedge clk or negedge rstn) begin
    if(!rstn) begin
        spi_clk_ibuf  <= #DLY 'd0;
    end
    else begin
        spi_clk_ibuf  <= #DLY spi_bus_clk;
    end
end

assign      spi_bus_pedge = (spi_bus_clk && !spi_clk_ibuf);

// FSM controll signal
assign      to_rx_receive = spi_bus_pedge ;
assign      to_rx_waiting = (rx_fsm_cs == RX_RECEIVING && (length_cnt == length));

// FSM-Shift
always@(posedge clk or negedge rstn) begin
    if(!rstn) begin
        rx_fsm_cs <= #DLY RX_WAITING;
    end
    else begin
        rx_fsm_cs <= #DLY rx_fsm_ns;
    end
end

// FSM-Jump
always@(rx_fsm_cs) begin
    case(rx_fsm_cs)
        RX_WAITING:         begin
                                if(to_rx_receive) begin
                                    rx_fsm_ns  <= #DLY RX_RECEIVING;
                                end
                                else begin
                                    rx_fsm_ns  <= #DLY RX_WAITING;
                                end
                            end
        RX_RECEIVING:       begin
                                if(to_rx_waiting) begin
                                    rx_fsm_ns  <= #DLY RX_WAITING;
                                end
                                else begin
                                    rx_fsm_ns  <= #DLY RX_RECEIVING;
                                end
                            end
        default:            begin
                                rx_fsm_ns  <= #DLY RX_WAITING;
                            end
    endcase
end

// FSM-Output receive cnt
always@(posedge clk or negedge rstn) begin
    if(!rstn) begin
        length_cnt  <= #DLY 'd0;
    end
    else if(spi_bus_pedge) begin
        length_cnt  <= #DLY 'd1 + length_cnt;
    end
    else if(rx_vld_obuf) begin
        length_cnt  <= #DLY 'd0;
    end
end

// FSM-Output rx vld 
always@(posedge clk or negedge rstn) begin
    if(!rstn) begin
        rx_vld_obuf  <= #DLY 'd0;
    end
    else if(length == length_cnt) begin
        rx_vld_obuf  <= #DLY 'd1;
    end
    else begin
        rx_vld_obuf  <= #DLY 'd0;
    end
end

// FSM-Output rx data
always@(posedge clk or negedge rstn) begin
    if(!rstn) begin
        rx_data_obuf  <= #DLY 'd0;
    end
    else if(spi_bus_pedge) begin
        rx_data_obuf  <= #DLY {sdi, rx_data_obuf[SPI_RX_WIDTH-1:1]};
    end
    else if(rx_vld_obuf) begin
        rx_data_obuf  <= #DLY 'd0;
    end
end

// FSM-Output rx interrupt
always@(posedge clk or negedge rstn) begin
    if(!rstn) begin
        rx_interrupt_obuf  <= #DLY 'd0;
    end
    else if(length == length_cnt) begin
        rx_interrupt_obuf  <= #DLY 'd1;
    end
    else begin
        rx_interrupt_obuf <= #DLY 'd0;
    end
end

endmodule
