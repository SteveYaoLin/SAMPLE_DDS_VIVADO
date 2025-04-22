`timescale 1ns/1ps

module pwm_generator_tb;

    // Testbench 信号
    reg clk;
    reg rst_n;
    reg enable;
    reg [7:0] data_in;
    wire pwm;
    wire valid;

    // 时钟周期定义
    localparam CLK_PERIOD = 10;

    // 实例化待测模块
    pwm_generator uut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .data_in(data_in),
        .pwm(pwm),
        .valid(valid)
    );

    // 时钟生成
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // 复位任务
    task reset_dut();
        begin
            rst_n = 0;
            enable = 0;
            data_in = 8'b0;
            #(2 * CLK_PERIOD);
            rst_n = 1;
        end
    endtask

    // 发送数据任务
    task send_data(input [7:0] data);
        begin
            @(posedge clk);
            enable = 1;
            data_in = data;
            @(posedge clk);
            enable = 0;
            // 等待 valid 信号拉高
            wait(valid == 1);
            @(posedge clk);
        end
    endtask

    // 主测试过程
    initial begin
        // 初始化信号
        reset_dut();

        // 第一次发送数据 0xA5
        send_data(8'hA5);

        // 等待一段时间
        #(5 * CLK_PERIOD);

        // 第二次发送数据 0x5A
        send_data(8'h5A);

        // 等待一段时间
        #(10 * CLK_PERIOD);

        // 结束仿真
        $finish;
    end

    // 监视信号
    initial begin
        $monitor("Time: %0t | clk: %b | rst_n: %b | enable: %b | data_in: %h | pwm: %b | valid: %b",
                 $time, clk, rst_n, enable, data_in, pwm, valid);
    end

endmodule