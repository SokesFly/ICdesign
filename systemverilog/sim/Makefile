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
RTL_DIR         :=${SIM_DIR}/../rtl
TB_DIR          :=${SIM_DIR}/../tb

VCS             :=vcs
LDFLAGS         :=-cpp g++-4.8 -cc gcc-4.8 -LDFLAGS -Wl,--no-as-needed -j8
# LDFLAGS         +=-cpp -cc -LDFLAGS -Wl,--no-as-needed
OPTIONS         :=-full64 -debug_acc+all -sverilog -nc -l comp_log +v2k -lca -kdb
# 启用UVM库
# OPTIONS		+=-ntb_opts uvm-1.1 
# Dump MEM
# OPTIONS		+=-mda
VERDI_LIBS      :=${VERDI_HOME}/share/PLI/VCS/LINUX64/novas.tab ${VERDI_HOME}/share/PLI/VCS/LINUX64/pli.a
TIME_SCALE      :=-timescale=1ns/1ps
NO_TIMING       :=+notimingcheck +nospecify
FILELIST		:=${SIM_DIR}/filelist.f

export			RTL_DIR TB_DIR

all: elab sim

elab:
	${VCS} ${OPTIONS}  ${GCC} ${LDFLAGS} \
	-f $(FILELIST)	\
	${TIME_SCALE} ${NO_TIMING}

sim:
	./simv -l run_log

# 指定simv的路径后，您可以使用Verdi nTrace中的Tools -> Run Simulation
# 菜单命令，直接启动Verdi交互式仿真调试模式。
verdi:
	verdi -nologo \
	-dbdir simv.daidir	\
	-simBin simv \
	-ssf tb.fsdb

clean:
	rm -fr AN.DB DEVfiles csrc simv.* inter.vpd ucli.key *_log novas* *fsdb simv verdiLog comp_log
