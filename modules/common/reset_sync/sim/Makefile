#***************************************************************************************
# Function: 
# Author: SK 
# Company: Ltd.JRLC.SK
# Right : 
# Tel : 
# Last modified: 2022-03-10 03:28
# None: 
# Filename: Makefile
# Resverd: 
# Description: 
#*************************************************************************************/

SIM_DIR         :=$(shell pwd)
RTL_DIR         :=../rtl
TB_DIR          :=../tb

VCS             :=vcs
#GCC             :=-cpp g++-4.8 -cc gcc-4.8 -LDFLAGS -Wl,--no-as-needed
GCC             :=-cpp -cc -LDFLAGS -Wl,--no-as-needed
MODE            :=-full64 -debug_acc+all -sverilog -nc -l comp_log +v2k
MODE            +=-lca -kdb
VERDI_LIBS      :=${VERDI_HOME}/share/PLI/VCS/LINUX64/novas.tab ${VERDI_HOME}/share/PLI/VCS/LINUX64/pli.a
TIME_SCALE      :=-timescale=1ns/1ps
NO_TIMING       :=+notimingcheck +nospecify

export			RTL_DIR TB_DIR

all: elab elab

#${VCS} ${GCC} ${MODE} ${SRCS} ${TIME_SCALE} ${NO_TIMING}

elab:
	${VCS} ${GCC} ${MODE}	\
	-f ${TBLIST}	\
	-f ${FILELIST}	\
	${TIME_SCALE} ${NO_TIMING}

sim:
	./simv -l run_log

verdi:
	verdi -nologo \
	-dbdir simv.daidir	\
	-ssf tb.fsdb	\
	-simflow -simBin ./simv	\
	-simBin simv

clean:
	rm -fr AN.DB DEVfiles csrc simv.* inter.vpd ucli.key *_log novas* *fsdb simv verdiLog comp_log
