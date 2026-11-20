// Receives a video frame over UART in raster order (left -> right, top -> bottom) and writes it
// to the vga adapter. Same ports as uart_reciever_mock so the two can be swapped.
//
// Pixels are 9 bits, {R[2:0], G[2:0], B[2:0]}, sent back to back MSB first and packed into
// bytes, so 8 pixels take 9 bytes. There are no markers: every byte is data, and X and Y
// wrap to (0, 0) after the last pixel of a frame. Reset the FPGA before starting the sender.
module uart_receiver #(
    parameter CLOCK_FREQUENCY = 50_000_000,
    parameter BAUD_RATE = 2_000_000,  // 25 clocks per bit at 50 MHz, must match sender.py
    parameter RESOLUTION = "640x480",
    parameter bits_per_pixel = 9,  // the unpacking below only works for 9
    parameter nX = (RESOLUTION == "640x480") ? 10 : ((RESOLUTION == "320x240") ? 9 : 8),
    parameter nY = (RESOLUTION == "640x480") ? 9 : ((RESOLUTION == "320x240") ? 8 : 7)
) (
    input wire uart,
    input wire clock,
    input wire resetn,
    output reg [bits_per_pixel-1:0] RGB,
    output reg [nX-1:0] X,
    output reg [nY-1:0] Y,
    output reg vga_write
);
  parameter COLS = (RESOLUTION == "640x480") ? 640 : ((RESOLUTION == "320x240") ? 320 : 160);
  parameter ROWS = (RESOLUTION == "640x480") ? 480 : ((RESOLUTION == "320x240") ? 240 : 120);
  parameter CLKS_PER_BIT = (CLOCK_FREQUENCY + BAUD_RATE / 2) / BAUD_RATE;  // rounded

  wire [7:0] byte_data;
  wire byte_valid;

  uart_rx_byte #(
      .CLKS_PER_BIT(CLKS_PER_BIT)
  ) u_uart_rx_byte (
      .clock (clock),
      .resetn(resetn),
      .rx    (uart),
      .data  (byte_data),
      .valid (byte_valid)
  );

  // Each data byte either finishes a pixel (leaving 0-7 of its bits for the next one) or doesn't
  // (all 8 bits left over), so unused bits always fit in the previous byte.
  reg [7:0] PREV_BYTE;
  reg [3:0] n_bits;  // bits of PREV_BYTE (its lowest ones) not yet used in a pixel
  wire [15:0] bits = {PREV_BYTE, byte_data};
  wire [4:0] total = n_bits + 5'd8;
  wire [8:0] pixel = bits >> (total - 5'd9);  // the oldest 9 unused bits

  //_C -> _COUNTER, position of the next pixel
  reg [nX-1:0] X_C;
  reg [nY-1:0] Y_C;

  always @(posedge clock) begin
    vga_write <= 1'b0;
    if (!resetn) begin
      X_C    <= 0;
      Y_C    <= 0;
      n_bits <= 0;
    end else if (byte_valid) begin
      if (total >= 9) begin
        RGB       <= pixel;
        X         <= X_C;
        Y         <= Y_C;
        vga_write <= 1'b1;
        n_bits    <= total - 5'd9;

        if (X_C == COLS - 1) begin
          X_C <= 0;
          Y_C <= (Y_C == ROWS - 1) ? 0 : Y_C + 1'b1;
        end else begin
          X_C <= X_C + 1'b1;
        end
      end else begin
        n_bits <= total;
      end

      PREV_BYTE <= byte_data;
    end
  end

endmodule
