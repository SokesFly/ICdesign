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

MODULE_NAME		:=sync_fifo

SIM_DIR			:=$(shell pwd)
RTL_DIR		 	:=${module_dir}/../rtl
TB_DIR		    :=${module_dir}/../tb

SRCS			:=$(wildcard ${SIM_DIR}/../rtl/*.v)
SRCS			+=$(wildcard ${SIM_DIR}/../tb/*.v)

VCS				:=vcs
GCC				:=-cpp g++-4.8 -cc gcc-4.8 -LDFLAGS -Wl,--no-as-needed
MODE			:=-full64 -debug_acc+all -sverilog -nc -l comp_log +v2k
VERDI_LIBS			:=${VERDI_HOME}/share/PLI/VCS/LINUX64/novas.tab ${VERDI_HOME}/share/PLI/VCS/LINUX64/pli.a
TIME_SCALE		:=-timescale=1ns/1ps
NO_TIMING		:=+notimingcheck +nospecify

all: elab

elab:
	${VCS} ${GCC} ${MODE} ${SRCS} ${TIME_SCALE} ${NO_TIMING}

simv:
	./simv -l run_log

verdi:
	verdi -nologo ${SRCS} -ssf ./tb.fsdb

clean:
	rm -fr AN.DB DEVfiles csrc simv.* inter.vpd ucli.key *_log novas* *fsdb simv verdiLog
