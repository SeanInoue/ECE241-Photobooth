module photobooth (
    input resetn,
    input clock
);
  parameter bits_per_pixel = 9;
  parameter bits_per_channel = bits_per_pixel / 3;
  parameter max_channel_value = {bits_per_channel{1'b1}};

  wire [bits_per_pixel-1:0] RGB;  // connect uart to processor
  wire [bits_per_pixel-1:0] RGB_processed;  // connect processor to vga

  wire x, y;  // connect  uart to vga
  wire write;  // connect uart to vga

  inverter #(
      .bits_per_pixel(bits_per_pixel)
  ) u_inverter (
      .RGB         (RGB),
      .RGB_inverted(RGB_processed)
  );

  vga_adapter u_vga_adapter (
      .resetn(resetn),
      .clock (clock),
      .color (RGB_processed),
      .x     (x),              // pixel location: left -> right
      .y     (y),              //                 top  -> bottom
      .write (write),

      // outputs
      // TODO: find out where these connect to
      .VGA_R      (VGA_R),
      .VGA_G      (VGA_G),
      .VGA_B      (VGA_B),
      .VGA_HS     (VGA_HS),
      .VGA_VS     (VGA_VS),
      .VGA_BLANK_N(VGA_BLANK_N),
      .VGA_SYNC_N (VGA_SYNC_N),
      .VGA_CLK    (VGA_CLK)
  );

endmodule
