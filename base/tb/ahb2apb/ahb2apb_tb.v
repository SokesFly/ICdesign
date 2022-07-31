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


// AHB master fsm
reg  [ADDR_WIDTH-1  :0] haddr_wrap_fixed;
reg  [ADDR_WIDTH-1  :0] wrap_width      ;
reg  [ADDR_WIDTH-1  :0] wrap_single     ;
wire [ADDR_WIDTH-1  :0] addr_single     ;
wire [ADDR_WIDTH-1  :0] wrap_addr_start ;
wire [ADDR_WIDTH-1  :0] wrap_addr_end   ;
wire [ADDR_WIDTH-1  :0] down_half       ;
wire [ADDR_WIDTH-1  :0] upper_half      ;
reg  [ADDR_WIDTH-1  :0] wrap_upper_offset     ;
reg  [ADDR_WIDTH-1  :0] wrap_down_offset      ;
reg  [3             :0] wrap_step       ;
reg  [3             :0] wrap_step_cnt   ;

reg                     ending_of_trans     ;
reg                     ahb_trans_last_flag ;

enum    {AHB_IDLE='d0, AHB_ADDR_PHASE, AHB_DATA_PHASE} ahbfsm_reg, ahbfsm_next;
enum    {AHB_TRANS_IDLE='d0, AHB_TRANS_FIRST, AHB_TRANS_MIDDLE, AHB_TRANS_LAST} ahbfsm_trans_reg,ahbfsm_trans_next;
enum    {APB_IDLE='d0, APB_SETUP, APB_ACCESS} apbfsm_reg, apbfsm_next;

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

// Wait signal to ending the simulation
initial begin
    wait(transfer_times == 16'h0F) begin
        $finish;
    end
end

always@(posedge clk or negedge reset)
begin
    if(!reset) begin
        transfer_times = 16'h00;
    end
    else if(ending_of_trans) begin
        transfer_times <= transfer_times + 16'h01;
    end
end

// Verdi Dump
initial begin
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars(0, "ahb2apb_tb");
    $fsdbDumpMDA(0, "ahb2apb_tb");
end

// AHB trasnfer type fsm state jump
always@(posedge clk or negedge reset)
begin
    if(!reset) begin
        ahbfsm_trans_reg    <= AHB_TRANS_IDLE;
    end
    else begin
        ahbfsm_trans_reg    <= ahbfsm_trans_next;
    end
end

// AHB transfer type fsm state control
always@(*)
begin
    if(!reset) begin
        ahbfsm_trans_next    <= AHB_TRANS_IDLE;
    end
    else begin
        case(ahbfsm_trans_reg)
            AHB_TRANS_IDLE:         begin
                                        if(ahbfsm_next == AHB_ADDR_PHASE) begin
                                            ahbfsm_trans_next <= AHB_TRANS_FIRST;
                                        end
                                        else begin
                                            ahbfsm_trans_next <= AHB_TRANS_IDLE;
                                        end
                                    end
            AHB_TRANS_FIRST:        begin
                                        if(hready_o) begin
                                            ahbfsm_trans_next <= AHB_TRANS_MIDDLE;
                                        end
                                        else begin
                                            ahbfsm_trans_next <= AHB_TRANS_FIRST;
                                        end
                                    end

            AHB_TRANS_MIDDLE:       begin
                                        if(ahbfsm_next == AHB_ADDR_PHASE && hready_o && ahb_trans_last_flag) begin
                                            ahbfsm_trans_next <= AHB_TRANS_LAST;
                                        end
                                        else begin
                                            ahbfsm_trans_next <= AHB_TRANS_MIDDLE;
                                        end
                                    end

            AHB_TRANS_LAST:         begin
                                        if(ahbfsm_next == AHB_ADDR_PHASE && hready_o) begin
                                            ahbfsm_trans_next <= AHB_TRANS_FIRST;
                                        end
                                        else begin
                                            ahbfsm_trans_next <= AHB_TRANS_LAST;
                                        end
                                    end
            default:                begin
                                        ahbfsm_trans_next <= AHB_TRANS_IDLE;
                                    end
        endcase
    end
end

// AHB fsm state transfer
always@(posedge clk or negedge reset)
begin
    if(!reset) begin
        ahbfsm_reg <= AHB_IDLE;
    end
    else begin
        ahbfsm_reg <= ahbfsm_next;
    end
end

// AHB fsm stat jump
always@(*)
begin
    if(!reset) begin
        ahbfsm_next <= AHB_IDLE;
    end
    else begin
        case(ahbfsm_reg)
            AHB_IDLE:               begin
                                        if(transfer_times != 16'h0F && hready_o) begin
                                            ahbfsm_next <= AHB_ADDR_PHASE;
                                        end
                                        else begin
                                            ahbfsm_next <= AHB_IDLE;
                                        end
                                    end
            AHB_ADDR_PHASE:         begin
                                        if(hready_o) begin
                                            ahbfsm_next <= AHB_DATA_PHASE;
                                        end
                                        else begin
                                            ahbfsm_next <= AHB_ADDR_PHASE;
                                        end
                                    end
            AHB_DATA_PHASE:         begin
                                        if(hready_o && ending_of_trans) begin
                                            ahbfsm_next <= AHB_IDLE;
                                        end
                                        else if(hready_o && !ending_of_trans) begin
                                            ahbfsm_next <= AHB_ADDR_PHASE;
                                        end
                                        else if(!hready_o) begin
                                            ahbfsm_next <= AHB_DATA_PHASE;
                                        end
                                    end

            default: begin ahbfsm_next <= AHB_ADDR_PHASE; end
        endcase
    end
end

// AHB fsm master signals output: hburst_i
always@(posedge clk or negedge reset)
begin
    if(!reset) begin
        hburst_i    <= `AHB_HTRANS_IDLE;
    end
    else if(ahbfsm_reg == AHB_IDLE && ahbfsm_next == AHB_ADDR_PHASE) begin
        hburst_i    <= {$random} % 4;
        //hburst_i    <= `AHB_HBURST_WRAP8;
    end
end

assign          wrap_addr_start = (ahbfsm_trans_next == AHB_TRANS_MIDDLE && ahbfsm_trans_reg == AHB_TRANS_FIRST) ? ( haddr_i - down_half ): wrap_addr_start;
assign          wrap_single     = (ahbfsm_trans_next == AHB_TRANS_MIDDLE) ? (1 << ( hsize_i + 3) >> 3) : 'd0 ;
assign          down_half       = (ahbfsm_trans_next == AHB_TRANS_MIDDLE && ahbfsm_trans_reg == AHB_TRANS_FIRST) ? (haddr_i % wrap_width) : down_half;
assign          upper_half      = (ahbfsm_trans_next == AHB_TRANS_MIDDLE && ahbfsm_trans_reg == AHB_TRANS_FIRST) ? (wrap_width - down_half) : upper_half;
assign          addr_single     = wrap_single;

always@(*)
begin
    if(!reset) begin
        wrap_step <= 4'h0;
    end
    else if(ahbfsm_trans_next == AHB_TRANS_MIDDLE && ahbfsm_trans_reg == AHB_TRANS_FIRST) begin
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

always@(hsize_i or hburst_i or wrap_single)
begin
    case(hburst_i)
        `AHB_HBURST_WRAP4:      begin
                                    wrap_width     <= (wrap_single << 2);
                                end
        `AHB_HBURST_WRAP8:      begin
                                    wrap_width     <= (wrap_single << 3);
                                end
        `AHB_HBURST_WRAP16:     begin
                                    wrap_width     <= (wrap_single << 4);
                                end
        default:                begin
                                    wrap_width     <= 32'h0000_0000;
                                end
    endcase
end

always@(posedge clk or negedge reset)
begin
    if(!reset) begin
        hsize_i <= 'd0;
    end
    else begin
        hsize_i <= 3'b010;
    end
end

always@(posedge clk or negedge reset)
begin
    if(!reset) begin
        wrap_upper_offset <= 'd0;
        wrap_down_offset  <= 'd0;
    end
    else if(ahbfsm_trans_next == AHB_TRANS_FIRST && ahbfsm_trans_reg == AHB_TRANS_IDLE) begin
        wrap_upper_offset <= 'd0;
        wrap_down_offset  <= 'd0;
    end
    else if(ahbfsm_trans_next == AHB_TRANS_LAST && ahbfsm_trans_reg == AHB_TRANS_MIDDLE) begin
        wrap_upper_offset <= 'd0;
        wrap_down_offset  <= 'd0;
    end
    else if((ahbfsm_trans_next == AHB_TRANS_MIDDLE) && (upper_half - wrap_single <= wrap_upper_offset)) begin
        wrap_down_offset <= wrap_down_offset + wrap_single;
    end
    else begin
        wrap_upper_offset <= wrap_upper_offset + wrap_single;
    end
end

always@(posedge clk or negedge reset)
begin
    if(!reset) begin
        wrap_step_cnt <= 4'h0;
    end
    else if(ahbfsm_trans_next == AHB_TRANS_MIDDLE) begin
        wrap_step_cnt <= 4'h1 + wrap_step_cnt;
    end
    else if(ahbfsm_trans_next == AHB_TRANS_LAST) begin
        wrap_step_cnt <= 4'h0;
    end
end

always@(posedge clk or negedge reset)
begin
    if(!reset) begin
        ahb_trans_last_flag <= 1'b0;
    end
    else if(wrap_step_cnt < wrap_step - 3) begin
        ahb_trans_last_flag <= 1'b0;
    end
    else if(wrap_step_cnt >= wrap_step -3) begin
        ahb_trans_last_flag <= 1'b1;
    end
end

always@(posedge clk or negedge reset)
begin
    if(!reset) begin
        haddr_i     <= 'd0;
    end
    else if(ahbfsm_trans_next == AHB_TRANS_FIRST) begin
        //haddr_i     <= 32'h0000_002c;
        haddr_i     <= {$random} / wrap_single;
    end
    else if(ahbfsm_trans_next == AHB_TRANS_MIDDLE) begin
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
                                    if(upper_half - wrap_single <= wrap_upper_offset) begin
                                        haddr_i  <= wrap_addr_start + wrap_down_offset;
                                    end
                                    else begin
                                        haddr_i  <= haddr_i + wrap_single;
                                    end
                                end
            `AHB_HBURST_INCR8:  begin
                                    haddr_i  <= haddr_i + addr_single;
                                end
            `AHB_HBURST_WRAP8:  begin
                                    if(upper_half - wrap_single <= wrap_upper_offset) begin
                                        haddr_i  <= wrap_addr_start + wrap_down_offset;
                                    end
                                    else begin
                                        haddr_i  <= haddr_i + wrap_single;
                                    end
                                end
            `AHB_HBURST_INCR16: begin
                                    haddr_i  <= haddr_i + addr_single;
                                end
            `AHB_HBURST_WRAP16: begin
                                    if(upper_half - wrap_single <= wrap_upper_offset) begin
                                        haddr_i  <= wrap_addr_start + wrap_down_offset;
                                    end
                                    else begin
                                        haddr_i  <= haddr_i + wrap_single;
                                    end
                                end
            default:            begin haddr_i <= 'd0; end
        endcase
    end
end


// AHB Brust transfer end.
always@(posedge clk or negedge reset)
begin
    if(!reset) begin
        ending_of_trans <= 1'b0;
    end
    else if(ahbfsm_next == AHB_IDLE) begin
        ending_of_trans <= 1'b0;
    end
    else if(ahbfsm_next == AHB_DATA_PHASE) begin
        ending_of_trans <= 1'b0;
    end
end

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
