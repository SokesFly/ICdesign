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
    parameter       FIFO_DEPTH      = 32
    )(
    /********************************************************************************
    * Declare rst 
    ********************************************************************************/
    input wire      rst_n_i     ,
    
    /********************************************************************************
    * Declare write channel.
    ********************************************************************************/
    input wire                      wr_clk_i    ,
    input wire [WRITE_WIDTH-1:0]    wr_data_i   ,
    input wire                      wr_en_i     ,
    
    /********************************************************************************
    * Declare read channel.
    ********************************************************************************/
    input wire                      rd_clk_i    ,
    output wire [READ_WIDTH-1:0]    rd_data_o   ,
    input wire                      rd_en_i     ,
    
    /********************************************************************************
    * Declare status 
    ********************************************************************************/
    output wire                     full_o      ,
    output wire                     empty_o
    );

parameter                       FIRST_EDGE      = 1'b1;
parameter                       LAST_EDGE       = 1'b1;
parameter                       MID_STAGE_NUM   = 'd3;


/********************************************************************************
* Write clock domain signals
********************************************************************************/
wire    [FIFO_WIDTH-1:0]        wr_ptr      ;
wire                            wr_valid    ;
wire    [FIFO_DEPTH  :0]        wr_cnt      ;
wire    [FIFO_DEPTH  :0]        wr_cnt_gray ;

wire                            rd_cnt_gray_synced ;

/********************************************************************************
* Read clock domain signals
********************************************************************************/
wire    [FIFO_WIDTH-1:0]        rd_ptr      ;
wire                            rd_valid    ;
wire    [FIFO_DEPTH  :0]        rd_cnt      ;
wire    [FIFO_DEPTH  :0]        rd_cnt_gray ;

wire                            wr_cnt_gray_synced ;

/********************************************************************************
* Dut dual port mem
********************************************************************************/
dual_port_mem       #(
    .DLY            (DLY            ),
    .FIFO_WIDTH     (FIFO_WIDTH     ),
    .FIFO_DEPTH     (FIFO_DEPTH     )
    )
    u_dual_port_mem_i
    (
    .rst_n_i        (rst_n_i        ),

    .wr_clk_i       (wr_clk_i       ),
    .wr_data_i      (wr_data_i      ),
    .wr_ptr_i       (wr_ptr         ),
    .wr_valid_i     (wr_valid       ),

    .rd_clk_i       (rd_clk_i       ),
    .rd_data_o      (rd_data_o      ),
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
    .wr_ptr_o       (wr_ptr         ),
    .wr_valid_o     (wr_valid       ),
    .wr_cnt_o       (wr_cnt         )
    );

/********************************************************************************
* Dut for bin2gray
********************************************************************************/
bin2gray            #(
    .DLY            (DLY            ),
    .FIFO_DEPTH     (FIFO_DEPTH     )
    )
    u_bin2gray_wr_i
    (
    .bin_i          (wr_cnt         ),
    .gray_o         (wr_cnt_gray    )
    );

/********************************************************************************
* Dut for full check
********************************************************************************/
is_full             #(
    .DLY            (DLY            ),
    .FIFO_DEPTH     (FIFO_DEPTH     )
    )
    u_is_full_i
    (
    .wr_cnt_i               (wr_cnt             ),
    .rd_cnt_gray_synced_i   (rd_cnt_gray_synced ),
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
    .rd_clk_i       (rd_clk_i       ),
    .rd_en_i        (rd_en_i        ),
    .rd_ptr_o       (rd_ptr         ),
    .rd_valid_o     (rd_valid       ),
    .rd_cnt_o       (rd_cnt         )
    );

/********************************************************************************
* Dut for bin2gray 
********************************************************************************/
bin2gray            #(
    .DLY            (DLY            ),
    .FIFO_DEPTH     (FIFO_DEPTH     )
    )
    u_bin2gray_rd_i
    (
    .bin_i          (rd_cnt         ),
    .gray_o         (rd_cnt_gray    )
    );

/********************************************************************************
* Dut for is empty
********************************************************************************/
is_empty            #(
    .DLY            (DLY            ),
    .FIFO_DEPTH     (FIFO_DEPTH     )
    )
    u_is_empty_i
    (
    .rd_cnt_i               (rd_cnt             ),
    .wr_cnt_gray_synced_i   (wr_cnt_gray_synced ),
    .empty_o                (empty              )
    );

/********************************************************************************
* CDC
********************************************************************************/
general_syncer      #(
    .DLY            (DLY            ),
    .FIRST_EDGE     (FIRST_EDGE     ),
    .LAST_EDGE      (LAST_EDGE      ),
    .MID_STAGE_NUM  (MID_STAGE_NUM  ),
    .DATA_WIDTH     (FIFO_DEPTH     )
    )
    u_general_syncer_r2w_i
    (
    .clk_i          (wr_clk_i           ),
    .rst_n_i        (rst_n_i            ),
    .data_unsync_i  (rd_cnt_gray        ),
    .data_synced_o  (rd_cnt_gray_synced )
    );


general_syncer      #(
    .DLY            (DLY            ),
    .FIRST_EDGE     (FIRST_EDGE     ),
    .LAST_EDGE      (LAST_EDGE      ),
    .MID_STAGE_NUM  (MID_STAGE_NUM  ),
    .DATA_WIDTH     (FIFO_DEPTH     )
    )
    u_general_syncer_w2r_i
    (
    .clk_i          (rd_clk_i           ),
    .rst_n_i        (rst_n_i            ),
    .data_unsync_i  (wr_cnt_gray        ),
    .data_synced_o  (wr_cnt_gray_synced )
    );

endmodule
