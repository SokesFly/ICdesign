/***************************************************************************************
* Function: 
* Author: SK 
* Company: Ltd.JRLC.SK
* Right : 
* Tel : 
* Last modified: 2022-04-07 09:33
* None: 
* Filename: uart_tb.v
* Resverd: 
* Description: 
**************************************************************************************/
`timescale 1ns/1ps

module          uart_tb;

parameter                   DLY             = 1 ;
parameter                   DATA_WIDTH      = 8 ;
parameter                   CLK_PERIOD      = 20;  // Primary clk is 50Mhz.


/**************************** Declare clocks *********************************/
reg                         clk                 ;
/**************************** Declare reset  *********************************/
reg                         rst_n               ;

reg                         ctrl_enable         ;
reg   [31    :0]            ctrl_r              ;
wire  [31    :0]            ctrl                ;
wire  [31    :0]            state               ;
wire  [31    :0]            ctrl_mirror         ;

assign                      ctrl  = ctrl_r      ;

/**************************** Declare tx sigs ********************************/
reg   [DATA_WIDTH-1 :0]     tx_data_r           ;
wire  [DATA_WIDTH-1 :0]     tx_data             ;
reg                         tx_vld_r            ;
wire                        tx_vld              ;
wire                        tx_rdy              ;


assign                      tx_data = tx_data_r ;
assign                      tx_vld  = tx_vld_r  ;

/**************************** Declare rx sigs ********************************/
reg                         rx_rdy_r            ;
wire                        rx_rdy              ;
wire                        rx_vld              ;
wire  [DATA_WIDTH-1 :0]     rx_data             ;

assign                      rx_rdy  = rx_rdy_r  ;

/**************************** Uart physical link  ***************************/
wire                        tx                  ;
wire                        rx                  ;

assign                      rx  =   tx          ;

/**************************** Declare fifo status  **************************/
wire                        ur_rx_fifo_full     ;
wire                        ur_rx_fifo_empty    ;
wire                        ur_tx_fifo_full     ;
wire                        ur_tx_fifo_empty    ;


assign                      ur_tx_fifo_full     = {state[0:0]} ;
assign                      ur_tx_fifo_empty    = {state[1:1]} ;
assign                      ur_rx_fifo_full     = {state[2:2]} ;
assign                      ur_tx_fifo_empty    = {state[3:3]} ;


/**************************** Verdi waveform dump ***************************/
initial begin
                            $fsdbDumpfile   ("tb.fsdb"   );
                            $fsdbDumpvars   (0, "uart_tb");
                            $fsdbDumpMDA    (0, "uart_tb");
end

/**************************** Gen sys clock *********************************/
initial begin
                            clk     = 1'b0  ;
                            forever begin
                                #(CLK_PERIOD/2)
                                clk = 1'b0  ;
                                #(CLK_PERIOD/2)
                                clk = 1'b1  ;
                            end
end

/**************************** System reset **********************************/
initial begin
                            rst_n   = 1'b0;
                            #(CLK_PERIOD*10)
                            rst_n   = 1'b0;
                            #(CLK_PERIOD%3)
                            rst_n   = 1'b1;
end

/**************************** uart config **********************************/
initial begin
                            ctrl_r[0 : 0]   = 1'b0     ;
                            ctrl_r[2 : 1]   = 2'b00    ;
                            ctrl_r[4 : 3]   = 2'b00    ;
                            ctrl_r[8 : 5]   = 4'h8     ;
                            ctrl_r[24: 9]   = 16'h0036 ;
                            ctrl_r[31:25]   = 7'h00    ;
end

/**************************** Generate tx data *****************************/
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        tx_data_r  <= #DLY {DATA_WIDTH{1'b0}};
    end
    else begin
        tx_data_r  <= #DLY {$random};
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        tx_vld_r  <= #DLY 1'b0;
    end
    else begin
        tx_vld_r  <= #DLY 1'b1;
    end
end


/****************************  Rx data *************************************/
// case 1 resver data.
assign                      rx_rdy      =   1'b0;

// case 2 resver data.
// assign                      rx_rdy      =   1'b0;

/**************************** Sim end **************************************/
initial begin
                            #(CLK_PERIOD*3000)
                            $finish;
end

/****************************  Module Instance **********************************/
/**************************  Instance uart DUT  *********************************/
/****************************  Module Instance **********************************/
uart                        #(
    .DLY                    (DLY                ),
    .BAUDRATE_WIDTH         (12                 ),
    .DATA_WIDTH             (8                  )
    )
    u_DUT_uart_i
    (
    .clk_i                  (clk                ),
    .rst_n_i                (rst_n              ),
    .ctrl_enable            (1'b1               ),
    .ctrl                   (ctrl               ),
    .ctrl_mirror            (ctrl_mirror        ),
    .state                  (state              ),
    .tx_data_i              (tx_data            ),
    .tx_vld_i               (tx_vld             ),
    .tx_rdy_o               (tx_rdy             ),
    .rx_data_o              (rx_data            ),
    .rx_vld_o               (rx_vld             ),
    .rx_rdy_i               (rx_rdy             ),
    .tx                     (tx                 ),
    .rx                     (rx                 )
    );

endmodule

