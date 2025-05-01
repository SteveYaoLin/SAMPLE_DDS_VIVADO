// PWM Module with Dynamic Pattern Length
module pattern_pwm #(
    parameter _PAT_WIDTH = 8    // 模式寄存器宽度
) (
    input         clk,
    input         rst_n,        // 异步复位（低有效）
    input         pwm_en,       // 使能信号
    input [7:0]   duty_num,     // 占空比周期数
    input [_PAT_WIDTH-1:0] PAT, // 模式寄存器
    output reg    pwm_out,      // PWM输出
    output reg    busy,         // 忙信号
    output reg    valid         // PWM结束标志
);

reg [7:0]  bit_cnt;            // 位计数器
reg [7:0]  duty_cnt;           // 占空比计数器
reg        start_delay;        // 启动延时寄存器
reg [7:0]  pat_bit;            // PAT最高位检测结果
integer i;  // 使用Verilog的integer类型
reg found;
// PAT最高位检测逻辑
always @(*) begin

    pat_bit = 0;  // 默认值
    found = 0;
    
    // 从高位向低位扫描
    for (i = _PAT_WIDTH-1; i >= 0; i = i-1) begin
        if (!found) begin
            if (PAT[i]) begin
                pat_bit = i;
                found = 1;
            end
        end
    end
end

// 主控制逻辑
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pwm_out   <= 1'b0;
        busy      <= 1'b0;
        valid     <= 1'b0;
        bit_cnt   <= 8'd0;
        duty_cnt  <= 8'h00;
        start_delay <= 1'b0;
    end
    else begin
        start_delay <= pwm_en && !busy;
        
        // 有效信号生成（基于动态检测的最高位）
        valid <= (bit_cnt == pat_bit) && (duty_cnt == duty_num) && busy;

        if (start_delay) begin
            busy      <= 1'b1;
            bit_cnt   <= 8'd0;
            duty_cnt  <= 8'h00;
            pwm_out   <= PAT[0];
        end
        else if (busy) begin
            if (duty_cnt < duty_num) begin
                duty_cnt <= duty_cnt + 1'b1;
            end
            else begin
                duty_cnt <= 8'h00;
                if (bit_cnt < pat_bit) begin
                    bit_cnt  <= bit_cnt + 1'b1;
                    pwm_out  <= PAT[bit_cnt + 1];
                end
                else begin
                    busy     <= 1'b0;
                    pwm_out  <= 1'b0;
                    bit_cnt  <= 8'd0;
                end
            end
        end
        else begin
            pwm_out <= 1'b0;
        end
    end
end

endmodule