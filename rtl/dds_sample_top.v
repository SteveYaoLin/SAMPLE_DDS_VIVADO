module dds_sample_top # (
    parameter _PAT_WIDTH = 16 ,   // 模式寄存器宽�?
    parameter _DAC_WIDTH = 8      // DAC数据宽度
)
(
    input wire sys_clk,          // System clock input U18
    input wire sys_rst_n,        // Active low reset input
    // N16
    input wire uart_rxd,         // UART RXD input T19
    
    // output reg [7:0] uart_data,  // UART data output
    // output reg uart_done,        // UART done signal
    // output reg uart_get,         // UART get signal
    
    // output reg [7:0] pack_cnt,   // Packet count output
    // output reg pack_ing,         // Packet in progress signal
    // output reg pack_done,        // Packet done signal
    // output reg [7:0] pack_num,   // Packet number output
    output [_DAC_WIDTH-1:0]   dac_data,
    output wire led,        // LED drive signal H 15
    output ad9748_sleep, // Sleep control signal for AD9748
    output pwm_port,
    output pwm_slow_port,
    output wire uart_txd //J15
    
    // output reg [7:0] dataA,      // Data A output
    // output reg [7:0] dataD,      // Data D output
    // output reg [15:0] dataB,     // Data B output
    // output reg [15:0] dataC       // Data C output
);

// parameter _PAT_WIDTH = 16 ;   // 模式寄存器宽�?????
// parameter _DAC_WIDTH = 8 ;   // 模式寄存器宽�?????
// First, declare the necessary signals
wire clk_50M;
wire clk_100M;
wire clk_150M;
wire clk_150M_O;
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
wire [7:0] dataA;
wire [7:0] dataD;
wire [15:0] dataB;
wire [15:0] dataC;
wire led_enable;
wire led_breath;
wire [7:0] pwm_busy;
wire [7:0] pwm_valid;
// wire [31:0] slow_drive;
// 添加以下信号声明
// wire [_DAC_WIDTH - 1:0] dac_data;
// wire pwm_ad9748;
// wire pwm_ad9748_busy;
// wire pwm_ad9748_valid;
  clk_wiz_0 u_mmcm
  (
  // Clock out ports  
  .clk_out1(clk_50M),
  .clk_out2(clk_100M),
  .clk_out3(clk_150M),
  .clk_out4(clk_150M_O),
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
    .pack_done  (pack_done),    // Connect to internal signal
    .pack_num   (pack_num),     // Connect to internal signal
    .recv_done  (recv_done),    // Connect to internal signal
    
    .dataA      (dataA),        // Connect to internal signal
    .dataD      (dataD),        // Connect to internal signal
    .dataB      (dataB),        // Connect to internal signal
    .dataC      (dataC)         // Connect to internal signal
);
//assign led_enable = (dataA == 8'h08) ? 1'b1 : 1'b0 ; // Example: drive LED with the least significant bit of received data
breath_led u_breath_led(
    .sys_clk       (clk_50M) ,      //
    .sys_rst_n       (rst_n) ,    //
    .led (led_breath )           //
);
assign led = (dataA == 8'h08) ? led_breath : 1'b0 ; // Example: drive LED with the least significant bit of received data

wire [1:0] pwm_out;
wire pwm_oddr;
pattern_pwm #(
    ._PAT_WIDTH(_PAT_WIDTH)    // 模式寄存器宽�?????
) pwm1 (
/*input                 */ .clk(clk_50M),
/*input                 */ .rst_n(rst_n),        // 异步复位（低有效�?????
/*input                 */ .pwm_en(1'b1),       // 使能信号
/*input [7:0]           */ .duty_num(8'b1),     // 占空比周期数
/*input [15:0]          */ .pulse_dessert(8'b1),// 脉冲间隔周期�?????
/*input [7:0]           */ .pulse_num(8'h0),    // 脉冲次数�?????0=无限�?????
/*input [_PAT_WIDTH-1:0]*/ .PAT(16'h1), // 模式寄存�?????
/*output reg            */ .pwm_out(pwm_out[0]),      // PWM输出
/*output reg            */ .busy(pwm_busy[0]),         // 忙信�?????
/*output reg            */ .valid(pwm_valid[0])         // PWM结束标志
);

// ODDR #(
//    .DDR_CLK_EDGE("SAME_EDGE"),  // 时钟双沿采样模式
//    .INIT(1'b0),                     // 初始化�??
//    .SRTYPE("SYNC")                  // 同步复位类型
// ) ODDR_inst (
//    .Q(pwm_port),    // 输出到IO的PWM信号
//    .C(clk_50m),     // 50MHz时钟输入（需与PWM逻辑同步�?????
//    .CE(1'b1),       // 始终使能
//    .D1(pwm_out[0]),  // 内部生成的PWM逻辑（高电平�?????
//    .D2(1'b0),  // 与D1相同，确保单沿输�?????
//    .R(1'b0),        // 无复�?????
//    .S(1'b0)         // 无置�?????
// );

OBUF #(
   .DRIVE(12),       // 驱动电流设为12mA（根据负载调整）
   .IOSTANDARD("LVCMOS33"), // I/O电平标准
   .SLEW("SLOW")     // 压摆率设为SLOW以减少高频噪�?????
) OBUF_fast_sig (
   .O(pwm_port),      // 实际引脚（B35_L19_P�?????
   .I(pwm_out[0])      // 来自ODDR的输�?????
);

OBUF #(
   .DRIVE(12),       // 驱动电流设为12mA（根据负载调整）
   .IOSTANDARD("LVCMOS33"), // I/O电平标准
   .SLEW("SLOW")     // 压摆率设为SLOW以减少高频噪�?????
) OBUF_slow_sig (
   .O(pwm_slow_port),      // 实际引脚（B35_L19_P�?????
   .I(pwm_out[1])      // 来自ODDR的输�?????
);

pattern_pwm #(
    ._PAT_WIDTH(_PAT_WIDTH)    // 模式寄存器宽�?????
) pwm2 (
/*input                 */ .clk(clk_50M),
/*input                 */ .rst_n(rst_n),        // 异步复位（低有效�?????
/*input                 */ .pwm_en(1'b1),       // 使能信号
/*input [7:0]           */ .duty_num(8'd50),     // 占空比周期数
/*input [15:0]          */ .pulse_dessert(16'd50),// 脉冲间隔周期�?????
/*input [7:0]           */ .pulse_num(8'h2),    // 脉冲次数�?????0=无限�?????
/*input [_PAT_WIDTH-1:0]*/ .PAT(16'h1), // 模式寄存�?????
/*output reg            */ .pwm_out(pwm_out[1]),      // PWM输出
/*output reg            */ .busy(pwm_busy[1]),         // 忙信�?????
/*output reg            */ .valid(pwm_valid[1])         // PWM结束标志
);

pattern_ad9748 #(
    ._PAT_WIDTH(_PAT_WIDTH),    // 模式寄存器宽�?
    ._DAC_WIDTH(_DAC_WIDTH)     // DAC数据宽度
) pwm_dac (
    .clk(clk_50M),
    .rst_n(rst_n),              // 异步复位（低有效�?
    .pwm_en(1'b1),             // 使能信号
    .duty_num(8'd1),          // 占空比周期数
    .pulse_dessert(16'd1),    // 脉冲间隔周期�?
    .pulse_num(8'h0),          // 脉冲次数�?0=无限�?
    .PAT(16'h1),               // 模式寄存�?
    .dac_data(dac_data),       // DAC数据输出
    .pwm_out(),      // PWM输出
    .busy(pwm_busy[7]),    // 忙信�?
    .valid(pwm_valid[7])   // PWM结束标志
);

// assign pwm_port = pwm_out[0] ; // 直接连接到引�???
// ila_0 u_ila_0(
// .clk	(sys_clk),
// .probe0	({pwm_busy,pwm_oddr})
// );

assign ad9748_sleep = ((pwm_busy == 8'h5a)&& (pwm_valid == 8'h5a)) ? 1'b1 : 1'b0; // 使能AD9748休眠模式（低电平有效�??

endmodule
