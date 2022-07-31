debImport "-sv" "-f" "/home/soke/ICdesign/base/sim/../tb/ahb2apb/filelist.f" "-f" \
          "/home/soke/ICdesign/base/sim/../rtl/ahb2apb/filelist.f"
debLoadSimResult /home/soke/ICdesign/base/sim/tb.fsdb
wvCreateWindow
wvRestoreSignal -win $_nWave2 "/home/soke/ICdesign/base/sim/signal.rc" \
           -overWriteAutoAlias on -appendSignals on
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "transmit_complete" -line 63 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSetCursor -win $_nWave2 623.272788 -snap {("G3" 2)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "transmited_cnt" -line 71 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "transmited_tgt" -line 70 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSetCursor -win $_nWave2 624.403954 -snap {("G3" 2)}
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 251.118982 800.865941
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
srcDeselectAll -win $_nTrace1
debReload
debReload
debReload
debReload
debReload
wvSelectSignal -win $_nWave2 {( "G3" 2 )} 
wvSetCursor -win $_nWave2 620.254023 -snap {("G3" 2)}
debReload
debReload
debReload
debReload
debReload
debReload
wvSetCursor -win $_nWave2 659.800421 -snap {("G3" 1)}
wvSetCursor -win $_nWave2 658.759726 -snap {("G3" 1)}
wvZoomOut -win $_nWave2
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvSetCursor -win $_nWave2 351.754799 -snap {("G1" 5)}
wvSetCursor -win $_nWave2 659.800421 -snap {("G3" 2)}
wvSetCursor -win $_nWave2 328.859516 -snap {("G3" 1)}
wvSetCursor -win $_nWave2 663.963200 -snap {("G3" 1)}
wvSetCursor -win $_nWave2 347.592020 -snap {("G1" 5)}
wvSetCursor -win $_nWave2 653.556253 -snap {("G3" 1)}
srcDeselectAll -win $_nTrace1
wvSetCursor -win $_nWave2 341.347852 -snap {("G1" 5)}
wvSetCursor -win $_nWave2 380.894249 -snap {("G1" 5)}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "go_ahb_idle" -line 117 -pos 1 -win $_nTrace1
srcSelect -signal "go_ahb_end" -line 116 -pos 1 -win $_nTrace1
srcSelect -signal "go_ahb_transmit" -line 115 -pos 1 -win $_nTrace1
srcSelect -signal "go_ahb_start" -line 113 -pos 1 -win $_nTrace1
wvSetPosition -win $_nWave2 {("G1" 3)}
wvSetPosition -win $_nWave2 {("G1" 4)}
wvAddSignal -win $_nWave2 "/ahb2apb_tb/go_ahb_idle" "/ahb2apb_tb/go_ahb_end" \
           "/ahb2apb_tb/go_ahb_transmit" "/ahb2apb_tb/go_ahb_start"
wvSetPosition -win $_nWave2 {("G1" 4)}
wvSetPosition -win $_nWave2 {("G1" 8)}
wvSetCursor -win $_nWave2 618.172634 -snap {("G1" 6)}
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvSelectSignal -win $_nWave2 {( "G1" 6 )} 
wvSetCursor -win $_nWave2 630.660970 -snap {("G1" 6)}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "go_ahb_idle" -line 117 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "go_ahb_end" -line 116 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -word -line 115 -pos 11 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "hresp_o" -line 116 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "transmit_complete" -line 116 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
wvSetCursor -win $_nWave2 703.509597 -snap {("G1" 6)}
wvSetCursor -win $_nWave2 645.230695 -snap {("G1" 6)}
wvSetCursor -win $_nWave2 624.416802 -snap {("G1" 6)}
srcDeselectAll -win $_nTrace1
srcSelect -signal "ahbfsm_trans_reg" -line 115 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -word -line 115 -pos 11 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "hresp_o" -line 116 -pos 1 -win $_nTrace1
wvSelectSignal -win $_nWave2 {( "G1" 4 )} 
wvZoom -win $_nWave2 501.614831 865.857966
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G2" 2 )} 
srcDeselectAll -win $_nTrace1
srcSelect -signal "ahbfsm_trans_reg" -line 116 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -word -line 115 -pos 11 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "hresp_o" -line 116 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "transmit_complete" -line 116 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "hresp_o" -line 116 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "hresp_o" -line 116 -pos 1 -win $_nTrace1
debReload
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 308.908517 -snap {("G1" 8)}
wvSetCursor -win $_nWave2 703.318499 -snap {("G2" 1)}
wvSetCursor -win $_nWave2 1017.743240 -snap {("G3" 2)}
wvSetCursor -win $_nWave2 650.914376 -snap {("G3" 2)}
wvZoom -win $_nWave2 535.073682 1064.631140
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 699.354285 -snap {("G1" 9)}
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 653.613749 -snap {("G3" 1)}
wvSetCursor -win $_nWave2 621.534546 -snap {("G3" 1)}
wvSetCursor -win $_nWave2 659.628599 -snap {("G1" 9)}
wvSetCursor -win $_nWave2 616.522171 -snap {("G1" 10)}
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 0.000000 9238.810288
wvZoom -win $_nWave2 0.000000 1145.560007
wvSetCursor -win $_nWave2 583.894050 -snap {("G3" 1)}
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 620.218007 -snap {("G3" 1)}
wvSetCursor -win $_nWave2 340.469325 -snap {("G3" 1)}
wvSetCursor -win $_nWave2 650.578329 -snap {("G3" 1)}
wvSetCursor -win $_nWave2 344.806514 -snap {("G3" 1)}
wvSelectSignal -win $_nWave2 {( "G1" 8 )} 
wvSelectSignal -win $_nWave2 {( "G1" 5 6 7 8 )} 
wvSetPosition -win $_nWave2 {("G1" 7)}
wvSetPosition -win $_nWave2 {("G1" 8)}
wvSetPosition -win $_nWave2 {("G1" 9)}
wvSetPosition -win $_nWave2 {("G1" 10)}
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G2" 1)}
wvSetPosition -win $_nWave2 {("G2" 3)}
wvSetPosition -win $_nWave2 {("G2" 4)}
wvSetPosition -win $_nWave2 {("G3" 0)}
wvSetPosition -win $_nWave2 {("G3" 1)}
wvSetPosition -win $_nWave2 {("G3" 2)}
wvSetPosition -win $_nWave2 {("G3" 3)}
wvSetPosition -win $_nWave2 {("G4" 0)}
wvSetPosition -win $_nWave2 {("G5" 0)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G5" 4)}
wvSetPosition -win $_nWave2 {("G5" 4)}
wvSetCursor -win $_nWave2 409.864347 -snap {("G6" 0)}
wvSetCursor -win $_nWave2 247.219765 -snap {("G5" 2)}
wvSetCursor -win $_nWave2 331.794948 -snap {("G3" 3)}
wvSelectSignal -win $_nWave2 {( "G2" 4 )} 
wvSetCursor -win $_nWave2 490.102341 -snap {("G2" 4)}
wvSetCursor -win $_nWave2 654.915517 -snap {("G1" 5)}
wvSetCursor -win $_nWave2 342.637920 -snap {("G3" 1)}
wvSetCursor -win $_nWave2 659.252706 -snap {("G1" 5)}
wvSetCursor -win $_nWave2 980.204682 -snap {("G1" 5)}
wvZoom -win $_nWave2 288.423059 1231.761636
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 341.084085 -snap {("G1" 5)}
wvSetCursor -win $_nWave2 655.381463 -snap {("G1" 5)}
wvSetCursor -win $_nWave2 619.665851 -snap {("G3" 1)}
wvSetCursor -win $_nWave2 659.845914 -snap {("G3" 1)}
wvZoomOut -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G2" 2 )} 
wvZoomOut -win $_nWave2
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 932.660672 -snap {("G2" 2)}
wvSetCursor -win $_nWave2 5414.613346 -snap {("G2" 2)}
wvSelectSignal -win $_nWave2 {( "G2" 2 )} 
wvSetPosition -win $_nWave2 {("G2" 2)}
wvSetPosition -win $_nWave2 {("G2" 1)}
wvSetPosition -win $_nWave2 {("G2" 0)}
wvSetPosition -win $_nWave2 {("G1" 6)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 6)}
wvSetPosition -win $_nWave2 {("G1" 7)}
wvSetCursor -win $_nWave2 603.638713 -snap {("G1" 7)}
wvSetCursor -win $_nWave2 334.203407 -snap {("G1" 6)}
wvSetCursor -win $_nWave2 616.592333 -snap {("G1" 7)}
wvSetCursor -win $_nWave2 668.406815 -snap {("G1" 6)}
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvZoom -win $_nWave2 546.642783 917.116327
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 657.680644 -snap {("G2" 1)}
wvSetCursor -win $_nWave2 1312.751443 -snap {("G2" 1)}
wvSetCursor -win $_nWave2 571.555797 -snap {("G3" 2)}
wvSetCursor -win $_nWave2 613.313299 -snap {("G3" 2)}
wvSelectSignal -win $_nWave2 {( "G3" 3 )} 
wvSelectSignal -win $_nWave2 {( "G2" 3 )} 
wvSelectSignal -win $_nWave2 {( "G2" 1 )} 
wvSetCursor -win $_nWave2 1289.262849 -snap {("G2" 2)}
srcDeselectAll -win $_nTrace1
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 0.000000 5386.717653
wvSetCursor -win $_nWave2 331.411876 -snap {("G3" 1)}
wvSetCursor -win $_nWave2 642.429176 -snap {("G2" 3)}
wvSetCursor -win $_nWave2 339.059843 -snap {("G2" 2)}
wvSetCursor -win $_nWave2 341.609165 -snap {("G2" 3)}
wvSetCursor -win $_nWave2 662.823753 -snap {("G2" 3)}
srcDeselectAll -win $_nTrace1
wvSelectSignal -win $_nWave2 {( "G2" 3 )} 
wvSetCursor -win $_nWave2 356.905098 -snap {("G2" 3)}
wvSetCursor -win $_nWave2 652.626464 -snap {("G2" 3)}
wvSetCursor -win $_nWave2 1261.914452 -snap {("G2" 3)}
wvSetCursor -win $_nWave2 660.274431 -snap {("G2" 3)}
wvSetCursor -win $_nWave2 1269.562419 -snap {("G2" 3)}
wvSetCursor -win $_nWave2 655.175786 -snap {("G2" 3)}
wvSetCursor -win $_nWave2 1244.069198 -snap {("G3" 1)}
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvSetCursor -win $_nWave2 1295.055640 -snap {("G3" 1)}
wvSetCursor -win $_nWave2 1611.171584 -snap {("G2" 3)}
wvSetCursor -win $_nWave2 2284.192625 -snap {("G2" 3)}
wvZoom -win $_nWave2 2070.049567 2926.621801
wvZoomOut -win $_nWave2
wvSelectSignal -win $_nWave2 {( "G2" 2 )} 
wvSelectSignal -win $_nWave2 {( "G2" 3 )} 
wvSetCursor -win $_nWave2 2421.718480 -snap {("G3" 1)}
wvSetCursor -win $_nWave2 2584.682057 -snap {("G3" 1)}
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 3230.084034 -snap {("G2" 3)}
wvZoomIn -win $_nWave2
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 3920.855017 -snap {("G3" 3)}
wvZoom -win $_nWave2 3667.896629 4199.757856
wvZoomOut -win $_nWave2
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 3898.084557 -snap {("G3" 1)}
wvSetCursor -win $_nWave2 3859.824781 -snap {("G3" 1)}
wvSetCursor -win $_nWave2 3896.070885 -snap {("G3" 1)}
wvSetCursor -win $_nWave2 3850.763255 -snap {("G3" 1)}
wvSetCursor -win $_nWave2 3898.084557 -snap {("G3" 1)}
wvSetCursor -win $_nWave2 3860.831617 -snap {("G3" 1)}
wvSetCursor -win $_nWave2 3898.084557 -snap {("G3" 1)}
wvSetCursor -win $_nWave2 3865.865798 -snap {("G5" 3)}
wvSelectSignal -win $_nWave2 {( "G3" 3 )} 
wvSetPosition -win $_nWave2 {("G3" 3)}
wvSetPosition -win $_nWave2 {("G3" 2)}
wvSetPosition -win $_nWave2 {("G3" 1)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G3" 1)}
wvSetPosition -win $_nWave2 {("G3" 2)}
wvSetCursor -win $_nWave2 3901.105066 -snap {("G3" 2)}
wvSetCursor -win $_nWave2 3859.824781 -snap {("G3" 1)}
wvSetCursor -win $_nWave2 3901.105066 -snap {("G3" 1)}
wvSetCursor -win $_nWave2 3863.852126 -snap {("G3" 1)}
wvSelectSignal -win $_nWave2 {( "G5" 3 )} 
srcDeselectAll -win $_nTrace1
wvSetCursor -win $_nWave2 3902.111902 -snap {("G5" 3)}
wvSetCursor -win $_nWave2 3866.872635 -snap {("G5" 3)}
wvSetCursor -win $_nWave2 3898.084557 -snap {("G3" 1)}
wvSetCursor -win $_nWave2 3858.817945 -snap {("G3" 1)}
wvSetCursor -win $_nWave2 3546.698721 -snap {("G5" 3)}
wvSetPosition -win $_nWave2 {("G5" 3)}
wvSetPosition -win $_nWave2 {("G5" 4)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G5" 4)}
wvSelectSignal -win $_nWave2 {( "G5" 2 )} 
wvSetPosition -win $_nWave2 {("G5" 2)}
wvSetPosition -win $_nWave2 {("G5" 3)}
wvSetPosition -win $_nWave2 {("G5" 4)}
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("G5" 4)}
wvSetCursor -win $_nWave2 3788.339410 -snap {("G5" 4)}
wvSetCursor -win $_nWave2 3824.585514 -snap {("G3" 3)}
wvSetCursor -win $_nWave2 3862.845290 -snap {("G5" 3)}
wvSetCursor -win $_nWave2 3903.118738 -snap {("G5" 3)}
wvSetCursor -win $_nWave2 3867.879471 -snap {("G5" 3)}
wvSetCursor -win $_nWave2 3907.146083 -snap {("G5" 3)}
wvSetCursor -win $_nWave2 3873.920488 -snap {("G5" 3)}
wvSetCursor -win $_nWave2 3911.173428 -snap {("G5" 3)}
wvSetCursor -win $_nWave2 3863.852126 -snap {("G5" 3)}
wvSetCursor -win $_nWave2 3905.132410 -snap {("G5" 3)}
wvSetCursor -win $_nWave2 3859.824781 -snap {("G5" 3)}
wvSetCursor -win $_nWave2 3864.858962 -snap {("G5" 3)}
wvSetCursor -win $_nWave2 3782.298393 -snap {("G5" 4)}
wvSetCursor -win $_nWave2 3780.000000
wvSetCursor -win $_nWave2 3861.838454 -snap {("G5" 3)}
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
wvSetCursor -win $_nWave2 3862.845289 -snap {("G5" 3)}
wvSetCursor -win $_nWave2 3900.098229 -snap {("G5" 3)}
wvSetCursor -win $_nWave2 3863.852126 -snap {("G5" 3)}
wvSetCursor -win $_nWave2 3901.105065 -snap {("G5" 3)}
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "go_ahb_transmit" -line 146 -pos 1 -win $_nTrace1
wvSetCursor -win $_nWave2 3857.811108 -snap {("G5" 3)}
wvSetCursor -win $_nWave2 3896.070884 -snap {("G5" 3)}
wvSetCursor -win $_nWave2 3863.852126 -snap {("G2" 3)}
srcDeselectAll -win $_nTrace1
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 0.000000 6121.564140
wvSetCursor -win $_nWave2 5495.791374 -snap {("G3" 2)}
wvSetCursor -win $_nWave2 5466.820413 -snap {("G2" 3)}
wvZoom -win $_nWave2 5226.361434 5808.677757
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 5501.811110 -snap {("G1" 6)}
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 5468.465026 -snap {("G2" 3)}
wvSetCursor -win $_nWave2 5502.637872 -snap {("G2" 3)}
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 0.000000 8501.322270
wvSelectSignal -win $_nWave2 {( "G5" 3 )} 
wvSetCursor -win $_nWave2 5548.189025 -snap {("G3" 2)}
wvSetCursor -win $_nWave2 5379.208649 -snap {("G3" 3)}
wvSetCursor -win $_nWave2 5419.442072 -snap {("G3" 3)}
wvZoom -win $_nWave2 4594.656901 6610.351391
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 5338.260240 -snap {("G3" 1)}
wvSetCursor -win $_nWave2 5366.878714 -snap {("G3" 1)}
wvSetCursor -win $_nWave2 5502.339489 -snap {("G3" 2)}
wvSetCursor -win $_nWave2 5538.589555 -snap {("G3" 2)}
wvSetCursor -win $_nWave2 5508.063183 -snap {("G3" 2)}
wvSetCursor -win $_nWave2 5540.497454 -snap {("G3" 2)}
wvSetCursor -win $_nWave2 5502.339489 -snap {("G3" 2)}
wvSetCursor -win $_nWave2 5536.681657 -snap {("G3" 2)}
wvSetCursor -win $_nWave2 5508.063183 -snap {("G3" 2)}
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 3897.471936 -snap {("G2" 3)}
wvSetCursor -win $_nWave2 3941.982679 -snap {("G2" 3)}
wvSetCursor -win $_nWave2 3941.982679 -snap {("G3" 1)}
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 1335.322291 -snap {("G2" 3)}
wvSetCursor -win $_nWave2 1307.503076 -snap {("G2" 1)}
srcDeselectAll -win $_nTrace1
wvSetCursor -win $_nWave2 1054.348225 -snap {("G2" 2)}
wvSelectSignal -win $_nWave2 {( "G3" 1 )} 
wvSelectSignal -win $_nWave2 {( "G3" 2 )} 
wvSetCursor -win $_nWave2 1335.322291 -snap {("G3" 1)}
wvSelectSignal -win $_nWave2 {( "G1" 7 )} 
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 27155.797823 -snap {("G3" 1)}
wvZoom -win $_nWave2 0.000000 3956.150402
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 6474.381491 -snap {("G2" 3)}
wvSetCursor -win $_nWave2 6631.653916 -snap {("G2" 3)}
wvSetCursor -win $_nWave2 7249.509871 -snap {("G2" 3)}
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 5354.751609 -snap {("G2" 3)}
wvSetCursor -win $_nWave2 5579.426502 -snap {("G2" 3)}
wvSetCursor -win $_nWave2 5654.318133 -snap {("G2" 3)}
verdiDockWidgetSetCurTab -dock widgetDock_<Decl._Tree>
srcDeselectAll -win $_nTrace1
