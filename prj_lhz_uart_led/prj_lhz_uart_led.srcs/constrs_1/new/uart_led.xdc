set_property PACKAGE_PIN U18 [get_ports sys_clk]
set_property PACKAGE_PIN Y7 [get_ports sys_rst_n]
set_property IOSTANDARD LVCMOS18 [get_ports sys_clk]
set_property IOSTANDARD LVCMOS33 [get_ports sys_rst_n]
#DDS BOARD

##领航者底板 UART调试器 红色为TXD
set_property PACKAGE_PIN U9 [get_ports debug_uart_rx]
set_property IOSTANDARD LVCMOS33 [get_ports debug_uart_rx]
set_property PACKAGE_PIN N15 [get_ports uart_txd]
set_property PACKAGE_PIN N16 [get_ports uart_rxd]
set_property PACKAGE_PIN J16 [get_ports led]
set_property IOSTANDARD LVCMOS33 [get_ports led]
set_property IOSTANDARD LVCMOS33 [get_ports uart_rxd]
set_property IOSTANDARD LVCMOS33 [get_ports uart_txd]


# 引脚位置约束
set_property IOSTANDARD LVCMOS33 [get_ports pwm_port]

# 时钟约束

# 创建一个新的时序约束
create_clock -period 20.000 -name sys_clk [get_ports sys_clk]
#create_clock -period 20.000 -name clk_50M [get_ports clk_50M]
set_property PACKAGE_PIN H15 [get_ports pwm_port]

set_property IOSTANDARD LVCMOS33 [get_ports ad9748_sleep]
set_property PACKAGE_PIN U8 [get_ports ad9748_sleep]
set_property PACKAGE_PIN G15 [get_ports pwm_slow_port]

set_property IOSTANDARD LVCMOS33 [get_ports {dac_data[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dac_data[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dac_data[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dac_data[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dac_data[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dac_data[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dac_data[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dac_data[0]}]
set_property PACKAGE_PIN K18 [get_ports {dac_data[0]}]
set_property PACKAGE_PIN K17 [get_ports {dac_data[1]}]
set_property PACKAGE_PIN D18 [get_ports {dac_data[2]}]
set_property PACKAGE_PIN E17 [get_ports {dac_data[3]}]
set_property PACKAGE_PIN B19 [get_ports {dac_data[4]}]
set_property PACKAGE_PIN A20 [get_ports {dac_data[5]}]
set_property PACKAGE_PIN H17 [get_ports {dac_data[6]}]
set_property PACKAGE_PIN H16 [get_ports {dac_data[7]}]

set_property PACKAGE_PIN U14 [get_ports pwm_diff_port_p]
set_property IOSTANDARD DIFF_HSTL_II_18 [get_ports pwm_diff_port_p]





set_property PACKAGE_PIN J15 [get_ports debug_uart_tx]
set_property IOSTANDARD LVCMOS33 [get_ports debug_uart_tx]
#set_property IOSTANDARD DIFF_HSTL_II_18 [get_ports adc_clk_p]
#set_property PACKAGE_PIN N20 [get_ports adc_clk_p]

#set_property SLEW FAST [get_ports adc_clk_p]
#set_property SLEW FAST [get_ports adc_clk_n]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_50M]

#set_property IOSTANDARD DIFF_HSTL_II_18 [get_ports dds_clk0_p]
#set_property PACKAGE_PIN N18 [get_ports dds_clk0_p]
