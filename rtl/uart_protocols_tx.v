module uart_protocol_tx (
    input clk_50M,
    input rst_n,
    input recv_done,
    input [7:0] rev_data1,
    input [7:0] rev_data2,
    input [7:0] rev_data3,
    input [7:0]     rev_data4  ,
    input [7:0]     rev_data5  ,
    input [7:0]     rev_data6  ,
    input [7:0]     rev_data7  ,
    input [7:0]     rev_data8  ,
    input [7:0]     rev_data9  ,
    input [7:0]     rev_data10 ,
    output uart_txd
);

reg uart_tx_en;
reg [7:0] uart_tx_data;
wire uart_tx_busy;

reg [2:0] tx_cnt;
reg [3:0] state;
localparam IDLE = 4'd0;
localparam START = 4'd1;
localparam SEND = 4'd2;
parameter _UART_TX_EN_DELAY = 16;
reg [_UART_TX_EN_DELAY-1:0] uart_start_delay;
wire uart_start;
wire uart_tx_done;
reg [7:0] uart_tx_keep;

always @(posedge clk_50M or negedge rst_n) begin
    if (!rst_n) begin
        uart_start_delay <= {_UART_TX_EN_DELAY{1'b0}};
    end else begin
        uart_start_delay <= {uart_start_delay[_UART_TX_EN_DELAY-2:0], recv_done};
    end
end

assign uart_start = uart_start_delay[_UART_TX_EN_DELAY-1];

always @(posedge clk_50M or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        tx_cnt <= 3'd0;
        uart_tx_en <= 1'b0;
        uart_tx_keep <= 8'h00;
    end else begin
        case (state)
            IDLE: begin
                if (uart_start&(!uart_tx_busy)) begin
                    state <= START;
                    tx_cnt <= 3'd0;
                    uart_tx_en <= 1'b0;
                    uart_tx_keep <= 8'h00;
                end
            end
            START:begin
                state <= SEND;
                uart_tx_en <= 1'b1;
                tx_cnt <= tx_cnt + 1'b1;
                uart_tx_keep <= 8'h00;
            end
            SEND: begin
                uart_tx_en <= 1'b0;
                if (uart_tx_done) begin
                    uart_tx_keep <= uart_tx_keep + 1'b1;
                    state <= SEND;
                end
                else if (uart_tx_keep == 8'h0f) begin
                    uart_tx_keep <= 8'h00;
                    if (tx_cnt == 3'd5) begin
                        state <= IDLE;
                    end else begin
                        state <= START;
                    end
                end
                else if (|uart_tx_keep)begin
                   uart_tx_keep <= uart_tx_keep + 1'b1;
                   state <= SEND;
                end
            end
        endcase
    end
end

wire [7:0] uart_tx_crc8;
wire crc8_en;
wire crc8_clr;

assign crc8_clr = (state == IDLE) && recv_done;
assign crc8_en = (state == START) && (tx_cnt >= 3'd1) && (tx_cnt <= 3'd3);

crc8 u_crc8 (
    .clk      (clk_50M),
    .rst_n    (rst_n),
    .crc_en   (crc8_en),
    .crc_clr  (crc8_clr),
    .data_in  (uart_tx_data),
    .crc_out  (uart_tx_crc8)
);

always @(*) begin
    case (tx_cnt)
        3'd0: uart_tx_data = 8'h80;
        3'd1: uart_tx_data = rev_data0;
        3'd2: uart_tx_data = rev_data1;
        3'd3: uart_tx_data = rev_data2;
        3'd4: uart_tx_data = uart_tx_crc8;
        3'd5: uart_tx_data = 8'h55;
        default: uart_tx_data = 8'h00;
    endcase
end

uart_tx u_uart_tx(
    .clk           (clk_50M),
    .rst_n         (rst_n),
    .uart_tx_en    (uart_tx_en),
    .uart_tx_data  (uart_tx_data),
    .uart_txd      (uart_txd),
    .uart_tx_done  (uart_tx_done),
    .uart_tx_busy  (uart_tx_busy)
);

endmodule
// reg uart_tx_en;
// reg [7:0] uart_tx_data;
// wire uart_tx_busy;

// reg [2:0] tx_cnt;
// reg [3:0] state;
// localparam IDLE = 4'd0;
// localparam START = 4'd1;
// localparam SEND = 4'd2;
// // Add parameter for delay cycles
// parameter _UART_TX_EN_DELAY = 16;  // Default delay of 2 cycles, can be modified
// reg [_UART_TX_EN_DELAY-1:0] uart_start_delay;
// wire uart_start;
// wire uart_tx_done;
// reg [7:0] uart_tx_keep;

// // Create delayed version of uart_tx_en
// always @(posedge clk_50M or negedge rst_n) begin
//     if (!rst_n) begin
//         uart_start_delay <= {_UART_TX_EN_DELAY{1'b0}};
//     end else begin
//         uart_start_delay <= {uart_start_delay[_UART_TX_EN_DELAY-2:0], recv_done};
//     end
// end

// assign uart_start = uart_start_delay[_UART_TX_EN_DELAY-1];

// always @(posedge clk_50M or negedge rst_n) begin
//     if (!rst_n) begin
//         state <= IDLE;
//         tx_cnt <= 3'd0;
//         uart_tx_en <= 1'b0;
//         uart_tx_keep <= 8'h00;
//     end else begin
//         case (state)
//             IDLE: begin
//                 if (uart_start&(!uart_tx_busy)) begin
//                     state <= START;
//                     tx_cnt <= 3'd0;
//                     uart_tx_en <= 1'b0;
//                     uart_tx_keep <= 8'h00;
//                 end
//             end
//             START:begin
//                 // if (!uart_tx_busy) begin
//                     state <= SEND;
//                     uart_tx_en <= 1'b1;
//                     tx_cnt <= tx_cnt + 1'b1;
//                     uart_tx_keep <= 8'h00; // Store the data to be sent
//                 // end
//             end
//             SEND: begin
//                 uart_tx_en <= 1'b0;
//                 if (uart_tx_done) begin
//                     uart_tx_keep <= uart_tx_keep + 1'b1;
//                     state <= SEND; // Stay in SEND state until all data is sent
//                 end
//                 else if (uart_tx_keep == 8'h0f) begin
//                     uart_tx_keep <= 8'h00;
//                     if (tx_cnt == 3'd5) begin
//                         state <= IDLE;
//                     end else begin
//                         state <= START;
//                     end
//                 end
//                 else if (|uart_tx_keep)begin
//                    uart_tx_keep <= uart_tx_keep + 1'b1;
//                    state <= SEND; // Stay in SEND state until all data is sent
//                 end
//             end
//         endcase
//     end
// end
// // assign uart_tx_en = (state == SEND) && !uart_tx_busy && (tx_cnt < 3'd6);

// wire [7:0] uart_tx_crc8;
// wire crc8_en;
// wire crc8_clr;

// assign crc8_clr = (state == IDLE) && recv_done;
// assign crc8_en = (state == START) && (tx_cnt >= 3'd1) && (tx_cnt <= 3'd3);

// crc8 u_crc8 (
//     .clk      (clk_50M),
//     .rst_n    (rst_n),
//     .crc_en   (crc8_en),
//     .crc_clr  (crc8_clr),
//     .data_in  (uart_tx_data),
//     .crc_out  (uart_tx_crc8)
// );
// always @(*) begin
//     case (tx_cnt)
//         3'd0: uart_tx_data = 8'h80;
//         3'd1: uart_tx_data = rev_data1;
//         3'd2: uart_tx_data = rev_data2;
//         3'd3: uart_tx_data = rev_data3;
//         3'd4: uart_tx_data = uart_tx_crc8;
//         3'd5: uart_tx_data = 8'h55;
//         default: uart_tx_data = 8'h00;
//     endcase
// end



// uart_tx u_uart_tx(
//     .clk           (clk_50M),
//     .rst_n         (rst_n),
//     .uart_tx_en    (uart_tx_en),
//     .uart_tx_data  (uart_tx_data),
//     .uart_txd      (uart_txd),
//     .uart_tx_done  (uart_tx_done), // 拉高发�?�完成信�?
//     .uart_tx_busy  (uart_tx_busy)
// );