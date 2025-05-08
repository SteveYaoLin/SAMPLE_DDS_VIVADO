//uart_mapper
module uart_reg_mapper #(
    parameter _NUM_CHANNELS = 4        // 最大PWM通道数量
    // parameter REG_DEPTH    = 6,        // 每个通道的寄存器数量
    // parameter _PAT_WIDTH   =          // 匹配PAT寄存器宽度
)(
    input wire          clk_50M,
    input wire          rst_n,
    // UART接口信号
    input [7:0]     func_reg  ,
    input [7:0]     rev_data1  ,
    input [7:0]     rev_data2  ,
    input [7:0]     rev_data3  ,
    input [7:0]     rev_data4  ,
    input [7:0]     rev_data5  ,
    input [7:0]     rev_data6  ,
    input [7:0]     rev_data7  ,
    input [7:0]     rev_data8  ,
    input [7:0]     rev_data9  ,
    input [7:0]     rev_data10 ,
    input [7:0]     rev_data11 ,
    input           pack_done,     // 数据包接收完成标志
    
    // PWM通道接口
    output [7:0]   hs_ctrl_sta       [_NUM_CHANNELS-1:0], 
    output [7:0]   duty_num          [_NUM_CHANNELS-1:0], 
    output [15:0]  pulse_dessert     [_NUM_CHANNELS-1:0], 
    output [7:0]   pulse_num         [_NUM_CHANNELS-1:0], 
    output [31:0]  PAT               [_NUM_CHANNELS-1:0], 
    output [7:0]   ls_ctrl_sta       [_NUM_CHANNELS-1:0], 
    output [7:0]   hs_pwm_ch                           , 
    output [7:0]   ls_pwm_ch                            
    // output wire [_NUM_CHANNELS-1:0] pwm_out,    // PWM输出总线
    // output wire [_NUM_CHANNELS-1:0] pwm_busy,   // 忙状态总线
    // output wire [_NUM_CHANNELS-1:0] pwm_valid   // 有效标志总线
);

// 寄存器组定义
reg [7:0]   hs_ctrl_sta       [_NUM_CHANNELS-1:0];  // 控制状态寄存器
reg [7:0]   duty_num          [_NUM_CHANNELS-1:0];  // 占空比周期数
reg [15:0]  pulse_dessert     [_NUM_CHANNELS-1:0];  // 脉冲间隔
reg [7:0]   pulse_num         [_NUM_CHANNELS-1:0];  // 脉冲次数
reg [31:0]  PAT               [_NUM_CHANNELS-1:0];  // 模式寄存器
reg [7:0]   ls_ctrl_sta       [_NUM_CHANNELS-1:0]; // 当前通道控制状态
reg [7:0]   hs_pwm_ch                           ; // 当前通道号
reg [7:0]   ls_pwm_ch                           ; // 当前通道号


// 寄存器写入控制
always @(posedge clk_50M or negedge rst_n) begin
    if (!rst_n) begin
        // 寄存器初始化
        hs_pwm_ch       <= 8'h00; // 当前通道号
        ls_pwm_ch       <= 8'h00; // 当前通道号
        for (integer i = 0; i < _NUM_CHANNELS; i = i + 1) begin
            hs_ctrl_sta[i]      <= 8'h00;
            duty_num[i]         <= 8'h00;
            pulse_dessert[i]    <= 16'h00;
            pulse_num[i]        <= 8'h00;
            PAT[i]              <= 32'h00;
            ls_ctrl_sta[i]      <= 8'h00;
        end
    end 
    else if (pack_done) begin
        if(func_reg == 8'h01) begin
            // 通道号更新
            hs_pwm_ch       <= rev_data1;
        end 
        else if (func_reg == 8'h02) begin
            // 通道号更新
            ls_pwm_ch       <= rev_data1;
        end
        // 通道号有效性检查
        if (rev_data1 < _NUM_CHANNELS) begin
            // 寄存器更新（按需添加更多寄存器）
            case (func_reg[7:0])
                8'h01: begin
                    // 控制寄存器更新
                    hs_ctrl_sta[rev_data1]   <= rev_data2 ;
                    duty_num[rev_data1]      <= rev_data3 ;
                    pulse_dessert[rev_data1] <= {rev_data4, rev_data5} ;
                    pulse_num[rev_data1]     <=     rev_data6 ;
                    PAT[rev_data1]           <= {rev_data7, rev_data8, rev_data9, rev_data10} ;
                end
                8'h02: begin
                    // 占空比周期数更新
                    ls_ctrl_sta[rev_data1] <= rev_data2;
                end
                // 8'h03: begin
                //     // 脉冲间隔更新
                //     pulse_dessert[hs_pwm_ch] <= {rev_data2, rev_data1};
                // end
                // 8'h04: begin
                //     // 脉冲次数更新
                //     pulse_num[hs_pwm_ch] <= rev_data1;
                // end
                // 8'h05: begin
                //     // 模式寄存器更新
                //     PAT[hs_pwm_ch] <= {rev_data4, rev_data3, rev_data2, rev_data1};
                // end
                default: begin
                    // 无效操作，保持原值不变
                end
            endcase
            // hs_ctrl_sta[hs_pwm_ch]   <= hs_ctrl_sta;
            // duty_num[hs_pwm_ch]      <= duty_num;
            // pulse_dessert[hs_pwm_ch] <= pulse_dessert;
            // pulse_num[hs_pwm_ch]     <= pulse_num;
            // PAT[hs_pwm_ch]           <= PAT;
        end
    end
end

// PWM通道实例化
// generate
//     genvar i;
//     for (i = 0; i < _NUM_CHANNELS; i = i + 1) begin : pwm_gen
//         pattern_pwm #(
//             ._PAT_WIDTH(_PAT_WIDTH)
//         ) pwm_inst (
//             .clk          (clk_50M),
//             .rst_n        (rst_n),
//             .pwm_en       (hs_ctrl_sta[i][0]),     // 使用控制寄存器的bit0作为使能
//             .duty_num     (duty_num[i]),
//             .pulse_dessert(pulse_dessert[i]),
//             .pulse_num    (pulse_num[i]),
//             .PAT          (PAT[i]),
//             .pwm_out      (pwm_out[i]),
//             .busy         (pwm_busy[i]),
//             .valid        (pwm_valid[i])
//         );
//     end
// endgenerate

endmodule