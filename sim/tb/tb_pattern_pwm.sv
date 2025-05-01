`timescale 1ns/1ps

module pattern_pwm_tb;
parameter _PAT_WIDTH = 16 ;  // 模式寄存器宽度
reg        clk;
reg        rst_n;
reg        pwm_en;
reg [7:0]  duty_num;
reg [_PAT_WIDTH - 1:0]  PAT;
wire       pwm_out;
wire       busy;
wire       valid;

// 实例化被测模块
pattern_pwm #(
    ._PAT_WIDTH(_PAT_WIDTH)
)uut (
    .clk(clk),
    .rst_n(rst_n),
    .pwm_en(pwm_en),
    .duty_num(duty_num),
    .PAT(PAT),
    .pwm_out(pwm_out),
    .busy(busy),
    .valid(valid)
);

// 时钟生成（100MHz）
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// 测试流程
initial begin
    // 初始化
    rst_n = 0;
    pwm_en = 0;
    PAT = 16'h0000;
    duty_num = 8'd0;
    #20;
    rst_n = 1;
    #10;

    // 测试用例1：单周期模式（duty_num=0）
    duty_num = 8'd0;
    // PAT = 8'b10101010;
    PAT = 16'b1010101010101010;
    pwm_en = 1;
    #10;
    pwm_en = 0;
    wait(valid);
    #50;
    
    // 测试用例2：多周期模式（duty_num=5）
    duty_num = 8'd1;
    // PAT = 8'b11001100;
    PAT = 16'b1100110011001100;
    pwm_en = 1;
    #10;
    pwm_en = 0;
    wait(valid);
    #50;
    
    // 测试用例3：最大周期测试（duty_num=255）
    duty_num = 8'd2;
    // PAT = 8'b11111111;
    PAT = 16'b1111111111111111;
    pwm_en = 1;
    #10;
    pwm_en = 0;
    wait(valid);
    #50;
    
    $finish;
end

// 波形记录
initial begin
    $dumpfile("pattern_pwm.vcd");
    $dumpvars(0, pattern_pwm_tb);
end

endmodule