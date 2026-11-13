module inverter #(
    parameter bits_per_pixel = 9
) (
    input  wire [bits_per_pixel-1:0] RGB,
    output reg  [bits_per_pixel-1:0] RGB_inverted
);
  parameter bits_per_channel  = bits_per_pixel / 3;
  parameter max_channel_value = {bits_per_channel{1'b1}};

  integer i;
  always @(*) begin
    for (i = 0; i < 3; i = i + 1) begin
      RGB_inverted[bits_per_channel*i +: bits_per_channel] = max_channel_value - RGB[bits_per_channel*i +: bits_per_channel];
    end
  end
endmodule
