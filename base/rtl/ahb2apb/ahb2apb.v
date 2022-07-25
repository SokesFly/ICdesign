module ahb2apb(
    // AHB interface: global signals.
    input  wire                 hclk_i      , // The bus clock times all bus transfer, All signals timing are related to rising edge of HCLK.
    input  wire                 hresetn_i   , // The bus reset signals is avtive LOW and reset the system and the bus, This is only avtive LOW signal

    // AHB interface: Manager signals
    input  wire                 haddr       , // The byte address of the transfer, ADDR_WIDTH is recommended to be tetween 10 and 64.

    );



endmodule
