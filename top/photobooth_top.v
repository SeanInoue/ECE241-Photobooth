module photobooth_top #(
    parameter RESOLUTION = "640x480",
    parameter bits_per_pixel = 9
) (
    input  wire       CLOCK_50,
    input  wire [0:0] KEY,
    input  wire [0:0] SW,
    output wire [7:0] VGA_R,
    output wire [7:0] VGA_G,
    output wire [7:0] VGA_B,
    output wire       VGA_HS,
    output wire       VGA_VS,
    output wire       VGA_BLANK_N,
    output wire       VGA_SYNC_N,
    output wire       VGA_CLK
);

  photobooth #(
      .RESOLUTION(RESOLUTION),
      .bits_per_pixel(bits_per_pixel)
  ) u_photobooth (
      .resetn       (KEY[0]),
      .clock        (CLOCK_50),
      .enable_invert(SW[0]),
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
