
module sdram_system (
	clk_clk,
	reset_reset_n,
	sdram_addr,
	sdram_ba,
	sdram_cas_n,
	sdram_cke,
	sdram_cs_n,
	sdram_dq,
	sdram_dqm,
	sdram_ras_n,
	sdram_we_n,
	mem_address,
	mem_byteenable_n,
	mem_chipselect,
	mem_writedata,
	mem_read_n,
	mem_write_n,
	mem_readdata,
	mem_readdatavalid,
	mem_waitrequest);	

	input		clk_clk;
	input		reset_reset_n;
	output	[12:0]	sdram_addr;
	output	[1:0]	sdram_ba;
	output		sdram_cas_n;
	output		sdram_cke;
	output		sdram_cs_n;
	inout	[15:0]	sdram_dq;
	output	[1:0]	sdram_dqm;
	output		sdram_ras_n;
	output		sdram_we_n;
	input	[24:0]	mem_address;
	input	[1:0]	mem_byteenable_n;
	input		mem_chipselect;
	input	[15:0]	mem_writedata;
	input		mem_read_n;
	input		mem_write_n;
	output	[15:0]	mem_readdata;
	output		mem_readdatavalid;
	output		mem_waitrequest;
endmodule
