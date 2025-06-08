`timescale 1ns / 1ps

module tb_dds_sample_top();

// 定义与被测模块连接的信号
reg         sys_clk;
reg         sys_rst_n;
reg         uart_rxd;
wire        led;
wire        pwm_port;
wire        uart_txd;
wire pwm_port_slow;
wire debug_uart_tx;
wire debug_uart_rx;
wire    adc_clk_p;
wire    adc_clk_n;
wire [7:0] dac_data;

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
    .dac_data   (dac_data),
    .pwm_slow_port  (pwm_port_slow),
    .ad9748_sleep(),
    // .pwm_slow_port(),
    .pwm_diff_port_n(),
    .pwm_diff_port_p(),
    .adc_clk_p(adc_clk_p),
    .adc_clk_n(adc_clk_n),
    .dds_clk0_p(dds_clk0_p),
    .dds_clk0_n(dds_clk0_n),
    .debug_uart_tx(debug_uart_tx),
    .debug_uart_rx(debug_uart_rx),
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
task send_pwm_packet;
    input [7:0] header;
    input [7:0] reg_func;
    input [7:0] hs_pwm_ch;
    input [7:0] hs_ctrl_sta;
    input [7:0] duty_num;
    input [7:0] pulse_dessert_h;
    input [7:0] pulse_dessert_l;
    input [7:0] pulse_num;
    input [7:0] pat1;
    input [7:0] pat2;
    input [7:0] pat3;
    input [7:0] pat4;
    input [7:0] crc;
    input [7:0] footer;
    begin
        uart_send_byte(header);
        uart_send_byte(reg_func);
        uart_send_byte(hs_pwm_ch);
        uart_send_byte(hs_ctrl_sta);
        uart_send_byte(duty_num);
        uart_send_byte(pulse_dessert_h);
        uart_send_byte(pulse_dessert_l);
        uart_send_byte(pulse_num);
        uart_send_byte(pat1);
        uart_send_byte(pat2);
        uart_send_byte(pat3);
        uart_send_byte(pat4);
        uart_send_byte(crc);
        uart_send_byte(footer);
        #BIT_PERIOD;
        uart_rxd = 1'b1;
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
	$display("Sending configuration dac...");	
    send_pwm_packet(
        8'h55,  // 假设包头
        8'h01,  // reg_func
        8'h02,  // hs_pwm_ch
        8'h00,  // hs_ctrl_sta
        8'h01,  // duty_num
        8'h00,  // pulse_dessert H
        8'h01,  // pulse_dessert L
        8'h00,  // pulse_num
        8'h00,  // PAT
        8'h00,  // PAT
        8'h00,  // PAT
        8'h01,  // PAT
        8'hf2,  // CRC
        8'haa   // 假设包尾
    );
	#(BIT_PERIOD * 50) ; 	
    $display("Sending configuration dac...");	
    send_pwm_packet(
        8'h55,  // 假设包头
        8'h02,  // reg_func
        8'h02,  // hs_pwm_ch
        8'h01,  // hs_ctrl_sta
        8'h00,  // duty_num
        8'h00,  // pulse_dessert H
        8'h00,  // pulse_dessert L
        8'h00,  // pulse_num
        8'h00,  // PAT
        8'h00,  // PAT
        8'h00,  // PAT
        8'h00,  // PAT
        8'h97,  // CRC
        8'haa   // 假设包尾
    );
	#(BIT_PERIOD * 50) ; 	

    $display("Sending configuration pwm1...");	
    send_pwm_packet(
        8'h55,  // 假设包头
        8'h01,  // reg_func
        8'h01,  // hs_pwm_ch
        8'h01,  // hs_ctrl_sta
        8'h01,  // duty_num
        8'h00,  // pulse_dessert H
        8'h01,  // pulse_dessert L
        8'h00,  // pulse_num
        8'h00,  // PAT
        8'h00,  // PAT
        8'h00,  // PAT
        8'h01,  // PAT
        8'h33,  // CRC
        8'haa   // 假设包尾
    );
	#(BIT_PERIOD * 50) ; 	
	$display("Enable pwm1...");	
    send_pwm_packet(
        8'h55,  // 假设包头
        8'h02,  // reg_func
        8'h01,  // hs_pwm_ch
        8'h01,  // hs_ctrl_sta
        8'h00,  // duty_num
        8'h00,  // pulse_dessert H
        8'h00,  // pulse_dessert L
        8'h00,  // pulse_num
        8'h00,  // PAT
        8'h00,  // PAT
        8'h00,  // PAT
        8'h00,  // PAT
        8'h2f,  // CRC
        8'haa   // 假设包尾
    );
	#(BIT_PERIOD * 50) ; 
	$display("Enable pwm3 slow pwm...");	
    send_pwm_packet(
        8'h55,  // 假设包头
        8'h02,  // reg_func
        8'h03,  // hs_pwm_ch
        8'h01,  // hs_ctrl_sta
        8'h00,  // duty_num
        8'h00,  // pulse_dessert H
        8'h00,  // pulse_dessert L
        8'h00,  // pulse_num
        8'h00,  // PAT
        8'h00,  // PAT
        8'h00,  // PAT
        8'h00,  // PAT
        8'hff,  // CRC
        8'hAA   // 假设包尾
    );
	
	#(BIT_PERIOD * 50) ; 	
	$display("disenable pwm3 slow pwm....");	
    send_pwm_packet(
        8'h55,  // 假设包头
        8'h02,  // reg_func
        8'h03,  // hs_pwm_ch
        8'h00,  // hs_ctrl_sta
        8'h00,  // duty_num
        8'h00,  // pulse_dessert H
        8'h00,  // pulse_dessert L
        8'h00,  // pulse_num
        8'h00,  // PAT
        8'h00,  // PAT
        8'h00,  // PAT
        8'h00,  // PAT
        8'h86,  // CRC
        8'hAA   // 假设包尾
    );
	
	#(BIT_PERIOD * 50) ; 
    $display("disable pwm1 unsecceed...");	
    send_pwm_packet(
        8'h55,  // 假设包头
        8'h02,  // reg_func
        8'h01,  // hs_pwm_ch
        8'h00,  // hs_ctrl_sta
        8'h00,  // duty_num
        8'h00,  // pulse_dessert H
        8'h00,  // pulse_dessert L
        8'h00,  // pulse_num
        8'h00,  // PAT
        8'h00,  // PAT
        8'h00,  // PAT
        8'h00,  // PAT
        // 8'h56,  // CRC
        8'h55,  // CRC ERROR
        8'hAA   // 假设包尾
    );
	#(BIT_PERIOD * 50) ; 	
    $display("disable pwm1...");	
    send_pwm_packet(
        8'h55,  // 假设包头
        8'h02,  // reg_func
        8'h01,  // hs_pwm_ch
        8'h00,  // hs_ctrl_sta
        8'h00,  // duty_num
        8'h00,  // pulse_dessert H
        8'h00,  // pulse_dessert L
        8'h00,  // pulse_num
        8'h00,  // PAT
        8'h00,  // PAT
        8'h00,  // PAT
        8'h00,  // PAT
        8'h56,  // CRC
        // 8'h55,  // CRC ERROR
        8'hAA   // 假设包尾
    );
	#(BIT_PERIOD * 50) ; 
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