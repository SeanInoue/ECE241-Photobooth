
module line_buffer #(
    parameter RESOLUTION = "640x480",
    parameter bits_per_pixel = 9,
    parameter nX = (RESOLUTION == "640x480") ? 10 : ((RESOLUTION == "320x240") ? 9 : 8),
    parameter nY = (RESOLUTION == "640x480") ? 9 : ((RESOLUTION == "320x240") ? 8 : 7),
    parameter COLS = (RESOLUTION == "640x480") ? 640 : ((RESOLUTION == "320x240") ? 320 : 160),
    parameter ROWS = (RESOLUTION == "640x480") ? 480 : ((RESOLUTION == "320x240") ? 240 : 120)

) (

    input wire clock,
    input wire resetn,
    input wire [bits_per_pixel-1:0] sdram_rgb,
    input wire [nX-1:0] display_x,
    input wire [nY-1:0] display_y,
    input wire display_write,

    // 3x3 pixels window_row_col
    output wire [bits_per_pixel-1:0] window_0_0,
    output wire [bits_per_pixel-1:0] window_0_1,
    output wire [bits_per_pixel-1:0] window_0_2,
    output wire [bits_per_pixel-1:0] window_1_0,
    output wire [bits_per_pixel-1:0] window_1_1,
    output wire [bits_per_pixel-1:0] window_1_2,
    output wire [bits_per_pixel-1:0] window_2_0,
    output wire [bits_per_pixel-1:0] window_2_1,
    output wire [bits_per_pixel-1:0] window_2_2,

    // VGA
    output reg [nX-1:0] vga_x,
    output reg [nY-1:0] vga_y,
    output wire vga_write_real
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
    if (!resetn) begin
      buffer_x <= 0;
      buffer_y <= 0;
      buffer_ready <= 0;
      sdram_done <= 0;
    end else begin

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

      if (vga_write_real && vga_x == COLS - 1 && vga_y == ROWS - 1) begin
        sdram_done <= 0;
      end
    end
  end

  assign vga_write_real = display_write & buffer_ready || sdram_done;

  // counter
  always @(posedge clock) begin
    if (!resetn) begin
      vga_x <= 0;
      vga_y <= 0;
    end else if (vga_write_real) begin
      if (vga_x == COLS - 1) begin
        vga_x <= 0;
        if (vga_y == ROWS - 1) begin
          vga_y <= 0;
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
    if (display_write) begin
      if (display_x == 0 && display_y == 0) window_1[1] <= sdram_rgb;
      if (display_x == 1 && display_y == 0) window_1[2] <= sdram_rgb;
      if (display_x == 0 && display_y == 1) window_2[1] <= sdram_rgb;
      if (display_x == 1 && display_y == 1) window_2[2] <= sdram_rgb;
    end

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

  assign window_0_0 = window_0[0];
  assign window_0_1 = window_0[1];
  assign window_0_2 = window_0[2];
  assign window_1_0 = window_1[0];
  assign window_1_1 = window_1[1];
  assign window_1_2 = window_1[2];
  assign window_2_0 = window_2[0];
  assign window_2_1 = window_2[1];
  assign window_2_2 = window_2[2];

endmodule
