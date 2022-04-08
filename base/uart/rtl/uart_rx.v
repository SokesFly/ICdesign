/***************************************************************************************
* Function: 
* Author: SK 
* Company: Ltd.JRLC.SK
* Right : 
* Tel : 
* Last modified: 2022-04-06 02:57
* None: 
* Filename: uart_rx.v
* Resverd: 
* Description: 
**************************************************************************************/

`timescale 1ns/1ps

module                              uart_rx #(
    parameter                       DLY           = 1,
    parameter                       DATA_WIDTH    = 8
    )(
    input  wire                     clk_i           ,    // Primary clock
    input  wire                     rst_n_i         ,    // Reset.

    input  wire [3           :0]    data_bits       ,
    input  wire [1           :0]    parity_mode     ,
    input  wire [1           :0]    stop_bits       ,

    input  wire                     br_en_i         ,
    input  wire                     br_en_half_i    ,

    input  wire                     rx_i            ,
    output wire [DATA_WIDTH-1:0]    rx_data_o       ,
    output wire                     rx_vld_o        ,
    output wire                     rx_interrupt_o
    );


/************************** IF register & wire *************************************/
reg  [DATA_WIDTH-1  :0]             rx_data_r       ;
reg                                 rx_vld_r        ;

/************************** Inner register & wire **********************************/
reg  [4             :0]             rx_flow_fsm_r   ;
reg  [3             :0]             rx_data_cnt_r   ;
wire                                rx_synced       ;
reg                                 rx_synced_d1    ;
wire                                rx_fall_edge    ;

/************************** Decalre FSM ********************************************/
wire                                go_idle         ;
wire                                go_start_bit    ;
wire                                go_data         ;
wire                                go_parity       ;
wire                                go_stop_bit     ;

localparam                          IDLE        =  5'b0_0001;
localparam                          START_BIT   =  5'b0_0010;
localparam                          DATA        =  5'b0_0100;
localparam                          PARITY      =  5'b0_1000;
localparam                          STOP_BIT    =  5'b1_0000;

/************************** interface link *****************************************/

assign                              rx_data_o      =  rx_data_r;
assign                              rx_vld_o       =  rx_vld_r;
assign                              rx_interrupt_o = rx_vld_r;


/**************************  FSM state ctrl ****************************************/
assign                              go_start_bit   = ((rx_flow_fsm_r == IDLE) && (rx_fall_edge));

assign                              go_data        = ((rx_flow_fsm_r == START_BIT) && (br_en_i));

assign                              go_parity      = ((rx_flow_fsm_r == DATA) &&
                                                      (rx_data_cnt_r == (data_bits - 4'h1)) &&
                                                      (br_en_i));

assign                              go_stop_bit    = (((rx_flow_fsm_r == PARITY) &&
                                                      ((parity_mode   == 2'b00) || (parity_mode == 2'b01)) &&
                                                      (br_en_i)) ||
                                                     ((rx_flow_fsm_r == DATA) &&
                                                      ((parity_mode == 2'b10) || (parity_mode == 2'b11)) &&
                                                      (br_en_i)));

assign                              go_idle        = ((rx_flow_fsm_r == STOP_BIT) &&
                                                   (br_en_i));

/**************************  FSM state jump ****************************************/
always@(posedge clk_i or negedge rst_n_i) begin
    if(!rst_n_i) begin
        rx_flow_fsm_r <= #DLY IDLE;
    end
    else begin
        case(rx_flow_fsm_r)
            IDLE:                   begin
                                        if(go_start_bit) begin
                                            rx_flow_fsm_r <= #DLY START_BIT;
                                        end
                                        else begin
                                            rx_flow_fsm_r <= #DLY IDLE;
                                        end
                                    end

            START_BIT:              begin
                                        if(go_data) begin
                                            rx_flow_fsm_r <= #DLY DATA;
                                        end
                                        else begin
                                            rx_flow_fsm_r <= #DLY START_BIT;
                                        end
                                    end

            DATA:                   begin
                                        if(go_parity) begin
                                            rx_flow_fsm_r <= #DLY PARITY;
                                        end
                                        else if(go_stop_bit) begin
                                            rx_flow_fsm_r <= #DLY STOP_BIT;
                                        end
                                        else begin
                                            rx_flow_fsm_r <= #DLY DATA;
                                        end
                                    end

            PARITY:                 begin
                                        if(go_stop_bit) begin
                                            rx_flow_fsm_r <= #DLY STOP_BIT;
                                        end
                                        else begin
                                            rx_flow_fsm_r <= #DLY PARITY;
                                        end
                                    end

            STOP_BIT:               begin
                                        if(go_idle) begin
                                            rx_flow_fsm_r <= #DLY IDLE;
                                        end
                                        else begin
                                            rx_flow_fsm_r <= #DLY STOP_BIT;
                                        end
                                    end

            default:                begin
                                        rx_flow_fsm_r <= #DLY IDLE;
                                    end
        endcase
    end
end


/**************************  FSM outpupt ****************************************/
always@(posedge clk_i or negedge rst_n_i) begin
    if(!rst_n_i) begin
        rx_data_cnt_r <= #DLY 4'h0;
    end
    else if(rx_flow_fsm_r == START_BIT) begin
        rx_data_cnt_r <= #DLY 4'h0;
    end
    else if((rx_flow_fsm_r == DATA) && br_en_i) begin
        rx_data_cnt_r <= #DLY rx_data_cnt_r + 4'h1;
    end
end

always@(posedge clk_i or negedge rst_n_i) begin
    if(!rst_n_i) begin
        rx_data_r <= #DLY {DATA_WIDTH{1'b0}};
    end
    else if(rx_flow_fsm_r == IDLE) begin
        rx_data_r <= #DLY {DATA_WIDTH{1'b0}};
    end
    else if((rx_flow_fsm_r == DATA) && (br_en_half_i)) begin
        rx_data_r <= #DLY {rx_synced_d1,rx_data_r[7:1]};    // LSB
    end
end

always@(posedge clk_i or negedge rst_n_i) begin
    if(!rst_n_i) begin
        rx_synced_d1 <= #DLY {1'b0};
    end
    else begin
        rx_synced_d1 <= #DLY rx_synced;
    end
end

assign  rx_fall_edge = (~rx_synced && rx_synced_d1);

always@(posedge clk_i or negedge rst_n_i) begin
    if(!rst_n_i) begin
        rx_vld_r <= #DLY 1'b0;
    end
    else if(rx_data_cnt_r == (data_bits - 4'h1) && br_en_half_i) begin
        rx_vld_r <= #DLY 1'b1;
    end
    else begin
        rx_vld_r <= #DLY 1'b0;
    end
end

general_syncer              #(
    .DLY                    (1              ),
    .FIRST_EDGE             (1              ),
    .LAST_EDGE              (1              ),
    .MID_STAGE_NUM          (3              ),
    .DATA_WIDTH             (1              )
    )
    u_general_syncer_i
    (
    .clk_i                  (clk_i          ),
    .rst_n_i                (rst_n_i        ),
    .data_unsync_i          (rx_i           ),
    .data_synced_o          (rx_synced      )
    );

endmodule
