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
  wire [nX-1:0] uart_x, display_x;
  wire [nY-1:0] uart_y, display_y;
  wire uart_pixel_valid, display_write;
  wire [4:0] frame_effects;

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

  reg [bits_per_pixel-1:0] line_buf0[0:COLS-1];
  reg [bits_per_pixel-1:0] line_buf1[0:COLS-1];
  reg [bits_per_pixel-1:0] line_buf2[0:COLS-1];
  reg [bits_per_pixel-1:0] line_buf3[0:COLS-1];

  reg [8:0] buffer_x;
  reg [1:0] buffer_y;
  reg buffer_ready;
  reg sdram_done;

  always @(posedge clock) begin
    if (display_write) begin
      // counter logic
      if (buffer_x == COLS - 1) begin
        buffer_x <= 0;
        if (buffer_y == 3) begin
          buffer_y <= 0;
        end else begin
          buffer_y <= buffer_y + 1;
        end
      end else begin
        buffer_x <= buffer_x + 1;
      end

      // write to buffer
      case (buffer_y)
        2'd0: line_buf0[buffer_x] <= sdram_rgb;
        2'd1: line_buf1[buffer_x] <= sdram_rgb;
        2'd2: line_buf2[buffer_x] <= sdram_rgb;
        2'd3: line_buf3[buffer_x] <= sdram_rgb;
        default: ;
      endcase
    end

    if (display_y == 1 && display_x == 1) begin
      buffer_ready <= 1;
    end else if (display_y == ROWS - 1 && display_x == COLS - 1) begin
      buffer_ready <= 0;
      sdram_done   <= 1;
    end
  end

  wire vga_write_real = display_write & buffer_ready || sdram_done; //TODO or buffer full and display_write off

  // counter
  reg [nX-1:0] vga_x;
  reg [nY-1:0] vga_y;
  always @(posedge clock) begin
    if (vga_write_real) begin
      if (vga_x == COLS - 1) begin
        vga_x <= 0;
        if (vga_y == ROWS - 1) begin
          vga_y <= 0;
          sdram_done <= 1'b0;
        end else begin
          vga_y <= vga_y + 1'b1;
        end
      end else begin
        vga_x <= vga_x + 1'b1;
      end
    end
  end

  reg [bits_per_pixel-1:0] window_0[0:2];
  reg [bits_per_pixel-1:0] window_1[0:2];
  reg [bits_per_pixel-1:0] window_2[0:2];

  always @(posedge clock) begin
    if (display_x == 0 && display_y == 0) window_1[1] <= sdram_rgb;
    if (display_x == 1 && display_y == 0) window_1[2] <= sdram_rgb;
    if (display_x == 0 && display_y == 1) window_2[1] <= sdram_rgb;
    if (display_x == 1 && display_y == 1) window_2[2] <= sdram_rgb;

    if (vga_write_real) begin
      if (vga_y < ROWS - 2 || vga_y == ROWS - 2 && vga_x < COLS - 2) begin
        case (buffer_y)
          2'd0: begin
            window_0[2] <= line_buf2[buffer_x];
            window_1[2] <= line_buf3[buffer_x];
            window_2[2] <= sdram_rgb;
          end
          2'd1: begin
            window_0[2] <= line_buf3[buffer_x];
            window_1[2] <= line_buf0[buffer_x];
            window_2[2] <= sdram_rgb;
          end
          2'd2: begin
            window_0[2] <= line_buf0[buffer_x];
            window_1[2] <= line_buf1[buffer_x];
            window_2[2] <= sdram_rgb;
          end
          2'd3: begin
            window_0[2] <= line_buf1[buffer_x];
            window_1[2] <= line_buf2[buffer_x];
            window_2[2] <= sdram_rgb;
          end
          default: ;
        endcase
      end else if (vga_y == ROWS - 1 && vga_x < COLS - 2) begin //last row up to r away from right edge
        case (buffer_y)
          2'd0: begin
            window_0[2] <= line_buf2[vga_x+2];
            window_1[2] <= line_buf3[vga_x+2];
          end
          2'd1: begin
            window_0[2] <= line_buf3[vga_x+2];
            window_1[2] <= line_buf0[vga_x+2];
          end
          2'd2: begin
            window_0[2] <= line_buf0[vga_x+2];
            window_1[2] <= line_buf1[vga_x+2];
          end
          2'd3: begin
            window_0[2] <= line_buf1[vga_x+2];
            window_1[2] <= line_buf2[vga_x+2];
          end
          default: ;
        endcase
      end else if (vga_x >= COLS - 2) begin //second last row up within 2 away from the right edge. last row doesnt matter here
        case (buffer_y)
          2'd0: begin
            window_0[2] <= line_buf2[vga_x+2-COLS];
            window_1[2] <= line_buf3[vga_x+2-COLS];
          end
          2'd1: begin
            window_0[2] <= line_buf3[vga_x+2-COLS];
            window_1[2] <= line_buf0[vga_x+2-COLS];
          end
          2'd2: begin
            window_0[2] <= line_buf0[vga_x+2-COLS];
            window_1[2] <= line_buf1[vga_x+2-COLS];
          end
          2'd3: begin
            window_0[2] <= line_buf1[vga_x+2-COLS];
            window_1[2] <= line_buf2[vga_x+2-COLS];
          end
          default: ;
        endcase
      end

      window_0[0] <= window_0[1];
      window_1[0] <= window_1[1];
      window_2[0] <= window_2[1];

      window_0[1] <= window_0[2];
      window_1[1] <= window_1[2];
      window_2[1] <= window_2[2];
    end
  end

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
