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
# DUT_MODULE  :=sync_fifo
# DUT_MODULE  :=memory
# DUT_MODULE  :=reset_sync
TOP_MODULE		:=convert_tb
DUT_MODULE 		:=cdc

# Define project dir
SIM_DIR         :=$(shell pwd)
RTL_DIR         :=${SIM_DIR}/../rtl
TB_DIR          :=${SIM_DIR}/../tb

# get top verilog/systemverilog file
SRCS            :=$(wildcard ${RTL_DIR}/${DUT_MODULE}/*.v)
SRCS            +=$(wildcard ${RTL_DIR}/${DUT_MODULE}/*.sv)

# get testbench verilog/systemlog file
SRCS            +=$(wildcard ${TB_DIR}/${DUT_MODULE}/*.v)
SRCS            +=$(wildcard ${TB_DIR}/${DUT_MODULE}/*.sv)

# config sub module
CONFIG_CLOCKS			:=n
CONFIG_SYNC_FIFO		:=n

ifeq (${CONFIG_SYNC_FIFO}, y)
SRCS            +=$(wildcard ${RTL_DIR}/sync_fifo/*.v)
SRCS            +=$(wildcard ${RTL_DIR}/sync_fifo/*.sv)
else
endif

ifeq (${CONFIG_CLOCKS}, y)
SRCS            +=$(wildcard ${RTL_DIR}/clocks/*.v)
SRCS            +=$(wildcard ${RTL_DIR}/clocks/*.sv)
else
endif


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
DESIGN			:=-top ${TOP_MODULE}

export			RTL_DIR TB_DIR

all: sim

#${VCS} ${GCC} ${MODE} ${SRCS} ${TIME_SCALE} ${NO_TIMING}

elab:
	${VCS} ${GCC_V} ${VCS_FLAGS} ${VCS_LDFLAGS}	${TIME_SCALE} ${NO_TIMING} ${SRCS} ${DESIGN}

sim: elab
	./simv -l run_log

verdi: sim 
	verdi -nologo ${SRCS}	\
	dbdir simv.daidir	\
	simflow -simBin ./simv	\
	simBin simv	\
	ssf tb.fsdb

clean:
	rm -fr AN.DB DEVfiles csrc simv.* inter.vpd ucli.key *_log novas* *fsdb simv verdiLog comp_log
