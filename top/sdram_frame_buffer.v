module sdram_frame_buffer #(
    parameter COLS = 640,
    parameter ROWS = 480,
    parameter nX = 10,
    parameter nY = 9,
    parameter bits_per_pixel = 9,
    parameter fifo_address_bits = 14
) (
    input wire clock,
    input wire resetn,
    input wire pixel_valid,
    input wire [bits_per_pixel-1:0] pixel,
    input wire [nX-1:0] pixel_x,
    input wire [nY-1:0] pixel_y,
    input wire [4:0] switches,
    output reg [4:0] frame_effects,

    output wire [24:0] mem_address,
    output wire [15:0] mem_writedata,
    output wire mem_write,
    output wire mem_read,
    input wire mem_waitrequest,
    input wire mem_readdatavalid,

    output reg [nX-1:0] display_x,
    output reg [nY-1:0] display_y,
    output wire display_write
);
  localparam FIFO_DEPTH = 1 << fifo_address_bits;
  localparam FRAME_WORDS = COLS * ROWS;
  localparam FRAME_ADDRESS_BITS = (FRAME_WORDS > 1) ? $clog2(FRAME_WORDS) : 1;

  wire first_pixel = (pixel_x == 0) && (pixel_y == 0);
  wire last_pixel = (pixel_x == COLS - 1) && (pixel_y == ROWS - 1);

  // Synchronous read and a holding register keep the head stable during SDRAM stalls.
  reg [bits_per_pixel+1:0] fifo [0:FIFO_DEPTH-1];
  reg [fifo_address_bits-1:0] fifo_write_address;
  reg [fifo_address_bits-1:0] fifo_read_address;
  reg [fifo_address_bits:0] fifo_used;
  reg [bits_per_pixel+1:0] fifo_head;
  reg fifo_head_valid;
  reg dropping_frame;

  wire write_accepted = mem_write && !mem_waitrequest;
  wire fifo_push = resetn && pixel_valid && (fifo_used < FIFO_DEPTH)
                   && (!dropping_frame || first_pixel);
  wire fifo_fetch = resetn && (fifo_used != 0) && (!fifo_head_valid || write_accepted);
  wire head_first = fifo_head[bits_per_pixel+1];
  wire head_last = fifo_head[bits_per_pixel];

  always @(posedge clock) begin
    if (fifo_push)
      fifo[fifo_write_address] <= {first_pixel, last_pixel, pixel};
    if (fifo_fetch)
      fifo_head <= fifo[fifo_read_address];
  end

  always @(posedge clock) begin
    if (!resetn) begin
      fifo_write_address <= 0;
      fifo_read_address <= 0;
      fifo_used <= 0;
      fifo_head_valid <= 1'b0;
      dropping_frame <= 1'b0;
    end else begin
      if (fifo_push)
        fifo_write_address <= fifo_write_address + 1'b1;
      if (fifo_fetch)
        fifo_read_address <= fifo_read_address + 1'b1;

      case ({fifo_push, fifo_fetch})
        2'b10: fifo_used <= fifo_used + 1'b1;
        2'b01: fifo_used <= fifo_used - 1'b1;
        default: ;
      endcase

      if (fifo_fetch || write_accepted)
        fifo_head_valid <= fifo_fetch;

      // On overflow, discard the rest of this frame. The next accepted (0,0)
      // restarts capture at SDRAM address zero.
      if (pixel_valid)
        dropping_frame <= !fifo_push;
    end
  end

  reg copying;
  reg all_reads_issued;
  reg [2:0] pending_reads;
  reg [FRAME_ADDRESS_BITS-1:0] write_address;
  reg [FRAME_ADDRESS_BITS-1:0] read_address;
  reg [4:0] switch_meta;
  reg [4:0] switch_sync;

  assign mem_write = resetn && !copying && fifo_head_valid;
  // The Platform Designer controller advertises up to seven pending reads.
  assign mem_read = resetn && copying && !all_reads_issued && (pending_reads < 3'd7);
  assign mem_address = copying ? read_address : (head_first ? 25'd0 : write_address);
  assign mem_writedata = fifo_head[bits_per_pixel-1:0];
  assign display_write = resetn && copying && mem_readdatavalid;
  wire read_accepted = mem_read && !mem_waitrequest;

  always @(posedge clock) begin
    if (!resetn) begin
      copying <= 1'b0;
      all_reads_issued <= 1'b0;
      pending_reads <= 0;
      write_address <= 0;
      read_address <= 0;
      display_x <= 0;
      display_y <= 0;
      switch_meta <= 0;
      switch_sync <= 0;
      frame_effects <= 0;
    end else begin
      switch_meta <= switches;
      switch_sync <= switch_meta;

      if (write_accepted) begin
        write_address <= head_first ? 1 : write_address + 1'b1;
        if (head_last) begin
          copying <= 1'b1;
          all_reads_issued <= 1'b0;
          write_address <= 0;
          read_address <= 0;
          frame_effects <= switch_sync;
        end
      end

      if (read_accepted) begin
        if (read_address == FRAME_WORDS - 1)
          all_reads_issued <= 1'b1;
        else
          read_address <= read_address + 1'b1;
      end

      case ({read_accepted, display_write})
        2'b10: pending_reads <= pending_reads + 1'b1;
        2'b01: pending_reads <= pending_reads - 1'b1;
        default: ;
      endcase

      if (display_write) begin
        if (display_x == COLS - 1) begin
          display_x <= 0;
          if (display_y == ROWS - 1) begin
            display_y <= 0;
            copying <= 1'b0;
          end else begin
            display_y <= display_y + 1'b1;
          end
        end else begin
          display_x <= display_x + 1'b1;
        end
      end
    end
  end
endmodule
