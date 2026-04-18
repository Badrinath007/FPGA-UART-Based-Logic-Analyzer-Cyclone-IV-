module uart_tx #(
    parameter CLK_FREQ = 50000000,
    parameter BAUD = 115200
)(
    input clk,
    input rst_n,
    input [7:0] data_in,
    input send,
    output reg tx,
    output reg busy,
	 input valid,
	 output ready
);

localparam CLKS_PER_BIT = CLK_FREQ / BAUD;

reg [15:0] clk_cnt;
reg [3:0] bit_index;
reg [9:0] tx_shift;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tx <= 1'b1;
        busy <= 0;
        clk_cnt <= 0;
        bit_index <= 0;
    end else begin
        if (send && !busy) begin
            busy <= 1;
            tx_shift <= {1'b1, data_in, 1'b0}; // stop, data, start
            bit_index <= 0;
            clk_cnt <= 0;
        end else if (busy) begin
            if (clk_cnt < CLKS_PER_BIT - 1) begin
                clk_cnt <= clk_cnt + 1;
            end else begin
                clk_cnt <= 0;
                tx <= tx_shift[bit_index];
                bit_index <= bit_index + 1;

                if (bit_index == 9) begin
                    busy <= 0;
                    tx <= 1'b1;
                end
            end
        end
    end
end

endmodule