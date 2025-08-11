module uart_mult_byte_rx#(
        parameter  CLK_FREQ = 50_000_000,                 //系统时钟频率
        parameter  UART_BPS = 115200                     //串口波特�???????
    )
    (
    input			    sys_clk,                  //系统时钟
    input             sys_rst_n,                //系统复位，低电平有效
    input             uart_rxd,                 //UART接收�?�?

	 output  reg [ 7:0] uart_data,	
	 output  reg        uart_done,
	 output  reg        uart_get,               //采样�???????
	 
	 output  reg [7:0] pack_cnt,                //字节计数
	 output  reg       pack_ing, 	            //接收过程标志�???????
	 output  reg       pack_done_d1,               //帧接收完成标志位
	 output  reg [7:0] pack_num,                //接收到的字节�???????
	 output  reg       recv_done,              //接收完一帧数�?的接收和解�??????

     output  reg [7:0]     rev_data0   ,
     output  reg [7:0]     rev_data1   ,
     output  reg [7:0]     rev_data2   ,
     output  reg [7:0]     rev_data3   ,
     output  reg [7:0]     rev_data4   ,
     output  reg [7:0]     rev_data5   , 
     output  reg [7:0]     rev_data6   ,
     output  reg [7:0]     rev_data7   ,
     output  reg [7:0]     rev_data8   ,
     output  reg [7:0]     rev_data9   ,
     output  reg [7:0]     rev_data10  ,
     output  reg [7:0]     response_data // 响应数据寄存�?? 
    );
    
localparam  DATA_NUM = 14;
integer j;

reg [7:0] pack_data [DATA_NUM-1:0];           //接收的数�???????
//parameter define
// parameter  CLK_FREQ = 50_000_000;                 //系统时钟频率
// parameter  UART_BPS = 115200;                     //串口波特�???????
localparam BPS_CNT  = CLK_FREQ/UART_BPS;        //为得到指定波特率
 
localparam  TimeOut = BPS_CNT*DATA_NUM*10*2;//超时时间

//起�?�信号下降沿捕�??????
wire       start_flag;
reg        uart_rxd_d0;
reg        uart_rxd_d1;

reg [15:0] clk_cnt;                             //系统时钟计数�???????
reg [ 3:0] rx_cnt;                              //接收数据计数�???????
reg        rx_flag;                             //接收过程标志信号
reg [ 7:0] rxdata;                              //接收数据寄存�???????

//接收信号完成标志位上升沿
wire  rxdone_flag;
reg   uart_done_d0;
reg   uart_done_d1;
//包数�?接收完�??????
wire  packdone_flag;
reg   pack_done;
reg   pack_done_d0;
// Add CRC8 calculation signals
wire [7:0] crc8_value;  // CRC8 calculated value
reg        crc8_en;     // CRC calculation enable
reg        crc8_clr;    // CRC clear signal
reg        crc_valid;  // CRC valid signal
// reg [7:0]     rev_data11;                            //接收数据包功能号
//wire [7:0] crc8_value;  // 当前CRC�???
//reg        crc8_en;     // CRC计算使能
// reg [7:0] reg_func;                            //接收数据包功能号
//*****************************************************
//**                    main code
//*****************************************************
//捕获接收�?口下降�??????(起�?��??????)，得到一�?时钟周期的脉冲信�?
assign  start_flag = uart_rxd_d1 & (~uart_rxd_d0);    
//对UART接收�?口的数据延迟两个时钟�?�???????
always @(posedge sys_clk or posedge sys_rst_n) begin 
    if (sys_rst_n) begin 
        uart_rxd_d0 <= 1'b0;
        uart_rxd_d1 <= 1'b0;          
    end
    else begin
        uart_rxd_d0  <= uart_rxd;                   
        uart_rxd_d1  <= uart_rxd_d0;
    end   
end
//当脉冲信号start_flag到达时，进入接收过程           
always @(posedge sys_clk or posedge sys_rst_n) begin         
    if (sys_rst_n)                                  
        rx_flag <= 1'b0;
    else begin
        if(start_flag)                          //�???????测到起�?��??????
            rx_flag <= 1'b1;                    //进入接收过程，标志位rx_flag拉高
        else if((rx_cnt == 4'd9)&&(clk_cnt == BPS_CNT/2))
            rx_flag <= 1'b0;                    //计数到停�?位中间时，停止接收过�?
        else
            rx_flag <= rx_flag;
    end
end
//进入接收过程后，�?动系统时钟�?�数器与接收数据计数�???????
always @(posedge sys_clk or posedge sys_rst_n) begin         
    if (sys_rst_n) begin                             
        clk_cnt <= 16'd0;                                  
        rx_cnt  <= 4'd0;
    end                                                      
    else if ( rx_flag ) begin                   //处于接收过程
            if (clk_cnt < BPS_CNT - 1) begin
                clk_cnt <= clk_cnt + 1'b1;
                rx_cnt  <= rx_cnt;
            end
            else begin
                clk_cnt <= 16'd0;               //对系统时钟�?�数达�??????�?波特率周期后清�??????
                rx_cnt  <= rx_cnt + 1'b1;       //此时接收数据计数器加1
            end
        end
        else begin                              //接收过程结束，�?�数器清�?
            clk_cnt <= 16'd0;
            rx_cnt  <= 4'd0;
        end
end
//根据接收数据计数器来寄存uart接收�?口数�?
always @(posedge sys_clk or posedge sys_rst_n) begin 
    if (sys_rst_n)  begin
        rxdata <= 8'd0;     
		  uart_get<=1'b0;		
	 end  
    else if(rx_flag)                            //系统处于接收过程
        if (clk_cnt == BPS_CNT/2) begin         //判断系统时钟计数器�?�数到数�?位中�???????
            case ( rx_cnt )
             4'd1 : rxdata[0] <= uart_rxd_d1;   //寄存数据位最低位
             4'd2 : rxdata[1] <= uart_rxd_d1;
             4'd3 : rxdata[2] <= uart_rxd_d1;
             4'd4 : rxdata[3] <= uart_rxd_d1;
             4'd5 : rxdata[4] <= uart_rxd_d1;
             4'd6 : rxdata[5] <= uart_rxd_d1;
             4'd7 : rxdata[6] <= uart_rxd_d1;
             4'd8 : rxdata[7] <= uart_rxd_d1;   //寄存数据位最高位
             default:;                                    
            endcase
				uart_get<=1'b1;	
        end
        else  begin
            rxdata <= rxdata;
				uart_get<=1'b0;	
		  end
    else begin
        rxdata <= 8'd0;
		  uart_get<=1'b0;	
	 end
end


//数据接收完毕后给出标志信号并寄存输出接收到的数据
always @(posedge sys_clk or posedge sys_rst_n) begin        
    if (sys_rst_n) begin
        uart_data <= 8'd0;                               
        uart_done <= 1'b0;
    end
    else if(rx_cnt == 4'd9) begin               //接收数据计数器�?�数到停�?位时           
        uart_data <= rxdata;                    //寄存输出接收到的数据
        uart_done <= 1'b1;                      //并将接收完成标志位拉�???????
    end
    else begin
        uart_data <= 8'd0;                                   
        uart_done <= 1'b0; 
    end    
end

//---单字节接收程序，uart_done接收完成标志位会持续半个波特率周期，捕捉上升沿可以�?�数，高电平状�?�，接收数据有效
//==============================================接收多个字节，添加的模块====================================================//

//捕获接收完成标志位的上升沿，得到�???????�?时钟周期的脉冲信�?
assign  rxdone_flag = uart_done_d0 & (~uart_done_d1);    
//对UART完成标志的数�?延迟两个时钟�?�???????
always @(posedge sys_clk or posedge sys_rst_n) begin 
    if (sys_rst_n) begin 
        uart_done_d0 <= 1'b0;
        uart_done_d1 <= 1'b0;          
    end
    else begin
        uart_done_d0  <= uart_done;                   
        uart_done_d1  <= uart_done_d0;
    end   
end

//接收到的数据存入数组�?，并计�??????
always @(posedge sys_clk or posedge sys_rst_n) begin      //接收到数�???????  
    if (sys_rst_n) begin                             
		  pack_cnt <=8'd0;
		  pack_num <=8'd0;
		  pack_done<=1'b0; 
		  pack_ing <=1'b0;
          crc8_en  <= 1'b0;
          crc8_clr <= 1'b0;
          crc_valid <= 1'b0;
		  for (j=0;j<DATA_NUM;j=j+1) 
		    pack_data[j] <= 8'd0;		 
    end
	 else if(rxdone_flag) begin //接收完成标志位的上升沿，延迟了两�?时钟�?�???????
		 if (pack_cnt < DATA_NUM-1) begin       //处于接收过程�???????
				 for (j=0;j<DATA_NUM;j=j+1) begin
				     if(j==pack_cnt)
					    pack_data[pack_cnt] <= uart_data;//寄存输出接收到的数据
					  else
					    pack_data[j] <= pack_data[j];	
				 end
				 pack_cnt  <= pack_cnt + 1'b1; 
             pack_num <= 8'd0;	
		       pack_done<=1'b0; 
		       pack_ing <=1'b1;		 
		 end
		 else begin //接收完成---�???????后一�?字节的接�?
				 for (j=0;j<DATA_NUM;j=j+1) begin
				     if(j==pack_cnt)
					  pack_data[pack_cnt] <= uart_data;//寄存输出接收到的数据
					  else
					  pack_data[j] <= pack_data[j];	
				 end
				 pack_num <= pack_cnt + 1'b1; //加上�???????后一�?字�??????
			    pack_cnt  <= 8'd0;               //此时接收数据计数器归零，�?有接收完成时才清�?
				 pack_done<=1'b1;      			 //输出帧接收完成标志位，只存在�???????�?�?�???????
				 pack_ing <=1'b0;
		 end  

        if (pack_cnt >= 1 && pack_cnt <= (DATA_NUM - 3)) begin
            crc8_en <= 1'b1;
        end
        else begin
            crc8_en <= 1'b0;
        end

        // Clear CRC at the start of a new frame
        if (pack_cnt == 0) begin
            crc8_clr <= 1'b1;
        end
        else begin
            crc8_clr <= 1'b0;
        end

        // Check CRC at byte 10 (index 10)
        if (pack_cnt == (DATA_NUM - 2)) begin
            crc_valid <= (pack_data[DATA_NUM - 2] == crc8_value);
        end
	 end
	 else begin
		  pack_cnt <=pack_cnt;
		  pack_ing <=pack_ing;//保持
		  pack_num <=pack_num;
		  pack_done<=1'b0;  
          crc8_en  <= 1'b0;
          crc8_clr <= 1'b0;
		  for (j=0;j<DATA_NUM;j=j+1) 
		    pack_data[j] <= pack_data[j];	
	 end
end
// ================== 控制逻辑 ==================
//always @(posedge sys_clk or negedge sys_rst_n) begin
//    if (sys_rst_n) begin
//        crc8_en <= 1'b0;
//    end else begin
//        // 在接收数�?时使能CRC计算
//        crc8_en <= uart_done;  // uart_done为字节接收完成标�???
//    end
//end
//crc8 u_crc8 (
//    .clk      (sys_clk),
//    .rst_n    (~sys_rst_n),
//    .crc_en   (crc8_en),
//    .crc_clr  (pack_done),  // �???帧接收完成时清除CRC
//    .data_in  (uart_data),  // 接收到的字节
//    .crc_out  (crc8_value)
//);

//------------解码-------------------------//
//捕获接收完成标志位的上升沿，得到�???????�?时钟周期的脉冲信�?
assign  packdone_flag = pack_done_d0 & (~pack_done_d1);    
//对UART完成标志的数�?延迟两个时钟�?�???????
always @(posedge sys_clk or posedge sys_rst_n) begin 
    if (sys_rst_n) begin 
        pack_done_d0 <= 1'b0;
        pack_done_d1 <= 1'b0;          
    end
    else begin
        pack_done_d0  <= pack_done;                   
        pack_done_d1  <= pack_done_d0;
    end   
end

always @(posedge sys_clk or posedge sys_rst_n) begin         
    if (sys_rst_n) begin                             
	    recv_done <=1'b0;
        rev_data0  <= 8'd0;
        rev_data1  <= 8'd0;
        rev_data2  <= 8'd0;
        rev_data3  <= 8'd0;
        rev_data4  <= 8'd0;
        rev_data5  <= 8'd0;
        rev_data6  <= 8'd0;
        rev_data7  <= 8'd0;
        rev_data8  <= 8'd0;
        rev_data9  <= 8'd0;
        rev_data10 <= 8'd0;
        // rev_data11 <= 8'd0;
        response_data <= 8'h00; // 响应数据寄存器清�??
    end  
	 else if(packdone_flag) begin //数据接收完成，进行解�???????
		//  if((pack_num==DATA_NUM) && (pack_data[0]==8'h55) &&(pack_data[DATA_NUM - 1]==8'haa) ) begin  //判断数据正�??
         if((pack_num==DATA_NUM) && (pack_data[0]==8'h55) &&(pack_data[DATA_NUM - 1]==8'haa) ) begin  //判断数据正�??
                    // rev_data11      <= pack_data[12]; //数据�??????7 8 9 10 
                if(pack_data[DATA_NUM - 2]==crc8_value) begin
                    response_data <= 8'h01;
                    recv_done <=1'b1;
                    rev_data0       <= pack_data[1]; //数据�??????1
                    rev_data1       <= pack_data[2]; //数据�??????2
                    rev_data2       <= pack_data[3]; //数据�??????3
                    rev_data3       <= pack_data[4]; //数据�??????4 5
                    rev_data4       <= pack_data[5]; //数据�??????6
                    rev_data5       <= pack_data[6]; //数据�??????7 8 9 10
                    rev_data6       <= pack_data[7]; //数据�??????2
                    rev_data7       <= pack_data[8]; //数据�??????3
                    rev_data8       <= pack_data[9]; //数据�??????4 5
                    rev_data9       <= pack_data[10]; //数据�??????6
                    rev_data10      <= pack_data[11]; //数据�??????7 8 9 10
                end
                else begin
                    response_data <= 8'h04; // CRC校验失败
                    recv_done <=1'b1;
                    rev_data0       <= rev_data0  ; //数据�??????1
                    rev_data1       <= rev_data1  ; //数据�??????2
                    rev_data2       <= rev_data2  ; //数据�??????3
                    rev_data3       <= rev_data3  ; //数据�??????4 5
                    rev_data4       <= rev_data4  ; //数据�??????6
                    rev_data5       <= rev_data5  ; //数据�??????7 8 9 10
                    rev_data6       <= rev_data6  ; //数据�??????2
                    rev_data7       <= rev_data7  ; //数据�??????3
                    rev_data8       <= rev_data8  ; //数据�??????4 5
                    rev_data9       <= rev_data9  ; //数据�??????6
                    rev_data10      <= rev_data10 ; //数据�??????7 8 9 10
                end
            end 
            else begin
            response_data <= 8'hff;
            recv_done <=1'b0;
            rev_data0       <=  rev_data0 ;
            rev_data1       <=  rev_data1 ;
            rev_data2       <=  rev_data2 ;
            rev_data3       <=  rev_data3 ;
            rev_data4       <=  rev_data4 ;
            rev_data5       <=  rev_data5 ;
            rev_data6       <=  rev_data6 ;
            rev_data7       <=  rev_data7 ;
            rev_data8       <=  rev_data8 ;
            rev_data9       <=  rev_data9 ;
            rev_data10      <=  rev_data10;
            // rev_data11      <=  rev_data11;

		 end
	 end
	 else begin //数据保持到下�???????�?周期，标志位保持�?�?�?�???????
            recv_done <=1'b0;
            rev_data0       <=  rev_data0 ;
            rev_data1       <=  rev_data1 ;
            rev_data2       <=  rev_data2 ;
            rev_data3       <=  rev_data3 ;
            rev_data4       <=  rev_data4 ;
            rev_data5       <=  rev_data5 ;
            rev_data6       <=  rev_data6 ;
            rev_data7       <=  rev_data7 ;
            rev_data8       <=  rev_data8 ;
            rev_data9       <=  rev_data9 ;
            rev_data10      <=  rev_data10;
            // rev_data11      <=  rev_data11;
            response_data <= response_data;
	 end	 
end
// CRC8 module instantiation
crc8 u_crc8 (
    .clk      (sys_clk),
    .rst_n    (~sys_rst_n),
    .crc_en   (crc8_en),
    .crc_clr  (crc8_clr),
    .data_in  (uart_data),
    .crc_out  (crc8_value)
);
// Modify the pack_data storage logic to include CRC validation


//  ila_0 u_ila_1(
//  .clk	(sys_clk),
//  .probe0	(crc8_value),
//  .probe1	(rev_data0),
//  .probe2	(rev_data1),
//  .probe3	({pack_done_d0,recv_done,uart_rxd_d0,packdone_flag}),
//  .probe4	(rev_data4),
//  .probe5	(rev_data2),
//  .probe6	(pack_cnt),
//  .probe7	(rev_data3)
//  );

endmodule	
