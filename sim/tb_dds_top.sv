`timescale 1ns / 1ps

module tb_dds_sample_top();

// 定义与被测模块连接的信号
reg         sys_clk;
reg         sys_rst_n;
reg         uart_rxd;
wire        led;
wire        pwm_port;
wire        uart_txd;

// 定义仿真控制参数
localparam SYS_CLK_PERIOD = 10;    // 100MHz系统时钟
localparam UART_BAUD_RATE  = 115200;
localparam CLK_FREQ_MHZ    = 100;
localparam BIT_PERIOD      = 1_000_000_000 / UART_BAUD_RATE; // 单位：ns

// 实例化被测模块
dds_sample_top uut (
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),
    .uart_rxd    (uart_rxd),
    .led         (led),
    .pwm_port    (pwm_port),
    .uart_txd    (uart_txd)
);

// 系统时钟生成
always #(SYS_CLK_PERIOD/2) sys_clk = ~sys_clk;

// UART数据发送任务
task uart_send_byte;
    input [7:0] data;
    integer i;
    begin
        // 起始位
        uart_rxd = 0;
        #BIT_PERIOD;
        // 数据位（LSB first）
        for (i=0; i<8; i=i+1) begin
            uart_rxd = data[i];
            #BIT_PERIOD;
        end
        // 停止位
        uart_rxd = 1;
        #BIT_PERIOD;
    end
endtask

// 主测试流程
initial begin
    // 初始化信号
    sys_clk   = 0;
    sys_rst_n = 0;
    uart_rxd  = 1;  // UART空闲状态
    
    // 系统复位
    #100;
    sys_rst_n = 1;
    #200;  // 等待锁相环锁定
    
    // 测试案例1：发送配置数据包（示例：设置dataA=8'h08）
    $display("Sending configuration data...");
    uart_send_byte(8'hAA);  // 假设包头
    uart_send_byte(8'h08);  // dataA
    uart_send_byte(8'h00);  // dataD
    uart_send_byte(8'h00);  // dataB[7:0]
    uart_send_byte(8'h00);  // dataB[15:8]
    uart_send_byte(8'h00);  // dataC[7:0]
    uart_send_byte(8'h00);  // dataC[15:8]
    uart_send_byte(8'h55);  // 假设包尾
    
    // 验证LED状态
    #1000000;  // 等待1ms观察呼吸灯效果
    if(uut.u_uart_rx_inst.dataA == 8'h08) begin
        $display("LED control signal activated!");
    end else begin
        $display("Error: dataA not set correctly!");
    end
    
    // 测试案例2：添加更多测试场景...
    
    #1000;
    $finish;
end

// 波形记录
initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, tb_dds_sample_top);
end

endmodule