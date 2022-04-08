/***************************************************************************************
* Function: 
* Author: SK 
* Company: Ltd.JRLC.SK
* Right : 
* Tel : 
* Last modified:	2022-04-05 10:30
* None: 
* Filename:		uart_tx.v
* Resverd: 
* Description: 
**************************************************************************************/
`timescale 1ns/1ps

module                             uart_tx #(
    parameter                      DLY         = 1   ,
    parameter                      DATA_WIDTH  = 8
    )(

    input  wire                     clk_i            ,    // input primary clock
    input  wire                     rst_n_i          ,    // input reset.

    input  wire [3            :0]   data_bits        ,    // Primary clock
    input  wire [1            :0]   parity_mode     ,
    input  wire [1            :0]   stop_bits        ,


    input  wire [DATA_WIDTH-1 :0]   tx_data_i        ,    // Data need to send.
    input  wire                     tx_vld_i         ,    // Data enable
    input  wire                     br_en_i          ,    // generate from primary

    output wire                     tx_busy_o        ,

    output wire                     tx_o                  //TX Phsical link
    );


/********************************************************************************
* Moore tx_flow_fsm_r, output without input.
********************************************************************************/
reg [4:0]                           tx_flow_fsm_r    ;
reg [3:0]                           tx_data_cnt_r    ;
reg                                 tx_r             ;

localparam                          IDLE      = 5'b0_0001;
localparam                          START_BIT = 5'b0_0010;
localparam                          DATA_SEND = 5'b0_0100;
localparam                          PARITY_BIT= 5'b0_1000;
localparam                          STOP_BIT  = 5'b1_0000;


/********************************************************************************
* Declare FSM jump condition signals
********************************************************************************/
wire                                go_start_bit    ;
wire                                go_data_send    ;
wire                                go_parity_bit   ;
wire                                go_stop_bit     ;
wire                                go_idle         ;


/********************************************************************************
* FSM state jump condition
********************************************************************************/
assign                              go_start_bit  = ((tx_flow_fsm_r  == IDLE) &&
                                                     (br_en_i               ));

assign                              go_data_send  = ((tx_flow_fsm_r  == START_BIT) &&
                                                     (br_en_i                    ));

assign                              go_parity_bit = ((tx_flow_fsm_r  == DATA_SEND   ) &&
                                                     (tx_data_cnt_r  == (data_bits - 4'h1)) &&
                                                     (parity_mode    != 2'b10       ) &&
                                                     (br_en_i                       ));

assign                              go_stop_bit   = (((tx_flow_fsm_r == PARITY_BIT ) &&
                                                      (br_en_i                     )) ||
                                                     ((tx_flow_fsm_r == DATA_SEND  ) &&
                                                      (parity_mode   == 2'b10       ) &&
                                                      (br_en_i                     )));

assign                              go_idle       = ((tx_flow_fsm_r == STOP_BIT) && 
                                                     (br_en_i                  ));


/********************************************************************************
* FSM state jump.
********************************************************************************/
always@(posedge clk_i or negedge rst_n_i) begin
    if(!rst_n_i) begin
        tx_flow_fsm_r <= #DLY {5{1'b0}};
    end
    else begin
        case(tx_flow_fsm_r)
            // uart tx be idle.
            IDLE:                   begin
                                        if(go_start_bit) begin
                                            tx_flow_fsm_r <= #DLY START_BIT;
                                        end
                                        else begin
                                            tx_flow_fsm_r <= #DLY IDLE ;
                                        end
                                    end

            // generate start bit on uart bus tx.
            START_BIT:              begin
                                        if(go_data_send) begin
                                            tx_flow_fsm_r <= #DLY DATA_SEND;
                                        end
                                        else begin
                                            tx_flow_fsm_r <= #DLY START_BIT;
                                        end
                                    end

            // send data to tx.
            DATA_SEND:              begin
                                        if(go_parity_bit) begin
                                            tx_flow_fsm_r <= #DLY PARITY_BIT;
                                        end
                                        else if(go_stop_bit) begin
                                            tx_flow_fsm_r <= #DLY STOP_BIT;
                                        end 
                                        else begin
                                            tx_flow_fsm_r <= #DLY DATA_SEND;
                                        end
                                    end
            // generate check bit according to PARITY_WAY
            PARITY_BIT:             begin
                                        if(go_stop_bit) begin
                                            tx_flow_fsm_r <= #DLY STOP_BIT;
                                        end
                                        else begin
                                            tx_flow_fsm_r <= #DLY PARITY_BIT;
                                        end
                                    end

            STOP_BIT:               begin
                                        if(go_idle) begin
                                            tx_flow_fsm_r <= #DLY IDLE;
                                        end
                                        else begin
                                            tx_flow_fsm_r <= #DLY STOP_BIT;
                                        end
                                    end

            default:                begin 
                                        tx_flow_fsm_r <= #DLY IDLE; 
                                    end
        endcase
    end
end


/********************************************************************************
* FSM output
********************************************************************************/

assign  tx_busy_o  = ~(tx_flow_fsm_r == IDLE);

always@(posedge clk_i or negedge rst_n_i) begin
    if(!rst_n_i) begin
        tx_data_cnt_r   <= #DLY 4'h0;
    end
    else if(tx_flow_fsm_r == START_BIT) begin
        tx_data_cnt_r   <= #DLY 4'h0;
    end
    else if((tx_flow_fsm_r == DATA_SEND) && br_en_i) begin
        tx_data_cnt_r   <= #DLY tx_data_cnt_r + 4'h1;
    end
end

always@(posedge clk_i or negedge rst_n_i) begin
    if(!rst_n_i) begin
        tx_r   <= #DLY 1'b1;
    end
    else begin
        case(tx_flow_fsm_r)
            IDLE:           begin
                                tx_r    <= #DLY 1'b1;
                            end

            START_BIT:      begin
                                tx_r    <= #DLY 1'b0;
                            end

            DATA_SEND:      begin
                                tx_r    <= #DLY (tx_data_i[tx_data_cnt_r]);
                            end

            PARITY_BIT:     begin
                                tx_r    <= ^tx_data_i;  // ODD check.
                            end

            STOP_BIT:       begin
                                tx_r    <= #DLY 1'b1;
                            end

            default:        begin
                                tx_r    <= #DLY 1'b1;
                            end
        endcase
    end
end

assign          tx_o = tx_r;

endmodule
