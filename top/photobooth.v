module photobooth #(
    parameter RESOLUTION = "640x480",
    parameter bits_per_pixel = 9,
    parameter delay = 24_999_999,
    parameter nX = (RESOLUTION == "640x480") ? 10 : ((RESOLUTION == "320x240") ? 9 : 8),
    parameter nY = (RESOLUTION == "640x480") ? 9 : ((RESOLUTION == "320x240") ? 8 : 7)

) (
    input wire resetn,
    input wire clock,
    input wire uart,
    input wire enable_invert,
    input wire enable_grayscale,
    input wire enable_red_filter,
    input wire enable_blue_filter,
    input wire enable_green_filter,

    output wire [7:0] VGA_R,
    output wire [7:0] VGA_G,
    output wire [7:0] VGA_B,
    output wire       VGA_HS,
    output wire       VGA_VS,
    output wire       VGA_BLANK_N,
    output wire       VGA_SYNC_N,
    output wire       VGA_CLK
);

  parameter bits_per_channel  = bits_per_pixel / 3;
  parameter max_channel_value = {bits_per_channel{1'b1}};


  wire [bits_per_pixel-1:0] RGB;  // connect uart to image processor
  wire [bits_per_pixel-1:0] RGB_processed, RGB_inverted, RGB_grayscaled, RGB_filtered; // connect image processor to vga
  wire [nX-1:0] X;  // connect  uart to vga
  wire [nY-1:0] Y;  // connect  uart to vga
  wire vga_write;  // connect uart to vga

  // uart
  uart_reciever u_uart_reciever (
      .uart     (uart),
      .clock    (clock),
      .resetn   (resetn),
      .RGB      (RGB),
      .X        (X),
      .Y        (Y),
      .vga_write(vga_write)
  );

  // image processors
  inverter #(
      .bits_per_pixel(bits_per_pixel)
  ) u_inverter (
      .enable_invert(enable_invert),
      .RGB          (RGB),
      .RGB_inverted (RGB_inverted)
  );

  grayscaler #(
      .bits_per_pixel(bits_per_pixel)
  ) u_grayscaler (
      .enable_grayscale(enable_grayscale),
      .RGB             (RGB_inverted),
      .RGB_grayscaled  (RGB_grayscaled)
  );

  rgb_filter #(
      .bits_per_pixel(bits_per_pixel)
  ) u_rgb_filter (
      .enable_red_filter  (enable_red_filter),
      .enable_blue_filter (enable_blue_filter),
      .enable_green_filter(enable_green_filter),
      .RGB                (RGB_grayscaled),
      .RGB_filtered       (RGB_filtered)
  );

  assign RGB_processed = RGB_filtered;

  // vga
  vga_adapter u_vga_adapter (
      .resetn     (resetn),
      .clock      (clock),
      .color      (RGB_processed),
      .x          (X),              // pixel location: left -> right
      .y          (Y),              //                 top  -> bottom
      .write      (vga_write),
      .VGA_R      (VGA_R),
      .VGA_G      (VGA_G),
      .VGA_B      (VGA_B),
      .VGA_HS     (VGA_HS),
      .VGA_VS     (VGA_VS),
      .VGA_BLANK_N(VGA_BLANK_N),
      .VGA_SYNC_N (VGA_SYNC_N),
      .VGA_CLK    (VGA_CLK)
  );
  defparam u_vga_adapter.RESOLUTION = RESOLUTION;
      defparam u_vga_adapter.COLOR_DEPTH = bits_per_pixel;

endmodule
