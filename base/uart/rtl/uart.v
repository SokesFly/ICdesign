/***************************************************************************************
* Function: 
* Author: SK 
* Company: Ltd.JRLC.SK
* Right : 
* Tel : 
* Last modified:	2022-04-07 11:56
* None: 
* Filename:		uart.v
* Resverd: 
* Description: 
**************************************************************************************/
`timescale 1ns/1ps

module                                uart #(
    parameter                         DLY             = 1,
    parameter                         BAUDRATE_WIDTH  = 16,
    parameter                         DATA_WIDTH      = 8     // Data width , without parity bit.
    )(
    input  wire                       clk_i          ,        // Primary clock of system.
    input  wire                       rst_n_i        ,        // Sys reset.

    /********************************************************************************
    * Ctrl register description ADDR -- 0
    * Bit  |  Value | Read/Write | FUNC 
    * 0    |   1/0  | RDWR       | off/on module, for low power.
    * 1-2  |   00   | RDWR       | Parity mode ODD.
    * 1-2  |   01   | RDWR       | Parity mode OEVEN.
    * 1-2  |   10   | RDWR       | Parity mode NONE
    * 1-2  |   11   | RDWR       | Parity mode SPACE
    * 3-4  |   00   | RDWR       | 1 bit stop
    * 3-4  |   01   | RDWR       | 1.5 bit stop
    * 3-4  |   10   | RDWR       | 2 bit stop
    * 5-8  | 0x05   | RDWR       | Data bits 5
    * 5-8  | 0x06   | RDWR       | Data bits 6
    * 5-8  | 0x07   | RDWR       | Data bits 7
    * 5-8  | 0x08   | RDWR       | Data bits 8
    * 9~28 | lookup | RDWR       | set baudrate factor.
    *_______________________________________________________________________________
    *Baudrate config in primary clock is 50Mhz.
    * Baudrate    | Uart-period | Primary-clk-period | Factor | baudrate_cfg_i
    * 600 bps     | 1666667 ns  | 20 ns              | 83333  | 0x208D
    * 1200 bps    | 833333  ns  | 20 ns              | 41667  | 0xA2C3
    * 2400 bps    | 416667  ns  | 20 ns              | 20833  | 0x5161
    * 4800 bps    | 208333  ns  | 20 ns              | 10417  | 0x28B1
    * 9600 bps    | 104167  ns  | 20 ns              | 5028   | 0x13A4
    * 19200 bps   | 52083   ns  | 20 ns              | 2604/  | 0xA2C
    * 38400 bps   | 26041   ns  | 20 ns              | 1302   | 0x516
    * 43000 bps   | 23255   ns  | 20 ns              | 1162   | 0x48A
    * 56000 bps   | 17857   ns  | 20 ns              | 893    | 0x37D
    * 57600 bps   | 17361   ns  | 20 ns              | 868    | 0x364
    * 115200 bps  | 8680    ns  | 20 ns              | 434    | 0x1B2
    * 230400 bps  | 4340    ns  | 20 ns              | 217    | 0xD9
    * 380400 bps  | 2628    ns  | 20 ns              | 131    | 0x83
    * 460800 bps  | 2170    ns  | 20 ns              | 108    | 0x6C
    * 921600 bps  | 1085    ns  | 20 ns              | 54     | 0x36
    *_______________________________________________________________________________
    ********************************************************************************/
    input  wire                       ctrl_enable    ,        // Reconfigure uart ip.
    input  wire [31             :0]   ctrl           ,        // Generate baudrate.
    output wire [31             :0]   ctrl_mirror    ,        // Ctrl register mirror.

    /********************************************************************************
    * State regsiter description AADE -- 1
    * Bit  |  Value | Read/Write | FUNC 
    * 0    |   High | RD-ONLY    | TX FIFO full
    * 1    |   Low  | RD-ONLY    | TX FIFO empty
    * 2    |   High | RD-ONLY    | RX FIFO full
    * 3    |   Low  | RD-ONLY    | RX FIFO empty
    * 4    |   High | RD-ONLY    | RX Interrupt arrives
    * 5    |   Low  | RD-ONLY    | RX No Interrupt
    * 6~31  Reserved
    ********************************************************************************/
    output wire [31             :0]   state          ,       // FIFO full.

    /********************* High level interface  *******************************/
    input  wire [DATA_WIDTH-1   :0]   tx_data_i      ,       // Input tx data.
    input  wire                       tx_vld_i       ,       // Input tx data valid.
    output wire                       tx_rdy_o       ,       // Output tx data ready.

    input  wire                       rx_rdy_i       ,       // Input rx data ready.
    output wire                       rx_vld_o       ,       // Output rx data valid.
    output wire [DATA_WIDTH-1   :0]   rx_data_o      ,       // Output rx data.

    /********************* UART physical wire  *********************************/
    output wire                       tx             ,       // Physical uart tx.
    input  wire                       rx                     // Physical uart rx.
    );

/*********************   Declare synced.  **************************************/
wire                                  rst_n           ;
wire                                  clk             ;

/*********************   Declare baudrate enable   *****************************/
wire                                  baudrate_en     ;
wire                                  baudrate_en_n   ;

/*************************** Uart config  wire declare *************************/
wire                                  low_power       ;
wire  [3    :0]                       data_bits       ;
wire  [1    :0]                       stop_bits       ;
wire  [1    :0]                       parity_mode     ;
wire  [11   :0]                       baudrate_cfg    ;
wire                                  ur_rx_fifo_full ;
wire                                  ur_rx_fifo_empty;
wire                                  ur_tx_fifo_full ;
wire                                  ur_tx_fifo_empty;
wire                                  ur_rx_interrupt ;


/****************************  Module Instance **********************************/
/**************************  status ctrl module instance ************************/
/****************************  Module Instance **********************************/
status_ctrl                           #(
    .DLY                              (DLY                )
    )
    u_status_ctrl_i
    (
    .clk_i                            (clk_i              ),
    .rst_n_i                          (rst_n_i            ),
    .ctrl_enable                      (ctrl_enable        ),
    .ctrl                             (ctrl               ),
    .ctrl_mirror                      (ctrl_mirror        ),
    .state                            (state              ),
    .low_power                        (low_power          ),
    .data_bits                        (data_bits          ),
    .parity_mode                      (parity_mode        ),
    .stop_bits                        (stop_bits          ),
    .baudrate_cfg                     (baudrate_cfg       ),
    .ur_rx_fifo_full                  (ur_rx_fifo_full    ),
    .ur_rx_fifo_empty                 (ur_rx_fifo_empty   ),
    .ur_tx_fifo_full                  (ur_tx_fifo_full    ),
    .ur_tx_fifo_empty                 (ur_tx_fifo_empty   ),
    .ur_rx_interrupt                  (ur_rx_interrupt    )
    );


/****************************  Module Instance **********************************/
/******************** Off clock, if mode is low power ***************************/
/****************************  Module Instance **********************************/
clk_mask                              u_clk_mask_i(
    .clk_i                            (clk_i              ),
    .enable                           (low_power          ),
    .clk_o                            (clk                )
    );

/****************************  Module Instance **********************************/
/**************************  Global rst sync  ***********************************/
/****************************  Module Instance **********************************/
reset_syncer                          #(
    .DLY                              (DLY                )
    )
    u_reset_syncer_i 
    (
    .clk_i                            (clk_i              ),
    .rst_n_sync_i                     (rst_n_i            ),
    .rst_n_synced_o                   (rst_n              )
    );

/****************************  Module Instance **********************************/
/************************** Baudrate generate ***********************************/
/****************************  Module Instance **********************************/
gen_baudrate_bit                      #(
    .DLY                              (DLY                ),
    .BAUDRATE_WIDTH                   (BAUDRATE_WIDTH     )
    )
    u_gen_baudrate_bit_i
    (
    .clk_i                            (clk                ),
    .rst_n_i                          (rst_n              ),
    .baudrate_cfg_i                   (baudrate_cfg       ),
    .baudrate_en_o                    (baudrate_en        ),
    .baudrate_en_n_o                  (baudrate_en_n      )
    );

/****************************  Module Instance **********************************/
/*************************** Uart rx ctrl ***************************************/
/****************************  Module Instance **********************************/
uart_rx_ctrl                          #(
    .DLY                              (DLY                ),
    .DATA_WIDTH                       (DATA_WIDTH         )
    )
    u_uart_rx_ctrl_i
    (
    .clk_i                            (clk                ),
    .rst_n_i                          (rst_n              ),
    .data_bits                        (data_bits          ),
    .parity_mode                      (parity_mode        ),
    .stop_bits                        (stop_bits          ),
    .br_en_i                          (baudrate_en        ),
    .br_en_half_i                     (baudrate_en_n      ),
    .rx_rdy_i                         (rx_rdy_i           ),
    .rx_data_o                        (rx_data_o          ),
    .rx_vld_o                         (rx_vld_o           ),
    .ur_rx_fifo_full_o                (ur_rx_fifo_full    ),
    .ur_rx_fifo_empty_o               (ur_rx_fifo_empty   ),
    .ur_rx_interrupt_o                (ur_rx_interrupt    ),
    .rx_i                             (rx                 )
    );


/****************************  Module Instance **********************************/
/************************** Uart tx ctrl  ***************************************/
/****************************  Module Instance **********************************/
uart_tx_ctrl                          #(
    .DLY                              (DLY                ),
    .DATA_WIDTH                       (DATA_WIDTH         )
    )
    u_uart_tx_ctrl_i
    (
    .clk_i                            (clk                ),
    .rst_n_i                          (rst_n              ),
    .data_bits                        (data_bits          ),
    .parity_mode                      (parity_mode        ),
    .stop_bits                        (stop_bits          ),
    .br_en_i                          (baudrate_en        ),
    .ur_tx_ctrl_data_i                (tx_data_i          ),
    .ur_tx_ctrl_vld_i                 (tx_vld_i           ),
    .ur_tx_ctrl_rdy_o                 (tx_rdy_o           ),
    .ur_tx_fifo_full_o                (ur_tx_fifo_full    ),
    .ur_tx_fifo_empty_o               (ur_tx_fifo_empty   ),
    .tx_o                             (tx                 )
    );

endmodule
