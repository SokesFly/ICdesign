###################################
#   一、设置工艺库文件              #
###################################
#工艺库文件.db保存在上级目录ref下的db文件夹
#my_design.v文件保存在当前目录rtl下
# set search_path "$search_path ../ref/db  ./rtl "
# synopsys 内置DesignWare库
# set synthetic_library dw_foundation.sldb
# set target_library   "flow.db"
# set link_library     "* $target_library $synthetic_library"
set DESIGN_NAME reset_syncer
###################################
#   二、读入RTL文件                #
###################################
read_verilog ./rtl/reset_syncer.v
current_design reset_syncer
link
###################################
#   三、设置约束                   #
###################################
# 1、时钟设定
# 移除之前的约束
reset_design
#时钟周期3ns
create_clock -period 3.0 [get_ports clk_i]
#系统时钟到输入端口clk时钟的延迟 
set_clock_latency -source  -max 0.7 [get_clocks clk_i] 
#输入端口时钟clk到模块内部时钟的延时
set_clock_latency -max 0.3 [get_clocks clk_i]
#时钟的不确定偏斜时间0.15ns
set_clock_uncertainty -setup 0.15 [get_clocks clk_i]
#时钟的转换时间0.12ns
set_clock_transition 0.12 [get_clocks clk_i]

#2、输入延迟设定
#输入端口data1、data2的延迟
# set_input_delay -max  0.45 -clock clk [get_ports rst_n_sync_i]

#3、输出延迟设定
#输出端口out1的延迟
# set_output_delay -max  0.5 -clock clk [get_ports rst_n_synced_o]

#4、输入转换时间
#输入端口data1、data2、sel的转换时间 
# set_driving_cell -lib_cell bufbd1 -library cb13fs120_tsmc_max \
 [remove_from_collection [all_inputs] [get_ports "clk Cin*"]]
#输入端口Cin1、Cin2的转换时间 
# set_input_transition 0.12 [get_ports Cin*]

#5、输出负载
#输出端口的负载
set_load 0.025 [get_ports rst_n_*]

###################################
#   四、综合		               #
###################################
compile_ultra

###################################
#   五、结果输出                   #
###################################
file mkdir syn_files
file mkdir reports
#报告
#功耗报告
report_power -hierarchy > reports/$DESIGN_NAME.hierarchy.power
report_power > reports/$DESIGN_NAME.power
#面积报告
report_area  -hierarchy > reports/$DESIGN_NAME.area
#时序报告
report_timing > reports/$DESIGN_NAME.timing
#约束报告
report_constraint -verbose > reports/$DESIGN_NAME.constraint
#违例报告
report_constraint -all_violators > reports/$DESIGN_NAME.violation

#输出文件
write -h $DESIGN_NAME -output ./syn_files/$DESIGN_NAME.db
write_file -format ddc -hierarchy -output ./syn_files/$DESIGN_NAME.ddc
#SDF格式的延迟，用于Verilog仿真
write_sdf -context verilog -version 1.0 ./syn_files/$DESIGN_NAME.syn.sdf
#Verilog门级网表，用于ICC
write -h -f verilog $DESIGN_NAME -output ./syn_files/$DESIGN_NAME.syn.v
#SDC格式的约束, 用于ICC
write_sdc ./syn_files/$DESIGN_NAME.sdc
