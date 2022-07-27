
`default_nettype wire
`define   AHB_BRUST_IDLE    2'b00
`define   AHB_BRUST_BUSY    2'b01
`define   AHB_BRUST_NONSEQ  2'b10
`define   AHB_BRUST_SEQ     2'b11

module              ahb2apb_tb();

// clock
reg                 clk         ;
reg                 reset       ;

// AHB dut signals 
wire                hready_o    ;
wire                hreadyout_o ;

// AHB master fsm 
enum    {AHB_ADDR_PHASE='d0, AHB_DATA_PHASE} ahbfsm_c, ahbfsm_n;

// generate clock and reset
initial begin
    clk     =  1'b0;
    forever begin
        clk = #20 1'b1;
        clk = #20 1'b0;
    end
end

initial begin
    reset = 1'b1;
    #103
    reset = 1'b0;
    #100
    reset = 1'b1;
    // finished simulation
    #(20*1000)
    $finish;
end

// Verdi Dump
initial begin
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars(0, "ahb2apb_tb");
    $fsdbDumpMDA(0, "ahb2apb_tb");
end

// AHB fsm state transfer
always@(posedge clk or negedge reset)
begin
    if(!reset) begin
        ahbfsm_c <= AHB_ADDR_PHASE;
    end
    else begin
        ahbfsm_c <= ahbfsm_n;
    end
end

// AHB fsm stat jump
always@(*)
begin
    if(!reset) begin
        ahbfsm_n <= AHB_ADDR_PHASE;
    end
    else begin
        case(ahbfsm_c)
            AHB_ADDR_PHASE:         begin
                                        if(hready_o) begin
                                            ahbfsm_n <= AHB_DATA_PHASE;
                                        end
                                        else begin
                                            ahbfsm_n <= AHB_ADDR_PHASE;
                                        end
                                    end
            AHB_DATA_PHASE:         begin
                                        if(hready_o) begin
                                            ahbfsm_n <= AHB_ADDR_PHASE;
                                        end
                                        else begin
                                            ahbfsm_n <= AHB_DATA_PHASE;
                                        end
                                    end

            default: begin ahbfsm_n <= AHB_ADDR_PHASE; end
        endcase
    end

end

// AHB fsm master signals output
always@(posedge clk or negedge reset)
begin
    if(!reset) begin
        haddr_i     <= 32'd0;
        hburst_i    <= `AHB_BRUST_IDLE;
        hsel_i      <= 1'b0;
        hprot_i     <= 4'b000;
        //hsize_i     <= 
    end
    else if(ahbfsm_n == AHB_ADDR_PHASE) begin
    end
    else if(ahbfsm_n == AHB_DATA_PHASE) begin
    end
end

ahb2apb           #(
    .ADDR_WIDTH   (32          ),
    .HBURST_WIDTH (3           ),
    .HPROT_WIDTH  (0           ),
    .DATA_WIDTH   (32          )
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


endmodule
