set_property PACKAGE_PIN U18 [get_ports sys_clk]
set_property PACKAGE_PIN N16 [get_ports sys_rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports sys_clk]
set_property IOSTANDARD LVCMOS33 [get_ports sys_rst_n]
#DDS BOARD
set_property PACKAGE_PIN U9 [get_ports uart_rxd]
#�캽�ߵװ� UART������ ��ɫΪTXD
#set_property PACKAGE_PIN T19 [get_ports uart_rxd]
set_property PACKAGE_PIN J15 [get_ports uart_txd]
set_property PACKAGE_PIN H15 [get_ports led]
set_property IOSTANDARD LVCMOS33 [get_ports led]
set_property IOSTANDARD LVCMOS33 [get_ports uart_rxd]
set_property IOSTANDARD LVCMOS33 [get_ports uart_txd]

