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
wire [7:0] rx_data;
wire rx_done;
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
uart_rx u_rx(
    .clk(sys_clk),
    .rst_n(sys_rst_n),
    .uart_rxd(uart_txd),
    .uart_rx_done(rx_done),
    .uart_rx_data(rx_data)
);
// 系统时钟生成
always #(SYS_CLK_PERIOD/2) sys_clk = ~sys_clk;
// Connect uut's TX to testbench's RX
// always @(*) begin
//     uart_rxd = uut.uart_txd;  // Assuming your uut instance is named 'uut'
// end
// Task to monitor received data
task monitor_rx;
    reg [7:0] rx_buffer [0:5];
    static integer count = 0;
    begin
        forever begin
            @(posedge rx_done);
            rx_buffer[count] = rx_data;
            count = count + 1;
            
            if(count == 6) begin
                $display("Received 6 bytes: %h %h %h %h %h %h", 
                    rx_buffer[0], rx_buffer[1], rx_buffer[2],
                    rx_buffer[3], rx_buffer[4], rx_buffer[5]);
                count = 0;
            end
        end
    end
endtask
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
// In your initial block
initial begin
    // ... existing initialization ...
    
    fork
        monitor_rx();  // Start monitoring received data
    join_none
end
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
        8'h01,  // hs_ctrl_sta
        8'h01,  // duty_num
        8'h00,  // pulse_dessert H
        8'h02,  // pulse_dessert L
        8'h00,  // pulse_num
        8'h00,  // PAT
        8'h00,  // PAT
        8'h00,  // PAT
        8'h03,  // PAT
        8'hfE,  // CRC
        8'haa   // 假设包尾
    );
	#(BIT_PERIOD * 100) ; 	
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
	#(BIT_PERIOD * 100) ; 	

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
	#(BIT_PERIOD * 100) ; 	
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
	#(BIT_PERIOD * 100) ; 
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
	
	#(BIT_PERIOD * 100) ; 	
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
	$display("disenable pwm2 dac....");	
    send_pwm_packet(
        8'h55,  // 假设包头
        8'h02,  // reg_func
        8'h02,  // hs_pwm_ch
        8'h00,  // hs_ctrl_sta
        8'h00,  // duty_num
        8'h00,  // pulse_dessert H
        8'h00,  // pulse_dessert L
        8'h00,  // pulse_num
        8'h00,  // PAT
        8'h00,  // PAT
        8'h00,  // PAT
        8'h00,  // PAT
        8'hEE,  // CRC
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
// initial begin
//     $dumpfile("waveform.vcd");
//     $dumpvars(0, tb_dds_sample_top);
// end

endmodule

module uart_rx(
    input               clk         ,  //系统时钟
    input               rst_n       ,  //系统复位，低有效

    input               uart_rxd    ,  //UART接收端口
    output  reg         uart_rx_done,  //UART接收完成信号
    output  reg  [7:0]  uart_rx_data   //UART接收到的数据
    );

//parameter define
parameter CLK_FREQ = 50000000;               //系统时钟频率
parameter UART_BPS = 115200  ;               //串口波特率
localparam BAUD_CNT_MAX = CLK_FREQ/UART_BPS; //为得到指定波特率，对系统时钟计数BPS_CNT次

//reg define
reg          uart_rxd_d0;
reg          uart_rxd_d1;
reg          uart_rxd_d2;
reg          rx_flag    ;  //接收过程标志信号
reg  [3:0 ]  rx_cnt     ;  //接收数据计数器
reg  [15:0]  baud_cnt   ;  //波特率计数器
reg  [7:0 ]  rx_data_t  ;  //接收数据寄存器

//wire define
wire        start_en;

//*****************************************************
//**                    main code
//*****************************************************
//捕获接收端口下降沿(起始位)，得到一个时钟周期的脉冲信号
assign start_en = uart_rxd_d2 & (~uart_rxd_d1) & (~rx_flag);

//针对异步信号的同步处理
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        uart_rxd_d0 <= 1'b0;
        uart_rxd_d1 <= 1'b0;
        uart_rxd_d2 <= 1'b0;
    end
    else begin
        uart_rxd_d0 <= uart_rxd;
        uart_rxd_d1 <= uart_rxd_d0;
        uart_rxd_d2 <= uart_rxd_d1;
    end
end

//给接收标志赋值
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        rx_flag <= 1'b0;
    else if(start_en)    //检测到起始位
        rx_flag <= 1'b1; //接收过程中，标志信号rx_flag拉高
    //在停止位一半的时候，即接收过程结束，标志信号rx_flag拉低
    else if((rx_cnt == 4'd9) && (baud_cnt == BAUD_CNT_MAX/2 - 1'b1))
        rx_flag <= 1'b0;
    else
        rx_flag <= rx_flag;
end        

//波特率的计数器赋值
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        baud_cnt <= 16'd0;
    else if(rx_flag) begin     //处于接收过程时，波特率计数器（baud_cnt）进行循环计数
        if(baud_cnt < BAUD_CNT_MAX - 1'b1)
            baud_cnt <= baud_cnt + 16'b1;
        else 
            baud_cnt <= 16'd0; //计数达到一个波特率周期后清零
    end    
    else
        baud_cnt <= 16'd0;     //接收过程结束时计数器清零
end

//对接收数据计数器（rx_cnt）进行赋值
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        rx_cnt <= 4'd0;
    else if(rx_flag) begin                  //处于接收过程时rx_cnt才进行计数
        if(baud_cnt == BAUD_CNT_MAX - 1'b1) //当波特率计数器计数到一个波特率周期时
            rx_cnt <= rx_cnt + 1'b1;        //接收数据计数器加1
        else
            rx_cnt <= rx_cnt;
    end
    else
        rx_cnt <= 4'd0;                     //接收过程结束时计数器清零
end        

//根据rx_cnt来寄存rxd端口的数据
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        rx_data_t <= 8'b0;
    else if(rx_flag) begin                           //系统处于接收过程时
        if(baud_cnt == BAUD_CNT_MAX/2 - 1'b1) begin  //判断baud_cnt是否计数到数据位的中间
           case(rx_cnt)
               4'd1 : rx_data_t[0] <= uart_rxd_d2;   //寄存数据的最低位
               4'd2 : rx_data_t[1] <= uart_rxd_d2;
               4'd3 : rx_data_t[2] <= uart_rxd_d2;
               4'd4 : rx_data_t[3] <= uart_rxd_d2;
               4'd5 : rx_data_t[4] <= uart_rxd_d2;
               4'd6 : rx_data_t[5] <= uart_rxd_d2;
               4'd7 : rx_data_t[6] <= uart_rxd_d2;
               4'd8 : rx_data_t[7] <= uart_rxd_d2;   //寄存数据的高低位
               default : ;
            endcase  
        end
        else
            rx_data_t <= rx_data_t;
    end
    else
        rx_data_t <= 8'b0;
end        

//给接收完成信号和接收到的数据赋值
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        uart_rx_done <= 1'b0;
        uart_rx_data <= 8'b0;
    end
    //当接收数据计数器计数到停止位，且baud_cnt计数到停止位的中间时
    else if(rx_cnt == 4'd9 && baud_cnt == BAUD_CNT_MAX/2 - 1'b1) begin
        uart_rx_done <= 1'b1     ;  //拉高接收完成信号
        uart_rx_data <= rx_data_t;  //并对UART接收到的数据进行赋值
    end    
    else begin
        uart_rx_done <= 1'b0;
        uart_rx_data <= uart_rx_data;
    end
end

endmodule