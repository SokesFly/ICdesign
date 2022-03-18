/***************************************************************************************
* Function: 
* Author: SK 
* Company: Ltd.JRLC.SK
* Right : 
* Tel : 
* Last modified: 2022-03-18 04:40
* None: 
* Filename: general_syncer_tb.v
* Resverd: 
* Description: 
**************************************************************************************/

module general_syncer_tb;
    parameter   DLY             = 1;
    parameter   FIRST_EDGE      = 1;
    parameter   LAST_EDGE       = 1;
    parameter   MID_STAGE_NUM   = 3;
    parameter   DATA_WIDTH      = 8;

    reg                             clk_i;
    reg                             rst_n_i;
    reg [DATA_WIDTH - 1 : 0]        data_unsync_i;
    reg [DATA_WIDTH - 1 : 0]        data_synced_i;

    /*************************************************************************
    * Dut
    **************************************************************************/
   general_syncer #()u_general_syncer_i();

endmodule
