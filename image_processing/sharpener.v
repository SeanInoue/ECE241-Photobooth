module sharpener #(
    parameter RESOLUTION = "640x480",
    parameter nX = (RESOLUTION == "640x480") ? 10 : ((RESOLUTION == "320x240") ? 9 : 8),
    parameter nY = (RESOLUTION == "640x480") ? 9 : ((RESOLUTION == "320x240") ? 8 : 7),
    parameter num_pixels = 307_200,
    parameter bits_per_pixel = 9
) (
    input wire clock,
    input wire resetn,
    input wire enable_sharpen,
    input wire [15:0] mem_readdata,
    input reg [nX-1:0] X,
    input reg [nY-1:0] Y,
    input wire [bits_per_pixel-1:0] RGB,
    output reg [bits_per_pixel-1:0] RGB_sharpened
);
  parameter ROWS = 4;    //actually 3
  parameter COLS = 480;
  reg [bits_per_pixel-1:0] buffer[0:ROWS-1][0:COLS-1];

  wire [bits_per_pixel-1:0] sdram_rgb = mem_readdata;

  reg [nX-1:0] X_C;
  reg [nY-1:0] Y_C;

  //sdram -> buffer including second row first columns
  //TODO: add start condition, count backwards from start of real vga write
  always @(posedge clock) begin

  end

  //sdram -> buffer rest of the rows at the same time as real vga_write

  //buffer shift last row to first when done convolving last row

  //

  always @(posedge clock) begin

  end

endmodule
