module               spi_apb_if_tb();

localparam                 ADDR_WIDE = 32 ;
localparam                 DATA_WIDE = 32 ;
localparam                 REG_WIDE  = 32 ;
localparam                 PERIOD    = 20 ;

reg                        clk_i          ;
reg                        resetn_i       ;

enum  {IDLE = 'd0, SETUP, ACCESS} fsmc,fsmn;

// IF transfer long drawm,value is 1'1 ,or 1'b0
wire                       transfer    ;
// AHB interface
reg  [ADDR_WIDE-1 :0]      paddr_i     ;
reg                        pwrite_i    ;
reg                        psel_i      ;
reg                        penable_i   ;
reg  [DATA_WIDE-1 :0]      pwdata_i    ;
wire [DATA_WIDE-1 :0]      prdata_o    ;
wire                       pready_o    ;

// Generate clock
initial begin
    clk_i    = 1'b0;
    #(PERIOD*10)
    forever begin
       #(PERIOD/2) clk_i = 1'b1;
       #(PERIOD/2) clk_i = 1'b0;
    end
end

// Reset singal , Low active.
initial begin
    resetn_i =  1'b0;
    #(PERIOD*10)
    resetn_i =  1'b1;
end

// Dump wavm
initial begin
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars(0, "spi_apb_if_tb");
end

assign                      transfer = 1'b1;

// FSM status jump
always@(posedge clk_i or negedge resetn_i)
begin
    if(!resetn_i) begin
        fsmc <= IDLE ;
    end
    else begin
        fsmc <= fsmn ;
    end
end

// FSM stats control
always@(*)
begin
    case(fsmc)
        IDLE:       begin
                        if(transfer) begin
                            fsmn <= SETUP;
                        end
                        else begin
                            fsmn <= IDLE;
                        end
                    end

        SETUP:      begin
                        fsmn <= ACCESS;
                    end
        ACCESS:     begin
                        if(pready_o && transfer) begin
                            fsmn <= SETUP;
                        end
                        else if((pready_o && !transfer) || (!pready_o)) begin
                            fsmn <= IDLE;
                        end
                    end
        default:    begin fsmn <= IDLE; end
    endcase
end

// FSM output , enable signal control
always@(posedge clk_i or negedge resetn_i)
begin
    if(!resetn_i) begin
        penable_i <= 1'b0;
    end
    else if(fsmn == SETUP || fsmn == IDLE) begin
        penable_i <= 1'b0;
    end
    else if(fsmn == ACCESS) begin
        penable_i <= 1'b1;
    end
end

// FSM output , write or read
always@(posedge clk_i or negedge resetn_i)
begin
    if(!resetn_i) begin
        pwdata_i <= 32'd0 ;
        pwrite_i <= 1'b0  ;
        paddr_i  <= 32'd0 ;
        psel_i   <= 1'b0  ;
    end
    else if(fsmn == IDLE) begin
        pwdata_i <= 32'd0 ;
        pwrite_i <= 1'b0  ;
        paddr_i  <= 32'd0 ;
        psel_i   <= 1'b0  ;
    end
    else if(fsmn == SETUP) begin
        pwdata_i <= {$random} % 32'h0FF0_FFFF ;
        pwrite_i <= {$random} % 1 ;
        paddr_i  <= {$random} % 1024 ;
        psel_i   <= 1'b1 ;
    end
end

spi_apb_if      #(
    .ADDR_WIDE   (ADDR_WIDE  ),
    .DATA_WIDE   (DATA_WIDE  ),
    .REG_WIDE    (REG_WIDE   )
    )
    spi_apb_if_inst
    (
    .pclk_i      (clk_i      ),
    .prstn_i     (resetn_i   ),
    .paddr_i     (paddr_i    ),
    .pwrite_i    (pwrite_i   ),
    .psel_i      (psel_i     ),
    .penable_i   (penable_i  ),
    .pwdata_i    (pwdata_i   ),
    .prdata_o    (prdata_o   ),
    .pready_o    (pready_o   )
    );

endmodule
