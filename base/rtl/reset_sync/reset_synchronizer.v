/***************************************************************************************
* Function: 
* Author: SK 
* Company: Ltd.JRLC.SK
* Right : 
* Tel : 
* Last modified:	2022-03-15 10:04
* None: 
* Filename:		reset_synchronizer.v
* Resverd: 
* Description: 
**************************************************************************************/

module reset_synchronizer #(
    parameter       DLY      = 1,
    parameter       EDGE_WAY = 1  // 1 -- Rising , 0 -- falling
)(
    /*************************************************************************
    * Declare reset
    **************************************************************************/
    input wire      rst_n_i ,

    /*************************************************************************
    * Declare input clock & data
    **************************************************************************/
    input wire      clk_0_i , 
    input wire      data_i  ,

    /*************************************************************************
    * Declare output clock & data
    **************************************************************************/
    input wire      clk_1_i ,
    output reg      data_o
);
    /*************************************************************************
    * Declare common signal
    **************************************************************************/
    wire            rst_synced ;
    reg             data_d1  ;
    reg             data_d2  ;
    reg             data_o_r ;
    reg             data_cross_domain ;

    /*************************************************************************
    * input data buffer
    **************************************************************************/
    always@(posedge clk_0_i or negedge rst_synced) begin
        if(!rst_synced) begin
            data_cross_domain <= #DLY   1'b0 ;
        end else begin
            data_cross_domain <= #DLY   data_i ;
        end
    end

    /*************************************************************************
    * Slow 2 fast , edge synchornizer
    **************************************************************************/
    always@(posedge clk_1_i or negedge rst_synced) begin
        if(!rst_synced) begin
            data_d1 <= #DLY     1'b0 ;
        end else begin
            data_d1 <= #DLY     data_cross_domain ;
        end
    end

    always@(posedge clk_1_i or negedge rst_synced) begin
        if(!rst_synced) begin
            data_d2 <= #DLY     1'b0 ;
        end else begin
            data_d2 <= #DLY     data_d1 ;
        end
    end

    always@(posedge clk_1_i or negedge rst_synced) begin
        if(!rst_synced) begin
            data_o_r <= #DLY     1'b0 ;
        end else begin
            data_o_r <= #DLY     data_d2 ;
        end
    end

    /*************************************************************************
    * clk_1_i domain output
    **************************************************************************/
    assign      data_o = ( EDGE_WAY ) ? ( data_d2 && !data_o_r ) : ( !data_d2 && data_o_r );

    /*************************************************************************
    * reset sync module
    **************************************************************************/
    reset_syncer #(
        .DLY    ( 1 )
    )u_reset_syncer_i(
        .clk_i         ( clk_0_i    ),
        .rst_n_sync_i  ( rst_n_i    ),
        .rst_n_synced_o( rst_synced )
    );

endmodule
