	sdram_system u0 (
		.clk_clk           (<connected-to-clk_clk>),           //   clk.clk
		.reset_reset_n     (<connected-to-reset_reset_n>),     // reset.reset_n
		.sdram_addr        (<connected-to-sdram_addr>),        // sdram.addr
		.sdram_ba          (<connected-to-sdram_ba>),          //      .ba
		.sdram_cas_n       (<connected-to-sdram_cas_n>),       //      .cas_n
		.sdram_cke         (<connected-to-sdram_cke>),         //      .cke
		.sdram_cs_n        (<connected-to-sdram_cs_n>),        //      .cs_n
		.sdram_dq          (<connected-to-sdram_dq>),          //      .dq
		.sdram_dqm         (<connected-to-sdram_dqm>),         //      .dqm
		.sdram_ras_n       (<connected-to-sdram_ras_n>),       //      .ras_n
		.sdram_we_n        (<connected-to-sdram_we_n>),        //      .we_n
		.mem_address       (<connected-to-mem_address>),       //   mem.address
		.mem_byteenable_n  (<connected-to-mem_byteenable_n>),  //      .byteenable_n
		.mem_chipselect    (<connected-to-mem_chipselect>),    //      .chipselect
		.mem_writedata     (<connected-to-mem_writedata>),     //      .writedata
		.mem_read_n        (<connected-to-mem_read_n>),        //      .read_n
		.mem_write_n       (<connected-to-mem_write_n>),       //      .write_n
		.mem_readdata      (<connected-to-mem_readdata>),      //      .readdata
		.mem_readdatavalid (<connected-to-mem_readdatavalid>), //      .readdatavalid
		.mem_waitrequest   (<connected-to-mem_waitrequest>)    //      .waitrequest
	);

