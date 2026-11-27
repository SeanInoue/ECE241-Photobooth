`timescale 1ns / 1ps

module tb ();
  parameter integer bits_per_pixel = 9;

  reg enable_blur;
  reg enable_sharpen;
  reg [bits_per_pixel-1:0] window_0_0, window_0_1, window_0_2;
  reg [bits_per_pixel-1:0] window_1_0, window_1_1, window_1_2;
  reg [bits_per_pixel-1:0] window_2_0, window_2_1, window_2_2;
  wire [17:0] RGB_blurred;

  initial begin
    enable_blur <= 0;
    enable_sharpen <= 0;
    window_0_0 <= 0;
    window_0_1 <= 0;
    window_0_2 <= 0;
    window_1_0 <= 0;
    window_1_1 <= 0;
    window_1_2 <= 0;
    window_2_0 <= 0;
    window_2_1 <= 0;
    window_2_2 <= 0;
    #10;
    window_0_0 <= 5;
    window_0_1 <= 55;
    window_0_2 <= 3;
    window_1_0 <= 22;
    window_1_1 <= 13;
    window_1_2 <= 0;
    window_2_0 <= 24;
    window_2_1 <= 76;
    window_2_2 <= 2;
    #10;
    enable_blur <= 1;  //blur
    #10;
    window_0_0 <= 100;
    window_0_1 <= 100;
    window_0_2 <= 100;
    window_1_0 <= 100;
    window_1_1 <= 0;
    window_1_2 <= 0;
    window_2_0 <= 0;
    window_2_1 <= 0;
    window_2_2 <= 50;
    #10;
    enable_sharpen <= 1;  //blur+sharpen
    #10;
    enable_blur <= 0;  //sharpen
    #10;
    enable_sharpen <= 0;  //none
    #10;
  end
  blurrer u_blurrer (
      .enable_sharpen(enable_sharpen),
      .enable_blur   (enable_blur),
      .window_0_0    (window_0_0),
      .window_0_1    (window_0_1),
      .window_0_2    (window_0_2),
      .window_1_0    (window_1_0),
      .window_1_1    (window_1_1),
      .window_1_2    (window_1_2),
      .window_2_0    (window_2_0),
      .window_2_1    (window_2_1),
      .window_2_2    (window_2_2),
      .RGB_blurred   (RGB_blurred)
  );
endmodule
