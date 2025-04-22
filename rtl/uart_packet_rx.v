module uart_packet_rx(
    input               clk         ,  // 系统时钟
    input               rst_n       ,  // 系统复位，低有效
    input               uart_rxd    ,  // UART接收端口
    
    output reg          packet_done ,  // 包接收完成信号
    output reg [7:0]    uart_data0  ,  // 接收数据寄存器0
    output reg [7:0]    uart_data1  ,  // 接收数据寄存器1
    output reg [7:0]    uart_data2  ,  // 接收数据寄存器2
    output reg [7:0]    uart_data3  ,  // 接收数据寄存器3
    output reg [7:0]    uart_data4  ,  // 接收数据寄存器4
    output reg [7:0]    uart_data5  ,  // 接收数据寄存器5
    output reg [7:0]    uart_data6  ,  // 接收数据寄存器6
    output reg [7:0]    uart_data7     // 接收数据寄存器7
);

// 实例化uart_rx模块
wire        rx_done;    // 单字节接收完成信号
wire [7:0]  rx_data;    // 单字节接收数据

uart_rx u_uart_rx(
    .clk            (clk),
    .rst_n          (rst_n),
    .uart_rxd       (uart_rxd),
    .uart_rx_done   (rx_done),
    .uart_rx_data   (rx_data)
);

// 接收字节计数器（0-7）
reg [2:0] rx_byte_cnt;

// 主控制逻辑
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rx_byte_cnt <= 3'd0;
        packet_done <= 1'b0;
        uart_data0  <= 8'h0;
        uart_data1  <= 8'h0;
        uart_data2  <= 8'h0;
        uart_data3  <= 8'h0;
        uart_data4  <= 8'h0;
        uart_data5  <= 8'h0;
        uart_data6  <= 8'h0;
        uart_data7  <= 8'h0;
    end 
    else begin
        packet_done <= 1'b0;  // 默认拉低
        
        // 检测到单字节接收完成
        if (rx_done) begin
            case (rx_byte_cnt)
                3'd0 : uart_data0 <= rx_data;
                3'd1 : uart_data1 <= rx_data;
                3'd2 : uart_data2 <= rx_data;
                3'd3 : uart_data3 <= rx_data;
                3'd4 : uart_data4 <= rx_data;
                3'd5 : uart_data5 <= rx_data;
                3'd6 : uart_data6 <= rx_data;
                3'd7 : uart_data7 <= rx_data;
            endcase

            // 更新计数器
            if (rx_byte_cnt == 3'd7) begin
                rx_byte_cnt <= 3'd0;  // 计数器归零
                packet_done <= 1'b1;   // 生成包完成信号
            end 
            else begin
                rx_byte_cnt <= rx_byte_cnt + 1'b1;
            end
        end
    end
end

endmodule