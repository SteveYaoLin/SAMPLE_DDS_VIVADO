module lhz_uart_led (
    input wire sys_clk,          // System clock input U18
    input wire sys_rst_n,        // Active low reset input
    // N16
    input wire uart_rxd,         // UART RXD input T19
    
    // output reg [7:0] uart_data,  // UART data output
    // output reg uart_done,        // UART done signal
    // output reg uart_get,         // UART get signal
    
    // output reg [7:0] pack_cnt,   // Packet count output
    // output reg pack_ing,         // Packet in progress signal
    // output reg pack_done,        // Packet done signal
    // output reg [7:0] pack_num,   // Packet number output
    output wire led,        // LED drive signal
    // H 15
    output wire uart_txd //J15
    
    // output reg [7:0] dataA,      // Data A output
    // output reg [7:0] dataD,      // Data D output
    // output reg [15:0] dataB,     // Data B output
    // output reg [15:0] dataC       // Data C output
);

// First, declare the necessary signals
wire clk_50M;
wire clk_100M;
wire clk_150M;
wire clk_150M_O;
wire locked;
wire resetn;
wire rst_n = sys_rst_n & locked; // Active low reset signal

wire  [7:0] uart_data;
wire uart_done;
wire uart_get;
wire [7:0] pack_cnt;
wire pack_ing;
wire pack_done;
wire [7:0] pack_num;
wire recv_done;
wire [7:0] dataA;
wire [7:0] dataD;
wire [15:0] dataB;
wire [15:0] dataC;
wire led_enable;
wire led_breath;
//
  clk_wiz_0 u_mmcm
  (
  // Clock out ports  
  .clk_out1(clk_50M),
  .clk_out2(clk_100M),
  .clk_out3(clk_150M),
  .clk_out4(clk_150M_O),
  // Status and control signals               
  .resetn(sys_rst_n), 
  .locked(locked),
 // Clock in ports
  .clk_in1(sys_clk)
  );

// Then, instantiate the module with proper port connections
uart_mult_byte_rx u_uart_rx_inst (
    .sys_clk    (clk_50M),      // Connect to input clock
    .sys_rst_n  (!rst_n  ),    // Connect to reset
    .uart_rxd   (uart_rxd),     // Connect to UART RX input
    
    .uart_data  (uart_data),    // Connect to internal signal
    .uart_done  (uart_done),    // Connect to internal signal
    .uart_get   (uart_get),     // Connect to internal signal
    
    .pack_cnt   (pack_cnt),     // Connect to internal signal
    .pack_ing   (pack_ing),     // Connect to internal signal
    .pack_done  (pack_done),    // Connect to internal signal
    .pack_num   (pack_num),     // Connect to internal signal
    .recv_done  (recv_done),    // Connect to internal signal
    
    .dataA      (dataA),        // Connect to internal signal
    .dataD      (dataD),        // Connect to internal signal
    .dataB      (dataB),        // Connect to internal signal
    .dataC      (dataC)         // Connect to internal signal
);
//assign led_enable = (dataA == 8'h08) ? 1'b1 : 1'b0 ; // Example: drive LED with the least significant bit of received data
breath_led u_breath_led(
    .sys_clk       (clk_50M) ,      //
    .sys_rst_n       (rst_n) ,    //
    .led (led_breath )           //
);
assign led = (dataA == 8'h08) ? led_breath : 1'b0 ; // Example: drive LED with the least significant bit of received data
endmodule
