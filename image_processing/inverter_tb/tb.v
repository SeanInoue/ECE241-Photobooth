`timescale 1ns / 1ps

module tb ();
  parameter integer bits_per_pixel = 9;

  reg enable_invert;
  reg [bits_per_pixel-1:0] RGB;
  wire [bits_per_pixel-1:0] RGB_inverted;

  initial begin
    enable_invert <= 0;
    RGB <= 0;

    #10 enable_invert <= 1;
    #10 RGB <= 9'b000_110_011;
    #10 RGB <= 9'b111_111_111;
    #10 RGB <= 9'b100_000_111;

    #10 enable_invert <= 0;
    #10 enable_invert <= 1;

    #10;
  end

  inverter #(
      .bits_per_pixel(bits_per_pixel)
  ) u_inverter (
      .enable_invert(enable_invert),
      .RGB          (RGB),
      .RGB_inverted (RGB_inverted)
  );


endmodule
