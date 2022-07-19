
module                          pmu(
    // CPU Power up 
    input  wire                 clk_i     ,               // External clock input, 25MHz, single
    //input  wire                 reset_n_i ,               // Externale reset pin .
    output reg                  ATX_PWR_o ,               // Output ATX_PWR singal
    output reg                  CLK_EN_o  ,               // Output clk enable for CPU.
    output wire                 CPU_REF_CLK_48MHZ_o ,     // Output CPU 48MHz, exernal
    output reg                  VDDQ_VPP_VREFCA_o   ,     // Output Vddq / VPP / VREFCA
    output reg                  VTT_o               ,     // O vtt
    output reg                  VCOR8E_08V_o        ,     // O Vcore 0.8V
    output reg                  PEUX_AVDD_AVDDCLK_o ,     // O PEUX 
    output reg                  PLL_VDDPOST_o       ,     // PLL VDDPOST 0.8v
    output reg                  VDDIO_18V_o         ,     // VDD IO 1.8v
    output reg                  PEUX_XX_AVDDH_18V_o ,     // PEUx xx AVDDDH 1.8v
    output reg                  VDDA_VDDPOST_PLL_VDDHV_18V_o , // .....
    output reg                  PCIE_RESER_o        ,     // Pcie reset
    output reg                  FT_POR_o            ,     // FT POR
    output reg                  GPIO0_A1_CPU_o      ,     // GPIO0_A1_CPU_i 
    input  wire                 PWR_CTR0_i          ,     // PWR_CTR1_i   CPU output to Actel
    input  wire                 PWR_CTR1_i          ,     // PWR_CTR1_i   CPU output to Actel

    input  wire                 CPU_REFCLLK_i       ,     //Extern cpu ref clock input .

    // Powe up flow done signal
    output reg                  PWR_FLOW_DONE_o      ,

    // CPU spi IF
    input  wire                 cpu_qspi_clk         ,     // CPU output spi clock.
    input  wire                 cpu_qspi_sdo         ,     // CPU spi data output.
    output wire                 cpu_qspi_sdi         ,     // CPU spi data input.
    input  wire                 cpu_qspi_wp          ,     // CPU Qspi write protected.
    input  wire                 cpu_qspi_hold        ,     // CPU Hold.
    input  wire                 cpu_qspi_cs          ,     // CPU chip select.

    //To SPI Nor flash Interface
    output wire                 flash_qspi_clk  ,
    input  wire                 flash_qspi_sdo  ,
    output wire                 flash_qspi_sdi  ,
    output wire                 flash_qspi_wp   ,
    output wire                 flash_qspi_hold ,
    output wire                 flash_qspi_cs   ,

    // CPU2 spi IF
    input  wire                 cpu2_qspi_clk    ,     // CPU output spi clock.
    input  wire                 cpu2_qspi_sdo    ,     // CPU spi data output.
    output wire                 cpu2_qspi_sdi    ,     // CPU spi data input.
    input  wire                 cpu2_qspi_wp     ,     // CPU Qspi write protected.
    input  wire                 cpu2_qspi_hold   ,     // CPU Hold.
    input  wire                 cpu2_qspi_cs     ,     // CPU chip select.

    //To SPI Nor flash Interface
    output wire                 flash2_qspi_clk  ,
    input  wire                 flash2_qspi_sdo  ,
    output wire                 flash2_qspi_sdi  ,
    output wire                 flash2_qspi_wp   ,
    output wire                 flash2_qspi_hold ,
    output wire                 flash2_qspi_cs
    );

reg                         clock_gating;
reg                         reset_n_i = 1'b1;
reg [3:0]                   reset_cnt = 4'h0;

assign                      flash_qspi_clk = cpu_qspi_clk;
assign                      cpu_qspi_sdi   = flash_qspi_sdo;
assign                      flash_qspi_sdi = cpu_qspi_sdo;
assign                      flash_qspi_wp  = cpu_qspi_wp;
assign                      flash_qspi_hold= cpu_qspi_hold;
assign                      flash_qspi_cs  = cpu_qspi_cs;

assign                      flash2_qspi_clk = cpu2_qspi_clk;
assign                      cpu2_qspi_sdi   = flash2_qspi_sdo;
assign                      flash2_qspi_sdi = cpu2_qspi_sdo;
assign                      flash2_qspi_wp  = cpu2_qspi_wp;
assign                      flash2_qspi_hold= cpu2_qspi_hold;
assign                      flash2_qspi_cs  = cpu2_qspi_cs;

// CPU Power up
reg [7 :0]                  fsm    = 'b0  ;
reg [31:0]                  ticker = 'd0  ;

wire                        go_s_up_atx_pwr    ;
wire                        go_s_enable_clk    ;
wire                        go_s_set_vtt_vdd   ;
wire                        go_s_set_08v       ;
wire                        go_s_set_18v       ;
wire                        go_s_down_gpio_a1  ;
wire                        go_s_up_pcie_reset ;
wire                        go_s_up_ft_por     ;
wire                        go_s_wait_pwr_ctr0 ;
wire                        go_s_wait_pwr_ctr1 ;
wire                        go_s_pwr_ctl_done  ;
wire                        go_s_up_gpio_a1    ;

parameter                   S_IDLE          = 0'hFF ;
parameter                   S_UP_ATX_PWR    = 8'h00 ;
parameter                   S_ENABLE_CLK    = 8'h01 ;
parameter                   S_SET_VTT_VDD   = 8'h02 ;
parameter                   S_SET_08V       = 8'h03 ;
parameter                   S_SET_18V       = 8'h04 ;
parameter                   S_DOWN_GPIO_A1  = 8'h05;
parameter                   S_UP_PCIE_RESET = 8'h06;
parameter                   S_UP_FT_POR     = 8'h07 ;
parameter                   S_WAIT_PWR_CTR0 = 8'h08;
parameter                   S_WAIT_PWR_CTR1 = 8'h09;
parameter                   S_PWR_CTL_DONE  = 8'h0A;
parameter                   S_UP_GPIO_A1    = 8'h0B;

assign                      go_s_up_atx_pwr    = (fsm == S_IDLE              );
assign                      go_s_enable_clk    = (fsm == S_UP_ATX_PWR        ) && (ticker == 32'h0000_01F5);
assign                      go_s_set_vtt_vdd   = (fsm == S_ENABLE_CLK        ) && (ticker == 32'h0000_01F5);
assign                      go_s_set_08v       = (fsm == S_SET_VTT_VDD       ) && (ticker == 32'h0000_01F5);
assign                      go_s_set_18v       = (fsm == S_SET_08V           ) && (ticker == 32'h0000_01F5);
assign                      go_s_down_gpio_a1  = (fsm == S_SET_18V           ) && (ticker == 32'h0000_0E6A);
assign                      go_s_up_pcie_reset = (fsm == S_DOWN_GPIO_A1      ) && (ticker == 32'h0000_0E6A);
assign                      go_s_up_ft_por     = (fsm == S_UP_PCIE_RESET     ) && (ticker == 32'h0000_01F5);
assign                      go_s_wait_pwr_ctr0 = (fsm == S_UP_FT_POR         ) && (PWR_CTR0_i             );
assign                      go_s_wait_pwr_ctr1 = (fsm == S_WAIT_PWR_CTR0     ) && (PWR_CTR1_i             );
assign                      go_s_pwr_ctl_done  = (fsm == S_WAIT_PWR_CTR1     ) && (!PWR_CTR0_i) && (!PWR_CTR1_i);
assign                      go_s_up_gpio_a1    = (fsm == S_PWR_CTL_DONE      ) && (ticker == 32'h0000_00FF);

// Generate reset signal
always@(posedge clk_i)
begin
    if(reset_cnt == 4'hF) begin
        reset_n_i <= 1'b1;
    end
    else begin
        reset_n_i <= 1'b0;
    end
end

//Wait for reset
always@(posedge clk_i)
begin
    if(reset_cnt != 4'hF) begin
        reset_cnt <= reset_cnt + 4'h1;
    end
end

always@(posedge clk_i or negedge reset_n_i)
begin
    if(!reset_n_i) begin
        ticker <= 'd0;
    end
    else if(go_s_up_ft_por    ||
            go_s_enable_clk   ||
            go_s_set_vtt_vdd  ||
            go_s_set_08v      ||
            go_s_set_18v      ||
            go_s_down_gpio_a1 ||
            go_s_up_pcie_reset||
            go_s_up_ft_por    ||
            go_s_wait_pwr_ctr0||
            go_s_wait_pwr_ctr1||
            go_s_pwr_ctl_done ||
            go_s_up_gpio_a1) begin
        ticker <= 'd0;
    end
    else begin
        ticker <= ticker + 1'b1 ;
    end
end

always@(posedge clk_i or negedge reset_n_i)
begin
    if(!reset_n_i) begin
        fsm <= S_IDLE ;
    end
    else begin
        case(fsm[7:0])
            S_IDLE:             begin
                                    if(go_s_up_atx_pwr) begin
                                        fsm <= S_UP_ATX_PWR ;
                                    end
                                    else begin
                                        fsm <= S_IDLE ;
                                    end
                                end

            S_UP_ATX_PWR:       begin
                                    if(go_s_enable_clk) begin
                                        fsm <= S_ENABLE_CLK ;
                                    end
                                    else begin
                                        fsm <= S_UP_ATX_PWR ;
                                    end
                                end

            S_ENABLE_CLK:       begin
                                    if(go_s_set_vtt_vdd) begin
                                        fsm <= S_SET_VTT_VDD ;
                                    end
                                    else begin
                                        fsm <= S_ENABLE_CLK ;
                                    end
                                end

            S_SET_VTT_VDD:      begin
                                    if(go_s_set_08v) begin
                                        fsm <= S_SET_08V ;
                                    end
                                    else begin
                                        fsm <= S_SET_VTT_VDD;
                                    end
                                end

            S_SET_08V:          begin
                                        if(go_s_set_18v) begin
                                            fsm <= S_SET_18V ;
                                        end
                                        else begin
                                            fsm <= S_SET_08V;
                                        end
                                    end

            S_SET_18V:          begin
                                        if(go_s_down_gpio_a1) begin
                                            fsm <= S_DOWN_GPIO_A1 ;
                                        end
                                        else begin
                                            fsm <= S_SET_18V ;
                                        end
                                    end

            S_DOWN_GPIO_A1:     begin
                                        if(go_s_up_pcie_reset) begin
                                            fsm <= S_UP_PCIE_RESET ;
                                        end
                                        else begin
                                            fsm <= S_DOWN_GPIO_A1 ;
                                        end
                                    end

            S_UP_PCIE_RESET:    begin
                                        if(go_s_up_ft_por) begin
                                            fsm <= S_UP_FT_POR ;
                                        end
                                        else begin
                                            fsm <= S_UP_PCIE_RESET ;
                                        end
                                    end

            S_UP_FT_POR:        begin
                                        if(go_s_wait_pwr_ctr0) begin
                                            fsm <= S_WAIT_PWR_CTR0 ;
                                        end
                                        else begin
                                            fsm <= S_UP_FT_POR;
                                        end
                                    end

            S_WAIT_PWR_CTR0:    begin
                                        if(go_s_wait_pwr_ctr1) begin
                                            fsm <= S_WAIT_PWR_CTR1 ;
                                        end
                                        else begin
                                            fsm <= S_WAIT_PWR_CTR0 ;
                                        end
                                    end

            S_WAIT_PWR_CTR1:    begin
                                    if(go_s_pwr_ctl_done) begin
                                        fsm <= S_PWR_CTL_DONE ;
                                    end
                                    else begin
                                        fsm <= S_WAIT_PWR_CTR1 ;
                                    end
                                end

            S_PWR_CTL_DONE:     begin
                                         if(go_s_up_gpio_a1) begin
                                             fsm <= S_UP_GPIO_A1 ;
                                         end
                                         else begin
                                             fsm <= S_PWR_CTL_DONE ;
                                         end
                                     end

            S_UP_GPIO_A1:       begin
                                    fsm <= S_UP_GPIO_A1;
                                end

            default:            begin
                                    fsm <= S_IDLE;
                                end
        endcase
    end
end

always@(posedge clk_i or negedge reset_n_i)
begin
    if(!reset_n_i) begin
        ATX_PWR_o <= 1'b0;
    end
    else if(fsm == S_UP_ATX_PWR) begin
        ATX_PWR_o <= 1'b1;
    end
end

always@(posedge clk_i or negedge reset_n_i)
begin
    if(!reset_n_i) begin
        CLK_EN_o <= 1'b0;
        clock_gating <= 1'b0;
    end
    else if(fsm == S_ENABLE_CLK) begin
        CLK_EN_o <= 1'b1;
        clock_gating <= 1'b1;
    end
end

always@(posedge clk_i or negedge reset_n_i)
begin
    if(!reset_n_i) begin
        VDDQ_VPP_VREFCA_o <= 1'b0;
        VTT_o <= 1'b0;
    end
    else if(fsm == S_SET_VTT_VDD) begin
        VDDQ_VPP_VREFCA_o <= 1'b1;
        VTT_o <= 1'b1;
    end
end

always@(posedge clk_i or negedge reset_n_i)
begin
    if(!reset_n_i) begin
        VCOR8E_08V_o <= 1'b0;
        PEUX_AVDD_AVDDCLK_o <= 1'b0;
        PLL_VDDPOST_o <= 1'b0;
    end
    else if(fsm == S_SET_08V) begin
        VCOR8E_08V_o <= 1'b1;
        PEUX_AVDD_AVDDCLK_o <= 1'b1;
        PLL_VDDPOST_o <= 1'b1;
    end
end

always@(posedge clk_i or negedge reset_n_i)
begin
    if(!reset_n_i) begin
        VDDIO_18V_o <= 1'b0;
        PEUX_XX_AVDDH_18V_o <= 1'b0;
        VDDA_VDDPOST_PLL_VDDHV_18V_o <= 1'b0;
    end
    else if(fsm == S_SET_18V) begin
        VDDIO_18V_o <= 1'b1;
        PEUX_XX_AVDDH_18V_o <= 1'b1;
        VDDA_VDDPOST_PLL_VDDHV_18V_o <= 1'b1;
    end
end


always@(posedge clk_i or negedge reset_n_i)
begin
    if(!reset_n_i) begin
         GPIO0_A1_CPU_o <= 1'b1;
    end
    else if(fsm == S_IDLE) begin
        GPIO0_A1_CPU_o <= 1'b1;
    end
    else if(fsm == S_DOWN_GPIO_A1) begin
         GPIO0_A1_CPU_o <= 1'b0;
    end
    else if(fsm == S_UP_GPIO_A1) begin
         GPIO0_A1_CPU_o <= 1'b1;
    end
end


always@(posedge clk_i or negedge reset_n_i)
begin
    if(!reset_n_i) begin
        PCIE_RESER_o <= 1'b0;
    end
    else if(fsm == S_UP_PCIE_RESET) begin
        PCIE_RESER_o <= 1'b1;
    end
end

always@(posedge clk_i or negedge reset_n_i)
begin
    if(!reset_n_i) begin
        FT_POR_o <= 1'b0;
    end
    else if(fsm == S_UP_FT_POR) begin
        FT_POR_o <= 1'b1;
    end
end

always@(posedge clk_i or negedge reset_n_i)
begin
    if(!reset_n_i) begin
        PWR_FLOW_DONE_o <= 1'b0;
    end
    else if(fsm == S_UP_GPIO_A1) begin
        PWR_FLOW_DONE_o <= 1'b1;
    end
end


assign   CPU_REF_CLK_48MHZ_o = clock_gating && CPU_REFCLLK_i ;
endmodule
