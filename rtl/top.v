module top (
    input clk,
    input rst_n,
    output uart_XMIT_dataH,
    output [4:0] leds
);

// =====================
// SLOW CLOCK (1 Hz)
// =====================
reg [25:0] div;
wire tick = (div == 26'd49_999_999);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        div <= 0;
    else if (tick)
        div <= 0;
    else
        div <= div + 1;
end

// =====================
// COUNTER
// =====================
reg [7:0] count;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        count <= 0;
    else if (tick)
        count <= count + 1;
end

assign leds = ~count[4:0];

// =====================
// UART TX
// =====================
reg send;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        send <= 0;
    else if (tick)
        send <= 1;
    else
        send <= 0;
end

uart_tx #(
    .CLK_FREQ(50000000),
    .BAUD(115200)   // safer
) tx_inst (
    .clk(clk),
    .rst_n(rst_n),
    .data_in(count),
    .send(send),
    .tx(uart_XMIT_dataH),
    .busy()
);

endmodule