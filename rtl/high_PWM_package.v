module pwm_generator (
    input wire clk,             // 时钟信号
    input wire rst_n,           // 低有效复位信号
    input wire enable,          // 使能信号
    input wire [7:0] data_in,   // 8位输入寄存器
    output reg pwm,             // PWM输出端口
    output reg valid            // 有效信号
);

    reg [2:0] bit_counter;      // 用于跟踪当前输出的位
    reg active;                 // 内部状态信号，表示是否正在输出PWM

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // 异步复位
            pwm <= 0;
            valid <= 0;
            bit_counter <= 0;
            active <= 0;
        end else begin
            if (enable && !active) begin
                // 使能信号拉高且未处于活动状态时开始输出
                active <= 1;
                bit_counter <= 7; // 从最高位开始
                pwm <= data_in[7];
                valid <= 0;
            end else if (active) begin
                // 正在输出PWM信号
                if (bit_counter > 0) begin
                    bit_counter <= bit_counter - 1;
                    pwm <= data_in[bit_counter - 1];
                end else begin
                    // 所有位输出完成
                    active <= 0;
                    pwm <= 0;
                    valid <= 1; // 输出有效信号
                end
            end else begin
                // 默认状态
                valid <= 0;
            end
        end
    end

endmodule