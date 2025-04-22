`timescale 1ns/1ns

module tb_uart_pkg;

//parameter define
parameter CLK_PERIOD = 20;  // 50Mhz时钟周期为20ns

//reg define
reg sys_clk;    // 时钟信号
reg sys_rst_n;  // 复位信号
reg uart_rxd;   // UART接收端口

//wire define
wire uart_txd;  // UART发送端口

/*******************************************************
**                    UART发送任务
*******************************************************/
task uart_send;
    input [7:0] data;  // 需要发送的数据
    begin
        // 发送起始位（低电平）
        uart_rxd <= 1'b0;
        #(8680);  // 保持一个波特率周期
        
        // 发送数据位（从最低位到最高位）
        for (int i = 0; i < 8; i++) begin
            uart_rxd <= data[i];
            #(8680);
        end
        
        // 发送停止位（高电平）
        uart_rxd <= 1'b1;
        #(8680);  // 保持一个波特率周期
    end
endtask

/*******************************************************
**                    main code
*******************************************************/
initial begin
    // 初始化信号
    sys_clk <= 1'b0;
    sys_rst_n <= 1'b0;
    uart_rxd <= 1'b1;  // 空闲状态为高电平
    
    // 系统复位
    #200;
    sys_rst_n <= 1'b1;  // 释放复位
    
    // 测试数据发送
    #(1000);  // 等待稳定
    
    // 测试发送单个数据0x55
    // uart_send(8'h55);
    
    // 测试连续发送8个数据
    for (int i = 0; i < 8; i++) begin
        #(1000);  // 数据间隔
        uart_send(8'h10 + i);  // 发送0x10~0x17
    end
    
    #(8680*2);  // 等待最后一个停止位完成
    //$stop;      // 停止仿真
end

// 50Mhz时钟生成
always #(CLK_PERIOD/2) sys_clk = ~sys_clk;

// 模块实例化
uart_packet_rx u_uart_packet_rx(
    .clk(sys_clk),
    .rst_n(sys_rst_n),
    .uart_rxd(uart_rxd),
    // .uart_txd(uart_txd)
    .packet_done(),
    .uart_data0(),
    .uart_data1(),
    .uart_data2(),
    .uart_data3(),
    .uart_data4(),
    .uart_data5(),
    .uart_data6(),
    .uart_data7()
);

endmodule