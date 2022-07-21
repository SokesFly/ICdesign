module                              spi_apb_if #(
    parameter                       ADDR_WIDE   = 32,
    parameter                       DATA_WIDE   = 32,
    parameter                       REG_WIDE    = 32
    )(
    //SPI controll lane interface with APB protocol
    input  wire                     pclk_i      , //APB clock
    input  wire                     prstn_i     , //APB async reset
    input  wire [ADDR_WIDE-1 :0]    paddr_i     , //APB paddress
    input  wire                     pwrite_i    , //APB pwrite
    input  wire                     psel_i      , //APB pselect
    input  wire                     penable_i   , //APB penable
    input  wire [DATA_WIDE-1 :0]    pwdata_i    , //APB pwdata
    output wire [DATA_WIDE-1 :0]    prdata_o    , //APB prdata
    output wire                     pready_o     //APB pready

    //SPI data if with async fifo
    /*
    //Register sync output
    input  wire                     clk_i       , //SPI module primary
    input  wire                     rstn_i      , //SPI module async reset
    output wire [REG_WIDE-1  :0]    cfg_o       ,
    output wire [REG_WIDE-1  :0]    addr_o      ,
    output wire [REG_WIDE-1  :0]    operation_o ,
    output wire [REG_WIDE-1  :0]    len_o       ,
    output wire [REG_WIDE-1  :0]    data_o      ,
    input  wire [REG_WIDE-1  :0]    data_i
    */
    );


// No wait IO
assign          pready_o = penable_i  ;

//

endmodule
