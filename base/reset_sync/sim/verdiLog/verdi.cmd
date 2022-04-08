simSetSimulator "-vcssv" -exec "simv" -args
debImport "-f" "../syn/syn_files/reset_syncer.syn.v" "-dbdir" "simv.daidir" \
          "-simflow" "simv"
debLoadSimResult /home/ubuntu/ICdesign/base/reset_sync/sim/tb.fsdb
wvCreateWindow
srcHBSelect "reset_syncer_tb.reset_syncer_tb" -win $_nTrace1
srcHBSelect "reset_syncer_tb.reset_syncer_tb" -win $_nTrace1
srcSetScope -win $_nTrace1 "reset_syncer_tb.reset_syncer_tb" -delim "."
srcHBSelect "reset_syncer_tb.reset_syncer_tb" -win $_nTrace1
srcDeselectAll -win $_nTrace1
schCreateWindow -delim "." -win $_nSchema1 -scope \
           "reset_syncer_tb.reset_syncer_tb"
schSyncScopeWnd -win $_nSchema3 -bSyncWnd on
schFindHierFormCreate -win $_nSchema3
srcFndSignalSearch -delim "." -case on -fullHierarchy off -libcell off -name \
           "reset_syncer_tb.reset_syncer_tb.*"
schSetOptions -win $_nSchema3 -pinName on
schSelect -win $_nSchema3 -inst "reset_syncer\(@1\):Always0:26:34:Reg"
schDeselectAll -win $_nSchema3
srcSetSearchPath "/home/ubuntu/ICdesign/base/reset_sync/syn/syn_files"
srcShowFile -file \
           /home/ubuntu/ICdesign/base/reset_sync/syn/syn_files/reset_syncer.syn.v
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
schCreateWindow -delim "." -win $_nSchema1 -scope \
           "reset_syncer_tb.reset_syncer_tb"
verdiDockWidgetSetCurTab -dock windowDock_nSchema_3
schCloseWindow -win $_nSchema3
schSelect -win $_nSchema4 -inst "reset_syncer\(@1\):Always0:26:34:Reg"
schPushViewIn -win $_nSchema4
srcSetScope -win $_nTrace1 "reset_syncer_tb.reset_syncer_tb" -delim "."
srcSelect -win $_nTrace1 -range {26 34 1 3 1 1}
debExit
