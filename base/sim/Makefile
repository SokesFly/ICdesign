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


MODULE          :=ft-d2000-pmu
# MODULE          :=ahb2apb

# Define project dir
SIM_DIR         :=$(shell pwd)
RTL_DIR         :=${SIM_DIR}/../rtl
TB_DIR          :=${SIM_DIR}/../tb

VCS             :=vcs
# GCC             :=-cpp g++-4.8 -cc gcc-4.8 -LDFLAGS -Wl,--no-as-needed
GCC_V           :=-cpp -cc
VCS_FLAGS       :=-full64 -debug_acc+all -sverilog -nc -l comp_log +v2k
VCS_FLAGS		+=-j16
VCS_FLAGS		+=-M
# Show array var
VCS_FLAGS		+=+memcbk
VCS_FLAGS		+=+warn=all
VCS_FLAGS       +=-kdb
VCS_LDFLAGS		:=-LDFLAGS -Wl,--no-as-needed
LOG_OUTPU		:=-l vcs.log
VERDI_LIBS      :=${VERDI_HOME}/share/PLI/VCS/LINUX64/novas.tab ${VERDI_HOME}/share/PLI/VCS/LINUX64/pli.a
TIME_SCALE      :=-timescale=1ns/1ns
NO_TIMING       :=+notimingcheck +nospecify
SRCS            := -f ${TB_DIR}/${MODULE}/filelist.f
SRCS            += -f ${RTL_DIR}/${MODULE}/filelist.f

export          SIM_DIR RTL_DIR TB_DIR MODULE

all: sim

#${VCS} ${GCC} ${MODE} ${SRCS} ${TIME_SCALE} ${NO_TIMING}

elab:
	${VCS} ${GCC_V} ${VCS_FLAGS} ${VCS_LDFLAGS} ${TIME_SCALE} ${NO_TIMING} ${SRCS}

sim: elab
	./simv -l run_log

verdi:
	verdi -nologo ${SRCS} -ssf tb.fsdb

clean:
	rm -fr AN.DB DEVfiles csrc simv.* inter.vpd ucli.key *_log novas* *fsdb simv verdiLog comp_log
