`timescale 1ns / 1ps
// Description: 测试串口
// Dependencies:
module uart_top_vlg_tst();
//==========================================================================
//wire and reg 定义：信号与参数
//==========================================================================
	// input to module
	reg       sim_clk;		//模拟时钟信号
	//reg     tx_pulse;     // active posedge
	reg 	    sim_rst_n;
	reg       uart_rxd;		//串口发送信号线

	//output from module
	wire [7:0] rx_data;		//送入串口发送模块，准备发送的数据
	wire       rx_en;       //串口接收数据有效，接收完成拉高1个BPS
	wire       rx_get;
	 wire [7:0] pack_cnt;  
	 wire       pack_done; 
	 wire       pack_ing;
	 wire [7:0] pack_num;
	 
	 wire        recv_done;
	 wire [7:0]     rev_data0   ;
	 wire [7:0]     rev_data1   ;
	 wire [7:0]     rev_data2   ;
	 wire [7:0]     rev_data3   ;
	 wire [7:0]     rev_data4   ;
	 wire [7:0]     rev_data5   ;
	 wire [7:0]     rev_data6   ;
	 wire [7:0]     rev_data7   ;
	 wire [7:0]     rev_data8   ;
	 wire [7:0]     rev_data9   ;
	 wire [7:0]     rev_data10  ;
	 wire [7:0]     rev_data11  ;  
	            
	             
	 
  
	//时钟参数
	parameter SYS_CLK_FRE = 50_000_000;     //系统频率50MHz  40_000_000
	parameter SYS_CLK_PERIOD = 1_000_000_000/SYS_CLK_FRE;  //周期20ns
	//波特率参数
  	parameter BAUD_RATE = 115200; 	//串口波特率
	parameter BAUD_RATE_PERIOD	= 1_000_000_000/BAUD_RATE;

//==========================================================================
//模拟时钟信号
//==========================================================================
	//模拟系统时钟:50MHz，20ns
	always #((SYS_CLK_PERIOD)/2) sim_clk = ~sim_clk; //延时，电平翻转
	//模拟系统时钟:40MHz，25ns
//	always #((SYS_CLK_PERIOD+1)/2-1) sim_clk = ~sim_clk; //延时，电平翻转
	
	// UART数据发送任务
task uart_send_byte;
    input [7:0] data;
    integer i;
    begin
        // 起始位
        uart_rxd = 0;
        #BAUD_RATE_PERIOD;
        // 数据位（LSB first）
        for (i=0; i<8; i=i+1) begin
            uart_rxd = data[i];
            #BAUD_RATE_PERIOD;
        end
        // 停止位
        uart_rxd = 1;
        #BAUD_RATE_PERIOD;
    end
endtask

	initial	begin
		//模拟复位信号：一次，低电平5个clk
		#0;
			sim_clk = 1'b0;
			sim_rst_n = 1'b1;      //复位
		#BAUD_RATE_PERIOD;		   
			sim_rst_n = 1'b0;      //解除复位

		//==========================================================================
		//模拟串口接收：串行信号输入，转化成并行数据，并显示
		//==========================================================================			
		uart_rxd = 1'b1;	   //串口发送线，默认拉高
		
		$display("Initialization complete. BAUD_RATE is %d",BAUD_RATE); //命令行显示初始化完成，输出BPS_NUM
		#BAUD_RATE_PERIOD; 						//直接延时，一个波特率周期
	$display("Sending configuration data...");	
    uart_send_byte(8'h55);  // 假设包头
    uart_send_byte(8'h01);  // dataA
    uart_send_byte(8'h02);  // dataD
    uart_send_byte(8'h03);  // dataB[7:0]
    uart_send_byte(8'h04);  // dataB[15:8]
    uart_send_byte(8'h05);  // dataC[7:0]
    uart_send_byte(8'h06);  // dataC[15:8]
	uart_send_byte(8'h07);  // 假设包头
    uart_send_byte(8'h08);  // dataA
    uart_send_byte(8'h09);  // dataD
    uart_send_byte(8'h0a);  // dataB[7:0]
    uart_send_byte(8'h0b);  // dataB[15:8]
    uart_send_byte(8'h0c);  // dataC[7:0]
    uart_send_byte(8'haa);  // 假设包尾		
	#BAUD_RATE_PERIOD ;
	uart_rxd = 1'b1;	   //串口发送线，默认拉高
	#(BAUD_RATE_PERIOD * 5) ; 	
	$display("The 1st package...");	
	uart_send_byte(8'h55);  // 假设包头
    uart_send_byte(8'h02);  // dataA
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
    uart_send_byte(8'hA0 );  // 假设包尾	
	#BAUD_RATE_PERIOD ;
	uart_rxd = 1'b1;	   //串口发送线，默认拉高
	#(BAUD_RATE_PERIOD * 5) ; 
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
	#BAUD_RATE_PERIOD ;
	uart_rxd = 1'b1;	   //串口发送线，默认拉高
	#(BAUD_RATE_PERIOD * 5) ; 	
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
	#BAUD_RATE_PERIOD ;
	uart_rxd = 1'b1;	   //串口发送线，默认拉高
	#(BAUD_RATE_PERIOD * 5) ; 
	$stop;		//结束仿真
// //一帧数据		
// $display("The first byte...");
// 		//发送数据----起始位
// 			uart_rxd = 1'b0;			#BAUD_RATE_PERIOD;	
// 		//串行数据，一位一位送入接收信号线：***从位0到位7***，依次发送
// 		//测试数据为8'h55=8'b0101_0101
// 			uart_rxd = 1'b1;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;				#BAUD_RATE_PERIOD; 		
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;     		#BAUD_RATE_PERIOD; 		
// 		$display("The uart_rxd 8'h55=8'b0101_0101 has been sent.");  //命令行显示：串口信号线数据已发送
// 		//发送数据----停止位
// 			uart_rxd = 1'b1;	
// 		#(BAUD_RATE_PERIOD/3);//为了显示
// 			$display("The uart_rxd has received. rx_data = 8'h%h",rx_data);  
// 		#(BAUD_RATE_PERIOD*2/3);
// 		#5000;
// 		//命令行显示：串口信号线接收已结束，显示接收到的数据
// //一帧数据	
// $display("The second byte...");	
// 		//发送数据----起始位
// 			uart_rxd = 1'b0;			#BAUD_RATE_PERIOD;	
// 		//串行数据，一位一位送入接收信号线：***从位0到位7***，依次发送
// 		//测试数据为8'h12=8'b0001_0010
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 		
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;     		#BAUD_RATE_PERIOD; 	
// 		$display("The uart_rxd 8'h12=8'b0001_0010 has been sent.");  //命令行显示：串口信号线数据已发送
// 		//发送数据----停止位
// 			uart_rxd = 1'b1;	
// 		#(BAUD_RATE_PERIOD/3);//为了显示
// 			$display("The uart_rxd has received. rx_data = 8'h%h",rx_data);  
// 		#(BAUD_RATE_PERIOD*2/3);
// 		//命令行显示：串口信号线接收已结束，显示接收到的数据
// //一帧数据	
// $display("The third byte...");	
// 		//发送数据----起始位
// 			uart_rxd = 1'b0;			#BAUD_RATE_PERIOD;	
// 		//串行数据，一位一位送入接收信号线：***从位0到位7***，依次发送
// 		//测试数据为8'h13=8'b0001_0011
// 			uart_rxd = 1'b1;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 		
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;     		#BAUD_RATE_PERIOD; 
// 		$display("The uart_rxd 8'h13=8'b0001_0011 has been sent.");  //命令行显示：串口信号线数据已发送
// 		//发送数据----停止位
// 			uart_rxd = 1'b1;	
// 		#(BAUD_RATE_PERIOD/3);//为了显示
// 			$display("The uart_rxd has received. rx_data = 8'h%h",rx_data);  
// 		#(BAUD_RATE_PERIOD*2/3);
// 		//命令行显示：串口信号线接收已结束，显示接收到的数据
// $display("The 4 byte...");	
// 		//发送数据----起始位
// 			uart_rxd = 1'b0;			#BAUD_RATE_PERIOD;	
// 		//串行数据，一位一位送入接收信号线：***从位0到位7***，依次发送
// 		//测试数据为8'h14=8'b0001_0100
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;				#BAUD_RATE_PERIOD; 		
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;     		#BAUD_RATE_PERIOD; 
// 		$display("The uart_rxd 8'h14=8'b0001_0100 has been sent.");  //命令行显示：串口信号线数据已发送
// 		//发送数据----停止位
// 			uart_rxd = 1'b1;	
// 		#(BAUD_RATE_PERIOD/3);//为了显示
// 			$display("The uart_rxd has received. rx_data = 8'h%h",rx_data);  
// 		#(BAUD_RATE_PERIOD*2/3);
// 		//命令行显示：串口信号线接收已结束，显示接收到的数据	
// $display("The 5 byte...");	
// 		//发送数据----起始位
// 			uart_rxd = 1'b0;			#BAUD_RATE_PERIOD;	
// 		//串行数据，一位一位送入接收信号线：***从位0到位7***，依次发送
// 		//测试数据为8'h15=8'b0001_0101
// 			uart_rxd = 1'b1;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;				#BAUD_RATE_PERIOD; 		
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;     		#BAUD_RATE_PERIOD; 	
// 		$display("The uart_rxd 8'h15=8'b0001_0101 has been sent.");  //命令行显示：串口信号线数据已发送
// 		//发送数据----停止位
// 			uart_rxd = 1'b1;	
// 		#(BAUD_RATE_PERIOD/3);//为了显示
// 			$display("The uart_rxd has received. rx_data = 8'h%h",rx_data);  
// 		#(BAUD_RATE_PERIOD*2/3);
// 		//命令行显示：串口信号线接收已结束，显示接收到的数据	

// $display("The 6 byte...");	
// 		//发送数据----起始位
// 			uart_rxd = 1'b0;			#BAUD_RATE_PERIOD;	
// 		//串行数据，一位一位送入接收信号线：***从位0到位7***，依次发送
// 		//测试数据为8'h16=8'b0001_0110
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;				#BAUD_RATE_PERIOD; 		
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;     		#BAUD_RATE_PERIOD; 	
// 		$display("The uart_rxd 8'h16=8'b0001_0110 has been sent.");  //命令行显示：串口信号线数据已发送
// 		//发送数据----停止位
// 			uart_rxd = 1'b1;	
// 		#(BAUD_RATE_PERIOD/3);//为了显示
// 			$display("The uart_rxd has received. rx_data = 8'h%h",rx_data);  
// 		#(BAUD_RATE_PERIOD*2/3);
// 		//命令行显示：串口信号线接收已结束，显示接收到的数据
// $display("The 7 byte...");	
// 		//发送数据----起始位
// 			uart_rxd = 1'b0;			#BAUD_RATE_PERIOD;	
// 		//串行数据，一位一位送入接收信号线：***从位0到位7***，依次发送
// 		//测试数据为8'h0d=8'b0000_1101
// 			uart_rxd = 1'b1;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;				#BAUD_RATE_PERIOD; 		
// 			uart_rxd = 1'b1;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;			   #BAUD_RATE_PERIOD; 		
// 		$display("The uart_rxd 8'h0d=8'b0000_1101 has been sent.");  //命令行显示：串口信号线数据已发送
// 		//发送数据----停止位
// 			uart_rxd = 1'b1;	
// 		#(BAUD_RATE_PERIOD/3);//为了显示
// 			$display("The uart_rxd has received. rx_data = 8'h%h",rx_data);  
// 		#(BAUD_RATE_PERIOD*2/3);
// 		//命令行显示：串口信号线接收已结束，显示接收到的数据
// $display("The 8 byte...");	
// 		//发送数据----起始位
// 			uart_rxd = 1'b0;			#BAUD_RATE_PERIOD;	
// 		//串行数据，一位一位送入接收信号线：***从位0到位7***，依次发送
// 		//测试数据为8'h0a=8'b0000_1010
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 		
// 			uart_rxd = 1'b1;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;		   	#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;	   		#BAUD_RATE_PERIOD; 		
// 		$display("The uart_rxd 8'h0a=8'b0000_1010 has been sent.");  //命令行显示：串口信号线数据已发送
// 		//发送数据----停止位
		// 	uart_rxd = 1'b1;	
		// #(BAUD_RATE_PERIOD/3);//为了显示
		// 	$display("The uart_rxd has received. rx_data = 8'h%h",rx_data);  
		// #(BAUD_RATE_PERIOD*2/3);
		// //命令行显示：串口信号线接收已结束，显示接收到的数据
			
//------------------第二包数据------------------------//
		
// //一帧数据		
// $display("The first byte...");
// 		//发送数据----起始位
// 			uart_rxd = 1'b0;			#BAUD_RATE_PERIOD;	
// 		//串行数据，一位一位送入接收信号线：***从位0到位7***，依次发送
// 		//测试数据为8'h55=8'b0101_0101
// 			uart_rxd = 1'b1;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;				#BAUD_RATE_PERIOD; 		
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;     		#BAUD_RATE_PERIOD; 		
// 		$display("The uart_rxd 8'h55=8'b0101_0101 has been sent.");  //命令行显示：串口信号线数据已发送
// 		//发送数据----停止位
// 			uart_rxd = 1'b1;	
// 		#(BAUD_RATE_PERIOD/3);//为了显示
// 			$display("The uart_rxd has received. rx_data = 8'h%h",rx_data);  
// 		#(BAUD_RATE_PERIOD*2/3);
// 		//命令行显示：串口信号线接收已结束，显示接收到的数据
// //一帧数据	
// $display("The second byte...");	
// 		//发送数据----起始位
// 			uart_rxd = 1'b0;			#BAUD_RATE_PERIOD;	
// 		//串行数据，一位一位送入接收信号线：***从位0到位7***，依次发送
// 		//测试数据为8'h32=8'b0011_0010
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 		
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;     		#BAUD_RATE_PERIOD; 	
// 		$display("The uart_rxd 8'h32=8'b0011_0010 has been sent.");  //命令行显示：串口信号线数据已发送
// 		//发送数据----停止位
// 			uart_rxd = 1'b1;	
// 		#(BAUD_RATE_PERIOD/3);//为了显示
// 			$display("The uart_rxd has received. rx_data = 8'h%h",rx_data);  
// 		#(BAUD_RATE_PERIOD*2/3);
// 		//命令行显示：串口信号线接收已结束，显示接收到的数据
// //一帧数据	
// $display("The third byte...");	
// 		//发送数据----起始位
// 			uart_rxd = 1'b0;			#BAUD_RATE_PERIOD;	
// 		//串行数据，一位一位送入接收信号线：***从位0到位7***，依次发送
// 		//测试数据为8'h33=8'b0011_0011
// 			uart_rxd = 1'b1;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 		
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;     		#BAUD_RATE_PERIOD; 
// 		$display("The uart_rxd 8'h33=8'b0011_0011 has been sent.");  //命令行显示：串口信号线数据已发送
// 		//发送数据----停止位
// 			uart_rxd = 1'b1;	
// 		#(BAUD_RATE_PERIOD/3);//为了显示
// 			$display("The uart_rxd has received. rx_data = 8'h%h",rx_data);  
// 		#(BAUD_RATE_PERIOD*2/3);
// 		//命令行显示：串口信号线接收已结束，显示接收到的数据
// $display("The 4 byte...");	
// 		//发送数据----起始位
// 			uart_rxd = 1'b0;			#BAUD_RATE_PERIOD;	
// 		//串行数据，一位一位送入接收信号线：***从位0到位7***，依次发送
// 		//测试数据为8'h34=8'b0011_0100
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;				#BAUD_RATE_PERIOD; 		
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;     		#BAUD_RATE_PERIOD; 
// 		$display("The uart_rxd 8'h34=8'b0011_0100 has been sent.");  //命令行显示：串口信号线数据已发送
// 		//发送数据----停止位
// 			uart_rxd = 1'b1;	
// 		#(BAUD_RATE_PERIOD/3);//为了显示
// 			$display("The uart_rxd has received. rx_data = 8'h%h",rx_data);  
// 		#(BAUD_RATE_PERIOD*2/3);
// 		//命令行显示：串口信号线接收已结束，显示接收到的数据	
// $display("The 5 byte...");	
// 		//发送数据----起始位
// 			uart_rxd = 1'b0;			#BAUD_RATE_PERIOD;	
// 		//串行数据，一位一位送入接收信号线：***从位0到位7***，依次发送
// 		//测试数据为8'h35=8'b0001_0101
// 			uart_rxd = 1'b1;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;				#BAUD_RATE_PERIOD; 		
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;     		#BAUD_RATE_PERIOD; 	
// 		$display("The uart_rxd 8'h35=8'b0011_0101 has been sent.");  //命令行显示：串口信号线数据已发送
// 		//发送数据----停止位
// 			uart_rxd = 1'b1;	
// 		#(BAUD_RATE_PERIOD/3);//为了显示
// 			$display("The uart_rxd has received. rx_data = 8'h%h",rx_data);  
// 		#(BAUD_RATE_PERIOD*2/3);
// 		//命令行显示：串口信号线接收已结束，显示接收到的数据	

// $display("The 6 byte...");	
// 		//发送数据----起始位
// 			uart_rxd = 1'b0;			#BAUD_RATE_PERIOD;	
// 		//串行数据，一位一位送入接收信号线：***从位0到位7***，依次发送
// 		//测试数据为8'h36=8'b0001_0110
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;				#BAUD_RATE_PERIOD; 		
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;     		#BAUD_RATE_PERIOD; 	
// 		$display("The uart_rxd 8'h36=8'b0011_0110 has been sent.");  //命令行显示：串口信号线数据已发送
// 		//发送数据----停止位
// 			uart_rxd = 1'b1;	
// 		#(BAUD_RATE_PERIOD/3);//为了显示
// 			$display("The uart_rxd has received. rx_data = 8'h%h",rx_data);  
// 		#(BAUD_RATE_PERIOD*2/3);
// 		//命令行显示：串口信号线接收已结束，显示接收到的数据
// $display("The 7 byte...");	
// 		//发送数据----起始位
// 			uart_rxd = 1'b0;			#BAUD_RATE_PERIOD;	
// 		//串行数据，一位一位送入接收信号线：***从位0到位7***，依次发送
// 		//测试数据为8'h0d=8'b0000_1101
// 			uart_rxd = 1'b1;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;				#BAUD_RATE_PERIOD; 		
// 			uart_rxd = 1'b1;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;			   #BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;			   #BAUD_RATE_PERIOD; 		
// 		$display("The uart_rxd 8'h0d=8'b0000_1101 has been sent.");  //命令行显示：串口信号线数据已发送
// 		//发送数据----停止位
// 			uart_rxd = 1'b1;	
// 		#(BAUD_RATE_PERIOD/3);//为了显示
// 			$display("The uart_rxd has received. rx_data = 8'h%h",rx_data);  
// 		#(BAUD_RATE_PERIOD*2/3);
// 		//命令行显示：串口信号线接收已结束，显示接收到的数据
// $display("The 8 byte...");	
// 		//发送数据----起始位
// 			uart_rxd = 1'b0;			#BAUD_RATE_PERIOD;	
// 		//串行数据，一位一位送入接收信号线：***从位0到位7***，依次发送
// 		//测试数据为8'h0a=8'b0000_1010
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b1;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 		
// 			uart_rxd = 1'b1;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;				#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;		   	#BAUD_RATE_PERIOD; 
// 			uart_rxd = 1'b0;	   		#BAUD_RATE_PERIOD; 		
// 		$display("The uart_rxd 8'h0a=8'b0000_1010 has been sent.");  //命令行显示：串口信号线数据已发送
// 		//发送数据----停止位
// 			uart_rxd = 1'b1;	
// 		#(BAUD_RATE_PERIOD/3);//为了显示
// 			$display("The uart_rxd has received. rx_data = 8'h%h",rx_data);  
// 		#(BAUD_RATE_PERIOD*2/3);
// 		//命令行显示：串口信号线接收已结束，显示接收到的数据

	//    #BAUD_RATE_PERIOD;
	// 	#BAUD_RATE_PERIOD;
		
		
	end

//==========================================================================
//调用top模块
//==========================================================================
//串口接收
 
uart_mult_byte_rx #(
	.CLK_FREQ   (SYS_CLK_FRE), //系统时钟
	.UART_BPS   (  BAUD_RATE )  // 时钟/波特率，1 bit位宽所需时钟周期的个数
)
  u_uart_mult_byte_rx(
	.sys_clk     (sim_clk),
	.sys_rst_n   (sim_rst_n),
	.uart_done   (rx_en),
	.uart_rxd    (uart_rxd),
	.uart_data   (rx_data),
	.uart_get    (rx_get),
	.pack_cnt    (pack_cnt),
	.pack_done_d1   (pack_done),
	.pack_ing    (pack_ing),
	.pack_num    (pack_num),
	.recv_done   (recv_done),
	.rev_data0   (rev_data0 ),
	.rev_data1   (rev_data1 ),
	.rev_data2   (rev_data2 ),
	.rev_data3   (rev_data3 ),
	.rev_data4   (rev_data4 ),
	.rev_data5   (rev_data5 ),
	.rev_data6   (rev_data6 ),
	.rev_data7   (rev_data7 ),
	.rev_data8   (rev_data8 ),
	.rev_data9   (rev_data9 ),
	.rev_data10  (rev_data10),
	.rev_data11  (rev_data11)
  );  

endmodule
