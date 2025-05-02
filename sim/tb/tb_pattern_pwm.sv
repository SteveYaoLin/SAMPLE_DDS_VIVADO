`timescale 1ns/1ps

module pattern_pwm_tb;
parameter _PAT_WIDTH = 16 ;  // 模式寄存器宽度
reg         clk;
reg         rst_n;
reg         pwm_en;
reg [7:0]   duty_num;
reg [15:0]  pulse_dessert;
reg [7:0]   pulse_num;
reg [_PAT_WIDTH-1:0]   PAT;
wire        pwm_out;
wire        busy;
wire        valid;

pattern_pwm #(
    ._PAT_WIDTH(_PAT_WIDTH)
) uut (
    .clk(clk),
    .rst_n(rst_n),
    .pwm_en(pwm_en),
    .duty_num(duty_num),
    .pulse_dessert(pulse_dessert),
    .pulse_num(pulse_num),
    .PAT(PAT),
    .pwm_out(pwm_out),
    .busy(busy),
    .valid(valid)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    rst_n = 0;
    pwm_en = 0;
    duty_num = 0;
    pulse_dessert = 0;
    pulse_num = 0;
    PAT = 16'h00;
    #100;
    rst_n = 1;
    
    // 测试用例1：单脉冲模式
    duty_num = 8'd1;
    pulse_dessert = 16'h10;
    pulse_num = 8'd2;
    PAT = 16'b1010_1010;
    pwm_en = 1;
    // #10 pwm_en = 0;
    wait(valid);
    #10 pwm_en = 0;
    #100;
    
    // 测试用例2：多脉冲有限模式
    duty_num = 8'd2;
    pulse_dessert = 16'h15;
    pulse_num = 8'd3;
    PAT = 16'b11111111;
    pwm_en = 1;
    
    wait(valid);
    #10 pwm_en = 0;
    #100;
    
    // 测试用例3：无限模式终止
    duty_num = 8'd1;
    pulse_dessert = 16'd5;
    pulse_num = 8'd0;
    PAT = 16'b11111;
    pwm_en = 1;
    // #10 pwm_en = 0;
    #500;
    pwm_en = 0; // 产生下降沿
    // #10 pwm_en = 0;
    wait(valid);
    
    #100;
    $finish;
end

initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, pattern_pwm_tb);
end

endmodule