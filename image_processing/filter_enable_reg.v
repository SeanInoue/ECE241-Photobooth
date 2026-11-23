module filter_enable_reg #(
    parameter RESOLUTION = "640x480",
    parameter nX = (RESOLUTION == "640x480") ? 10 : ((RESOLUTION == "320x240") ? 9 : 8),
    parameter nY = (RESOLUTION == "640x480") ? 9 : ((RESOLUTION == "320x240") ? 8 : 7),
    parameter num_pixels = 307_200
) (
    input wire clock,
    input wire resetn,
    input wire uart_read,  // should be a pulse of 1 clk cycle
    input wire [4:0] enable_i,
    output reg [4:0] enable_o
);

  reg [nX+nY-1:0] counter;

  always @(posedge clock) begin
    if (!resetn) begin
      counter  <= 0;
      enable_o <= 0;
    end else begin
      if (uart_read) begin
        if (counter == num_pixels - 1) begin
          enable_o <= enable_i;
          counter  <= 0;
        end else begin
          counter <= counter + 1;
        end
      end
    end
  end

endmodule
