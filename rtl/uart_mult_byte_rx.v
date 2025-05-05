module uart_mult_byte_rx(
    input			    sys_clk,                  //系统时钟
    input             sys_rst_n,                //系统复位，低电平有效
    input             uart_rxd,                 //UART接收端口

	 output  reg [ 7:0] uart_data,	
	 output  reg        uart_done,
	 output  reg        uart_get,               //采样�??
	 
	 output  reg [7:0] pack_cnt,                //字节计数
	 output  reg       pack_ing, 	            //接收过程标志�??
	 output  reg       pack_done,               //帧接收完成标志位
	 output  reg [7:0] pack_num,                //接收到的字节�??
	 output  reg       recv_done,              //接收完一帧数据的接收和解�??

     output  reg [7:0]     hs_pwm_ch        ,   
     output  reg [7:0]     hs_ctrl_sta      ,  
     output  reg [7:0]     duty_num         , 
     output  reg [16:0]    pulse_dessert    , 
     output  reg [7:0]     pulse_num        , 
     output  reg [31:0]    PAT              , 
     output  reg [7:0]     ls_pwm_ch        , 
     output  reg [7:0]     ls_ctrl_sta     
    );
    
localparam  DATA_NUM = 14;
integer j;

reg [7:0] pack_data [DATA_NUM-1:0];           //接收的数�??
//parameter define
parameter  CLK_FREQ = 50_000_000;                 //系统时钟频率
parameter  UART_BPS = 115200;                     //串口波特�??
localparam BPS_CNT  = CLK_FREQ/UART_BPS;        //为得到指定波特率
 
localparam  TimeOut = BPS_CNT*DATA_NUM*10*2;//超时时间

//起始信号下降沿捕�??
wire       start_flag;
reg        uart_rxd_d0;
reg        uart_rxd_d1;

reg [15:0] clk_cnt;                             //系统时钟计数�??
reg [ 3:0] rx_cnt;                              //接收数据计数�??
reg        rx_flag;                             //接收过程标志信号
reg [ 7:0] rxdata;                              //接收数据寄存�??

//接收信号完成标志位上升沿
wire  rxdone_flag;
reg   uart_done_d0;
reg   uart_done_d1;
//包数据接收完�??
wire  packdone_flag;
reg   pack_done_d0;
reg   pack_done_d1;
reg [7:0] reg_func;                            //接收数据包功能号
//*****************************************************
//**                    main code
//*****************************************************
//捕获接收端口下降�??(起始�??)，得到一个时钟周期的脉冲信号
assign  start_flag = uart_rxd_d1 & (~uart_rxd_d0);    
//对UART接收端口的数据延迟两个时钟周�??
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
        if(start_flag)                          //�??测到起始�??
            rx_flag <= 1'b1;                    //进入接收过程，标志位rx_flag拉高
        else if((rx_cnt == 4'd9)&&(clk_cnt == BPS_CNT/2))
            rx_flag <= 1'b0;                    //计数到停止位中间时，停止接收过程
        else
            rx_flag <= rx_flag;
    end
end
//进入接收过程后，启动系统时钟计数器与接收数据计数�??
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
                clk_cnt <= 16'd0;               //对系统时钟计数达�??个波特率周期后清�??
                rx_cnt  <= rx_cnt + 1'b1;       //此时接收数据计数器加1
            end
        end
        else begin                              //接收过程结束，计数器清零
            clk_cnt <= 16'd0;
            rx_cnt  <= 4'd0;
        end
end
//根据接收数据计数器来寄存uart接收端口数据
always @(posedge sys_clk or posedge sys_rst_n) begin 
    if (sys_rst_n)  begin
        rxdata <= 8'd0;     
		  uart_get<=1'b0;		
	 end  
    else if(rx_flag)                            //系统处于接收过程
        if (clk_cnt == BPS_CNT/2) begin         //判断系统时钟计数器计数到数据位中�??
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
    else if(rx_cnt == 4'd9) begin               //接收数据计数器计数到停止位时           
        uart_data <= rxdata;                    //寄存输出接收到的数据
        uart_done <= 1'b1;                      //并将接收完成标志位拉�??
    end
    else begin
        uart_data <= 8'd0;                                   
        uart_done <= 1'b0; 
    end    
end

//---单字节接收程序，uart_done接收完成标志位会持续半个波特率周期，捕捉上升沿可以计数，高电平状态，接收数据有效
//==============================================接收多个字节，添加的模块====================================================//

//捕获接收完成标志位的上升沿，得到�??个时钟周期的脉冲信号
assign  rxdone_flag = uart_done_d0 & (~uart_done_d1);    
//对UART完成标志的数据延迟两个时钟周�??
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

//接收到的数据存入数组中，并计�??
always @(posedge sys_clk or posedge sys_rst_n) begin      //接收到数�??  
    if (sys_rst_n) begin                             
		  pack_cnt <=8'd0;
		  pack_num <=8'd0;
		  pack_done<=1'b0; 
		  pack_ing <=1'b0;
		  for (j=0;j<DATA_NUM;j=j+1) 
		    pack_data[j] <= 8'd0;		 
    end
	 else if(rxdone_flag) begin //接收完成标志位的上升沿，延迟了两个时钟周�??
		 if (pack_cnt < DATA_NUM-1) begin       //处于接收过程�??
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
		 else begin //接收完成---�??后一个字节的接收
				 for (j=0;j<DATA_NUM;j=j+1) begin
				     if(j==pack_cnt)
					  pack_data[pack_cnt] <= uart_data;//寄存输出接收到的数据
					  else
					  pack_data[j] <= pack_data[j];	
				 end
				 pack_num <= pack_cnt + 1'b1; //加上�??后一个字�??
			    pack_cnt  <= 8'd0;               //此时接收数据计数器归零，只有接收完成时才清零
				 pack_done<=1'b1;      			 //输出帧接收完成标志位，只存在�??个周�??
				 pack_ing <=1'b0;
		 end  
	 end
	 else begin
		  pack_cnt <=pack_cnt;
		  pack_ing <=pack_ing;//保持
		  pack_num <=pack_num;
		  pack_done<=1'b0;  
		  for (j=0;j<DATA_NUM;j=j+1) 
		    pack_data[j] <= pack_data[j];	
	 end
end


//------------解码-------------------------//
//捕获接收完成标志位的上升沿，得到�??个时钟周期的脉冲信号
assign  packdone_flag = pack_done_d0 & (~pack_done_d1);    
//对UART完成标志的数据延迟两个时钟周�??
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
        reg_func <= 8'd0; 
	    recv_done <=1'b0;
        hs_pwm_ch       <= 8'd0;   
        hs_ctrl_sta     <= 8'd0;
        duty_num        <= 8'd0;
        pulse_dessert   <= 16'd0;
        pulse_num       <= 8'd0;
        PAT             <= 32'd0;
        ls_pwm_ch       <= 8'd0;
        ls_ctrl_sta     <= 8'd0;
    end  
	 else if(packdone_flag) begin //数据接收完成，进行解�??
		 if((pack_num==DATA_NUM) && (pack_data[0]==8'h55) &&(pack_data[DATA_NUM - 1]==8'haa)) begin  //判断数据正误
			 reg_func  <=pack_data[1];
             recv_done <=1'b1;
            case (pack_data[1]) //解码数据
                8'h01 : begin
                    hs_pwm_ch       <= pack_data[2]; //数据�?1
                    hs_ctrl_sta     <= pack_data[3]; //数据�?2
                    duty_num        <= pack_data[4]; //数据�?3
                    pulse_dessert   <= {pack_data[5],pack_data[6]}; //数据�?4 5
                    pulse_num       <= pack_data[7]; //数据�?6
                    PAT             <= {pack_data[8],pack_data[9],pack_data[10],pack_data[11]}; //数据�?7 8 9 10
                end
                8'h02 : begin
                    ls_pwm_ch       <= pack_data[2]; //数据�?2
                    ls_ctrl_sta     <= pack_data[3]; //数据�?3
                end
                
                default: begin
                    hs_pwm_ch       <= hs_pwm_ch      ;
                    hs_ctrl_sta     <= hs_ctrl_sta    ;
                    duty_num        <= duty_num       ;
                    pulse_dessert   <= pulse_dessert  ;
                    pulse_num       <= pulse_num      ;
                    PAT             <= PAT            ;
                    ls_pwm_ch       <= ls_pwm_ch      ;
                    ls_ctrl_sta     <= ls_ctrl_sta    ;
                end
            endcase
            //  dataD <=pack_data[6];
            //  dataD <=pack_data[1];
			//  dataB <= {8'h0b,pack_data[2]};
			//  dataC <= {pack_data[12],pack_data[11]};
			 
		 end  
		 else begin //数据错误
            reg_func  <=8'd0;
            recv_done <=1'b0;
		    hs_pwm_ch       <= hs_pwm_ch      ;
            hs_ctrl_sta     <= hs_ctrl_sta    ;
            duty_num        <= duty_num       ;
            pulse_dessert   <= pulse_dessert  ;
            pulse_num       <= pulse_num      ;
            PAT             <= PAT            ;
            ls_pwm_ch       <= ls_pwm_ch      ;
            ls_ctrl_sta     <= ls_ctrl_sta    ;
		 end
	 end
	 else begin //数据保持到下�??个周期，标志位保持一个周�??
		    reg_func  <=reg_func;
            recv_done <=1'b0;
		    hs_pwm_ch       <= hs_pwm_ch      ;
            hs_ctrl_sta     <= hs_ctrl_sta    ;
            duty_num        <= duty_num       ;
            pulse_dessert   <= pulse_dessert  ;
            pulse_num       <= pulse_num      ;
            PAT             <= PAT            ;
            ls_pwm_ch       <= ls_pwm_ch      ;
            ls_ctrl_sta     <= ls_ctrl_sta    ;
	 end	 
end

 ila_0 u_ila_0(
 .clk	(sys_clk),
 .probe0	(rxdata),
 .probe1	(reg_func),
 .probe2	(ls_pwm_ch),
 .probe3	({rxdone_flag,uart_done,uart_rxd_d0}),
 .probe4	(rx_cnt),
 .probe5	(uart_data),
 .probe6	(pack_cnt),
 .probe7	(pack_num)
 );

endmodule	
