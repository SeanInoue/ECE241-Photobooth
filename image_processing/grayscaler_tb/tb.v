`timescale 1ns / 1ps

module tb ();
  parameter integer bits_per_pixel = 9;

  reg enable_grayscale;
  reg [bits_per_pixel-1:0] RGB;
  wire [bits_per_pixel-1:0] RGB_grayscaled;

  initial begin
    enable_grayscale <= 0;
    RGB <= 0;

    #10 enable_grayscale <= 1;
    #10 RGB <= 9'b000_110_011;
    #10 RGB <= 9'b111_111_111;
    #10 RGB <= 9'b100_000_111;

    #10 enable_grayscale <= 0;
    #10 enable_grayscale <= 1;

    #10;
  end

  grayscaler #(
      .bits_per_pixel(bits_per_pixel)
  ) u_grayscaler (
      .enable_grayscale(enable_grayscale),
      .RGB             (RGB),
      .RGB_grayscaled  (RGB_grayscaled)
  );


endmodule
