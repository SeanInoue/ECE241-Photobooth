module uart_reciever_mock #(
    parameter bits_per_pixel = 9,
    parameter RESOLUTION = "640x480",
    parameter nX = (RESOLUTION == "640x480") ? 10 : ((RESOLUTION == "320x240") ? 9 : 8),
    parameter nY = (RESOLUTION == "640x480") ? 9 : ((RESOLUTION == "320x240") ? 8 : 7)
) (
    input wire uart,
    input wire clock,
    input wire resetn,
    output wire [bits_per_pixel-1:0] RGB,
    output wire [nX-1:0] X,
    output wire [nY-1:0] Y,
    output wire vga_write
);
  parameter bits_per_channel  = bits_per_pixel / 3;
  parameter max_channel_value = {bits_per_channel{1'b1}};

  //_C -> _COUNTER
  reg [nX-1:0] X_C;
  reg [nY-1:0] Y_C;
  reg [bits_per_pixel-1:0] COLOUR_C;

  wire halfSec;
  halfSecondCounter u_halfSecondCounter (
      .clock(clock),
      .resetn   (resetn),
      .halfSec (halfSec)
  );

  always @(posedge clock) begin
    if (!resetn) begin
      X_C <= 0;
      Y_C <= 0;
      COLOUR_C <= 0;
    end else begin
      X_C <= X_C + 1;
      if (X_C == {nX{1'b1}}) begin
        Y_C <= Y_C + 1;
      end
      if (halfSec) begin
        COLOUR_C <= COLOUR_C + 1;
      end
    end
  end

  assign X = X_C;
  assign Y = Y_C;
  assign RGB = COLOUR_C;
  assign vga_write = 1;

endmodule
