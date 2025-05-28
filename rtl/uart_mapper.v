//uart_mapper
module uart_reg_mapper #(
    parameter _NUM_CHANNELS = 4,        // �???大PWM通道数量
    parameter _DAC_WIDTH    = 8,        // 每个通道的寄存器数量
    parameter _PAT_WIDTH    = 32        // 匹配PAT寄存器宽�???
)(
    input wire          clk_50M,
    input wire          clk_100M,
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
    input           pack_done,     // 数据包接收完成标�???
    
    // PWM通道接口
    // output [7:0]   hs_ctrl_sta       [_NUM_CHANNELS-1:0], 
    // output [7:0]   duty_num          [_NUM_CHANNELS-1:0], 
    // output [15:0]  pulse_dessert     [_NUM_CHANNELS-1:0], 
    // output [7:0]   pulse_num         [_NUM_CHANNELS-1:0], 
    // output [31:0]  PAT               [_NUM_CHANNELS-1:0], 
    // output [7:0]   ls_ctrl_sta       [_NUM_CHANNELS-1:0], 
    // output [7:0]   hs_pwm_ch                           , 
    // output [7:0]   ls_pwm_ch                            
    output reg [_DAC_WIDTH - 1:0 ] dac_data, // 控制状�?�寄存器
    output wire [_NUM_CHANNELS-1:0] pwm_out,    // PWM输出总线
    output wire [_NUM_CHANNELS-1:0] pwm_busy,   // 忙状态�?�线
    output wire [_NUM_CHANNELS-1:0] pwm_valid   // 有效标志总线
);

// 寄存器组定义
reg [7:0]   hs_ctrl_sta       [_NUM_CHANNELS-1:0];  // 控制状�?�寄存器
reg [7:0]   duty_num          [_NUM_CHANNELS-1:0];  // 占空比周期数
reg [15:0]  pulse_dessert     [_NUM_CHANNELS-1:0];  // 脉冲间隔
reg [7:0]   pulse_num         [_NUM_CHANNELS-1:0];  // 脉冲次数
reg [31:0]  PAT               [_NUM_CHANNELS-1:0];  // 模式寄存�???
reg [7:0]   ls_ctrl_sta       [_NUM_CHANNELS-1:0]; // 当前通道控制状�??
reg [7:0]   hs_pwm_ch                           ; // 当前通道�???
reg [7:0]   ls_pwm_ch                           ; // 当前通道�???
reg div_half ;

// 寄存器写入控�???
always @(posedge clk_50M or negedge rst_n) begin
    if (!rst_n) begin
        // 寄存器初始化
        hs_pwm_ch       <= 8'h00; // 当前通道�???
        ls_pwm_ch       <= 8'h00; // 当前通道�???
        // 通道0初始�???
        hs_ctrl_sta[0]      <= 8'h00;
        duty_num[0]         <= 8'h00;
        pulse_dessert[0]    <= 16'h00;
        pulse_num[0]        <= 8'h00;
        PAT[0]              <= 32'h00;
        ls_ctrl_sta[0]      <= 8'h00;
        // 通道1初始�??? 
        hs_ctrl_sta[1]      <= 8'h00;
        duty_num[1]         <= 8'h00;
        pulse_dessert[1]    <= 16'h00;
        pulse_num[1]        <= 8'h00;
        PAT[1]              <= 32'h00;
        ls_ctrl_sta[1]      <= 8'h00;
        // 通道2初始�???
        hs_ctrl_sta[2]      <= 8'h00;
        duty_num[2]         <= 8'h00;
        pulse_dessert[2]    <= 16'h00;
        pulse_num[2]        <= 8'h00;
        PAT[2]              <= 32'h00;
        ls_ctrl_sta[2]      <= 8'h00;
        // 通道3初始�???
        hs_ctrl_sta[3]      <= 8'h00;
        duty_num[3]         <= 8'h00;
        pulse_dessert[3]    <= 16'h00;
        pulse_num[3]        <= 8'h00;
        PAT[3]              <= 32'h00;
        ls_ctrl_sta[3]      <= 8'h00;
    //  generate
    //     genvar i;
    //     for (i = 0; i < _NUM_CHANNELS; i = i + 1) begin : init_reg
    //         hs_ctrl_sta[i]      <= 8'h00;
    //         duty_num[i]         <= 8'h00;
    //         pulse_dessert[i]    <= 16'h00;
    //         pulse_num[i]        <= 8'h00;
    //         PAT[i]              <= 32'h00;
    //         ls_ctrl_sta[i]      <= 8'h00;
    //     end
    //  endgenerate   
    end 
    else if (pack_done) begin
        if(func_reg == 8'h01) begin
            // 通道号更�???
            hs_pwm_ch       <= rev_data1;
        end 
        else if (func_reg == 8'h02) begin
            // 通道号更�???
            ls_pwm_ch       <= rev_data1;
        end
        // 通道号有效�?�检�???
        if (rev_data1 < _NUM_CHANNELS) begin
            // 寄存器更新（按需添加更多寄存器）
            case (func_reg[7:0])
                8'h01: begin
                    // 控制寄存器更�???
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
                //     // 模式寄存器更�???
                //     PAT[hs_pwm_ch] <= {rev_data4, rev_data3, rev_data2, rev_data1};
                // end
                default: begin
                    // 无效操作，保持原值不�???
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

 //PWM通道实例�???
 generate
     genvar i;
     for (i = 0; i < _NUM_CHANNELS-1; i = i + 1) begin : pwm_gen
         pattern_pwm #(
             ._PAT_WIDTH(_PAT_WIDTH)
         ) pwm_inst (
             .clk          (clk_50M),
             .rst_n        (rst_n),
             .pwm_en       (hs_ctrl_sta[i][0]),     // 使用控制寄存器的bit0作为使能
             .duty_num     (duty_num[i]),
             .pulse_dessert(pulse_dessert[i]),
             .pulse_num    (pulse_num[i]),
             .PAT          (PAT[i]),
             .pwm_out      (pwm_out[i]),
             .busy         (pwm_busy[i]),
             .valid        (pwm_valid[i])
         );
     end
 endgenerate

pattern_ad9748 #(
    ._PAT_WIDTH(_PAT_WIDTH),    // 模式寄存器宽�?????
    ._DAC_WIDTH(_DAC_WIDTH)     // DAC数据宽度
// ) pwm_dac (
//     .clk(clk_100M),
//     .rst_n(rst_n),                     
//     .pwm_en       ( hs_ctrl_sta  [_NUM_CHANNELS-1] [0] ),
//     .duty_num     ( duty_num     [_NUM_CHANNELS-1] ),
//     .pulse_dessert( pulse_dessert[_NUM_CHANNELS-1] ),
//     .pulse_num    ( pulse_num    [_NUM_CHANNELS-1] ),
//     .PAT          ( PAT          [_NUM_CHANNELS-1] ),
//     .pwm_out      ( pwm_out      [_NUM_CHANNELS-1] ),
//     .busy         ( pwm_busy     [_NUM_CHANNELS-1] ),
//     .valid        ( pwm_valid    [_NUM_CHANNELS-1] ),
//     .dac_data     ( dac_data         )       // DAC数据输出   
// );
) pwm_dac (
    .clk(clk_100M),
    .rst_n(rst_n),                     
    .pwm_en       ( 1'b1       ),     // 使用控制寄存器的bit0作为使能
    .duty_num     ( 8'h02     ),
    .pulse_dessert( 16'd50 ),
    .pulse_num    ( 8'h00 ),
    .PAT          ( 32'h00ffffff ),
    .pwm_out      (  ),
    .busy         (  ),
    .valid        (  ),
    .dac_data     (          )       // DAC数据输出   
);

always @(posedge clk_100M or negedge rst_n) begin
    if (!rst_n) begin
        div_half <= 0; // 初始化DAC数据寄存器
    end else begin
        // 根据当前通道的控制寄存器状态更新DAC数据
        div_half <= ~div_half; // 50MHz时钟下的分频
    end
end

reg up_down = 1'b1; // 1: up counting, 0: down counting

always @(posedge clk_100M or negedge rst_n) begin
    if (!rst_n) begin
        dac_data <= {(_DAC_WIDTH-1){1'b0}}; // Start from 0
        up_down <= 1'b1;
    end
    else if (div_half) begin
        if (up_down) begin
            if (dac_data == {(_DAC_WIDTH){1'b1}}) begin
                up_down <= 1'b0; // Switch to down counting
                dac_data <= dac_data - 1'b1;
            end else begin
                dac_data <= dac_data + 1'b1; // Count up
            end
        end else begin
            if (dac_data == {(_DAC_WIDTH){1'b0}}) begin
                up_down <= 1'b1; // Switch to up counting
                dac_data <= dac_data + 1'b1;
            end else begin
                dac_data <= dac_data - 1'b1; // Count down
            end
        end
    end
end
//  ila_0 u_ila_1(
//   .clk	(clk_50M),
//   .probe0	(duty_num[1]),
//   .probe1	(pulse_dessert[1][7 :0]),
//   .probe2	(pulse_dessert[1][15:8]),
//   .probe3	({hs_ctrl_sta[1][0],pwm_out[1],pwm_busy[1],pack_done}),
//   .probe4	(PAT[1][7 :0]),
//   .probe5	(func_reg),
//   .probe6	(rev_data0),
//   .probe7	(rev_data2)
//   );
endmodule