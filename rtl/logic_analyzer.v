module logic_analyzer #(
    parameter DEPTH = 128
)(
    input clk,
    input rst_n,
    input [7:0] data_in,

    input start,
    input [7:0] trigger_value,

    output reg [7:0] data_out,
    output reg valid,
    output reg done
);

// =========================
// MEMORY
// =========================
reg [7:0] mem [0:DEPTH-1];

// =========================
// REGISTERS
// =========================
reg [6:0] wr_ptr;
reg [6:0] rd_ptr;

reg capturing;
reg triggered;
reg sending;

reg [6:0] post_cnt;

// =========================
// SINGLE CONTROL BLOCK
// =========================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wr_ptr     <= 0;
        rd_ptr     <= 0;
        capturing  <= 0;
        triggered  <= 0;
        sending    <= 0;
        post_cnt   <= 0;
        valid      <= 0;
        done       <= 0;
    end else begin

        // =====================
        // START CAPTURE
        // =====================
        if (start)
            capturing <= 1;

        // =====================
        // CAPTURE (circular)
        // =====================
        if (capturing) begin
            mem[wr_ptr] <= data_in;
            wr_ptr <= wr_ptr + 1;

            if (data_in == trigger_value)
                triggered <= 1;
        end

        // =====================
        // POST-TRIGGER COUNT
        // =====================
        if (triggered && capturing) begin
            post_cnt <= post_cnt + 1;

            if (post_cnt == (DEPTH/2)) begin
                capturing <= 0;
                sending   <= 1;
                rd_ptr    <= wr_ptr + 1; // correct chronological start
            end
        end

        // =====================
        // READOUT
        // =====================
        if (sending) begin
            data_out <= mem[rd_ptr];
            rd_ptr   <= rd_ptr + 1;
            valid    <= 1;

            if (rd_ptr == wr_ptr) begin
                sending <= 0;
                done    <= 1;
                valid   <= 0;
            end
        end else begin
            valid <= 0;
        end

    end
end

endmodule