module                              spi_master_controller #(
    parameter                       DLY       = 1,
    parameter                       REG_WIDTH = 32
    )(
    input  wire                     clk_i       ,  //Module primary clock input
    input  wire                     rstn_i      ,  //Module sync reset input

    //SPI IF signals
    input  wire [REG_WIDTH-1   :0]  cfg_i       ,  //SPI config register in
    input  wire [REG_WIDTH-1   :0]  addr_i      ,  //Device addr
    input  wire [REG_WIDTH-1   :0]  operation_i ,  //Write or read
    input  wire [REG_WIDTH-1   :0]  len_i       ,  //Wirte or read lengt
    input  wire [REG_WIDTH-1   :0]  data_i      ,  //Op data input
    output wire [REG_WIDTH-1   :0]  data_o         //Data output receive from spi rx
    );

//TOP-FSM declare
/* verilog
reg  [2:0]                          ctrl_fsm_cs ;
reg  [2:0]                          ctrl_fsm_ns ;
localparam                          CTRL_ILDE   = 3'b001;
localparam                          CTRL_WRITE  = 3'b010;
localparam                          CTRL_READ   = 3'b100;
*/
wire [REG_WIDTH-1   :0]  cfg_synced_o       ,  //SPI config register in
wire [REG_WIDTH-1   :0]  addr_synced_o      ,  //Device addr
wire [REG_WIDTH-1   :0]  operation_synced_o ,  //Write or read
wire [REG_WIDTH-1   :0]  len_synced_o       ,  //Wirte or read lengt
wire [REG_WIDTH-1   :0]  data_synced_o      ,  //Op data input

typedef enum bit [2:0] {
    CTRL_ILDE,
    CTRL_WRITE,
    CTRL_READ
} ctrl_fsm_cs, ctrl_fsm_ns;

//TOP-FSM status controll signals
reg                                 to_ctrl_write_r;
reg                                 to_ctrl_read_r ;
reg                                 to_ctrl_idle_r ;

//TOP-FSM status transfer
always@(posedge clk_i or negedge rstn_i) begin
    if(!rstn_i) begin
        ctrl_fsm_cs  <= #DLY  CTRL_ILDE;
    end
    else begin
        ctrl_fsm_cs  <= #DLY  ctrl_fsm_ns;
    end
end

//TOP-FSM status jump
always@(ctrl_fsm_cs) begin
    case(ctrl_fsm_cs)
        CTRL_ILDE:      begin
                        end
        CTRL_WRITE:     begin
                        end
        CTRL_READ:      begin
                        end
    endcase
end

//TOP-OUTPUT 
always@(posedge clk_i or negedge rstn_i) begin
end

endmodule
