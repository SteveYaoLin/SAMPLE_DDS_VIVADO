// PWM Module
module pattern_pwm (
    input         clk,
    input         rst_n,       // 异步复位（低有效）
    input         pwm_en,      // 使能信号（异步，持续1时钟周期）
    input [7:0]   PAT,         // 模式寄存器
    output reg    pwm_out,     // PWM输出
    output reg    busy,        // 忙信号
    output reg    valid        // PWM结束标志
);

reg [2:0]  bit_cnt;           // 位计数器（0-7）
// reg [7:0]  pat_reg;           // 模式寄存器缓存
reg        start_delay;       // 启动延时寄存器

// 异步复位和时钟控制逻辑
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pwm_out   <= 1'b0;
        busy      <= 1'b0;
        valid     <= 1'b0;
        bit_cnt   <= 3'd0;
        // pat_reg   <= 8'h00;
        start_delay <= 1'b0;
    end
    else begin
        // 启动信号同步处理
        start_delay <= pwm_en && !busy;

        // 有效信号生成
        valid <= (bit_cnt == 3'd7) && busy;

        if (start_delay) begin
            // 启动延时周期
            busy    <= 1'b1;
            // pat_reg <= PAT;
            bit_cnt <= 3'd0;
            pwm_out <= PAT[0];
        end
        else if (busy) begin
            // PWM输出逻辑
            if (bit_cnt < 3'd7) begin
                bit_cnt <= bit_cnt + 1'b1;
                pwm_out <= PAT[bit_cnt + 1];
            end
            else begin
                // 输出结束
                busy    <= 1'b0;
                pwm_out <= 1'b0;
                bit_cnt <= 3'd0;
            end
        end
        else begin
            pwm_out <= 1'b0;
        end
    end
end

endmodule