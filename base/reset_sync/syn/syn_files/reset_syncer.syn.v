/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Ultra(TM) in wire load mode
// Version   : O-2018.06-SP1
// Date      : Thu Mar 24 09:16:40 2022
/////////////////////////////////////////////////////////////


module reset_syncer ( clk_i, rst_n_sync_i, rst_n_synced_o );
  input clk_i, rst_n_sync_i;
  output rst_n_synced_o;
  wire   n4;

  DFFSXL sync_d0_reg ( .D(1'b0), .CK(clk_i), .SN(rst_n_sync_i), .Q(n4) );
  DFFSXL sync_d1_reg ( .D(n4), .CK(clk_i), .SN(rst_n_sync_i), .QN(
        rst_n_synced_o) );
endmodule

