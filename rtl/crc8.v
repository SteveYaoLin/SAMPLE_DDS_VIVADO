module crc8 (
    input        clk,
    input        rst_n,
    input        crc_en,
    input        crc_clr,
    input  [7:0] data_in,
    output [7:0] crc_out
);

reg [7:0] crc_reg;
wire [7:0] next_crc;

// CRC8 polynomial: x^8 + x^2 + x + 1 (0x07)
assign next_crc[0] = data_in[7] ^ data_in[6] ^ data_in[0] ^ crc_reg[0] ^ crc_reg[6] ^ crc_reg[7];
assign next_crc[1] = data_in[6] ^ data_in[1] ^ data_in[0] ^ crc_reg[0] ^ crc_reg[1] ^ crc_reg[6];
assign next_crc[2] = data_in[6] ^ data_in[2] ^ data_in[1] ^ data_in[0] ^ crc_reg[0] ^ crc_reg[1] ^ crc_reg[2] ^ crc_reg[6];
assign next_crc[3] = data_in[7] ^ data_in[3] ^ data_in[2] ^ data_in[1] ^ crc_reg[1] ^ crc_reg[2] ^ crc_reg[3] ^ crc_reg[7];
assign next_crc[4] = data_in[4] ^ data_in[3] ^ data_in[2] ^ crc_reg[2] ^ crc_reg[3] ^ crc_reg[4];
assign next_crc[5] = data_in[5] ^ data_in[4] ^ data_in[3] ^ crc_reg[3] ^ crc_reg[4] ^ crc_reg[5];
assign next_crc[6] = data_in[6] ^ data_in[5] ^ data_in[4] ^ crc_reg[4] ^ crc_reg[5] ^ crc_reg[6];
assign next_crc[7] = data_in[7] ^ data_in[6] ^ data_in[5] ^ crc_reg[5] ^ crc_reg[6] ^ crc_reg[7];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        crc_reg <= 8'h00;
    end
    else if (crc_clr) begin
        crc_reg <= 8'h00;
    end
    else if (crc_en) begin
        crc_reg <= next_crc;
    end
end

assign crc_out = crc_reg;

endmodule