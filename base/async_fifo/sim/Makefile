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

MODULE_NAME     :=sync_fifo

SIM_DIR         :=$(shell pwd)
RTL_DIR         :=${SIM_DIR}/../rtl
TB_DIR          :=${SIM_DIR}/../tb

SRCS            :=$(wildcard ${SIM_DIR}/../rtl/*.v)
SRCS            +=$(wildcard ${SIM_DIR}/../tb/*.v)
FILELIST        :=${SIM_DIR}/../rtl/filelist.f
TBLIST          :=${SIM_DIR}/../tb/filelist.f

VCS             :=vcs
GCC             :=-cpp g++-4.8 -cc gcc-4.8 -LDFLAGS -Wl,--no-as-needed
MODE            :=-full64 -debug_acc+all -sverilog -nc -l comp_log +v2k
MODE            +=-kdb +lint=TFIPC-L +lint=PCWM
VERDI_LIBS      :=${VERDI_HOME}/share/PLI/VCS/LINUX64/novas.tab ${VERDI_HOME}/share/PLI/VCS/LINUX64/pli.a
TIME_SCALE      :=-timescale=1ns/1ps
NO_TIMING       :=+notimingcheck +nospecify

all: elab

#${VCS} ${GCC} ${MODE} ${SRCS} ${TIME_SCALE} ${NO_TIMING}

elab:
	${VCS} ${GCC} ${MODE}	\
	-f ${TBLIST}	\
	-f ${FILELIST}	\
	${TIME_SCALE} ${NO_TIMING}

sim:
	./simv -l run_log

verdi:
	verdi -nologo ${SRCS}	\
	-f ../rtl/filelist.f	\
	-dbdir simv.daidir	\
	-simflow -simBin ./simv	\
	-simBin simv	\
	-ssf tb.fsdb

clean:
	rm -fr AN.DB DEVfiles csrc simv.* inter.vpd ucli.key *_log novas* *fsdb simv verdiLog comp_log
