`include "timescale.v"
`include "bc_ufm_config.v"

module lm32_test;

	// Inputs
	reg sys_clk;
	reg sys_rst;
    
	wire [31:0] D_DAT_I;
	wire D_ACK_I;
	wire D_ERR_I;
	wire D_RTY_I;
    
	wire [31:0] I_DAT_I;
	wire I_ACK_I;
	wire I_ERR_I;
	wire I_RTY_I;

	// Outputs
	wire D_CYC_O;
	wire D_STB_O;
	wire D_WE_O;
	wire D_LOCK_O;
	wire [31:0] D_DAT_O;
	wire [31:0] D_ADR_O;
	wire [3:0] D_SEL_O;
	wire [2:0] D_CTI_O;
	wire [1:0] D_BTE_O;
    
    wire I_CYC_O;
	wire I_STB_O;
	wire I_WE_O;
	wire I_LOCK_O;
	wire [31:0] I_DAT_O;
	wire [31:0] I_ADR_O;
	wire [3:0] I_SEL_O;
	wire [2:0] I_CTI_O;
	wire [1:0] I_BTE_O;

    // interrupt lines
    wire [31:0] cpu_interrupt;
    assign cpu_interrupt = 32'd0;

	// lm32
	lm32_top lm32 (
		.clk_i(sys_clk), 
		.rst_i(sys_rst), 
        .interrupt(cpu_interrupt),
        
		.D_DAT_I(D_DAT_I), 
		.D_ACK_I(D_ACK_I), 
		.D_ERR_I(D_ERR_I), 
		.D_RTY_I(D_RTY_I), 
        
		.D_DAT_O(D_DAT_O), 
		.D_ADR_O(D_ADR_O), 
		.D_CYC_O(D_CYC_O), 
		.D_SEL_O(D_SEL_O), 
		.D_STB_O(D_STB_O), 
		.D_WE_O(D_WE_O), 
		.D_CTI_O(D_CTI_O), 
		.D_LOCK_O(D_LOCK_O), 
		.D_BTE_O(D_BTE_O),
        
        .I_ADR_O(I_ADR_O),
        .I_DAT_I(I_DAT_I),
        .I_DAT_O(I_DAT_O),
        .I_SEL_O(I_SEL_O),
        .I_CYC_O(I_CYC_O),
        .I_STB_O(I_STB_O),
        .I_ACK_I(I_ACK_I),
        
        .I_WE_O(I_WE_O),
        .I_CTI_O(I_CTI_O),
        .I_LOCK_O(I_LOCK_O),
        .I_BTE_O(I_BTE_O),
        .I_ERR_I(I_ERR_I),
        .I_RTY_I(I_RTY_I)
	);
    
    // bootloader RAM
    wb_bram #(
        .mem_file_name(`BC_BOOTRAM_FILE),
        .adr_width(`BC_BOOTRAM_WIDTH)
    ) bootram (
        .clk_i(sys_clk),
        .rst_i(sys_rst),
            
        .wb_stb_i(I_STB_O),
        .wb_cyc_i(I_CYC_O),
        .wb_we_i(I_WE_O),
        .wb_ack_o(I_ACK_I),
        .wb_adr_i(I_ADR_O),
        .wb_dat_o(I_DAT_I),
        .wb_dat_i(I_DAT_O),
        .wb_sel_i(I_SEL_O)
        );

    // working RAM
    wb_bram #(
        .mem_file_name("none"),
        .adr_width(`BC_BOOTRAM_WIDTH)
    ) workram (
        .clk_i(sys_clk),
        .rst_i(sys_rst),
            
        .wb_stb_i(D_STB_O),
        .wb_cyc_i(D_CYC_O),
        .wb_we_i(D_WE_O),
        .wb_ack_o(D_ACK_I),
        .wb_adr_i(D_ADR_O),
        .wb_dat_o(D_DAT_I),
        .wb_dat_i(D_DAT_O),
        .wb_sel_i(D_SEL_O)
        );

    // clock
    initial
    begin
        sys_clk=0;
        forever #20.83 sys_clk = ~sys_clk;
    end
    
    // reset
	initial begin
        sys_rst = 1;
        
        #100
        sys_rst = 0;
	end
    
    // simulate wb ack
//    always @(posedge sys_clk)
//    begin
//        I_ACK_I <= I_CYC_O & I_STB_O;
//    end
      
endmodule

