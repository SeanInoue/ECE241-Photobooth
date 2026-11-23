`timescale 1ns / 1ps

module tb ();
  parameter CLOCK_PERIOD = 10;

  reg CLOCK_50;
  reg resetn;
  reg uart_read;  // should be a pulse of 1 clk cycle
  reg [4:0] enable_i;
  wire [4:0] enable_o;

  initial begin
    CLOCK_50 <= 1'b0;
  end
  always @(*) begin : Clock_Generator
    #((CLOCK_PERIOD) / 2) CLOCK_50 <= ~CLOCK_50;
  end

  initial begin
    resetn <= 1'b0;
    #10 resetn <= 1'b1;
  end

  initial begin
    enable_i  <= 0;
    uart_read <= 0;

    // test no uart_read
    #10 enable_i <= 5'b10110;
    #10 enable_i <= 5'b01111;
    #30;

    // test uart_read
    #10 uart_read <= 1;
    #10 uart_read <= 0;
    #10 uart_read <= 1;
    #10 uart_read <= 0;
    #10 uart_read <= 1;
    #10 uart_read <= 0;


    // test uart_read not off
    #10 enable_i <= 5'b00000;
    #10 uart_read <= 1;
    #10 uart_read <= 0;
    #20 enable_i <= 5'b11000;
    #10 uart_read <= 1;
    #30;

    // test resetn
    #10 resetn <= 0;
    #10 resetn <= 1;
    #10 uart_read <= 0;
    #10 resetn <= 0;
    #10 resetn <= 1;

    #10;
  end

  filter_enable_reg #(
      .num_pixels(3)
  ) u_filter_enable_reg (
      .clock    (CLOCK_50),
      .resetn   (resetn),
      .uart_read(uart_read),
      .enable_i (enable_i),
      .enable_o (enable_o)
  );

endmodule
