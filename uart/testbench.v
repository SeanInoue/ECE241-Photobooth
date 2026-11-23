`timescale 1ns / 1ps

// Run from the uart directory in ModelSim:
//   vlib work
//   vlog uart_rx_byte.v uart_reciever.v testbench.v
//   vsim work.testbench
//   add wave sim:/testbench/clock sim:/testbench/resetn sim:/testbench/test_number
//   add wave sim:/testbench/uart sim:/testbench/data sim:/testbench/valid
//   add wave sim:/testbench/RGB sim:/testbench/X sim:/testbench/Y sim:/testbench/vga_write
//   add wave sim:/testbench/dut_pixels/byte_data sim:/testbench/dut_pixels/byte_valid
//   add wave sim:/testbench/dut_pixels/n_bits
//   run -all
//
// Real UART timing: 50 MHz clock, 2 Mbaud, 8N1 (LSB first).
// Uses the supported 160 x 120 resolution to check row and frame wrapping.
module testbench;
  localparam CLOCK_PERIOD = 20;
  localparam CLKS_PER_BIT = 17;
  localparam BIT_PERIOD = CLOCK_PERIOD * CLKS_PER_BIT;
  localparam COLS = 160;
  localparam ROWS = 120;
  localparam PIXEL_COUNT = COLS * ROWS + 8;

  reg clock = 0;
  reg resetn = 0;
  reg uart = 1;
  wire [7:0] data;
  wire valid;
  wire [8:0] RGB;
  wire [7:0] X;
  wire [6:0] Y;
  wire vga_write;

  // Watch these in the waveform to identify each demonstration.
  reg [2:0] test_number = 0;
  reg check_pixels = 0;
  integer errors = 0;
  integer expected_byte_count = 0;
  integer received_byte_count = 0;
  integer expected_pixel_count = 0;
  integer received_pixel_count = 0;
  reg [7:0] expected_bytes [0:32767];
  reg [8:0] expected_pixels [0:PIXEL_COUNT-1];
  reg previous_valid = 0;
  reg previous_write = 0;
  reg [71:0] packed_pixels;
  integer block_index;
  integer pixel_index;
  integer byte_index;

  always #(CLOCK_PERIOD / 2) clock = ~clock;

  uart_rx_byte #(.CLKS_PER_BIT(CLKS_PER_BIT)) dut_byte (
      .clock(clock), .resetn(resetn), .rx(uart),
      .data(data), .valid(valid)
  );

  uart_reciever #(
      .CLOCK_FREQUENCY(50_000_000), .BAUD_RATE(3_000_000),
      .RESOLUTION("160x120")
  ) dut_pixels (
      .clock(clock), .resetn(resetn), .uart(uart),
      .RGB(RGB), .X(X), .Y(Y), .vga_write(vga_write)
  );


  // Sample after nonblocking assignments have updated the DUT outputs.
  always @(posedge clock) begin
    #1;
    if (!resetn) begin
      received_byte_count = 0;
      received_pixel_count = 0;
      previous_valid = 0;
      previous_write = 0;
      if (valid !== 1'b0 || vga_write !== 1'b0) begin
        $display("FAIL: valid/write must be low during reset");
        errors = errors + 1;
      end
    end else begin
      if (valid === 1'b1) begin
        if (previous_valid) begin
          $display("FAIL: valid lasted more than one clock");
          errors = errors + 1;
        end
        if (received_byte_count >= expected_byte_count) begin
          $display("FAIL: unexpected byte %h", data);
          errors = errors + 1;
        end else if (data !== expected_bytes[received_byte_count]) begin
          $display("FAIL: byte %0d expected %h, got %h",
              received_byte_count, expected_bytes[received_byte_count], data);
          errors = errors + 1;
        end
        received_byte_count = received_byte_count + 1;
      end
      if (check_pixels && vga_write === 1'b1) begin
        if (previous_write) begin
          $display("FAIL: vga_write lasted more than one clock");
          errors = errors + 1;
        end
        if (received_pixel_count >= expected_pixel_count) begin
          $display("FAIL: unexpected pixel %h", RGB);
          errors = errors + 1;
        end else if (RGB !== expected_pixels[received_pixel_count] ||
            X !== (received_pixel_count % COLS) ||
            Y !== ((received_pixel_count / COLS) % ROWS)) begin
          $display("FAIL: pixel %0d expected RGB=%h X=%0d Y=%0d; got RGB=%h X=%0d Y=%0d",
              received_pixel_count, expected_pixels[received_pixel_count],
              received_pixel_count % COLS, (received_pixel_count / COLS) % ROWS,
              RGB, X, Y);
          errors = errors + 1;
        end else if (received_pixel_count < 8 || X == 0 || X == COLS - 1) begin
          $display("Pixel %0d: RGB=%h X=%0d Y=%0d OK",
              received_pixel_count, RGB, X, Y);
        end
        received_pixel_count = received_pixel_count + 1;
      end
      previous_valid = valid;
      previous_write = vga_write;
    end
  end

  task reset_receiver;
    begin
      @(negedge clock);
      resetn = 0;
      uart = 1;
      expected_byte_count = 0;
      expected_pixel_count = 0;
      repeat (5) @(negedge clock);
      resetn = 1;
      #(2 * BIT_PERIOD);
    end
  endtask

  task send_byte;
    input [7:0] value;
    input good_stop;
    integer bit_number;
    begin
      if (good_stop) begin
        expected_bytes[expected_byte_count] = value;
        expected_byte_count = expected_byte_count + 1;
      end
      // Drive between sampling edges, with a one-clock idle gap between frames.
      @(negedge clock);
      uart = 0;
      #(BIT_PERIOD);
      for (bit_number = 0; bit_number < 8; bit_number = bit_number + 1) begin
        uart = value[bit_number];
        #(BIT_PERIOD);
      end
      uart = good_stop;
      #(BIT_PERIOD);
      uart = 1;
    end
  endtask

  task check_counts;
    begin
      #(2 * BIT_PERIOD);
      if (received_byte_count != expected_byte_count) begin
        $display("FAIL: expected %0d bytes, received %0d",
            expected_byte_count, received_byte_count);
        errors = errors + 1;
      end
      if (check_pixels && received_pixel_count != expected_pixel_count) begin
        $display("FAIL: expected %0d pixels, received %0d",
            expected_pixel_count, received_pixel_count);
        errors = errors + 1;
      end
    end
  endtask

  initial begin
    reset_receiver;
    test_number = 1;
    $display("TEST 1: receive A5, 00, FF, 3C with one-clock valid pulses");
    send_byte(8'hA5, 1);
    send_byte(8'h00, 1);
    send_byte(8'hFF, 1);
    send_byte(8'h3C, 1);
    check_counts;

    test_number = 2;
    $display("TEST 2: reject a low stop bit and recover for the next byte");
    send_byte(8'hFF, 0);
    #(2 * BIT_PERIOD);
    check_counts;
    send_byte(8'h5A, 1);
    check_counts;

    test_number = 3;
    $display("TEST 3: reset clears a partial pixel (one byte buffered)");
    reset_receiver;
    send_byte(8'hD3, 1);
    check_counts;
    if (received_pixel_count != 0 || dut_pixels.n_bits !== 4'd8) begin
      $display("FAIL: first byte should buffer eight bits without a pixel");
      errors = errors + 1;
    end
    reset_receiver;
    if (dut_pixels.n_bits !== 4'd0 || dut_pixels.X_C !== 0 || dut_pixels.Y_C !== 0) begin
      $display("FAIL: reset did not clear unpacking state and coordinates");
      errors = errors + 1;
    end

    test_number = 4;
    check_pixels = 1;
    $display("TEST 4: unpack a 160x120 frame plus eight pixels; verify row/frame wrapping");
    // Send a complete frame plus eight pixels. The extra pixels must
    // restart at (0,0). First group includes black, white and primary colours.
    expected_pixels[0] = 9'h000;
    expected_pixels[1] = 9'h1FF;
    expected_pixels[2] = 9'h1C0;
    expected_pixels[3] = 9'h038;
    expected_pixels[4] = 9'h007;
    expected_pixels[5] = 9'h053;
    expected_pixels[6] = 9'h155;
    expected_pixels[7] = 9'h0AA;
    for (pixel_index = 8; pixel_index < PIXEL_COUNT; pixel_index = pixel_index + 1)
      expected_pixels[pixel_index] = (pixel_index * 37 + 11) & 9'h1FF;
    expected_pixel_count = PIXEL_COUNT;

    for (block_index = 0; block_index < PIXEL_COUNT / 8; block_index = block_index + 1) begin
      packed_pixels = 0;
      for (pixel_index = 0; pixel_index < 8; pixel_index = pixel_index + 1)
        packed_pixels = {packed_pixels[62:0], expected_pixels[block_index * 8 + pixel_index]};
      // Pixel stream is MSB first; each UART byte is transmitted LSB first.
      for (byte_index = 0; byte_index < 9; byte_index = byte_index + 1)
        send_byte(packed_pixels[71 - byte_index * 8 -: 8], 1);
    end
    check_counts;

    if (errors == 0)
      $display("PASS: all UART tests passed");
    else
      $fatal(1, "FAIL: %0d UART checks failed", errors);
    $finish;
  end

  initial begin
    #200_000_000;
    $fatal(1, "FAIL: simulation timed out");
  end
endmodule

