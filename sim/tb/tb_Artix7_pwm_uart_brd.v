`timescale 1ns / 1ps
module tb_Artix7_pwm_uart_brd();

    // Parameters
    parameter _PAT_WIDTH = 32;
    parameter _NUM_CHANNELS = 6;
    parameter _NUM_SLOW_CH = 1;
    parameter _DAC_WIDTH = 8;

    // Inputs
    reg sys_clk;
    reg sys_rst_n;
    reg uart_rxd;

    // Outputs
    wire [_DAC_WIDTH-1:0] dac_data;
    wire led;
    wire pwm_port;
    wire adc_clk_p;
    wire adc_clk_n;
    wire dds_clk0_p;
    wire dds_clk0_n;
    wire pwm_slow_port;
    wire pwm_diff_port_n;
    wire pwm_diff_port_p;
    wire uart_txd;
    // 定义仿真控制参数
    localparam SYS_CLK_PERIOD = 20;    // 100MHz系统时钟
    localparam UART_BAUD_RATE  = 115200;
    localparam CLK_FREQ_MHZ    = 50;
    localparam BIT_PERIOD      = 1_000_000_000 / UART_BAUD_RATE; // 单位：ns

    // Instantiate DUT
    Artix7_pwm_uart_brd #(
        ._PAT_WIDTH(_PAT_WIDTH),
        ._NUM_CHANNELS(_NUM_CHANNELS),
        ._NUM_SLOW_CH(_NUM_SLOW_CH),
        ._DAC_WIDTH(_DAC_WIDTH)
    ) dut (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .uart_rxd(uart_rxd),
        // .dac_data(dac_data),
        .led(led),
        // .pwm_port(pwm_port),
        .adc_clk_p(adc_clk_p),
        .adc_clk_n(adc_clk_n),
        .dds_clk0_p(dds_clk0_p),
        .dds_clk0_n(dds_clk0_n),
        .pwm_slow_port(pwm_slow_port),
        .pwm_diff_port_n(pwm_diff_port_n),
        .pwm_diff_port_p(pwm_diff_port_p),
        .uart_txd(uart_txd)
    );
// UART数据发�?�任�??
task uart_send_byte;
    input [7:0] data;
    integer i;
    begin
        // 起�?��?
        uart_rxd = 0;
        #BIT_PERIOD;
        // 数据位（LSB first�??
        for (i=0; i<8; i=i+1) begin
            uart_rxd = data[i];
            #BIT_PERIOD;
        end
        // 停�??�??
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
    // Clock generation
    initial begin
        sys_clk = 0;
        forever #(SYS_CLK_PERIOD/2) sys_clk = ~sys_clk; // 50MHz clock
    end

    // Reset generation
    initial begin
        // sys_rst_n = 0;
        // #500 
        sys_rst_n = 0;
        #3000 sys_rst_n = 1;
        uart_rxd = 1;
        // 系统复位
        // #100;
        // sys_rst_n = 0; // 复位信号拉低
        // #3000; 
        #BIT_PERIOD; 						//直接延时，一�?波特率周�?
	$display("Sending configuration dac...");	
    send_pwm_packet(
        8'h55,  // 假�?�包�?
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
        8'haa   // 假�?�包�?
    );
	#(BIT_PERIOD * 50) ; 	
    $display("Sending configuration dac...");	
    send_pwm_packet(
        8'h55,  // 假�?�包�?
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
        8'haa   // 假�?�包�?
    );
	#(BIT_PERIOD * 50) ; 	

    $display("Sending configuration pwm1...");	
    send_pwm_packet(
        8'h55,  // 假�?�包�?
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
        8'haa   // 假�?�包�?
    );
	#(BIT_PERIOD * 50) ; 	
	$display("Enable pwm1...");	
    send_pwm_packet(
        8'h55,  // 假�?�包�?
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
        8'haa   // 假�?�包�?
    );
	#(BIT_PERIOD * 50) ; 
	$display("Enable pwm3 slow pwm...");	
    send_pwm_packet(
        8'h55,  // 假�?�包�?
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
        8'hAA   // 假�?�包�?
    );
	
	#(BIT_PERIOD * 50) ; 	
	$display("disenable pwm3 slow pwm....");	
    send_pwm_packet(
        8'h55,  // 假�?�包�?
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
        8'hAA   // 假�?�包�?
    );
	
	#(BIT_PERIOD * 50) ; 
    $display("disable pwm1 unsecceed...");	
    send_pwm_packet(
        8'h55,  // 假�?�包�?
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
        8'hAA   // 假�?�包�?
    );
	#(BIT_PERIOD * 50) ; 	
    $display("disable pwm1...");	
    send_pwm_packet(
        8'h55,  // 假�?�包�?
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
        8'hAA   // 假�?�包�?
    );
	#(BIT_PERIOD * 50) ; 
	$stop;		//结束仿真
    end

    // // Test stimulus
    // initial begin
        
    //     // Add your test stimulus here

    //     // End simulation
    //     #1000 $finish;
    // end
    // 波形记录
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_Artix7_pwm_uart_brd);
    end
endmodule
