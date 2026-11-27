`timescale 1ns / 1ps

module line_buffer_tb ();

  parameter CLOCK_PERIOD = 10;
  parameter nX = 3;
  parameter nY = 3;
  parameter COLS = 8;
  parameter ROWS = 6;

  reg resetn;
  reg clock;
  reg [bits_per_pixel-1:0] sdram_rgb;
  reg [nX-1:0] display_x;
  reg [nY-1:0] display_y;
  reg display_write;

  wire [bits_per_pixel-1:0] window_0_0;
  wire [bits_per_pixel-1:0] window_0_1;
  wire [bits_per_pixel-1:0] window_0_2;
  wire [bits_per_pixel-1:0] window_1_0;
  wire [bits_per_pixel-1:0] window_1_1;
  wire [bits_per_pixel-1:0] window_1_2;
  wire [bits_per_pixel-1:0] window_2_0;
  wire [bits_per_pixel-1:0] window_2_1;
  wire [bits_per_pixel-1:0] window_2_2;
  wire [nX-1:0] vga_x;
  wire [nY-1:0] vga_y;
  wire vga_write_real;

  initial begin
    clock <= 1'b0;
  end
  always @(*) begin : Clock_Generator
    #((CLOCK_PERIOD) / 2) clock <= ~clock;
  end

  initial begin
    resetn <= 1'b0;
    #10 resetn <= 1'b1;
  end

  initial begin
    enable_invert <= 1'b0;
    enable_grayscale <= 1'b0;
    #5000 enable_grayscale <= 1'b1;
    #5000;
  end

  line_buffer #(
      .nX  (nX),
      .nY  (nY),
      .COLS(COLS),
      .ROWS(ROWS)
  ) u_line_buffer (
      .clock         (clock),
      .sdram_rgb     (sdram_rgb),
      .display_x     (display_x),
      .display_y     (display_y),
      .display_write (display_write),
      .window_0_0    (window_0_0),
      .window_0_1    (window_0_1),
      .window_0_2    (window_0_2),
      .window_1_0    (window_1_0),
      .window_1_1    (window_1_1),
      .window_1_2    (window_1_2),
      .window_2_0    (window_2_0),
      .window_2_1    (window_2_1),
      .window_2_2    (window_2_2),
      .vga_x         (vga_x),
      .vga_y         (vga_y),
      .vga_write_real(vga_write_real)
  );

endmodule
