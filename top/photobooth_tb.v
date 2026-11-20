`timescale 1ns / 1ps

module photobooth_tb ();

  parameter CLOCK_PERIOD = 10;
  parameter delay = 0;
  parameter nX = 4;
  parameter nY = 2;

  reg enable_invert, enable_grayscale;
  reg resetn;
  reg CLOCK_50;

  initial begin
    CLOCK_50 <= 1'b0;
  end
  always @(*) begin : Clock_Generator
    #((CLOCK_PERIOD) / 2) CLOCK_50 <= ~CLOCK_50;
  end

  initial begin
    resetn <= 1'b0;
    #10 resetn <= 1'b1;
  end

  initial begin
    enable_invert <= 1'b0;
    enable_grayscale <= 1'b0;
    #5000 enable_invert <= 1'b1;
    #5000 enable_grayscale <= 1'b1;
    #5000 enable_invert <= 1'b0;
    #5000 enable_grayscale <= 1'b1;
    #5000;
  end

  photobooth #(
      .delay(delay),
      .nX(nX),
      .nY(nY)
  ) u_photobooth (
      .resetn          (resetn),
      .clock           (CLOCK_50),
      .enable_invert   (enable_invert),
      .enable_grayscale(enable_grayscale)
  );

endmodule
