`timescale 1ns / 1ps

module sdram_frame_buffer_tb;
  localparam COLS = 3;
  localparam ROWS = 2;
  localparam FRAME_WORDS = COLS * ROWS;
  localparam READ_LATENCY = 3;

  reg clock = 0;
  always #10 clock = ~clock;

  reg resetn = 0;
  reg pixel_valid = 0;
  reg [8:0] pixel = 0;
  reg [1:0] pixel_x = 0;
  reg pixel_y = 0;

  wire [24:0] mem_address;
  wire [15:0] mem_writedata, mem_readdata;
  wire mem_write, mem_read, mem_waitrequest, mem_readdatavalid;
  wire [1:0] display_x;
  wire display_y, display_write;

  sdram_frame_buffer #(
      .COLS(COLS), .ROWS(ROWS), .nX(2), .nY(1), .fifo_address_bits(3)
  ) dut (
      .clock(clock),
      .resetn(resetn),
      .pixel_valid(pixel_valid),
      .pixel(pixel),
      .pixel_x(pixel_x),
      .pixel_y(pixel_y),
      .switches(5'b0),
      .frame_effects(),
      .mem_address(mem_address),
      .mem_writedata(mem_writedata),
      .mem_write(mem_write),
      .mem_read(mem_read),
      .mem_waitrequest(mem_waitrequest),
      .mem_readdatavalid(mem_readdatavalid),
      .display_x(display_x),
      .display_y(display_y),
      .display_write(display_write)
  );

  // Model the controller's request/response interface with six memory words.
  reg [15:0] memory [0:FRAME_WORDS-1];
  reg [1:0] write_stall_cycles;
  reg [READ_LATENCY-1:0] read_valid_pipeline;
  reg [15:0] read_data_pipeline [0:READ_LATENCY-1];

  assign mem_waitrequest = mem_write && (write_stall_cycles != 0);
  assign mem_readdatavalid = read_valid_pipeline[READ_LATENCY-1];
  assign mem_readdata = read_data_pipeline[READ_LATENCY-1];
  wire write_accepted = mem_write && !mem_waitrequest;
  wire read_accepted = mem_read && !mem_waitrequest;

  always @(posedge clock) begin
    if (!resetn) begin
      write_stall_cycles <= 2;
      read_valid_pipeline <= 0;
    end else begin
      if (mem_write && mem_waitrequest)
        write_stall_cycles <= write_stall_cycles - 1'b1;
      if (write_accepted)
        memory[mem_address] <= mem_writedata;

      read_valid_pipeline <= {read_valid_pipeline[READ_LATENCY-2:0], read_accepted};
      if (read_accepted)
        read_data_pipeline[0] <= memory[mem_address];
      for (integer stage = 1; stage < READ_LATENCY; stage = stage + 1)
        read_data_pipeline[stage] <= read_data_pipeline[stage-1];
    end
  end

  function automatic [8:0] pixel_value(input integer index);
    pixel_value = 9'h011 * (index + 1);
  endfunction

  integer writes_seen = 0;
  integer reads_seen = 0;
  integer pixels_seen = 0;
  integer stalls_seen = 0;
  reg test_passed = 0;

  always @(posedge clock) begin
    if (resetn) begin
      if (mem_write && mem_waitrequest) begin
        if (mem_address !== 25'd0 || mem_writedata !== 16'h0011)
          $fatal(1, "The first write changed while stalled");
        stalls_seen <= stalls_seen + 1;
      end
      if (write_accepted) begin
        if (writes_seen >= FRAME_WORDS || mem_address !== writes_seen ||
            mem_writedata !== {7'b0, pixel_value(writes_seen)})
          $fatal(1, "Unexpected write %0d at address %0d with data %h",
                 writes_seen, mem_address, mem_writedata);
        writes_seen <= writes_seen + 1;
      end
      if (read_accepted) begin
        if (writes_seen != FRAME_WORDS || reads_seen >= FRAME_WORDS ||
            mem_address !== reads_seen)
          $fatal(1, "Unexpected read %0d at address %0d", reads_seen, mem_address);
        reads_seen <= reads_seen + 1;
      end
      if (display_write !== mem_readdatavalid)
        $fatal(1, "Display write must match the read response valid signal");
      if (display_write) begin
        if (pixels_seen >= FRAME_WORDS || mem_readdata !== {7'b0, pixel_value(pixels_seen)} ||
            display_x !== (pixels_seen % COLS) || display_y !== (pixels_seen / COLS))
          $fatal(1, "Unexpected display pixel %0d at (%0d, %0d) with data %h",
                 pixels_seen, display_x, display_y, mem_readdata);
        pixels_seen <= pixels_seen + 1;
      end
    end
  end

  initial begin
    repeat (2) @(negedge clock);
    resetn = 1;

    for (integer index = 0; index < FRAME_WORDS; index = index + 1) begin
      pixel_valid = 1;
      pixel = pixel_value(index);
      pixel_x = index % COLS;
      pixel_y = index / COLS;
      @(negedge clock);
    end
    pixel_valid = 0;

    wait (pixels_seen == FRAME_WORDS);
    repeat (2) @(negedge clock);
    if (writes_seen != FRAME_WORDS || reads_seen != FRAME_WORDS || stalls_seen != 2 ||
        dut.copying !== 1'b0)
      $fatal(1, "The frame did not complete with the expected request counts and stalls");
    test_passed = 1;
    $display("PASS: all six pixels were written, read back, and displayed in order.");
    $finish;
  end

  initial begin
    #1000;
    $fatal(1, "Timed out after %0d writes, %0d reads, and %0d displayed pixels",
           writes_seen, reads_seen, pixels_seen);
  end
endmodule
