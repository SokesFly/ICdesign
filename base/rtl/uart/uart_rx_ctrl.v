/***************************************************************************************
* Function: 
* Author: SK 
* Company: Ltd.JRLC.SK
* Right : 
* Tel : 
* Last modified: 2022-04-06 02:50
* None: 
* Filename: ur_rx_ctrl.v
* Resverd: 
* Description: 
**************************************************************************************/
`timescale 1ns/1ps

module                                  uart_rx_ctrl #(
    parameter                           DLY         = 1     ,
    parameter                           DATA_WIDTH  = 8
    )(
    input  wire                         clk_i               ,  // Primary clk
    input  wire                         rst_n_i             ,  // Reset async

    input  wire [3           :0]        data_bits           ,  // Uart stop bit
    input  wire [1           :0]        parity_mode         ,  // Uart parity mode.
    input  wire [1           :0]        stop_bits           ,  // Uart stop bits.

    input  wire                         br_en_i             ,
    input  wire                         br_en_half_i        ,

    // Uart level wire rx.
    input  wire                         rx_rdy_i            ,
    output wire [DATA_WIDTH-1:0]        rx_data_o           ,
    output wire                         rx_vld_o            ,

    output wire                         ur_rx_fifo_full_o   ,
    output wire                         ur_rx_fifo_empty_o  ,
    output wire                         ur_rx_interrupt_o   ,

    input  wire                         rx_i
    );

/*********************  Wire for uart instance  ************************************/
wire                                    ur_rx_vld_o         ;
wire [DATA_WIDTH-1:0]                   ur_rx_data_o        ;


/*********************  Wire & Reg declare for async Write  ************************/
reg  [DATA_WIDTH-1:0]                   ur_rx_fifo_wr_data_r   ;
wire [DATA_WIDTH-1:0]                   ur_rx_fifo_wr_data     ;
wire                                    ur_rx_fifo_wr_en       ;
wire [DATA_WIDTH-1:0]                   ur_rx_fifo_rd_data     ;
wire                                    ur_rx_fifo_rd_en       ;

assign                                  ur_rx_fifo_wr_en   = ur_rx_vld_o    ;
assign                                  ur_rx_fifo_wr_data = ur_rx_fifo_wr_data_r;

assign                                  rx_data_o          = ur_rx_fifo_rd_data ;
assign                                  ur_rx_fifo_rd_en   = rx_rdy_i ;

/*********************  Data delay one clk push fifo *******************************/
always@(posedge clk_i  or negedge rst_n_i) begin
    if(!rst_n_i) begin
        ur_rx_fifo_wr_data_r <= #DLY {DATA_WIDTH{1'b0}};
    end
    else if(ur_rx_fifo_wr_en) begin
        ur_rx_fifo_wr_data_r <= #DLY ur_rx_data_o;
    end
end

/*********************  Uart rx output data from fifo ******************************/
assign                                  rx_vld_o  = (rx_rdy_i && ~ur_rx_fifo_empty_o);


/****************************  Module Instance **********************************/
/**************************  Uart rx FIFO instacne  *****************************/
/****************************  Module Instance **********************************/
async_fifo                              #(
    .DLY                                (DLY                ),
    .FIFO_WIDTH                         (DATA_WIDTH         ),
    .FIFO_DEPTH                         (8                  )
    )
    u_async_fifo_rx_i
    (
    .rst_n_i                            (rst_n_i            ),
    .wr_clk_i                           (clk_i              ),
    .wr_data_i                          (ur_rx_fifo_wr_data ),
    .wr_en_i                            (ur_rx_fifo_wr_en   ),
    .rd_clk_i                           (clk_i              ),
    .rd_data_o                          (ur_rx_fifo_rd_data ),
    .rd_en_i                            (ur_rx_fifo_rd_en   ),
    .full_o                             (ur_rx_fifo_full_o  ),
    .empty_o                            (ur_rx_fifo_empty_o )
    );


/****************************  Module Instance **********************************/
/****************************  Uart rx instance  ********************************/
/****************************  Module Instance **********************************/
uart_rx                                 #(
    .DLY                                (DLY                ),
    .DATA_WIDTH                         (DATA_WIDTH         )
    )
    u_ur_rx_i
    (
    .clk_i                              (clk_i              ),
    .rst_n_i                            (rst_n_i            ),
    .data_bits                          (data_bits          ),
    .parity_mode                        (parity_mode        ),
    .stop_bits                          (stop_bits          ),
    .br_en_i                            (br_en_i            ),
    .br_en_half_i                       (br_en_half_i       ),
    .rx_i                               (rx_i               ),
    .rx_data_o                          (ur_rx_data_o       ),
    .rx_vld_o                           (ur_rx_vld_o        ),
    .rx_interrupt_o                     (ur_rx_interrupt_o  )
    );

endmodule
