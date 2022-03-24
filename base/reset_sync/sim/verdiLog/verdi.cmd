simSetSimulator "-vcssv" -exec "simv" -args
debImport "-f" "../syn/filelist.f" "-dbdir" "simv.daidir" "-simflow" "simv"
debLoadSimResult /home/ubuntu/ICdesign/base/reset_sync/sim/tb.fsdb
wvCreateWindow
srcHBSelect "reset_syncer_tb.reset_syncer_tb" -win $_nTrace1
srcSetScope -win $_nTrace1 "reset_syncer_tb.reset_syncer_tb" -delim "."
srcHBSelect "reset_syncer_tb.reset_syncer_tb" -win $_nTrace1
srcHBSelect "reset_syncer_tb.reset_syncer_tb" -win $_nTrace1
srcHBAddObjectToWave -clipboard
wvDrop -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
srcDeselectAll -win $_nTrace1
srcHBSelect "reset_syncer_tb.reset_syncer_tb" -win $_nTrace1
schCreateWindow -delim "." -win $_nSchema1 -scope \
           "reset_syncer_tb.reset_syncer_tb"
schSelect -win $_nSchema3 -inst "reset_syncer\(@1\):Always0:26:34:Reg"
schPushViewIn -win $_nSchema3
srcSelect -win $_nTrace1 -range {26 34 1 3 1 1}
verdiDockWidgetSetCurTab -dock windowDock_nSchema_3
srcSetSearchPath "/home/ubuntu/ICdesign/base/reset_sync/syn/syn_files"
srcShowFile -file \
           /home/ubuntu/ICdesign/base/reset_sync/syn/syn_files/reset_syncer.syn.v
debLoadSDFFile \
           "/home/ubuntu/ICdesign/base/reset_sync/syn/syn_files/reset_syncer.syn.sdf"
srcHBSelect "reset_syncer_tb.reset_syncer_tb" -win $_nTrace1
srcHBAddObjectToWave -clipboard
wvDrop -win $_nWave2
wvSelectSignal -win $_nWave2 {( "reset_syncer_tb/reset_syncer_tb" 1 )} 
wvSelectSignal -win $_nWave2 {( "reset_syncer_tb/reset_syncer_tb" 2 )} 
wvSelectSignal -win $_nWave2 {( "reset_syncer_tb/reset_syncer_tb" 2 3 )} 
wvSelectSignal -win $_nWave2 {( "reset_syncer_tb/reset_syncer_tb" 1 2 3 )} 
wvMoveSelected -win $_nWave2
wvSetPosition -win $_nWave2 {("reset_syncer_tb/reset_syncer_tb" 3)}
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("reset_syncer_tb/reset_syncer_tb" 0)}
srcHBSelect "reset_syncer_tb.reset_syncer_tb" -win $_nTrace1
debLoadSDFFile \
           "/home/ubuntu/ICdesign/base/reset_sync/syn/syn_files/reset_syncer.syn.ddb"
debExit
