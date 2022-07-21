module               spi_apb_if_tb();

localparam                 ADDR_WIDE = 32 ;
localparam                 DATA_WIDE = 32 ;
localparam                 REG_WIDE  = 32 ;
localparam                 PERIOD    = 20 ;

reg                        clk_i          ;
reg                        resetn_i       ;

enum  {IDLE = 'd0, SETUP, ACCESS} fsm  ;

// IF transfer long drawm,value is 1'1 ,or 1'b0
wire                       transfer    ;

wire                       go_idle     ;
wire                       go_setup    ;
wire                       go_access   ;

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

// FSM jump
assign            transfer  = 1'b1;
assign            go_idle   = (fsm == ACCESS) && (pready_o) && (!transfer);
assign            go_setup  = (fsm == IDLE  ) && (transfer) || (fsm == ACCESS) || (transfer);
assign            go_access = (fsm == SETUP ) ;

// FSM condition control
always@(posedge clk_i or negedge resetn_i) 
begin
    if(!resetn_i) begin
       fsm <= IDLE;
    end
    else begin
        case(fsm)
            IDLE:    begin
                        if(go_setup) begin
                            fsm <= SETUP;
                        end
                        else begin
                            fsm <= IDLE;
                        end
                     end

            SETUP:   begin
                        if(go_access) begin
                            fsm <= ACCESS;
                        end
                        else begin
                            fsm <= SETUP;
                        end
                     end

            ACCESS:  begin
                        if(go_idle) begin
                            fsm <= IDLE;
                        end
                        else if(go_setup) begin
                            fsm <= SETUP;
                        end
                        else begin
                            fsm <= ACCESS;
                        end
                     end

            default: begin fsm <= IDLE; end

        endcase
    end
end

// FSM output , write or read
always@(posedge clk_i or negedge resetn_i)
begin
   if(!resetn_i) begi
    
   end
   else begin
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
