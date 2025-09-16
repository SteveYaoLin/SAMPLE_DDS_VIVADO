module gtx_tx(
    input  wire sys_clk,        // 50MHz系统时钟
    input  wire sys_rst_n,      // 复位
    input  wire gtx_refclk_p,   // GTX参考时钟正
    input  wire gtx_refclk_n,   // GTX参考时钟负
    input  wire [15:0] tx_data_in, // 发送数据
    output wire gtx_tx_p,       // GTX发送正端
    output wire gtx_tx_n,       // GTX发送负端
    output wire txusrclk_out    // GTX用户时钟输出
);

wire gtx_txusrclk;
wire gtx_txoutclk;
wire [1:0] txcharisk = 2'b00; // 无特殊字符

// GTX IP核实例化
gtwizard_0 u_gtx_ip (
    .soft_reset_tx_in        (~sys_rst_n),        // 软复位，低有效
    .sysclk_in               (sys_clk),           // 系统时钟（50MHz）
    
    // 参考时钟
    .gtrefclk0_in_p          (gtx_refclk_p),      // 参考时钟正
    .gtrefclk0_in_n          (gtx_refclk_n),      // 参考时钟负
    
    // 用户接口
    .txusrclk_in             (gtx_txusrclk),      // 用户时钟
    .txusrclk2_in            (gtx_txusrclk),      // 用户时钟2
    .txdata_in               (tx_data_in),        // 发送数据
    .txcharisk_in            (txcharisk),         // 无特殊字符
    
    // 高速串行接口
    .txp_out                 (gtx_tx_p),          // 发送正端
    .txn_out                 (gtx_tx_n),          // 发送负端
    
    // 时钟输出
    .txoutclk_out            (gtx_txoutclk),      // TX输出时钟
    
    // 状态指示
    .tx_resetdone_out        (),                  // 发送复位完成
    .gtpowergood_out         ()                   // GTX电源正常
);
// (
// input           sysclk_in,
// input           soft_reset_tx_in,
// input           dont_reset_on_data_error_in,
// output          gt0_tx_fsm_reset_done_out,
// output          gt0_rx_fsm_reset_done_out,
// input           gt0_data_valid_in,

//     //_________________________________________________________________________
//     //GT0  (X1Y0)
//     //____________________________CHANNEL PORTS________________________________
//     //-------------------------- Channel - DRP Ports  --------------------------
//     input   [8:0]   gt0_drpaddr_in,
//     input           gt0_drpclk_in,
//     input   [15:0]  gt0_drpdi_in,
//     output  [15:0]  gt0_drpdo_out,
//     input           gt0_drpen_in,
//     output          gt0_drprdy_out,
//     input           gt0_drpwe_in,
//     //------------------------- Digital Monitor Ports --------------------------
//     output  [7:0]   gt0_dmonitorout_out,
//     //------------------- RX Initialization and Reset Ports --------------------
//     input           gt0_eyescanreset_in,
//     //------------------------ RX Margin Analysis Ports ------------------------
//     output          gt0_eyescandataerror_out,
//     input           gt0_eyescantrigger_in,
//     //------------------- Receive Ports - RX Equalizer Ports -------------------
//     output  [6:0]   gt0_rxmonitorout_out,
//     input   [1:0]   gt0_rxmonitorsel_in,
//     //----------- Receive Ports - RX Initialization and Reset Ports ------------
//     input           gt0_gtrxreset_in,
//     //------------------- TX Initialization and Reset Ports --------------------
//     input           gt0_gttxreset_in,
//     input           gt0_txuserrdy_in,
//     //---------------- Transmit Ports - FPGA TX Interface Ports ----------------
//     input           gt0_txusrclk_in,
//     input           gt0_txusrclk2_in,
//     //---------------- Transmit Ports - TX Data Path interface -----------------
//     input   [15:0]  gt0_txdata_in,
//     //-------------- Transmit Ports - TX Driver and OOB signaling --------------
//     output          gt0_gtxtxn_out,
//     output          gt0_gtxtxp_out,
//     //--------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
//     output          gt0_txoutclk_out,
//     output          gt0_txoutclkfabric_out,
//     output          gt0_txoutclkpcs_out,
//     //------------------- Transmit Ports - TX Gearbox Ports --------------------
//     input   [1:0]   gt0_txcharisk_in,
//     //----------- Transmit Ports - TX Initialization and Reset Ports -----------
//     output          gt0_txresetdone_out,


//     //____________________________COMMON PORTS________________________________
//     input      gt0_qplllock_in,
//     input      gt0_qpllrefclklost_in,
//     output     gt0_qpllreset_out,
//     input      gt0_qplloutclk_in,
//     input      gt0_qplloutrefclk_in

// );
// 时钟缓冲器
BUFG bufg_gtx_txusrclk (
    .I(gtx_txoutclk),    // GTX输出的时钟
    .O(gtx_txusrclk)     // 全局时钟网络
);

assign txusrclk_out = gtx_txusrclk;

endmodule