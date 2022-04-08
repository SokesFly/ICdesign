/***************************************************************************************
* Function: 
* Author: SK 
* Company: Ltd.JRLC.SK
* Right : 
* Tel : 
* Last modified:	2022-04-05 10:37
* None: 
* Filename:		uart_tx_ctrl.v
* Resverd: 
* Description: 
**************************************************************************************/
`timescale 1ns/1ps

module                                  uart_tx_ctrl #(
    parameter                           DLY         = 1,
    parameter                           DATA_WIDTH  = 8
    )(
    input  wire                         clk_i               , // Primary clk
    input  wire                         rst_n_i             , // Reset

    input  wire [3            :0]       data_bits           ,
    input  wire [1            :0]       parity_mode         ,
    input  wire [1            :0]       stop_bits           ,

    input  wire                         br_en_i             ,

    /**************************** High level IF *********************************/
    input  wire [DATA_WIDTH-1 :0]       ur_tx_ctrl_data_i   ,
    input  wire                         ur_tx_ctrl_vld_i    ,
    output wire                         ur_tx_ctrl_rdy_o    ,

    /**************************** state IF **************************************/
    output wire                         ur_tx_fifo_full_o   ,
    output wire                         ur_tx_fifo_empty_o  ,

    output wire                         tx_o
    );

/****************************  Output tx state  *********************************/
assign                                  ur_tx_ctrl_rdy_o  = ur_tx_fifo_full_o;


/****************************  REG & WIRE declare for uart tx  ******************/
reg  [DATA_WIDTH-1:0]                   ur_tx_data_r        ;
wire [DATA_WIDTH-1:0]                   ur_tx_data          ;
wire                                    ur_tx_vld           ;
wire                                    ur_tx_busy          ;


/****************************  REG & WIRE declare for FIFO  *********************/
wire [DATA_WIDTH-1:0]                   ur_tx_fifo_wr_data  ;
wire                                    ur_tx_fifo_wr_en    ;
wire [DATA_WIDTH-1:0]                   ur_tx_fifo_rd_data  ;
wire                                    ur_tx_fifo_rd_en    ;

assign                                  ur_tx_fifo_wr_data = ur_tx_ctrl_data_i;
assign                                  ur_tx_fifo_wr_en   = (~ur_tx_fifo_full_o && ur_tx_ctrl_vld_i);
assign                                  ur_tx_fifo_rd_en   = (~ur_tx_busy && ~ur_tx_fifo_empty_o && br_en_i);
assign                                  ur_tx_vld          = ur_tx_fifo_rd_en;
assign                                  ur_tx_data         = ur_tx_fifo_rd_data;
/****************************  generate uart tx data and enable  *****************/

/****************************  Module Instance **********************************/
/**************************  Uart tx FIFO instance ******************************/
/****************************  Module Instance **********************************/
async_fifo                              #(
    .DLY                                (DLY                ),
    .FIFO_WIDTH                         (DATA_WIDTH         ),
    .FIFO_DEPTH                         (8                  )
    )
    u_async_fifo_tx_i
    (
    .rst_n_i                            (rst_n_i            ),
    .wr_clk_i                           (clk_i              ),
    .wr_data_i                          (ur_tx_fifo_wr_data ),
    .wr_en_i                            (ur_tx_fifo_wr_en   ),
    .rd_clk_i                           (clk_i              ),
    .rd_data_o                          (ur_tx_fifo_rd_data ),
    .rd_en_i                            (ur_tx_fifo_rd_en   ),
    .full_o                             (ur_tx_fifo_full_o  ),
    .empty_o                            (ur_tx_fifo_empty_o )
    );


/****************************  Module Instance **********************************/
/**************************  Uart tx           **********************************/
/****************************  Module Instance **********************************/
uart_tx                         #(
    .DLY                        (DLY                ),
    .DATA_WIDTH                 (DATA_WIDTH         )
    )
    u_uart_tx_i
    (
    .clk_i                      (clk_i              ),
    .rst_n_i                    (rst_n_i            ),
    .data_bits                  (data_bits          ),
    .parity_mode                (parity_mode        ),
    .stop_bits                  (stop_bits          ),
    .tx_data_i                  (ur_tx_data         ),
    .tx_vld_i                   (ur_tx_vld          ),
    .br_en_i                    (br_en_i            ),
    .tx_busy_o                  (ur_tx_busy         ),
    .tx_o                       (tx_o               )
    );

endmodule
