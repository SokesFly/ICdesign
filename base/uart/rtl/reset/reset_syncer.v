/***************************************************************************************
* Function: 
* Author: SK 
* Company: Ltd.JRLC.SK
* Right : 
* Tel : 
* Last modified: 2022-03-15 08:28
* None: 
* Filename: reset_syncer.v
* Resverd: 
* Description: 
**************************************************************************************/

module reset_syncer #(
    parameter       DLY     =   1
)(
    input wire      clk_i          ,    //input wire , input clock.
    input wire      rst_n_sync_i   ,    //input wire , the rst need synced.

    output wire     rst_n_synced_o      //output reg , the rst has been synced.
);

    reg             sync_d0 ;
    reg             sync_d1 ;

    always@(posedge clk_i or negedge rst_n_sync_i) begin
        if(!rst_n_sync_i) begin
            sync_d0 <= #DLY 1'b0 ;
            sync_d1 <= #DLY 1'b0 ;
        end else begin
            sync_d0 <= #DLY 1'b1 ;
            sync_d1 <= #DLY sync_d0 ;
        end
    end

    assign          rst_n_synced_o = sync_d1 ;

endmodule
