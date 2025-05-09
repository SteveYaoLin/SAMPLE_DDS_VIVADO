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
localparam SYS_CLK_PERIOD = 20;    // 100MHz系统时钟
localparam UART_BAUD_RATE  = 115200;
localparam CLK_FREQ_MHZ    = 50;
localparam BIT_PERIOD      = 1_000_000_000 / UART_BAUD_RATE; // 单位：ns

// 实例化被测模�?
dds_sample_top uut (
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),
    .uart_rxd    (uart_rxd),
    .led         (led),
    .pwm_port    (pwm_port),
    .dac_data   (),
//    .led    (),
    .ad9748_sleep(),
//    .pwm_port   (),
    .pwm_slow_port(),
    .pwm_diff_port_n(),
    .pwm_diff_port_p(),
    .uart_txd    (uart_txd)

);

// 系统时钟生成
always #(SYS_CLK_PERIOD/2) sys_clk = ~sys_clk;

// UART数据发�?�任�?
task uart_send_byte;
    input [7:0] data;
    integer i;
    begin
        // 起始�?
        uart_rxd = 0;
        #BIT_PERIOD;
        // 数据位（LSB first�?
        for (i=0; i<8; i=i+1) begin
            uart_rxd = data[i];
            #BIT_PERIOD;
        end
        // 停止�?
        uart_rxd = 1;
        #BIT_PERIOD;
    end
endtask

// 主测试流�?
initial begin
    // 初始化信�?
    sys_clk   = 0;
    sys_rst_n = 0;
    uart_rxd  = 1;  // UART空闲状�??
    
    // 系统复位
    #100;
    sys_rst_n = 1;
    #3000;  // 等待锁相环锁�?
    
	// $display("Initialization complete. BAUD_RATE is %d",BAUD_RATE); //命令行显示初始化完成，输出BPS_NUM
	#BIT_PERIOD; 						//直接延时，一个波特率周期
	$display("Sending configuration data...");	
    uart_send_byte(8'h55);  // 假设包头
    uart_send_byte(8'h01);  // dataA
    uart_send_byte(8'h01);  // dataD
    uart_send_byte(8'h01);  // dataB[7:0]
    uart_send_byte(8'h03);  // dataB[15:8]
    uart_send_byte(8'h00);  // dataC[7:0]
    uart_send_byte(8'h44);  // dataC[15:8]
	uart_send_byte(8'h00);  // 假设包头
    uart_send_byte(8'h00);  // dataA
    uart_send_byte(8'h00);  // dataD
    uart_send_byte(8'h00);  // dataB[7:0]
    uart_send_byte(8'hff);  // dataB[15:8]
    uart_send_byte(8'h0c);  // dataC[7:0]
    uart_send_byte(8'haa);  // 假设包尾		
	#BIT_PERIOD ;
	uart_rxd = 1'b1;	   //串口发送线，默认拉高
	#(BIT_PERIOD * 5) ; 	
	$display("The 1st package...");	
	uart_send_byte(8'h55);  // 假设包头
    uart_send_byte(8'h01);  // dataA
    uart_send_byte(8'h00);  // dataD
    uart_send_byte(8'h01);  // dataB[7:0]
    uart_send_byte(8'hff);  // dataB[15:8]
    uart_send_byte(8'h07);  // dataC[7:0]
    uart_send_byte(8'h30);  // dataC[15:8]
	uart_send_byte(8'h00);  // 假设包头
    uart_send_byte(8'hff);  // dataA
    uart_send_byte(8'hff);  // dataD
    uart_send_byte(8'hff);  // dataB[7:0]
    uart_send_byte(8'hff);  // dataB[15:8]
    uart_send_byte(8'h0c);  // dataC[7:0]
    uart_send_byte(8'haa );  // 假设包尾	
	#BIT_PERIOD ;
	uart_rxd = 1'b1;	   //串口发送线，默认拉高
	#(BIT_PERIOD * 5) ; 
	$display("The second package...");	
	uart_send_byte(8'h55);  // 假设包头
    uart_send_byte(8'h02);  // dataA
    uart_send_byte(8'h12);  // dataD
    uart_send_byte(8'h13);  // dataB[7:0]
    uart_send_byte(8'h14);  // dataB[15:8]
    uart_send_byte(8'h15);  // dataC[7:0]
    uart_send_byte(8'h16);  // dataC[15:8]
	uart_send_byte(8'h17);  // 假设包头
    uart_send_byte(8'h18);  // dataA
    uart_send_byte(8'h19);  // dataD
    uart_send_byte(8'h1a);  // dataB[7:0]
    uart_send_byte(8'h1b);  // dataB[15:8]
    uart_send_byte(8'h1c);  // dataC[7:0]
    uart_send_byte(8'hAA );  // 假设包尾	
	#BIT_PERIOD ;
	uart_rxd = 1'b1;	   //串口发送线，默认拉高
	#(BIT_PERIOD * 5) ; 	
	$display("The 3rd package...");	
	uart_send_byte(8'h55);  // 假设包头
    uart_send_byte(8'h01);  // dataA
    uart_send_byte(8'h22);  // dataD
    uart_send_byte(8'h23);  // dataB[7:0]
    uart_send_byte(8'h24);  // dataB[15:8]
    uart_send_byte(8'h25);  // dataC[7:0]
    uart_send_byte(8'h26);  // dataC[15:8]
	uart_send_byte(8'h27);  // 假设包头
    uart_send_byte(8'h28);  // dataA
    uart_send_byte(8'h29);  // dataD
    uart_send_byte(8'h2a);  // dataB[7:0]
    uart_send_byte(8'h2b);  // dataB[15:8]
    uart_send_byte(8'h2c);  // dataC[7:0]
    uart_send_byte(8'hAA );  // 假设包尾	
	#BIT_PERIOD ;
	uart_rxd = 1'b1;	   //串口发送线，默认拉高
	#(BIT_PERIOD * 5) ; 
	$stop;		//结束仿真
    
    // #1000;
    // $finish;
end

// 波形记录
initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, tb_dds_sample_top);
end

endmodule