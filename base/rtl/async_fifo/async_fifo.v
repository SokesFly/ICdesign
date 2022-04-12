/***************************************************************************************
* Function: general aync fifo
* Author: SK 
* Company: Ltd.JRLC.SK
* Right : 
* Tel : 
* Last modified: 2022-03-24 10:15
* None: 
* Filename: async_fifo.v
* Resverd: 
* Description: 
**************************************************************************************/

module async_fifo #(
    parameter       DLY             = 1,
    parameter       WRITE_WIDTH     = 8,
    parameter       READ_WIDTH      = 8,
    parameter       FIFO_WIDTH      = 8,
    parameter       FIFO_DEPTH      = 32,
    parameter       FIRST_EDGE      = 1'b1,
    parameter       LAST_EDGE       = 1'b1,
    parameter       MID_STAGE_NUM   = 4'h3,
    parameter       ADDR            = $clog2(FIFO_DEPTH)
    )(
    /********************************************************************************
    * Declare rst 
    ********************************************************************************/
    input wire      rst_n_i     ,
    
    /********************************************************************************
    * Declare write channel.
    ********************************************************************************/
    input wire                      wr_clk_i    ,
    input wire  [FIFO_WIDTH-1:0]    wr_data_i   ,
    input wire                      wr_en_i     ,
    
    /********************************************************************************
    * Declare read channel.
    ********************************************************************************/
    input wire                      rd_clk_i    ,
    output wire [FIFO_WIDTH-1:0]    rd_data_o   ,
    input wire                      rd_en_i     ,
    
    /********************************************************************************
    * Declare status 
    ********************************************************************************/
    output wire                     full_o      ,
    output wire                     empty_o
    );

/********************************************************************************
* Write clock domain signals
********************************************************************************/
wire    [ADDR-1:0]        wr_ptr       ;
wire                      wr_valid     ;
wire    [FIFO_WIDTH -1 :0]wr_vdata     ;
wire    [ADDR : 0]        wr_addr      ;
wire    [ADDR : 0]        wr_addr_gray ;
wire    [ADDR : 0]        rd_addr_gray_synced ;

/********************************************************************************
* Read clock domain signals
********************************************************************************/
wire    [ADDR-1:0]        rd_ptr        ;
wire                      rd_valid      ;
wire    [FIFO_WIDTH -1 :0]rd_vdata      ;
wire    [ADDR  :0]        rd_addr       ;
wire    [ADDR  :0]        rd_addr_gray  ;
wire    [ADDR  :0]        wr_addr_gray_synced ;

/********************************************************************************
* Dut dual port mem
********************************************************************************/
dual_port_mem       #(
    .DLY            (DLY                ),
    .FIFO_WIDTH     (FIFO_WIDTH         ),
    .FIFO_DEPTH     (FIFO_DEPTH         )
    )
    u_dual_port_mem_i
    (
    .rst_n_i        (rst_n_i        ),

    .wr_clk_i       (wr_clk_i       ),
    .wr_data_i      (wr_vdata       ),
    .wr_ptr_i       (wr_ptr         ),
    .wr_valid_i     (wr_valid       ),

    .rd_clk_i       (rd_clk_i       ),
    .rd_data_o      (rd_vdata       ),
    .rd_ptr_i       (rd_ptr         ),
    .rd_valid_i     (rd_valid       )
    );

/********************************************************************************
* Dut write ctrl
********************************************************************************/
write_ctrl          #(
    .DLY            (DLY            ),
    .FIFO_WIDTH     (FIFO_WIDTH     ),
    .FIFO_DEPTH     (FIFO_DEPTH     )
    )
    u_write_ctrl_i
    (
    .wr_clk_i       (wr_clk_i       ),
    .rst_n_i        (rst_n_i        ),
    .wr_en_i        (wr_en_i        ),
    .wr_data_i      (wr_data_i      ),
    .full_o         (full_o         ),

    .wr_ptr_o       (wr_ptr         ),
    .wr_valid_o     (wr_valid       ),
    .wr_vdata_o     (wr_vdata       ),
    .wr_addr_o       (wr_addr         )
    );

/********************************************************************************
* Dut for bin2gray
********************************************************************************/
bin2gray            #(
    .DLY            (DLY            ),
    .WIDTH          (ADDR + 1       )
    )
    u_bin2gray_wr_i
    (
    .bin_i          (wr_addr         ),
    .gray_o         (wr_addr_gray    )
    );

/********************************************************************************
* Dut for full check
********************************************************************************/
if_full             #(
    .FIFO_DEPTH     (FIFO_DEPTH     )
    )
    u_if_full_i
    (
    .wr_addr_gray_i          (wr_addr_gray        ),
    .rd_addr_gray_synced_i   (rd_addr_gray_synced ),
    .full_o                 (full_o             )
    );

/********************************************************************************
* Dut read ctrl
********************************************************************************/
read_ctrl          #(
    .DLY            (DLY            ),
    .FIFO_WIDTH     (FIFO_WIDTH     ),
    .FIFO_DEPTH     (FIFO_DEPTH     )
    )
    u_read_ctrl_i
    (
    .rst_n_i        (rst_n_i        ),

    .rd_clk_i       (rd_clk_i       ),
    .rd_en_i        (rd_en_i        ),
    .rd_data_i      (rd_vdata       ),
    .empty_i        (empty_o        ),

    .rd_ptr_o       (rd_ptr         ),
    .rd_valid_o     (rd_valid       ),
    .rd_vdata_o     (rd_data_o      ),
    .rd_addr_o       (rd_addr         )
    );

/********************************************************************************
* Dut for bin2gray 
********************************************************************************/
bin2gray            #(
    .DLY            (DLY            ),
    .WIDTH          (ADDR + 1       )
    )
    u_bin2gray_rd_i
    (
    .bin_i          (rd_addr         ),
    .gray_o         (rd_addr_gray    )
    );

/********************************************************************************
* Dut for if empty
********************************************************************************/
if_empty            #(
    .FIFO_DEPTH     (FIFO_DEPTH     )
    )
    u_if_empty_i
    (
    .rd_addr_gray_i          (rd_addr_gray        ),
    .wr_addr_gray_synced_i   (wr_addr_gray_synced ),
    .empty_o                 (empty_o             )
    );

/********************************************************************************
* CDC
********************************************************************************/
general_syncer      #(
    .DLY            (DLY            ),
    .FIRST_EDGE     (FIRST_EDGE     ),
    .LAST_EDGE      (LAST_EDGE      ),
    .MID_STAGE_NUM  (MID_STAGE_NUM  ),
    .DATA_WIDTH     (ADDR + 1       )
    )
    u_general_syncer_r2w_i
    (
    .clk_i          (wr_clk_i            ),
    .rst_n_i        (rst_n_i             ),
    .data_unsync_i  (rd_addr_gray        ),
    .data_synced_o  (rd_addr_gray_synced )
    );

general_syncer      #(
    .DLY            (DLY            ),
    .FIRST_EDGE     (FIRST_EDGE     ),
    .LAST_EDGE      (LAST_EDGE      ),
    .MID_STAGE_NUM  (MID_STAGE_NUM  ),
    .DATA_WIDTH     (ADDR + 1       )
    )
    u_general_syncer_w2r_i
    (
    .clk_i          (rd_clk_i            ),
    .rst_n_i        (rst_n_i             ),
    .data_unsync_i  (wr_addr_gray        ),
    .data_synced_o  (wr_addr_gray_synced )
    );

endmodule
