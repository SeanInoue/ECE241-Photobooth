module grayscaler #(
    parameter bits_per_pixel = 9
) (
    input  wire                      enable_grayscale,
    input  wire [bits_per_pixel-1:0] RGB,
    output reg  [bits_per_pixel-1:0] RGB_grayscaled
);
  parameter bits_per_channel = bits_per_pixel / 3;

  integer i, sum, average;
  always @(*) begin
    sum = 0;
    if (enable_grayscale) begin
      for (i = 0; i < 3; i = i + 1) begin
        sum = sum + RGB[bits_per_channel*i+:bits_per_channel];
      end
      average = (sum + 1) / 3;  // add 1 to round to nearest integer instead of truncating
      for (i = 0; i < 3; i = i + 1) begin
        RGB_grayscaled[bits_per_channel*i+:bits_per_channel] = average;
      end
    end else begin
      RGB_grayscaled = RGB;
    end
  end
endmodule

