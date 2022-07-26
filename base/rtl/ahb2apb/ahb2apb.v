module ahb2apb #(
    parameter                               ADDR_WIDTH    = 32,
    parameter                               HBURST_WIDTH  = 3 ,
    parameter                               HPROT_WIDTH   = 0 ,  // 0 or 4 or 7
    parameter                               DATA_WIDTH    = 32,  // 8,16,32,64,128,256.512,1024
    )
    (
    // AHB interface: global signals.
    input  wire                             hclk_i       , // The bus clock times all bus transfer, All signals timing are related to rising edge of HCLK.
    input  wire                             hresetn_i    , // The bus reset signals is avtive LOW and reset the system and the bus, This is only avtive LOW signal

    // AHB interface: Manager signals
    input  wire [ADDR_WIDTH-1   :0]         haddr_i      , // The byte address of the transfer, ADDR_WIDTH is recommended to be tetween 10 and 64.
    input  wire [HBURST_WIDTH-1 :0]         hburst_i     , // Indicates how many transfers are in the burst and how the address increments. HBURST_WIDTH must be 0 or 3
    input  wire                             hmastlock_i  , // Indicates that the current transfer is a part of a locked seqence. Tt has the same timing as the address and control signal
    input  wire [HPROT_WIDTH-1  :0]         hprot_i      , // Protection control signal, Which provides information about the access type.
    input  wire [2              :0]         hsize_i      , // Indicates the size of, width is 3
    input  wire                             hnonsec_i    , // Indicates whether the transfers is Non-secure or Secure. This signal is supoorted if the AHB5 Secure_Transfers property is Ture
    input  wire                             hexcl_i      , // Indicates whether the transfer is part of an Exclusive Access sequence.
    input  wire                             hmaster_i    , // Manager identifier. Generated by a Manager if it has multiple Exclusive capable threads.
    input  wire [1              :0]         hrans_i      , // Indicates the transfer type, This can be: IDLE,BUSY,NONOSEQUENCETIAL, SEQUENCETIAL
    input  wire [DATA_WIDTH-1   :0]         hwdata_i     , // transfer data from the Manager to the subordinate during write opertaions.However, ang value smaller than 32 or lager than 256 is not recommended.
    input  wire [DATA_WIDTH/8-1 :0]         hwstrb_i     , // Write strobes. Deasserted to Indicate when active write data bytes lanes do not contain valid data.
    input  wire                             hwrite_i     , // Indicates the transfer direction. When HIGH this signal indicate a write transfer and when LOW a read trasnfer. It has the same timing as the address signals
    // AHB subordinate signals
    output wire [DATA_WIDTH-1   :0]         hrdata_o     , // During read operations, the read data bus transfer data from the selected Subordinate to the multipexor.
    output wire                             hready_o     , // When HIGH, the HREADY signal indicates to the Manager and all Subordinates, that the previus transfer is complete.
    output wire                             hreadyout_o  , // When HIGH, the HOUT signal indicate that a trasnfer has finsihed on the bus.
    output wire                             hresp_o      , // When LOW,the HRESP signal indicate the transfer status is OKAY, or LOW indicate ERROR.
    output wire                             hexokay_o    , // Exclusive Okay,Indicates the success or failure of an Exclusive transfer.

    // APB interface
    input  wire                             pclk_i       , // The APB bus clock time all APB bus transfer.
    input  wire                             presetn_i     , // The APB bus reset signals is LOW actice.
    output wire [ADDR_WIDTH-1   :0]         paddr_o      , // PADDR is the APB address bus. 
    output wire                             psel_o       , // The requester generates a PSELx signal for each Completer.
    output wire                             penabe_o     , // PENABLE indicate the second and subsequent cycles of an APB transfer.
    output wire [DATA_WIDTH-1   :0]         pwdate_o     , // The PWDATA write data bus is driven by the APB bridge Requester during write cycles when PWRITE is HIGH.
    input  wire [DATA_WIDTH-1   :0]         prdata_i     , // The PRDATA read data bus is driven by the APB bridge Requester druing read cycles when PWRITE is LOW.
    input  wire                             pready_i       // PREADY is used to exend an APB transfer by the completer.
);

// AHB fsm signals declare.
enum {AHB_ADDR_PHASE=32'd0, AHC_DATA_PHASE} ahbfsm_c, ahbfsm_n;

// APB fsm signals declare.
enum {APB_IDLE=32'd0, APB_SETUP, APB_ACCESS} apbfsm_c, apbfsm_n;

// APB fsm state jump
always@(posedge pclk_i or negedge presetn_i)
begin
    if(!presetn_i) begin
        apbfsm_c <= APB_IDLE;
    end
    else begin
        apbfsm_c <= apbfsm_n;
    end
end

endmodule
