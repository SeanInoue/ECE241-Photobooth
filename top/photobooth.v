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

    output wire [24:0] mem_address,
    output wire [15:0] mem_writedata,
    output wire mem_write,
    output wire mem_read,
    input wire [15:0] mem_readdata,
    input wire mem_waitrequest,
    input wire mem_readdatavalid,

    output wire [7:0] VGA_R,
    output wire [7:0] VGA_G,
    output wire [7:0] VGA_B,
    output wire       VGA_HS,
    output wire       VGA_VS,
    output wire       VGA_BLANK_N,
    output wire       VGA_SYNC_N,
    output wire       VGA_CLK
);

  localparam COLS = (RESOLUTION == "640x480") ? 640 : ((RESOLUTION == "320x240") ? 320 : 160);
  localparam ROWS = (RESOLUTION == "640x480") ? 480 : ((RESOLUTION == "320x240") ? 240 : 120);

  wire [bits_per_pixel-1:0] uart_rgb, RGB_inverted, RGB_grayscaled, RGB_filtered;
  wire [bits_per_pixel-1:0] sdram_rgb = mem_readdata;
  wire [nX-1:0] uart_x, display_x, vga_x;
  wire [nY-1:0] uart_y, display_y, vga_y;
  wire uart_pixel_valid, display_write, vga_write_real;
  wire [4:0] frame_effects;

  wire [bits_per_pixel-1:0] window_0_0;
  wire [bits_per_pixel-1:0] window_0_1;
  wire [bits_per_pixel-1:0] window_0_2;
  wire [bits_per_pixel-1:0] window_1_0;
  wire [bits_per_pixel-1:0] window_1_1;
  wire [bits_per_pixel-1:0] window_1_2;
  wire [bits_per_pixel-1:0] window_2_0;
  wire [bits_per_pixel-1:0] window_2_1;
  wire [bits_per_pixel-1:0] window_2_2;

  // uart
  uart_receiver #(
      .RESOLUTION(RESOLUTION),
      .bits_per_pixel(bits_per_pixel),
      .nX(nX),
      .nY(nY)
  ) u_uart_receiver (
      .uart     (uart),
      .clock    (clock),
      .resetn   (resetn),
      .RGB      (uart_rgb),
      .X        (uart_x),
      .Y        (uart_y),
      .vga_write(uart_pixel_valid)
  );

  sdram_frame_buffer #(
      .COLS(COLS),
      .ROWS(ROWS),
      .nX(nX),
      .nY(nY),
      .bits_per_pixel(bits_per_pixel)
  ) u_frame_buffer (
      .clock(clock),
      .resetn(resetn),
      .pixel_valid(uart_pixel_valid),
      .pixel(uart_rgb),
      .pixel_x(uart_x),
      .pixel_y(uart_y),
      .switches({
        enable_red_filter, enable_green_filter, enable_blue_filter, enable_grayscale, enable_invert
      }),
      .frame_effects(frame_effects),
      .mem_address(mem_address),
      .mem_writedata(mem_writedata),
      .mem_write(mem_write),
      .mem_read(mem_read),
      .mem_waitrequest(mem_waitrequest),
      .mem_readdatavalid(mem_readdatavalid),
      .display_x(display_x),
      .display_y(display_y),
      .display_write(display_write)
  );

  line_buffer #(
      .RESOLUTION(RESOLUTION),
      .bits_per_pixel(bits_per_pixel),
      .nX(nX),
      .nY(nY),
      .COLS(COLS),
      .ROWS(ROWS)
  ) u_line_buffer (
      .clock         (clock),
      .sdram_rgb     (sdram_rgb),
      .display_x     (display_x),
      .display_y     (display_y),
      .display_write (display_write),
      .window_0_0    (window_0_0),
      .window_0_1    (window_0_1),
      .window_0_2    (window_0_2),
      .window_1_0    (window_1_0),
      .window_1_1    (window_1_1),
      .window_1_2    (window_1_2),
      .window_2_0    (window_2_0),
      .window_2_1    (window_2_1),
      .window_2_2    (window_2_2),
      .vga_x         (vga_x),
      .vga_y         (vga_y),
      .vga_write_real(vga_write_real)
  );


  //   blurrer u_blurrer (.window(window));

  // image processors
  inverter #(
      .bits_per_pixel(bits_per_pixel)
  ) u_inverter (
      .enable_invert(frame_effects[0]),  // could use filter_enable_reg module as well
      .RGB          (sdram_rgb),
      .RGB_inverted (RGB_inverted)
  );

  grayscaler #(
      .bits_per_pixel(bits_per_pixel)
  ) u_grayscaler (
      .enable_grayscale(frame_effects[1]),
      .RGB             (RGB_inverted),
      .RGB_grayscaled  (RGB_grayscaled)
  );

  rgb_filter #(
      .bits_per_pixel(bits_per_pixel)
  ) u_rgb_filter (
      .enable_red_filter  (frame_effects[4]),
      .enable_blue_filter (frame_effects[2]),
      .enable_green_filter(frame_effects[3]),
      .RGB                (RGB_grayscaled),
      .RGB_filtered       (RGB_filtered)
  );

  // vga
  vga_adapter u_vga_adapter (
      .resetn     (resetn),
      .clock      (clock),
      .color      (RGB_filtered),
      .x          (vga_x),
      .y          (vga_y),
      .write      (vga_write_real),
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
