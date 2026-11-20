`timescale 1ns / 1ps

module tb ();
  parameter integer bits_per_pixel = 9;

  reg enable_red_filter;
  reg enable_blue_filter;
  reg enable_green_filter;
  reg [bits_per_pixel-1:0] RGB;
  wire [bits_per_pixel-1:0] RGB_processed;

  initial begin
    enable_red_filter <= 0;
    enable_blue_filter <= 0;
    enable_green_filter <= 0;
    RGB <= 0;

    #10 enable_red_filter <= 1;
    #10 RGB <= 9'b000_110_011;
    #10 RGB <= 9'b111_111_111;
    #10 RGB <= 9'b100_000_111;

    #10 enable_blue_filter <= 1;
    #10 enable_green_filter <= 1;

    #10;
  end

  rgb_filter #(
      .bits_per_pixel(bits_per_pixel)
  ) u_rgb_filter (
      .enable_red_filter  (enable_red_filter),
      .enable_blue_filter (enable_blue_filter),
      .enable_green_filter(enable_green_filter),
      .RGB                (RGB),
      .RGB_filtered       (RGB_processed)
  );



endmodule
