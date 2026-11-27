`timescale 1ns / 1ps

module tb ();
  parameter integer bits_per_pixel = 9;

  reg enable_sharpen;
  reg [17:0] RGB_blurred;
  reg [bits_per_pixel-1:0] window_1_1;
  wire [bits_per_pixel-1:0] RGB_sharpened;

  initial begin
    RGB_blurred <= 0;
    enable_sharpen <= 0;
    window_1_1 <= 0;
    #10;
    RGB_blurred <= 18'b010010_111111_011100;
    #10;
    enable_sharpen <= 1;
    #10;
    window_1_1 <= 9'b100_111_000;
    #10;
    enable_sharpen <= 0;
    #10;
  end
  sharpener u_sharpener (
      .enable_sharpen(enable_sharpen),
      .RGB_blurred   (RGB_blurred),
      .window_1_1    (window_1_1),
      .RGB_sharpened (RGB_sharpened)
  );

endmodule
