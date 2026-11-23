// Receives one 8N1 UART frame: start bit (low), 8 data bits LSB first, stop bit (high).
// valid pulses for one clock when data holds a newly received byte.
module uart_rx_byte #(
    parameter CLKS_PER_BIT = 17  // clock frequency / baud rate
) (
    input wire clock,
    input wire resetn,
    input wire rx,
    output reg [7:0] data,
    output reg valid
);
  localparam IDLE = 2'd0, START = 2'd1, DATA = 2'd2, STOP = 2'd3;

  // rx is asynchronous to clock, so pass it through two flip flops to avoid metastability
  reg rx_meta, rx_sync;

  reg [1:0] state;
  reg [$clog2(CLKS_PER_BIT)-1:0] count;  // clocks spent in the current bit
  reg [2:0] bit_index;
  reg [7:0] SHIFT_REG;  // shift in from the left so the LSB (sent first) ends up at bit 0

  always @(posedge clock) begin
    if (!resetn) begin
      rx_meta <= 1'b1;  // line idles high
      rx_sync <= 1'b1;
    end else begin
      rx_meta <= rx;
      rx_sync <= rx_meta;
    end
  end

  always @(posedge clock) begin
    valid <= 1'b0;
    if (!resetn) begin
      state     <= IDLE;
      count     <= 0;
      bit_index <= 0;
    end else begin
      case (state)
        IDLE: begin
          count <= 0;
          if (!rx_sync) state <= START;
        end

        // wait half a bit to reach the middle of the start bit, then make sure it wasn't a glitch
        START: begin
          if (count == CLKS_PER_BIT / 2 - 1) begin
            count     <= 0;
            bit_index <= 0;
            state     <= rx_sync ? IDLE : DATA;
          end else count <= count + 1'b1;
        end

        // from the middle of one bit, a full bit period lands in the middle of the next
        DATA: begin
          if (count == CLKS_PER_BIT - 1) begin
            count     <= 0;
            SHIFT_REG <= {rx_sync, SHIFT_REG[7:1]};
            if (bit_index == 3'd7) state <= STOP;
            else bit_index <= bit_index + 1'b1;
          end else count <= count + 1'b1;
        end

        // a low stop bit means the frame is corrupt (framing error), so drop the byte
        STOP: begin
          if (count == CLKS_PER_BIT - 1) begin
            count <= 0;
            state <= IDLE;
            if (rx_sync) begin
              data  <= SHIFT_REG;
              valid <= 1'b1;
            end
          end else count <= count + 1'b1;
        end
      endcase
    end
  end

endmodule
