`timescale 1ns/1ps

module pwm_tb;

reg        clk;
reg        rst_n;
reg        pwm_en;
reg [7:0]  PAT;
wire       pwm_out;
wire       busy;
wire       valid;

// 实例化被测模块
pattern_pwm uut (
    .clk(clk),
    .rst_n(rst_n),
    .pwm_en(pwm_en),
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
    PAT = 8'h00;
    #20;
    rst_n = 1;
    #10;

    // 测试用例1：正常模式（PAT=8'b10101010）
    PAT = 8'b10101010;
    #100;
    pwm_en = 1;
    #10;
    pwm_en = 0;
    
    // 等待当前PWM完成
    wait(valid);
    #50;
    
    // 测试用例2：全1模式（PAT=8'b11111111）
    PAT = 8'b11111111;
    #100;
    pwm_en = 1;
    #10;
    pwm_en = 0;
    
    // 等待当前PWM完成
    wait(valid);
    #50;
    
    // 测试用例3：连续触发测试
    PAT = 8'b11001100;
    #100;
    pwm_en = 1;
    #10;
    pwm_en = 0;
    #15;
    // 在busy期间再次触发（应被忽略）
    pwm_en = 1;
    #10;
    pwm_en = 0;
    
    #200;
    $finish;
end

// 波形记录
initial begin
    $dumpfile("pwm.vcd");
    $dumpvars(0, pwm_tb);
end

endmodule