/***************************************************************************************
* Function: 
* Author: SK 
* Company: Ltd.JRLC.SK
* Right : 
* Tel : 
* Last modified: 2022-04-07 08:39
* None: 
* Filename: status_ctrl.v
* Resverd: 
* Description: 
**************************************************************************************/
module                                  status_ctrl #(
    parameter                           DLY     =   1
    )(
    input  wire                         clk_i           ,
    input  wire                         rst_n_i         ,

    input  wire                         ctrl_enable     ,
    input  wire [31 : 0]                ctrl            ,
    output wire [31 : 0]                ctrl_mirror     ,
    output wire [31 : 0]                state           ,

    output wire                         low_power       ,
    output wire [3  : 0]                data_bits       ,
    output wire [1  : 0]                stop_bits       ,
    output wire [1  : 0]                parity_mode     ,
    output wire [11 : 0]                baudrate_cfg    ,

    input  wire                         ur_rx_fifo_full ,
    input  wire                         ur_rx_fifo_empty,
    input  wire                         ur_tx_fifo_full ,
    input  wire                         ur_tx_fifo_empty,
    input  wire                         ur_rx_interrupt
    );

reg [31:0]                              ctrl_r          ;
reg [31:0]                              ctrl_mirror_r   ;
reg [31:0]                              state_r         ;

/**************************** ctrl manager *********************************/
always@(posedge clk_i or negedge rst_n_i) begin
    if(!rst_n_i) begin
        ctrl_r   <= #DLY  32'd0;
    end
    else if(ctrl_enable) begin
        ctrl_r   <= #DLY  ctrl;
    end
end


always@(posedge clk_i or negedge rst_n_i) begin
    if(!rst_n_i) begin
        ctrl_mirror_r   <= #DLY  32'd0;
    end
    else if(ctrl_enable) begin
        ctrl_mirror_r   <= #DLY  ctrl_r;
    end
end


/**************************** Status update *********************************/
always@(posedge clk_i or negedge rst_n_i) begin
    if(!rst_n_i) begin
        state_r   <= #DLY  32'd0;
    end
    else begin
        state_r   <= #DLY  {27'd0,ur_rx_interrupt,ur_rx_fifo_empty,ur_rx_fifo_full,ur_tx_fifo_empty,ur_tx_fifo_full};
    end
end

assign  state       =  state_r;


/**************************** config assign *********************************/
assign  ctrl_mirror = ctrl_mirror_r ;
assign  low_power   = ctrl[0 : 0]   ;
assign  parity_mode = ctrl[2 : 1]   ;
assign  stop_bits   = ctrl[4 : 3]   ;
assign  data_bits   = ctrl[8 : 5]   ;
assign  baudrate_cfg= ctrl[24: 9]   ;

endmodule
