module photobooth_top #(
    parameter RESOLUTION = "640x480",
    parameter bits_per_pixel = 9
) (
    input  wire       CLOCK_50,
    input  wire [0:0] GPIO_0,
    input  wire [0:0] KEY,
    input  wire [9:0] SW,
    output wire [7:0] VGA_R,
    output wire [7:0] VGA_G,
    output wire [7:0] VGA_B,
    output wire       VGA_HS,
    output wire       VGA_VS,
    output wire       VGA_BLANK_N,
    output wire       VGA_SYNC_N,
    output wire       VGA_CLK,
    output wire [12:0] DRAM_ADDR,
    output wire [1:0]  DRAM_BA,
    output wire        DRAM_CAS_N,
    output wire        DRAM_CKE,
    output wire        DRAM_CLK,
    output wire        DRAM_CS_N,
    inout  wire [15:0] DRAM_DQ,
    output wire        DRAM_LDQM,
    output wire        DRAM_RAS_N,
    output wire        DRAM_UDQM,
    output wire        DRAM_WE_N
);

  assign DRAM_CLK = CLOCK_50;

  // Platform Designer system sdram_system exports clk, reset, mem, and sdram.
  // Park the memory port until the frame buffer logic drives it.
  sdram_system u_sdram_system (
      .clk_clk          (CLOCK_50),
      .reset_reset_n    (KEY[0]),
      .mem_address      (25'd0),
      .mem_byteenable_n (2'b11),
      .mem_chipselect   (1'b0),
      .mem_writedata    (16'd0),
      .mem_read_n       (1'b1),
      .mem_write_n      (1'b1),
      .mem_readdata     (),
      .mem_readdatavalid(),
      .mem_waitrequest  (),
      .sdram_addr       (DRAM_ADDR),
      .sdram_ba         (DRAM_BA),
      .sdram_cas_n      (DRAM_CAS_N),
      .sdram_cke        (DRAM_CKE),
      .sdram_cs_n       (DRAM_CS_N),
      .sdram_dq         (DRAM_DQ),
      .sdram_dqm        ({DRAM_UDQM, DRAM_LDQM}),
      .sdram_ras_n      (DRAM_RAS_N),
      .sdram_we_n       (DRAM_WE_N)
  );

  photobooth #(
      .RESOLUTION(RESOLUTION),
      .bits_per_pixel(bits_per_pixel)
  ) u_photobooth (
      .resetn             (KEY[0]),
      .clock              (CLOCK_50),
      .uart               (GPIO_0[0]),
      .enable_invert      (SW[0]),
      .enable_grayscale   (SW[1]),
      .enable_blue_filter (SW[2]),
      .enable_green_filter(SW[3]),
      .enable_red_filter  (SW[4]),
      .VGA_R              (VGA_R),
      .VGA_G              (VGA_G),
      .VGA_B              (VGA_B),
      .VGA_HS             (VGA_HS),
      .VGA_VS             (VGA_VS),
      .VGA_BLANK_N        (VGA_BLANK_N),
      .VGA_SYNC_N         (VGA_SYNC_N),
      .VGA_CLK            (VGA_CLK)
  );

endmodule
