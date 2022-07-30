debImport "-sv" "-f" "/home/soke/ICdesign/base/sim/../tb/ahb2apb/filelist.f" "-f" \
          "/home/soke/ICdesign/base/sim/../rtl/ahb2apb/filelist.f"
debLoadSimResult /home/soke/ICdesign/base/sim/tb.fsdb
wvCreateWindow
wvRestoreSignal -win $_nWave2 "/home/soke/ICdesign/base/sim/signal.rc" \
           -overWriteAutoAlias on -appendSignals on
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 807.498910 -snap {("G3" 4)}
wvZoom -win $_nWave2 175.993352 3626.843395
wvSetCursor -win $_nWave2 740.499405 -snap {("G1" 7)}
wvSetCursor -win $_nWave2 668.504430 -snap {("G4" 4)}
srcDeselectAll -win $_nTrace1
wvSetCursor -win $_nWave2 693.048171 -snap {("G3" 3)}
wvSelectSignal -win $_nWave2 {( "G3" 3 )} 
wvSetCursor -win $_nWave2 668.504430 -snap {("G3" 6)}
wvSelectSignal -win $_nWave2 {( "G3" 1 )} 
wvSelectSignal -win $_nWave2 {( "G3" 2 )} 
wvSetCursor -win $_nWave2 619.416947 -snap {("G3" 1)}
wvSetCursor -win $_nWave2 657.050684 -snap {("G3" 1)}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "wrap_step" -line 344 -pos 1 -win $_nTrace1
wvZoom -win $_nWave2 262.714572 994.118066
wvSetCursor -win $_nWave2 659.455016 -snap {("G3" 6)}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "wrap_step" -line 341 -pos 1 -win $_nTrace1
wvSetCursor -win $_nWave2 655.293403 -snap {("G3" 2)}
wvSetCursor -win $_nWave2 640.034155 -snap {("G3" 3)}
wvSelectSignal -win $_nWave2 {( "G3" 3 )} 
tfgSetPreference
tfgGenerate -incr -ref "ahb2apb_tb.ahb_trans_last_flag#700#T" -startWithStmt -schFG
tfgNodeTraceActTrans -win $_tFlowView3 -folder "group_0#T" "ahb2apb_tb.ahb_trans_last_flag" -stopLevel 10
verdiDockWidgetSetCurTab -dock windowDock_nWave_2
wvSetCursor -win $_nWave2 702.458351 -snap {("G3" 3)}
wvSetCursor -win $_nWave2 693.441523 -snap {("G3" 3)}
debExit
