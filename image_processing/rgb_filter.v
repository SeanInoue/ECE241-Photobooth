module rgb_filter #(
    parameter bits_per_pixel = 9
) (
    input  wire                      enable_red_filter,
    input  wire                      enable_blue_filter,
    input  wire                      enable_green_filter,
    input  wire [bits_per_pixel-1:0] RGB,
    output reg  [bits_per_pixel-1:0] RGB_filtered
);
  parameter bits_per_channel = bits_per_pixel / 3;

  always @(*) begin
    RGB_filtered = RGB;
    if (enable_red_filter) begin
      RGB_filtered[bits_per_channel*2+:bits_per_channel] = 0;
    end
    if (enable_blue_filter) begin
      RGB_filtered[bits_per_channel*1+:bits_per_channel] = 0;
    end
    if (enable_green_filter) begin
      RGB_filtered[bits_per_channel*0+:bits_per_channel] = 0;
    end
  end
endmodule

