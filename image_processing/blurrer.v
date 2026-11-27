module blurrer #(
    parameter RESOLUTION = "640x480",
    parameter nX = (RESOLUTION == "640x480") ? 10 : ((RESOLUTION == "320x240") ? 9 : 8),
    parameter nY = (RESOLUTION == "640x480") ? 9 : ((RESOLUTION == "320x240") ? 8 : 7),
    parameter bits_per_pixel = 9,
    parameter bits_per_channel = bits_per_pixel / 3,
    parameter bpc_sum = 6,  // 3'b111 * d5 = 6
    parameter bpc = bits_per_channel

) (
    input wire clock,
    input wire enable_sharpen,
    input wire enable_blur,
    input wire [bits_per_pixel-1:0] window_0_0,
    input wire [bits_per_pixel-1:0] window_0_0,
    input wire [bits_per_pixel-1:0] window_0_1,
    input wire [bits_per_pixel-1:0] window_0_2,
    input wire [bits_per_pixel-1:0] window_1_0,
    input wire [bits_per_pixel-1:0] window_1_1,
    input wire [bits_per_pixel-1:0] window_1_2,
    input wire [bits_per_pixel-1:0] window_2_0,
    input wire [bits_per_pixel-1:0] window_2_1,
    input wire [bits_per_pixel-1:0] window_2_2,

    output reg [bpc_sum*3-1:0] RGB_blurred
);

  integer i;
  reg [bpc_sum*3-1:0] sum;  // 6*3=18

  always @(*) begin
    if (enable_blur || enable_sharpen) begin
      for (i = 0; i < 3; i = i + 1) begin  //todo: add corners properly
        sum[bpc_sum*i +: bpc_sum] = window_0_1[bpc*i +: bpc] + window_1_0[bpc*i +: bpc] + window_1_1[bpc*i +: bpc] + window_1_2[bpc*i +: bpc] + window_2_1[bpc*i +: bpc];
      end
    end else begin
      for (i = 0; i < 3; i = i + 1) begin
        sum[bpc_sum*i+:bpc_sum] = window_1_1;
      end
    end
  end

  always @(*) begin
    if (enable_blur && !enable_sharpen) begin
      for (i = 0; i < 3; i = i + 1) begin
        RGB_blurred[bpc_sum*i+:bpc_sum] = (sum[bpc_sum*i+:bpc_sum] + 2) / 5;
      end
    end else begin
      RGB_blurred = sum;
    end
  end

endmodule
