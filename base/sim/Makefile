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
TOP_MODULE_NAME     :=memory
# TOP_MODULE_NAME     :=reset_sync

# config sub module
CONFIG_RESET_SYNC		:=y
CONFIG_GENERAL_SYNCER	:=y

ifeq (${CONFIG_RESET_SYNC}, y)
else
endif

ifeq (${CONFIG_GENERAL_SYNCER}, y)
else
endif

SIM_DIR         :=$(shell pwd)
RTL_DIR         :=${SIM_DIR}/../rtl
TB_DIR          :=${SIM_DIR}/../tb

# get top verilog/systemverilog file
SRCS            :=$(wildcard ${RTL_DIR}/${TOP_MODULE_NAME}/*.v)
SRCS            +=$(wildcard ${RTL_DIR}/${TOP_MODULE_NAME}/*.sv)

# get testbench verilog/systemlog file
SRCS            +=$(wildcard ${TB_DIR}/${TOP_MODULE_NAME}/*.v)
SRCS            +=$(wildcard ${TB_DIR}/${TOP_MODULE_NAME}/*.sv)

# get submodule verilog/systemverilog file

VCS             :=vcs
# GCC             :=-cpp g++-4.8 -cc gcc-4.8 -LDFLAGS -Wl,--no-as-needed
GCC             :=-cpp -cc -LDFLAGS -Wl,--no-as-needed
MODE            :=-full64 -debug_acc+all -sverilog -nc -l comp_log +v2k
MODE            +=-lca -kdb
VERDI_LIBS      :=${VERDI_HOME}/share/PLI/VCS/LINUX64/novas.tab ${VERDI_HOME}/share/PLI/VCS/LINUX64/pli.a
TIME_SCALE      :=-timescale=1ns/1ps
NO_TIMING       :=+notimingcheck +nospecify

export			RTL_DIR TB_DIR

all: elab

#${VCS} ${GCC} ${MODE} ${SRCS} ${TIME_SCALE} ${NO_TIMING}

elab:
	${VCS} ${GCC} ${MODE}	\
	${SRCS}	\
	${TIME_SCALE} ${NO_TIMING}

sim:
	./simv -l run_log

verdi:
	cp ../../novas.rc .
	verdi -nologo ${SRCS}	\
	-dbdir simv.daidir	\
	-simflow -simBin ./simv	\
	-simBin simv	\
	-ssf tb.fsdb

clean:
	rm -fr AN.DB DEVfiles csrc simv.* inter.vpd ucli.key *_log novas* *fsdb simv verdiLog comp_log
