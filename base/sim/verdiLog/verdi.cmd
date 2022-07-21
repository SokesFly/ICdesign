debImport "-sv" "-f" "/home/soke/ICdesign/base/sim/../tb/spi/filelist.f" "-f" \
          "/home/soke/ICdesign/base/sim/../rtl/spi/filelist.f"
debLoadSimResult /home/soke/ICdesign/base/sim/tb.fsdb
wvCreateWindow
srcDeselectAll -win $_nTrace1
srcSelect -signal "fsm" -line 11 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvSetCursor -win $_nWave2 13524340.228833 -snap {("G1" 1)}
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "psel_i" -line 23 -pos 1 -win $_nTrace1
wvSetCursor -win $_nWave2 249.696736 -snap {("G1" 1)}
wvSetCursor -win $_nWave2 210.289290 -snap {("G1" 1)}
srcDeselectAll -win $_nTrace1
debExit
