`timescale 1ns / 1ps

module photobooth_tb ();

  parameter CLOCK_PERIOD = 10;

  reg enable_invert;
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
    // $dumpfile("photobooth.vcd");
    // $dumpvars();
    enable_invert <= 1'b0;
    #5000 enable_invert <= 1'b1;
    #5000;
    // $finish;
  end

  photobooth u_photobooth (
      .resetn       (resetn),
      .clock        (CLOCK_50),
      .enable_invert(enable_invert),
      .VGA_R        (VGA_R),
      .VGA_G        (VGA_G),
      .VGA_B        (VGA_B),
      .VGA_HS       (VGA_HS),
      .VGA_VS       (VGA_VS),
      .VGA_BLANK_N  (VGA_BLANK_N),
      .VGA_SYNC_N   (VGA_SYNC_N),
      .VGA_CLK      (VGA_CLK)
  );

endmodule
