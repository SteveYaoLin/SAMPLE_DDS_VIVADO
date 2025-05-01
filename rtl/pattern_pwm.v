// PWM Module with Duty Cycle Control
module pattern_pwm (
    input         clk,
    input         rst_n,       // 异步复位（低有效）
    input         pwm_en,      // 使能信号（异步，持续1时钟周期）
    input [7:0]   duty_num,    // 占空比周期数
    input [7:0]   PAT,         // 模式寄存器
    output reg    pwm_out,     // PWM输出
    output reg    busy,        // 忙信号
    output reg    valid        // PWM结束标志
);

reg [2:0]  bit_cnt;           // 位计数器（0-7）
reg [7:0]  duty_cnt;          // 占空比计数器
reg        start_delay;       // 启动延时寄存器

// 异步复位和时钟控制逻辑
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pwm_out   <= 1'b0;
        busy      <= 1'b0;
        valid     <= 1'b0;
        bit_cnt   <= 3'd0;
        duty_cnt  <= 8'h00;
        start_delay <= 1'b0;
    end
    else begin
        // 启动信号同步处理
        start_delay <= pwm_en && !busy;

        // 有效信号生成（在最后一个bit的最后一个周期有效）
        valid <= (bit_cnt == 3'd7) && (duty_cnt == duty_num) && busy;

        if (start_delay) begin
            // 启动延时周期后进入busy状态
            busy      <= 1'b1;
            bit_cnt   <= 3'd0;
            duty_cnt  <= 8'h00;
            pwm_out   <= PAT[0];
        end
        else if (busy) begin
            if (duty_cnt < duty_num) begin
                duty_cnt <= duty_cnt + 1'b1;
            end
            else begin
                duty_cnt <= 8'h00;
                if (bit_cnt < 3'd7) begin
                    bit_cnt  <= bit_cnt + 1'b1;
                    pwm_out  <= PAT[bit_cnt + 1];
                end
                else begin
                    // 输出结束
                    busy     <= 1'b0;
                    pwm_out  <= 1'b0;
                    bit_cnt  <= 3'd0;
                end
            end
        end
        else begin
            pwm_out <= 1'b0;
        end
    end
end

endmodule