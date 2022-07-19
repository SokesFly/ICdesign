module pmu_tb();

parameter CLK_PERIOD       =  40;
parameter CPU_48MHz_PERIOD =  20;

reg  clk_i          ;
reg  CPU_48MHz      ;
reg  reset_n_i      ;
reg [31:0]  ticker  ;

// Declare wire 
wire                 ATX_PWR_o           ;     // Output ATX_PWR singal
wire                 CLK_EN_o            ;     // Output clk enable for CPU.
wire                 CPU_REF_CLK_48MHZ_o ;     // Output CPU 48MHz, exernal
wire                 VDDQ_VPP_VREFCA_o   ;     // Output Vddq / VPP / VREFCA
wire                 VTT_o               ;     // O vtt
wire                 VCOR8E_08V_o        ;     // O Vcore 0.8V
wire                 PEUX_AVDD_AVDDCLK_o ;     // O PEUX 
wire                 PLL_VDDPOST_o       ;     // PLL VDDPOST 0.8v
wire                 VDDIO_18V_o         ;     // VDD IO 1.8v
wire                 PEUX_XX_AVDDH_18V_o ;     // PEUx xx AVDDDH 1.8v
wire                 VDDA_VDDPOST_PLL_VDDHV_18V_o ; // .....
wire                 PCIE_RESER_o        ;
wire                 FT_POR_o            ;     // FT POR
wire                 GPIO0_A1_CPU_o      ;     // GPIO0_A1_CPU_i 
reg                  PWR_CTR0_i          ;     // CPU output to Actel
reg                  PWR_CTR1_i          ;     // CPU output to Actel

wire                 PWR_FLOW_DONE_o     ;

// CPU spi IF
wire                 cpu_qspi_clk        ;     // CPU output spi clock.
wire                 cpu_qspi_sdo        ;     // CPU spi data output.
wire                 cpu_qspi_sdi        ;     // CPU spi data input.
wire                 cpu_qspi_wp         ;     // CPU Qspi write protected.
wire                 cpu_qspi_hold       ;     // CPU Hold.
wire                 cpu_qspi_cs         ;     // CPU chip select.

//To SPI Nor flash Interface
wire                 flash_qspi_clk      ;
wire                 flash_qspi_sdo      ;
wire                 flash_qspi_sdi      ;
wire                 flash_qspi_wp       ;
wire                 flash_qspi_hold     ;
wire                 flash_qspi_cs       ;

// CPU2 spi IF
wire                 cpu2_qspi_clk       ;     // CPU output spi clock.
wire                 cpu2_qspi_sdo       ;     // CPU spi data output.
wire                 cpu2_qspi_sdi       ;     // CPU spi data input.
wire                 cpu2_qspi_wp        ;     // CPU Qspi write protected.
wire                 cpu2_qspi_hold      ;     // CPU Hold.
wire                 cpu2_qspi_cs        ;     // CPU chip select.

//To SPI Nor flash Interface
wire                 flash2_qspi_clk     ;
wire                 flash2_qspi_sdo     ;
wire                 flash2_qspi_sdi     ;
wire                 flash2_qspi_wp      ;
wire                 flash2_qspi_hold    ;
wire                 flash2_qspi_cs      ;

reg [7:0]            fsm = 8'hFF          ;

wire                 go_ready            ;
wire                 go_hpwr_ctr0        ;
wire                 go_hpwr_ctr1        ;
wire                 go_lpwr_ctr1        ;
wire                 go_lpwr_ctr0        ;
wire                 go_end              ;

initial begin
  clk_i = 1'b0;
  #10 reset_n_i = 1'b1;
  #20 reset_n_i = 1'b0;
  #20 reset_n_i = 1'b1;
  forever begin
    #(CLK_PERIOD/2) clk_i = 1'b1;
    #(CLK_PERIOD/2) clk_i = 1'b0;
  end
end


initial begin
  CPU_48MHz = 1'b0;
  forever begin
    #(CPU_48MHz_PERIOD/2) CPU_48MHz = 1'b0;
    #(CPU_48MHz_PERIOD/2) CPU_48MHz = 1'b1;
  end
end

initial begin
    @(posedge PWR_FLOW_DONE_o) $finish;
end

initial begin
  $fsdbDumpfile("tb.fsdb");
  $fsdbDumpvars(0, "pmu_tb");
end

// Generate PWR_CTR0_i and PWR_CTR1_i by FSM
parameter           S_IDLE      = 8'hFF;
parameter           S_READY     = 8'h00;
parameter           S_HPWR_CTR0 = 8'h01;
parameter           S_HPWR_CTR1 = 8'h02;
parameter           S_LPWR_CTR1 = 8'h03;
parameter           S_LPWR_CTR0 = 8'h04;
parameter           S_END       = 8'h05;

assign              go_ready     = (fsm == S_IDLE      ) && (FT_POR_o               );
assign              go_hpwr_ctr0 = (fsm == S_READY     ) && (ticker == 32'h0000_0100);
assign              go_hpwr_ctr1 = (fsm == S_HPWR_CTR0 ) && (ticker == 32'h0000_0040);
assign              go_lpwr_ctr1 = (fsm == S_HPWR_CTR1 ) && (ticker == 32'h0000_0010);
assign              go_lpwr_ctr0 = (fsm == S_LPWR_CTR1 ) && (ticker == 32'h0000_0040);
assign              go_end       = (fsm == S_LPWR_CTR0 ) && (ticker == 32'h0000_0100);

// Reset counter.
always@(posedge clk_i)
begin
   if(go_ready || go_hpwr_ctr0 || go_hpwr_ctr1 || go_lpwr_ctr0 || go_lpwr_ctr1 || go_end) begin
       ticker <= 32'h0000_0000;
   end
   else begin
       ticker <= ticker + 32'd1;
   end
end


always@(posedge clk_i) begin
   case(fsm[7:0])
       S_IDLE:      begin
                       if(go_ready) begin
                          fsm <= S_READY ;
                       end
                       else begin
                          fsm <= S_IDLE ;
                       end
                    end

       S_READY:     begin
                       if(go_hpwr_ctr0) begin
                          fsm <= S_HPWR_CTR0 ;
                       end
                       else begin
                          fsm <= S_READY ;
                       end
                    end

       S_HPWR_CTR0: begin
                       if(go_hpwr_ctr1) begin
                          fsm <= S_HPWR_CTR1 ;
                       end
                       else begin
                          fsm <= S_HPWR_CTR0 ;
                       end
                    end

       S_HPWR_CTR1: begin
                       if(go_lpwr_ctr1) begin
                          fsm <= S_LPWR_CTR1 ;
                       end
                       else begin
                          fsm <= S_HPWR_CTR1 ;
                       end
                    end

       S_LPWR_CTR1: begin
                       if(go_lpwr_ctr0) begin
                          fsm <= S_LPWR_CTR0 ;
                       end
                       else begin
                          fsm <= S_LPWR_CTR1 ;
                       end
                    end

       S_LPWR_CTR0: begin
                       if(go_end) begin
                          fsm <= S_END ;
                       end
                       else begin
                          fsm <= S_LPWR_CTR0 ;
                       end
                    end

       S_END:       begin
                       fsm <= S_END;
                    end

       default:     begin
                        fsm <= S_END;
                    end
   endcase
end

//FSM output 
always@(posedge clk_i)
begin
   if(fsm == S_IDLE || fsm == S_LPWR_CTR0) begin
      PWR_CTR0_i <=  1'b0;
   end
   else if(fsm == S_HPWR_CTR0) begin
      PWR_CTR0_i <=  1'b1;
   end
end

always@(posedge clk_i)
begin
   if(fsm == S_IDLE || fsm == S_LPWR_CTR1) begin
      PWR_CTR1_i <=  1'b0;
   end
   else if(fsm == S_HPWR_CTR1) begin
      PWR_CTR1_i <=  1'b1;
   end
end


pmu                               pmu(
    // CPU Power up 
    .clk_i                        (clk_i                       ),
    .ATX_PWR_o                    (ATX_PWR_o                   ),
    .CLK_EN_o                     (CLK_EN_o                    ),
    .CPU_REF_CLK_48MHZ_o          (CPU_REF_CLK_48MHZ_o         ),
    .VDDQ_VPP_VREFCA_o            (VDDQ_VPP_VREFCA_o           ),
    .VTT_o                        (VTT_o                       ),
    .VCOR8E_08V_o                 (VCOR8E_08V_o                ),
    .PEUX_AVDD_AVDDCLK_o          (PEUX_AVDD_AVDDCLK_o         ),
    .PLL_VDDPOST_o                (PLL_VDDPOST_o               ),
    .VDDIO_18V_o                  (VDDIO_18V_o                 ),
    .PEUX_XX_AVDDH_18V_o          (PEUX_XX_AVDDH_18V_o         ),
    .VDDA_VDDPOST_PLL_VDDHV_18V_o (VDDA_VDDPOST_PLL_VDDHV_18V_o),
    .PCIE_RESER_o                 (PCIE_RESER_o                ),
    .FT_POR_o                     (FT_POR_o                    ),
    .GPIO0_A1_CPU_o               (GPIO0_A1_CPU_o              ),
    .PWR_CTR0_i                   (PWR_CTR0_i                  ),
    .PWR_CTR1_i                   (PWR_CTR1_i                  ),
    .CPU_REFCLLK_i                (CPU_48MHz                   ),
    .PWR_FLOW_DONE_o              (PWR_FLOW_DONE_o             ),
    .cpu_qspi_clk                 (cpu_qspi_clk                ),
    .cpu_qspi_sdo                 (cpu_qspi_sdo                ),
    .cpu_qspi_sdi                 (cpu_qspi_sdi                ),
    .cpu_qspi_wp                  (cpu_qspi_wp                 ),
    .cpu_qspi_hold                (cpu_qspi_hold               ),
    .cpu_qspi_cs                  (cpu_qspi_cs                 ),
    .flash_qspi_clk               (flash_qspi_clk              ),
    .flash_qspi_sdo               (flash_qspi_sdo              ),
    .flash_qspi_sdi               (flash_qspi_sdi              ),
    .flash_qspi_wp                (flash_qspi_wp               ),
    .flash_qspi_hold              (flash_qspi_hold             ),
    .flash_qspi_cs                (flash_qspi_cs               ),
    .cpu2_qspi_clk                (cpu2_qspi_clk               ),
    .cpu2_qspi_sdo                (cpu2_qspi_sdo               ),
    .cpu2_qspi_sdi                (cpu2_qspi_sdi               ),
    .cpu2_qspi_wp                 (cpu2_qspi_wp                ),
    .cpu2_qspi_hold               (cpu2_qspi_hold              ),
    .cpu2_qspi_cs                 (cpu2_qspi_cs                ),
    .flash2_qspi_clk              (flash2_qspi_clk             ),
    .flash2_qspi_sdo              (flash2_qspi_sdo             ),
    .flash2_qspi_sdi              (flash2_qspi_sdi             ),
    .flash2_qspi_wp               (flash2_qspi_wp              ),
    .flash2_qspi_hold             (flash2_qspi_hold            ),
    .flash2_qspi_cs               (flash2_qspi_cs              )
    );
endmodule
