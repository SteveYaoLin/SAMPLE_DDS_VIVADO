module hsem_s750_uart_pwm # (
    parameter _PAT_WIDTH = 32 ,   // 模式寄存器宽�?????????
    parameter _NUM_CHANNELS = 3,        // �???????大PWM通道数量
    parameter _DAC_WIDTH = 8      // DAC数据宽度
)
(
    input wire sys_clk,          // System clock input U18
    input wire sys_rst_n,        // Active low reset input
    input wire uart_rxd,         // UART RXD input T19
    output [_DAC_WIDTH-1:0]   dac_data,//fmc bus
    output wire led,        // LED drive signal H 15
    // output ad9748_sleep, // Sleep control signal for AD9748
    output pwm_port,
    output adc_clk_p,
    output adc_clk_n,
    output pwm_slow_port,
    output pwm_diff_port_n,
    output pwm_diff_port_p,
    output wire uart_txd //J15

);

// First, declare the necessary signals
wire clk_50M;
wire clk_100M;
wire clk_100M_o;
wire clk_50M_o;
wire locked;
wire resetn;
wire rst_n = sys_rst_n & locked; // Active low reset signal

wire  [7:0] uart_data;
wire uart_done;
wire uart_get;
wire [7:0] pack_cnt;
wire pack_ing;
wire pack_done;
wire [7:0] pack_num;
wire recv_done;
wire led_enable;
wire led_breath;
wire [_NUM_CHANNELS:0] pwm_out;
wire [_NUM_CHANNELS - 1:0] pwm_busy;
wire [_NUM_CHANNELS - 1:0] pwm_valid;

wire [7:0]     hs_pwm_ch     [_NUM_CHANNELS-1:0];
wire [7:0]     hs_ctrl_sta   [_NUM_CHANNELS-1:0];
wire [7:0]     duty_num      [_NUM_CHANNELS-1:0];
wire [16:0]    pulse_dessert [_NUM_CHANNELS-1:0];
wire [7:0]     pulse_num     [_NUM_CHANNELS-1:0];
wire [31:0]    PAT           [_NUM_CHANNELS-1:0];
wire [7:0]     ls_pwm_ch     ;
wire [7:0]     ls_ctrl_sta   ;

wire    [7:0]     rev_data0  ;
wire    [7:0]     rev_data1  ;
wire    [7:0]     rev_data2  ;
wire    [7:0]     rev_data3  ;
wire    [7:0]     rev_data4  ;
wire    [7:0]     rev_data5  ;
wire    [7:0]     rev_data6  ;
wire    [7:0]     rev_data7  ;
wire    [7:0]     rev_data8  ;
wire    [7:0]     rev_data9  ;
wire    [7:0]     rev_data10 ;

  clk_wiz_0 u_mmcm
  (
  // Clock out ports  
  .clk_out1(clk_50M),
  .clk_out2(clk_100M),
  .clk_out3(clk_100M_o),
  .clk_out4(clk_50M_o),
  // Status and control signals               
  .resetn(sys_rst_n), 
  .locked(locked),
 // Clock in ports
  .clk_in1(sys_clk)
  );

// Then, instantiate the module with proper port connections
uart_mult_byte_rx u_uart_rx_inst (
    .sys_clk    (clk_50M),      // Connect to input clock
    .sys_rst_n  (!rst_n  ),    // Connect to reset
    .uart_rxd   (uart_rxd),     // Connect to UART RX input
    
    .uart_data  (uart_data),    // Connect to internal signal
    .uart_done  (uart_done),    // Connect to internal signal
    .uart_get   (uart_get),     // Connect to internal signal
    
    .pack_cnt   (pack_cnt),     // Connect to internal signal
    .pack_ing   (pack_ing),     // Connect to internal signal
    .pack_done_d1  (pack_done),    // Connect to internal signal
    .pack_num   (pack_num),     // Connect to internal signal
    .recv_done  (recv_done),    // Connect to internal signal
    
    .rev_data0  (rev_data0   ),
    .rev_data1  (rev_data1   ),
    .rev_data2  (rev_data2   ),
    .rev_data3  (rev_data3   ),
    .rev_data4  (rev_data4   ),
    .rev_data5  (rev_data5   ),
    .rev_data6  (rev_data6   ),
    .rev_data7  (rev_data7   ),
    .rev_data8  (rev_data8   ),
    .rev_data9  (rev_data9   ),
    .rev_data10 (rev_data10  )
);

uart_reg_mapper # (
    ._NUM_CHANNELS(_NUM_CHANNELS)
)u_uart_reg_mapper(
   /*input wire  */.clk_50M    (clk_50M) ,      // 50MHz时钟输入
   /*input wire  */.clk_100M   (clk_100M) ,     // 100MHz时钟输入
   /*input wire  */.rst_n      (rst_n  ) ,
   // UART接口信号
   /*input [7:0] */  .func_reg    (rev_data0   ) ,
   /*input [7:0] */  .rev_data1   (rev_data1   ) ,
   /*input [7:0] */  .rev_data2   (rev_data2   ) ,
   /*input [7:0] */  .rev_data3   (rev_data3   ) ,
   /*input [7:0] */  .rev_data4   (rev_data4   ) ,
   /*input [7:0] */  .rev_data5   (rev_data5   ) ,
   /*input [7:0] */  .rev_data6   (rev_data6   ) ,
   /*input [7:0] */  .rev_data7   (rev_data7   ) ,
   /*input [7:0] */  .rev_data8   (rev_data8   ) ,
   /*input [7:0] */  .rev_data9   (rev_data9   ) ,
   /*input [7:0] */  .rev_data10  (rev_data10  ) ,
//    /*input [7:0] */  .rev_data11  (rev_data11  ) ,
   /*input       */  .pack_done   (pack_done   ) ,     // 数据包接收完成标�???????    
   /*output wire [_DAC_WIDTH - 1:0 ]*/.dac_data (dac_data ),         
   /*output wire [_NUM_CHANNELS-1:0]*/.pwm_out  (pwm_out  ),    // PWM输出总线
   /*output wire [_NUM_CHANNELS-1:0]*/.pwm_busy (pwm_busy ),   // 忙状态�?�线
   /*output wire [_NUM_CHANNELS-1:0]*/.pwm_valid(pwm_valid)   // 有效标志总线
);
uart_protocol_tx u_uart_protocol_tx(
    /*input       */.clk_50M  (clk_50M  ),
    /*input       */.rst_n    (rst_n    ),
                                //8'h80;
    /*input       */.recv_done(recv_done),
    /*input [7:0] */.rev_data1(rev_data1),
    /*input [7:0] */.rev_data2(rev_data2),
    /*input [7:0] */.rev_data3(rev_data3),
                    .rev_data4   (rev_data4   ) ,
                    .rev_data5   (rev_data5   ) ,
                    .rev_data6   (rev_data6   ) ,
                    .rev_data7   (rev_data7   ) ,
                    .rev_data8   (rev_data8   ) ,
                    .rev_data9   (rev_data9   ) ,
                    .rev_data10  (rev_data10  ) ,
                            //uart_tx_crc8
    /*output      */.uart_txd (uart_txd )
    );
//assign led_enable = (dataA == 8'h08) ? 1'b1 : 1'b0 ; // Example: drive LED with the least significant bit of received data
breath_led u_breath_led(
    .sys_clk         (clk_50M) ,      //
    .sys_rst_n       (rst_n) ,    //
    .led (led_breath )           //
);



// ODDR #(
//    .DDR_CLK_EDGE("SAME_EDGE"),  // 时钟双沿采样模式
//    .INIT(1'b0),                     // 初始化�??
//    .SRTYPE("SYNC")                  // 同步复位类型
// ) ODDR_inst (
//    .Q(pwm_port),    // 输出到IO的PWM信号
//    .C(clk_50m),     // 50MHz时钟输入（需与PWM逻辑同步�?????????????
//    .CE(1'b1),       // 始终使能
//    .D1(pwm_out[0]),  // 内部生成的PWM逻辑（高电平�?????????????
//    .D2(1'b0),  // 与D1相同，确保单沿输�?????????????
//    .R(1'b0),        // 无复�?????????????
//    .S(1'b0)         // 无置�?????????????
// );

OBUF #(
   .DRIVE(12),       // 驱动电流设为12mA（根据负载调整）
   .IOSTANDARD("LVCMOS33"), // I/O电平标准
   .SLEW("SLOW")     // 压摆率设为SLOW以减少高频噪�?????????????
) OBUF_fast_sig (
   .O(pwm_port),      // 实际引脚（B35_L19_P�?????????????
   .I(pwm_out[0])      // 来自ODDR的输�?????????????
);

OBUF #(
   .DRIVE(12),       // 驱动电流设为12mA（根据负载调整）
   .IOSTANDARD("LVCMOS33"), // I/O电平标准
   .SLEW("SLOW")     // 压摆率设为SLOW以减少高频噪�?????????????
) OBUF_slow_sig (
   .O(pwm_slow_port),      // 实际引脚（B35_L19_P�?????????????
//    .I(1'b1)     // 单端信号输入
   .I(pwm_out[_NUM_CHANNELS])      // 来自ODDR的输�?????????????
);

 OBUFDS obufds_inst0 (
     .O(pwm_diff_port_p),  // 差分信号正端
     .OB(pwm_diff_port_n), // 差分信号负端
     .I(pwm_out[1])     // 单端信号输入
 );


OBUFDS obufds_inst1 (
   .O(adc_clk_p),  // 差分信号正端
   .OB(adc_clk_n), // 差分信号负端
   .I(clk_100M_o)     // 单端信号输入
);

assign led = ((pwm_busy == 8'h5a)&& (pwm_valid == 8'h5a)) ? 1'b0 : led_breath ; // Example: drive LED with the least significant bit of received data
// assign ad9748_sleep = 1'b0; // 使能AD9748休眠模式（低电平有效�??????????

endmodule
