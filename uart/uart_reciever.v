module uart_reciever #(
    parameter BAUD_RATE = 19200,
    parameter RESOLUTION = "640x480",
    parameter bits_per_pixel = 9,
    parameter nX = (RESOLUTION == "640x480") ? 10 : ((RESOLUTION == "320x240") ? 9 : 8),
    parameter nY = (RESOLUTION == "640x480") ? 9 : ((RESOLUTION == "320x240") ? 8 : 7)
) (
    input uart,
    input CLOCK_50,
    output reg [bits_per_pixel-1:0] RGB, // write from shift reg to these when shift reg full. this only adds 1 constant clock 50 delay
    output reg [nX-1:0] X,
    output reg [nY-1:0] Y,
    output reg vga_write
);
  parameter bits_per_uart_frame = 8;// since uart can only send 5-9 data bits at a time, use counter here in receiver to count when shift register is full

  wire start;  // start bit logic

  wire enable_shift;
  reg [bits_per_pixel+nX+nY-1:0] SHIFT_REG;  // shift left to right
  always @(posedge CLOCK_50) begin
    if (enable_shift) SHIFT_REG <= {uart, SHIFT_REG[bits_per_pixel+nX+nY-1:1]};
  end
endmodule
