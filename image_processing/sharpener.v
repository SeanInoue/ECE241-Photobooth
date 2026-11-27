module sharpener #(
    parameter RESOLUTION = "640x480",
    parameter nX = (RESOLUTION == "640x480") ? 10 : ((RESOLUTION == "320x240") ? 9 : 8),
    parameter nY = (RESOLUTION == "640x480") ? 9 : ((RESOLUTION == "320x240") ? 8 : 7),
    parameter bits_per_pixel = 9,
    parameter bits_per_channel = bits_per_pixel / 3,
    parameter bpc_sum = 6,  // 3'b111 * d5 = 6
    parameter bpc = bits_per_channel
) (
    input wire enable_sharpen,
    input wire [bpc_sum*3-1:0] RGB_blurred,
    input wire [bits_per_pixel-1:0] window_1_1,

    output reg [bits_per_pixel-1:0] RGB_sharpened
);

  integer i;
  reg [(bpc_sum+1)*3-1:0] multiple;
  reg [(bpc_sum+1)*3-1:0] negative_blur;
  reg [(bpc_sum+1)*3-1:0] sum;

  always @(*) begin
    for (i = 0; i < 3; i = i + 1) begin
      negative_blur[(bpc_sum+1)*i+:(bpc_sum+1)] = {1'b1, ~RGB_blurred[bpc_sum*i+:bpc_sum]} + 1'b1;
      multiple[(bpc_sum+1)*i+:(bpc_sum+1)] = window_1_1[bpc*i+:bpc] * 6;
      sum[(bpc_sum+1)*i+:(bpc_sum+1)] = multiple[(bpc_sum+1)*i+:(bpc_sum+1)] + negative_blur[(bpc_sum+1)*i+:(bpc_sum+1)];
    end

    if (enable_sharpen) begin
      for (i = 0; i < 3; i = i + 1) begin
        if (sum[(bpc_sum+1)*(i+1)-1]) begin  //if negative
          RGB_sharpened[bpc*i+:bpc] = 0;
        end else if (sum[(bpc_sum+1)*i+:(bpc_sum+1)-1] > 3'b111) begin  //if greater than max
          RGB_sharpened[bpc*i+:bpc] = 3'b111;
        end else begin
          RGB_sharpened[bpc*i+:bpc] = sum[(bpc_sum+1)*i+:(bpc_sum+1)];
        end
      end
    end else begin
      for (i = 0; i < 3; i = i + 1) begin
        RGB_sharpened[bpc*i+:bpc] = RGB_blurred[bpc_sum*i+:bpc_sum];
      end
    end
  end

endmodule
