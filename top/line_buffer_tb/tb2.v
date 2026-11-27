`timescale 1ns / 1ps

module tb2 ();

  parameter CLOCK_PERIOD = 10;
  parameter nX = 3;
  parameter nY = 3;
  parameter COLS = 8;
  parameter ROWS = 6;
  parameter bits_per_pixel = 9;

  reg resetn;
  reg clock;
  reg [bits_per_pixel-1:0] sdram_rgb;
  reg [nX-1:0] display_x;
  reg [nY-1:0] display_y;
  reg display_write;
  reg looped = 0;

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

  always @(posedge clock) begin
    if (!resetn) begin
      display_x <= 0;
      display_y <= 0;
      display_write <= 1;
      sdram_rgb <= 0;
    end else begin
      sdram_rgb <= sdram_rgb + 1;

      if ((display_x < 7 || display_y < 5) && looped == 0) begin
        if (display_x == 7) begin
          display_x <= 0;
          if (display_y == 5) begin
            display_y <= 0;
          end else begin
            display_y <= display_y + 1;
          end
        end else begin
          display_x <= display_x + 1;
        end
      end else begin
        looped <= 1;
        display_x <= 0;
        display_y <= 0;
      end
    end
  end

  initial begin
    resetn <= 1'b0;
    #10 resetn <= 1'b1;
  end

  line_buffer #(
      .nX  (nX),
      .nY  (nY),
      .COLS(COLS),
      .ROWS(ROWS)
  ) u_line_buffer (
      .resetn        (resetn),
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
