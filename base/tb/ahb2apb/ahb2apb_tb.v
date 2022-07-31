`default_nettype wire
// Declare AHB bus transfer type.
`define   AHB_HTRANS_IDLE    2'b00
`define   AHB_HTRANS_BUSY    2'b01
`define   AHB_HTRANS_NONSEQ  2'b10
`define   AHB_HTRANS_SEQ     2'b11

// Declare AHB bus burst transfer type.
`define   AHB_HBURST_SINGLE  3'b000
`define   AHB_HBURST_INCR    3'b001
`define   AHB_HBURST_WRAP4   3'b010
`define   AHB_HBURST_INCR4   3'b011
`define   AHB_HBURST_WRAP8   3'b100
`define   AHB_HBURST_INCR8   3'b101
`define   AHB_HBURST_WRAP16  3'b110
`define   AHB_HBURST_INCR16  3'b111

module                  ahb2apb_tb();

parameter               ADDR_WIDTH      = 32;
parameter               HBURST_WIDTH    = 3;
parameter               HPROT_WIDTH     = 4;
parameter               DATA_WIDTH      = 32;

// counter for record AHB transfer times
reg  [15            :0] transfer_times  ;

// clock
reg                     clk             ;
reg                     reset_async     ;
wire                    reset           ;

// AHB dut signals 
reg  [ADDR_WIDTH-1  :0] haddr_i         ;
reg  [HBURST_WIDTH-1:0] hburst_i        ;
reg                     hmastlock_i     ;
reg                     hsel_i          ;
reg  [HPROT_WIDTH-1 :0] hprot_i         ;
reg  [2             :0] hsize_i         ;
reg                     hnonsec_i       ;
reg                     hexcl_i         ;
reg  [1             :0] htrans_i        ;
reg                     hmaster_i       ;
reg  [DATA_WIDTH-1  :0] hwdata_i        ;
reg  [DATA_WIDTH/8-1:0] hwstrb_i        ;
reg                     hwrite_i        ;
wire [DATA_WIDTH-1  :0] hrdata_o        ;
wire                    hready_o        ;
wire                    hreadyout_o     ;
wire                    hresp_o         ;
wire                    hexokay_o       ;

// APB interface signals declare
wire [ADDR_WIDTH-1  :0] paddr_o         ;
wire                    psel_o          ;
wire                    penabe_o        ;
wire [DATA_WIDTH-1  :0] pwdata_o        ;
reg  [DATA_WIDTH-1  :0] prdata_i        ;
reg                     pready_i        ;

// AHB starting control
reg                     ahb_trans_start     ;
reg                     transmit_complete   ;
reg                     transmit_is_single  ;
wire                    go_ahb_idle         ;
wire                    go_ahb_start        ;
wire                    go_ahb_transmit     ;
wire                    go_ahb_end          ;

// AHB ending control signals declare
reg [15             :0] transmited_tgt      ;
reg [15             :0] transmited_cnt      ;

// wrap calulate signals declare
reg  [ADDR_WIDTH-1  :0] wrap_width          ;
reg  [ADDR_WIDTH-1  :0] addr_single         ;
reg  [ADDR_WIDTH-1  :0] wrap_addr_start     ;
reg  [ADDR_WIDTH-1  :0] wrap_addr_end       ;
reg  [ADDR_WIDTH-1  :0] down_half           ;
reg  [ADDR_WIDTH-1  :0] upper_half          ;
reg  [ADDR_WIDTH-1  :0] wrap_upper_offset   ;
reg  [ADDR_WIDTH-1  :0] wrap_down_offset    ;

reg  [3             :0] wrap_step           ;
reg  [3             :0] wrap_step_cnt       ;

enum {AHB_IDLE='d0, AHB_START, AHB_TRANSMIT, AHB_END} ahbfsm_trans_reg, ahbfsm_trans_next;

// generate clock and reset
initial begin
    clk     =  1'b0;
    forever begin
        clk = #20 1'b1;
        clk = #20 1'b0;
    end
end

initial begin
    reset_async = 1'b1;
    #103
    reset_async = 1'b0;
    #100
    reset_async = 1'b1;
end

initial begin
    wait(transfer_times == 16'h000F) begin
        $finish;
    end
end

// Verdi Dump
initial begin
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars(0, "ahb2apb_tb");
    $fsdbDumpMDA(0, "ahb2apb_tb");
end

// generate ahb transfer start signal
always@(posedge clk or negedge reset)
begin
    if(!reset) begin
        ahb_trans_start <= 1'b0;
    end
    else if(hready_o) begin
        ahb_trans_start <= 1'b1;
    end
    else begin
        ahb_trans_start <= 1'b1;
    end
end

always@(posedge clk or negedge reset)
begin
    if(!reset) begin
        transfer_times <= 16'h00;
    end
    else if(ahbfsm_trans_reg == AHB_END) begin
        transfer_times <= transfer_times + 16'h01;
    end
end

assign              go_ahb_start       = ((ahbfsm_trans_reg == AHB_IDLE     ) && ahb_trans_start) ||
                                         ((ahbfsm_trans_reg == AHB_END      ) && ahb_trans_start && hready_o) ||
                                         ((ahbfsm_trans_reg == AHB_START    ) && transmit_is_single && hready_o);
assign              go_ahb_transmit    = (ahbfsm_trans_reg == AHB_START     ) && hready_o && (!transmit_is_single);
assign              go_ahb_end         = (ahbfsm_trans_reg == AHB_TRANSMIT  ) && hready_o && transmit_complete;
assign              go_ahb_idle        = (ahbfsm_trans_reg == AHB_END       ) && (!ahb_trans_start);

always@(*)
begin
    if(!reset) begin
        transmit_is_single <= 1'b0;
    end
    else if(ahbfsm_trans_reg == AHB_START && hburst_i == `AHB_HBURST_SINGLE) begin
        transmit_is_single <= 1'b1;
    end
    else begin
        transmit_is_single <= 1'b0;
    end
end

always@(posedge clk or negedge reset)
begin
    if(!reset) begin
        ahbfsm_trans_reg <= AHB_IDLE;
    end
    else begin
        ahbfsm_trans_reg <= ahbfsm_trans_next;
    end
end

always@(*)
begin
    if(!reset) begin
        ahbfsm_trans_next <= AHB_IDLE;
    end
    else begin
        case(ahbfsm_trans_reg)
            AHB_IDLE:           begin
                                    if(go_ahb_start) begin
                                        ahbfsm_trans_next <= AHB_START;
                                    end
                                    else begin
                                        ahbfsm_trans_next <= AHB_IDLE;
                                    end
                                end

            AHB_START:          begin
                                    if(go_ahb_transmit) begin
                                        ahbfsm_trans_next <= AHB_TRANSMIT;
                                    end
                                    else if(go_ahb_start) begin
                                        ahbfsm_trans_next <= AHB_START;
                                    end
                                    else begin
                                        ahbfsm_trans_next <= AHB_START;
                                    end
                                end

            AHB_TRANSMIT:       begin
                                    if(go_ahb_end) begin
                                        ahbfsm_trans_next <= AHB_END;
                                    end
                                    else begin
                                        ahbfsm_trans_next <= AHB_TRANSMIT;
                                    end
                                end

            AHB_END:            begin
                                    if(go_ahb_idle) begin
                                        ahbfsm_trans_next <= AHB_TRANSMIT;
                                    end
                                    else if(go_ahb_start) begin
                                        ahbfsm_trans_next <= AHB_START;
                                    end
                                    else begin
                                        ahbfsm_trans_next <= AHB_END;
                                    end
                                end

            default:            begin ahbfsm_trans_next <= AHB_IDLE; end
        endcase
    end
end

// AHB fsm output signal: hsize_i
always@(posedge clk or negedge reset)
begin
    if(!reset) begin
        hsize_i <= 'd0;
    end
    else if(ahbfsm_trans_next == AHB_START && ahbfsm_trans_reg != AHB_START ) begin
        hsize_i <= {$random} % 8;
    end
end

// wraping address calulate
always@(*)
begin
    if(!reset) begin
        addr_single <= 'd0;
    end
    else if(ahbfsm_trans_next == AHB_START) begin
        addr_single <= (1 << ( hsize_i + 3) >> 3);
    end
    else begin
        addr_single <= addr_single; // Avoid generate latch.
    end
end

always@(hsize_i or hburst_i or addr_single)
begin
    case(hburst_i)
        `AHB_HBURST_WRAP4:      begin
                                    wrap_width     <= (addr_single << 2);
                                end
        `AHB_HBURST_WRAP8:      begin
                                    wrap_width     <= (addr_single << 3);
                                end
        `AHB_HBURST_WRAP16:     begin
                                    wrap_width     <= (addr_single << 4);
                                end
        default:                begin
                                    wrap_width     <= 32'h0000_0000;
                                end
    endcase
end

always@(*)
begin
    if(!reset) begin
        wrap_step <= 4'h0;
    end
    else if(ahbfsm_trans_next == AHB_START) begin
        case(hburst_i)
        `AHB_HBURST_WRAP4:      begin
                                    wrap_step <= 4'h4;
                                end
        `AHB_HBURST_WRAP8:      begin
                                    wrap_step <= 4'h8;
                                end
        `AHB_HBURST_WRAP16:     begin
                                    wrap_step <= 4'hF;
                                end
        default:                begin
                                    wrap_step <= 4'h0;
                                end
        endcase
    end
    else begin
        wrap_step <= wrap_step ;
    end
end


// AHB fsm output signal: haddr_i
always@(posedge clk or negedge reset)
begin
    if(!reset) begin
        haddr_i <= 'd0;
    end
    else if(ahbfsm_trans_next == AHB_START && hready_o) begin
        haddr_i <= ({$random} % 16'h0F) * 4;
    end
    else if((ahbfsm_trans_next == AHB_TRANSMIT || ahbfsm_trans_next == AHB_END) && hready_o) begin
        case(hburst_i)
            `AHB_HBURST_SINGLE: begin
                                    haddr_i  <= haddr_i + addr_single;
                                end
            `AHB_HBURST_INCR:   begin
                                    haddr_i  <= haddr_i + addr_single;
                                end
            `AHB_HBURST_INCR4:  begin
                                    haddr_i  <= haddr_i + addr_single;
                                end
            `AHB_HBURST_WRAP4:  begin
                                    if(upper_half - addr_single <= wrap_upper_offset) begin
                                        haddr_i  <= wrap_addr_start + wrap_down_offset;
                                    end
                                    else begin
                                        haddr_i  <= haddr_i + addr_single;
                                    end
                                end
            `AHB_HBURST_INCR8:  begin
                                    haddr_i  <= haddr_i + addr_single;
                                end
            `AHB_HBURST_WRAP8:  begin
                                    if(upper_half - addr_single <= wrap_upper_offset) begin
                                        haddr_i  <= wrap_addr_start + wrap_down_offset;
                                    end
                                    else begin
                                        haddr_i  <= haddr_i + addr_single;
                                    end
                                end
            `AHB_HBURST_INCR16: begin
                                    haddr_i  <= haddr_i + addr_single;
                                end
            `AHB_HBURST_WRAP16: begin
                                    if(upper_half - addr_single <= wrap_upper_offset) begin
                                        haddr_i  <= wrap_addr_start + wrap_down_offset;
                                    end
                                    else begin
                                        haddr_i  <= haddr_i + addr_single;
                                    end
                                end
            default:            begin haddr_i <= 'd0; end
        endcase
    end
end

// AHB fsm output signal: hburst_i
always@(posedge clk or negedge reset)
begin
    if(!reset) begin
        hburst_i <= 'd0;
    end
    else if(ahbfsm_trans_next == AHB_START && ahbfsm_trans_reg != AHB_START) begin
        hburst_i <= {$random} % 8;
    end
end

// AHB fsm output signal: hsel_i
always@(posedge clk or negedge reset)
begin
    if(!reset) begin
        hsel_i <= 1'b0;
    end
    else if(ahbfsm_trans_next == AHB_START || ahbfsm_trans_next == AHB_TRANSMIT || ahbfsm_trans_next == AHB_END) begin
        hsel_i <= 1'b1;
    end
end

always@(posedge clk or negedge reset)
begin
    if(!reset) begin
        hwrite_i <= 1'b0;
    end
    else if(ahbfsm_trans_next == AHB_START) begin
        hwrite_i <= {$random} % 2;
    end
end

// AHB fsm output signal: htrans_i
always@(posedge clk or negedge reset)
begin
    if(!reset) begin
        htrans_i <= `AHB_HTRANS_IDLE;
    end
    else if(ahbfsm_trans_next == AHB_START) begin
        htrans_i <= `AHB_HTRANS_NONSEQ;
    end
    else if(ahbfsm_trans_next == AHB_TRANSMIT || ahbfsm_trans_next == AHB_END) begin
        htrans_i <= `AHB_HTRANS_SEQ;
    end
end

// AHB fsm output signal: transmited_cnt
always@(posedge clk or negedge reset)
begin
    if(!reset) begin
        transmited_cnt <= 16'h00;
    end
    else if(ahbfsm_trans_next == AHB_IDLE || transmit_complete || transmit_is_single) begin
        transmited_cnt <= 16'h00;
    end
    else if((ahbfsm_trans_next == AHB_START || ahbfsm_trans_next == AHB_TRANSMIT) && hready_o) begin
        transmited_cnt <=  transmited_cnt + 16'h01;
    end
end

// AHB fsm output signal: transmit_complete
always@(posedge clk or negedge reset)
begin
    if(!reset) begin
        transmit_complete <= 1'b0;
    end
    else if(transmit_complete) begin
        transmit_complete <= 1'b0;
    end
    else if(transmited_tgt - 2 == transmited_cnt) begin
        transmit_complete <= 1'b1;
    end
end

// AHB fsm output signal: hwdata_i
always@(posedge clk or negedge reset)
begin
    if(!reset) begin
        hwdata_i <= 'd0;
    end
    else if(ahbfsm_trans_next == AHB_START && hready_o && hwrite_i) begin
        hwdata_i <= {$random};
    end if((ahbfsm_trans_next == AHB_TRANSMIT || ahbfsm_trans_next == AHB_END) && hready_o && hwrite_i) begin
        hwdata_i <= {$random};
    end
end


// AHB fsm output signal: transmit target
always@(posedge clk or negedge reset)
begin
    if(!reset) begin
        transmited_tgt <= 16'h00;
    end
    else if(ahbfsm_trans_reg == AHB_START) begin
        case(hburst_i)
            `AHB_HBURST_SINGLE:     begin
                                        transmited_tgt <= 16'h01;
                                    end
            `AHB_HBURST_INCR:       begin
                                        transmited_tgt <= 16'h10;
                                    end
            `AHB_HBURST_WRAP4:      begin
                                        transmited_tgt <= 16'h04;
                                    end
            `AHB_HBURST_INCR4:      begin
                                        transmited_tgt <= 16'h04;
                                    end
            `AHB_HBURST_WRAP8:      begin
                                        transmited_tgt <= 16'h08;
                                    end
            `AHB_HBURST_INCR8:       begin
                                        transmited_tgt <= 16'h08;
                                    end
            `AHB_HBURST_WRAP16:     begin
                                        transmited_tgt <= 16'h10;
                                    end
            `AHB_HBURST_INCR16:     begin
                                        transmited_tgt <= 16'h10;
                                    end
            default:                begin
                                        transmited_tgt <= 16'hFF;
                                    end
        endcase
    end
end

assign                              pready_i    = 1'b1;

ahb2apb           #(
    .ADDR_WIDTH   (ADDR_WIDTH  ),
    .HBURST_WIDTH (HBURST_WIDTH),
    .HPROT_WIDTH  (HPROT_WIDTH ),
    .DATA_WIDTH   (DATA_WIDTH  )
    )
    ahb2apb_i
    (
    // AHB signals
    .hclk_i      (clk        ),
    .hresetn_i   (reset      ),

    .haddr_i     (haddr_i    ),
    .hburst_i    (hburst_i   ),
    .hmastlock_i (hmastlock_i),
    .hsel_i      (hsel_i     ),
    .hprot_i     (hprot_i    ),
    .hsize_i     (hsize_i    ),
    .hnonsec_i   (hnonsec_i  ),
    .hexcl_i     (hexcl_i    ),
    .hmaster_i   (hmaster_i  ),
    .htrans_i    (htrans_i   ),
    .hwdata_i    (hwdata_i   ),
    .hwstrb_i    (hwstrb_i   ),
    .hwrite_i    (hwrite_i   ),
    .hrdata_o    (hrdata_o   ),
    .hready_o    (hready_o   ),
    .hreadyout_o (hreadyout_o),
    .hresp_o     (hresp_o    ),
    .hexokay_o   (hexokay_o  ),

    // APB signals
    .pclk_i      (clk        ),
    .presetn_i   (reset      ),

    .paddr_o     (paddr_o    ),
    .psel_o      (psel_o     ),
    .penabe_o    (penabe_o   ),
    .pwdata_o    (pwdata_o   ),
    .prdata_i    (prdata_i   ),
    .pready_i    (pready_i   )
    );


reset_syncer    reset_syncer_i(
    .clk_i          (clk           ),
    .rst_n_sync_i   (reset_async   ),
    .rst_n_synced_o (reset         )
    );


endmodule
