simSetSimulator "-vcssv" -exec "simv" -args
debImport "-dbdir" "simv.daidir"
debLoadSimResult /home/remo/ICdesign/systemverilog/sim/tb.fsdb
wvCreateWindow
srcDeselectAll -win $_nTrace1
srcSelect -signal "unsynced_i" -line 10 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "clk_i" -line 2 -pos 1 -win $_nTrace1
srcSelect -win $_nTrace1 -range {2 3 4 4 3 5}
srcDeselectAll -win $_nTrace1
srcSelect -signal "clk_i" -line 2 -pos 1 -win $_nTrace1
srcSelect -signal "rstn_i" -line 3 -pos 1 -win $_nTrace1
srcSelect -signal "unsynced_i" -line 4 -pos 1 -win $_nTrace1
srcSelect -signal "synced_o" -line 5 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSetCursor -win $_nWave2 1764.028797
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "clk_i" -line 8 -pos 1 -win $_nTrace1
wvAddSignal -win $_nWave2 "tb/dut/clk_i"
srcDeselectAll -win $_nTrace1
wvSetCursor -win $_nWave2 2185.373255
srcDeselectAll -win $_nTrace1
debReload
srcDeselectAll -win $_nTrace1
srcSelect -signal "clk_i" -line 2 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "rstn_i" -line 3 -pos 1 -win $_nTrace1
srcSelect -signal "unsynced_i" -line 4 -pos 1 -win $_nTrace1
srcSelect -signal "synced_o" -line 5 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvSetCursor -win $_nWave2 994.372921 -snap {("G1" 4)}
wvZoom -win $_nWave2 0.000000 140.448153
wvZoom -win $_nWave2 0.000000 1.577264
wvZoom -win $_nWave2 0.000000 0.035426
wvZoom -win $_nWave2 0.000000 0.022460
srcDeselectAll -win $_nTrace1
wvSetCursor -win $_nWave2 0.345074 -snap {("G2" 0)}
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
srcDeselectAll -win $_nTrace1
wvSetCursor -win $_nWave2 0.591118 -snap {("G2" 0)}
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
wvZoom -win $_nWave2 0.000000 0.038285
wvZoom -win $_nWave2 0.000000 0.009188
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
debReload
debReload
srcDeselectAll -win $_nTrace1
srcSelect -signal "clk_i" -line 17 -pos 2 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "clk_i" -line 17 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
wvZoom -win $_nWave2 0.003063 0.033691
wvZoom -win $_nWave2 0.003063 0.043900
wvZoom -win $_nWave2 0.003063 0.049005
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
wvZoom -win $_nWave2 0.000000 231232.686064
wvSetCursor -win $_nWave2 20184.170147 -snap {("G1" 2)}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
        