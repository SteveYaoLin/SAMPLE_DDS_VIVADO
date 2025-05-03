// pattern_pwm module add dac_data [7:0]
module pattern_ad9748 #(
    parameter _PAT_WIDTH = 8  ,  // 模式寄存器宽�??
    parameter _DAC_WIDTH = 8    // 模式寄存器宽�??
) (
    input         clk,
    input         rst_n,        // 异步复位（低有效�??
    input         pwm_en,       // 使能信号
    input [7:0]   duty_num,     // 占空比周期数
    input [15:0]  pulse_dessert,// 脉冲间隔周期�??
    input [7:0]   pulse_num,    // 脉冲次数�??0=无限�??
    input  [_PAT_WIDTH-1:0] PAT, // 模式寄存�??
    output reg [_DAC_WIDTH-1:0]     dac_data,      // PWM输出
    output reg    pwm_out,      // PWM输出
    output reg    busy,         // 忙信�??
    output reg    valid         // PWM结束标志
);

// 状�?�机定义
localparam IDLE      = 3'd0;
localparam ACTIVE    = 3'd1;
localparam INTERVAL  = 3'd2;
localparam FINISH    = 3'd3;

reg [2:0]   state;
reg [7:0]   bit_cnt;           // 位计数器
reg [7:0]   duty_cnt;          // 占空比计数器
reg [15:0]  wait_cnt;          // 间隔计数�??
reg [7:0]   pulse_cnt;         // 脉冲计数�??
reg [7:0]   pat_bit;           // PAT�??高位�??测结�??
reg         en_fall;           // 使能下降沿检�??
reg         last_pwm_en;       // 使能信号缓存
reg         async_stop;        // 异步停止标志

// PAT�??高位�??测�?�辑
integer i;
reg     found;
always @(*) begin
    pat_bit = 0;
    found = 0;
    for (i = _PAT_WIDTH-1; i >= 0; i = i-1) begin
        if (!found && PAT[i]) begin
            pat_bit = i;
            found = 1;
        end
    end
end

// 使能下降沿检测和异步停止控制
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        last_pwm_en <= 1'b0;
        async_stop <= 1'b0;
    end
    else begin
        last_pwm_en <= pwm_en;
        // �??测到下降沿且处于无限模式
        if ((~pwm_en) & last_pwm_en & (pulse_num == 0)) 
            async_stop <= 1'b1;
        // 清除异步停止标志
        if (state == FINISH)
            async_stop <= 1'b0;
    end
end

// 主控制�?�辑
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state      <= IDLE;
        pwm_out    <= 1'b0;
        busy       <= 1'b0;
        valid      <= 1'b0;
        bit_cnt    <= 8'd0;
        duty_cnt   <= 8'h00;
        wait_cnt   <= 16'd0;
        pulse_cnt  <= 8'd0;
    end
    else begin
        valid <= 1'b0;  // 默认valid为低

        case(state)
            IDLE: begin
                if (pwm_en) begin
                    busy      <= 1'b1;
                    state     <= ACTIVE;
                    bit_cnt   <= 8'd0;
                    duty_cnt  <= 8'h00;
                    pulse_cnt <= 8'd0;
                    pwm_out   <= PAT[0];
                end
            end
            
            ACTIVE: begin
                // 优先处理异步停止
                if (async_stop) begin
                    state <= FINISH;
                    valid <= 1'b1;
                end
                else begin
                    if (duty_cnt < duty_num) begin
                        duty_cnt <= duty_cnt + 1'b1;
                    end
                    else begin
                        duty_cnt <= 8'h00;
                        if (bit_cnt < pat_bit) begin
                            bit_cnt <= bit_cnt + 1'b1;
                            pwm_out <= PAT[bit_cnt + 1];
                        end
                        else begin
                            pwm_out  <= 1'b0;
                            bit_cnt  <= 8'd0;
                            state    <= INTERVAL;
                            wait_cnt <= 16'd0;
                            // 更新脉冲计数（有限模式）
                            if (pulse_num != 0) begin
                                pulse_cnt <= pulse_cnt + 1'b1;
                            end
                        end
                    end
                end
            end
            
            INTERVAL: begin
                // 优先处理异步停止
                if (async_stop) begin
                    state <= FINISH;
                    valid <= 1'b1;
                end
                else begin
                    if (wait_cnt < pulse_dessert) begin
                        wait_cnt <= wait_cnt + 1'b1;
                    end
                    else begin
                        // �??查终止条�??
                        if ((pulse_num !=0 && pulse_cnt >= pulse_num) || 
                            (pulse_num ==0 && async_stop)) begin
                            state <= FINISH;
                            valid <= 1'b1;
                        end
                        else begin
                            state <= ACTIVE;
                            pwm_out <= PAT[0];
                        end
                        wait_cnt <= 16'd0;
                    end
                end
            end
            
            FINISH: begin
                busy  <= 1'b0;
                valid <= 1'b1;
                state <= IDLE;
                pwm_out <= 1'b0;
                // 清除�??有工作状�??
                bit_cnt   <= 8'd0;
                duty_cnt  <= 8'h00;
                wait_cnt  <= 16'd0;
                pulse_cnt <= 8'd0;
            end
        endcase

        // 强制终止处理（所有状态）
        if (async_stop && state != FINISH) begin
            state <= FINISH;
            valid <= 1'b1;
        end
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dac_data <= {_DAC_WIDTH{1'b0}};
    end
    else begin
        if (pwm_out) begin
            dac_data <= {_DAC_WIDTH{1'b1}};
        end
        else begin
            dac_data <= {_DAC_WIDTH{1'b0}};
        end
    end
end
endmodule