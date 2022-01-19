`include "timescale.v"
`include "bc_ufm_config.v"

module BC2_top_ufm(
    input IFCLK,
    
    // FX2
    input FLAGB, FLAGC,
    output SLOE, SLRD, SLWR,
    output PKTEND,
    output [1:0] FIFOADR,
    inout [7:0] FD,

    // Inputs
    input [3:0] TASTER,
    input ARM_BUSY,
    
    // Outputs
    output [7:0] DEVLED,
    output ARM_EXPOSURE,
    
    // PWM Outputs
    output POWERLED_PWM, POWERLED_EN,
    
    // CAN
    input CAN_FPGA_RX,
    output CAN_FPGA_TX, CAN_FPGA_EN,
    
    // SPI
    input SPI_MISO,
    output SPI_SCK, SPI_MOSI,
    output SPI_CS, // controlled by gpio
    
    // I2C
    inout CAM_SDA, CAM_SCL,
    
    // SDCARD
    output SD_CLK,
    inout SD_CMD,
    inout [3:0] SD_DAT
    );

// global clk
wire sys_clk;
assign sys_clk = IFCLK;

// reset
reg sys_rst;
initial sys_rst <= 1'b1;

// global reset triggered by button 0
reg trigger_reset;
always @(posedge sys_clk) trigger_reset <= !TASTER[0];

// trigger reset on startup
reg [7:0] rst_debounce;
initial rst_debounce <= 8'hFF;
always @(posedge sys_clk) begin
    if (trigger_reset)
        rst_debounce <= 8'hFF; 
    else if (rst_debounce != 8'd0)
        rst_debounce <= rst_debounce - 8'd1;
    sys_rst <= rst_debounce != 8'd0;
end

wire fx_cpu_rst;

//------------------------------------------------------------------
// Wishbone master wires
//------------------------------------------------------------------
wire         gnd   =  1'b0;
wire   [3:0] gnd4  =  4'h0;
wire  [31:0] gnd32 = 32'h00000000;

wire [31:0] cpuibus_adr,
        cpudbus_adr,
        fxl_adr,
        sdm_adr;

wire [2:0]  cpuibus_cti,
		cpudbus_cti,
        sdm_cti;

wire [3:0]  cpudbus_sel,
        sdm_sel;
`ifdef CFG_HW_DEBUG_ENABLED
wire [3:0]  cpuibus_sel;
`endif

wire [31:0]	fxl_dat_r,
        fxl_dat_w,
        cpuibus_dat_r,
        cpuibus_dat_w,
        cpudbus_dat_r,
        cpudbus_dat_w,
        sdm_dat_r,
        sdm_dat_w;

wire        cpudbus_we,
`ifdef CFG_HW_DEBUG_ENABLED
        cpuibus_we,
`endif
        fxl_we,
        sdm_we;

wire        cpuibus_cyc,
        cpudbus_cyc,
        fxl_cyc,
        sdm_cyc;

wire        cpuibus_stb,
		cpudbus_stb,
        fxl_stb,
        sdm_stb;

wire        cpuibus_ack,
        cpudbus_ack,
        fxl_ack,
        sdm_ack;

//------------------------------------------------------------------
// Wishbone slave wires
//------------------------------------------------------------------
wire [31:0]	gpio_adr,
        i2cm_adr,
        spi_adr,
        can_adr,
        sds_adr,
        bootram_adr,
        timer_adr;

wire [31:0]	gpio_dat_r,
		gpio_dat_w,
        i2cm_dat_r,
        i2cm_dat_w,
        spi_dat_r,
        spi_dat_w,
        can_dat_r,
        can_dat_w,
        sds_dat_r,
        sds_dat_w,
        bootram_dat_r,
        bootram_dat_w,
        timer_dat_r,
        timer_dat_w;

wire [3:0]	gpio_sel,
        sds_sel,
        bootram_sel,
        timer_sel;

wire		gpio_we,
        i2cm_we,
        spi_we,
        can_we,
        sds_we,
        bootram_we,
        timer_we;

wire		gpio_cyc,
        i2cm_cyc,
        spi_cyc,
        can_cyc,
        sds_cyc,
        bootram_cyc,
        timer_cyc;

wire		gpio_stb,
        i2cm_stb,
        spi_stb,
        can_stb,
        sds_stb,
        bootram_stb,
        timer_stb;

wire		gpio_ack,
        i2cm_ack,
        spi_ack,
        can_ack,
        sds_ack,
        bootram_ack,
        timer_ack;

//---------------------------------------------------------------------------
// Wishbone switch
//---------------------------------------------------------------------------
// MSB (Bit 31) is ignored for slave address decoding
conbus5x12 #(
	.s0_addr(3'b000),   // lmboot BRAM  0x00000000 (shadow @0x80000000)
	.s1_addr(3'b001),   // DDR RAM      0x10000000 (shadow @0x90000000)
	.s2_addr(3'b010),   //              0x20000000 (shadow @0xa0000000)
	.s3_addr(3'b011),   //              0x30000000 (shadow @0xb0000000)
	.s4_addr(4'b1000),  // CAN          0x40000000 ... etc ...
    .s5_addr(4'b1001),  // SPI          0x48000000
    .s6_addr(4'b1010),  // I2C          0x50000000
    .s7_addr(4'b1011),  // SDCARD       0x58000000
    .s8_addr(4'b1100),  // GPIO         0x60000000
    .s9_addr(4'b1101),  // TIMER        0x68000000
    .s10_addr(4'b1110), // MTCAM        0x70000000
    .s11_addr(4'b1111)  // IMGPROC      0x78000000
) wbswitch (
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),

	// Master 0: fxlink
	.m0_dat_i(fxl_dat_w),
	.m0_dat_o(fxl_dat_r),
	.m0_adr_i(fxl_adr),
	.m0_cti_i(),
	.m0_we_i(fxl_we),
	.m0_sel_i(),
	.m0_cyc_i(fxl_cyc),
	.m0_stb_i(fxl_stb),
	.m0_ack_o(fxl_ack),
	// Master 1: lm32 IBUS
`ifdef CFG_HW_DEBUG_ENABLED
	.m1_dat_i(cpuibus_dat_w),
`else
	.m1_dat_i(32'hx),
`endif
	.m1_dat_o(cpuibus_dat_r),
	.m1_adr_i(cpuibus_adr),
	.m1_cti_i(cpuibus_cti),
`ifdef CFG_HW_DEBUG_ENABLED
	.m1_we_i(cpuibus_we),
	.m1_sel_i(cpuibus_sel),
`else
	.m1_we_i(1'b0),
	.m1_sel_i(4'hf),
`endif
	.m1_cyc_i(cpuibus_cyc),
	.m1_stb_i(cpuibus_stb),
	.m1_ack_o(cpuibus_ack),
	// Master 2: lm32 DBUS
	.m2_dat_i(cpudbus_dat_w),
	.m2_dat_o(cpudbus_dat_r),
	.m2_adr_i(cpudbus_adr),
	.m2_cti_i(cpudbus_cti),
	.m2_we_i(cpudbus_we),
	.m2_sel_i(cpudbus_sel),
	.m2_cyc_i(cpudbus_cyc),
	.m2_stb_i(cpudbus_stb),
	.m2_ack_o(cpudbus_ack),
	// Master 3: SDCARD DMA Master
`ifdef BC_USE_SDCARD_DMA
	.m3_dat_i(sdm_dat_w),
	.m3_dat_o(sdm_dat_r),
	.m3_adr_i(sdm_adr),
	.m3_cti_i(sdm_cti),
	.m3_we_i(sdm_we),
	.m3_sel_i(sdm_sel),
	.m3_cyc_i(sdm_cyc),
	.m3_stb_i(sdm_stb),
	.m3_ack_o(sdm_ack),
`else
    .m3_dat_i(gnd32),
    .m3_adr_i(gnd32),
    .m3_sel_i(gnd4),
    .m3_cyc_i(gnd),
    .m3_stb_i(gnd),
`endif
	// Master 4
	.m4_dat_i(),
	.m4_dat_o(),
	.m4_adr_i(),
	.m4_cti_i(),
	.m4_we_i(),
	.m4_sel_i(),
	.m4_cyc_i(),
	.m4_stb_i(),
	.m4_ack_o(),

	// Slave 0: BOOTRAM
	.s0_dat_i(bootram_dat_r),
	.s0_dat_o(bootram_dat_w),
	.s0_adr_o(bootram_adr),
	.s0_cti_o(),
	.s0_sel_o(bootram_sel),
	.s0_we_o(bootram_we),
	.s0_cyc_o(bootram_cyc),
	.s0_stb_o(bootram_stb),
	.s0_ack_i(bootram_ack),
	// Slave 1
	.s1_dat_i(),
	.s1_dat_o(),
	.s1_adr_o(),
	.s1_cti_o(),
	.s1_sel_o(),
	.s1_we_o(),
	.s1_cyc_o(),
	.s1_stb_o(),
	.s1_ack_i(),
	// Slave 2
	.s2_dat_i(),
	.s2_dat_o(),
	.s2_adr_o(),
	.s2_cti_o(),
	.s2_sel_o(),
	.s2_we_o(),
	.s2_cyc_o(),
	.s2_stb_o(),
	.s2_ack_i(),
	// Slave 3
	.s3_dat_i(),
	.s3_dat_o(),
	.s3_adr_o(),
	.s3_cti_o(),
	.s3_sel_o(),
	.s3_we_o(),
	.s3_cyc_o(),
	.s3_stb_o(),
	.s3_ack_i(),
    
	// Slave 4: CAN
`ifdef BC_USE_CAN
	.s4_dat_i(can_dat_r),
	.s4_dat_o(can_dat_w),
	.s4_adr_o(can_adr),
	.s4_cti_o(),
	.s4_sel_o(),
	.s4_we_o(can_we),
	.s4_cyc_o(can_cyc),
	.s4_stb_o(can_stb),
	.s4_ack_i(can_ack),
`endif
	// Slave 5: SPI
`ifdef BC_USE_SPI
	.s5_dat_i(spi_dat_r),
	.s5_dat_o(spi_dat_w),
	.s5_adr_o(spi_adr),
	.s5_cti_o(),
	.s5_sel_o(),
	.s5_we_o(spi_we),
	.s5_cyc_o(spi_cyc),
	.s5_stb_o(spi_stb),
	.s5_ack_i(spi_ack),
`endif
	// Slave 6: I2C Master
`ifdef BC_USE_I2C
	.s6_dat_i(i2cm_dat_r),
	.s6_dat_o(i2cm_dat_w),
	.s6_adr_o(i2cm_adr),
	.s6_cti_o(),
	.s6_sel_o(),
	.s6_we_o(i2cm_we),
	.s6_cyc_o(i2cm_cyc),
	.s6_stb_o(i2cm_stb),
	.s6_ack_i(i2cm_ack),
`endif
	// Slave 7: SDCARD Slave
	.s7_dat_i(sds_dat_r),
	.s7_dat_o(sds_dat_w),
	.s7_adr_o(sds_adr),
	.s7_cti_o(),
	.s7_sel_o(sds_sel),
	.s7_we_o(sds_we),
	.s7_cyc_o(sds_cyc),
	.s7_stb_o(sds_stb),
	.s7_ack_i(sds_ack),
	// Slave 8: GPIO
	.s8_dat_i(gpio_dat_r),
	.s8_dat_o(gpio_dat_w),
	.s8_adr_o(gpio_adr),
	.s8_cti_o(),
	.s8_sel_o(gpio_sel),
	.s8_we_o(gpio_we),
	.s8_cyc_o(gpio_cyc),
	.s8_stb_o(gpio_stb),
	.s8_ack_i(gpio_ack),
	// Slave 9: TIMER
	.s9_dat_i(timer_dat_r),
	.s9_dat_o(timer_dat_w),
	.s9_adr_o(timer_adr),
	.s9_cti_o(),
	.s9_sel_o(timer_sel),
	.s9_we_o(timer_we),
	.s9_cyc_o(timer_cyc),
	.s9_stb_o(timer_stb),
	.s9_ack_i(timer_ack),
	// Slave 10
	.s10_dat_i(),
	.s10_dat_o(),
	.s10_adr_o(),
	.s10_cti_o(),
	.s10_sel_o(),
	.s10_we_o(),
	.s10_cyc_o(),
	.s10_stb_o(),
	.s10_ack_i(),
	// Slave 11
	.s11_dat_i(),
	.s11_dat_o(),
	.s11_adr_o(),
	.s11_cti_o(),
	.s11_sel_o(),
	.s11_we_o(),
	.s11_cyc_o(),
	.s11_stb_o(),
	.s11_ack_i()
);


//------------------------------------------------------------------
// fxlink WB<->USB Bridge
//------------------------------------------------------------------
fxlink fxlink (
    .CLK(sys_clk), 
    
    .FIFODATA_IO(FD), 
    .GOTDATA_IN(FLAGC), 
    .GOTROOM_IN(FLAGB), 
    .SLOE(SLOE), 
    .SLRD(SLRD), 
    .SLWR(SLWR), 
    .FIFOADR(FIFOADR), 
    .PKTEND(PKTEND), 
    
    .WB_DAT_O(fxl_dat_w), 
    .WB_DAT_I(fxl_dat_r), 
    .WB_ADR_O(fxl_adr), 
    .WB_ACK_I(fxl_ack), 
    .WB_CYC_O(fxl_cyc), 
    .WB_STB_O(fxl_stb), 
    .WB_WE_O(fxl_we), 
    
    .CPU_RST(fx_cpu_rst),
    
    .DEVLED()
    );

//---------------------------------------------------------------------------
// LM32 CPU
//---------------------------------------------------------------------------
// reset CPU on system reset or fxlink-invoked reset
wire cpu_rst;
assign cpu_rst = sys_rst | fx_cpu_rst;

// interrupt lines, low-active
wire [1:0] timer_intr;
wire [31:0] cpu_interrupt;
assign cpu_interrupt = {30'd0, ~timer_intr[1], ~timer_intr[0]};

// stuff copied from milkymist's system.v ...
wire bus_errors_en;
wire cpuibus_err;
wire cpudbus_err;
`ifdef CFG_BUS_ERRORS_ENABLED
// Catch NULL pointers and similar errors
// NOTE: ERR is asserted at the same time as ACK, which violates
// Wishbone rule 3.45. But LM32 doesn't care.
reg locked_addr_i;
reg locked_addr_d;
always @(posedge sys_clk) begin
	locked_addr_i <= cpuibus_adr[31:18] == 14'd0;
	locked_addr_d <= cpudbus_adr[31:18] == 14'd0;
end
assign cpuibus_err = bus_errors_en & locked_addr_i & cpuibus_ack;
assign cpudbus_err = bus_errors_en & locked_addr_d & cpudbus_ack;
`else
assign cpuibus_err = 1'b0;
assign cpudbus_err = 1'b0;
`endif

wire ext_break;

lm32_top lm32_cpu (
	.clk_i(sys_clk),
	.rst_i(cpu_rst),
	.interrupt(cpu_interrupt),

	.I_ADR_O(cpuibus_adr),
	.I_DAT_I(cpuibus_dat_r),
`ifdef CFG_HW_DEBUG_ENABLED
	.I_DAT_O(cpuibus_dat_w),
	.I_SEL_O(cpuibus_sel),
`else
	.I_DAT_O(),
	.I_SEL_O(),
`endif
	.I_CYC_O(cpuibus_cyc),
	.I_STB_O(cpuibus_stb),
	.I_ACK_I(cpuibus_ack),
`ifdef CFG_HW_DEBUG_ENABLED
	.I_WE_O(cpuibus_we),
`else
	.I_WE_O(),
`endif
	.I_CTI_O(cpuibus_cti),
	.I_LOCK_O(),
	.I_BTE_O(),
	.I_ERR_I(cpuibus_err),
	.I_RTY_I(1'b0),
`ifdef CFG_EXTERNAL_BREAK_ENABLED
	.ext_break(ext_break),
`endif

	.D_ADR_O(cpudbus_adr),
	.D_DAT_I(cpudbus_dat_r),
	.D_DAT_O(cpudbus_dat_w),
	.D_SEL_O(cpudbus_sel),
	.D_CYC_O(cpudbus_cyc),
	.D_STB_O(cpudbus_stb),
	.D_ACK_I(cpudbus_ack),
	.D_WE_O (cpudbus_we),
	.D_CTI_O(cpudbus_cti),
	.D_LOCK_O(),
	.D_BTE_O(),
	.D_ERR_I(cpudbus_err),
	.D_RTY_I(1'b0)
);

//------------------------------------------------------------------
// BOOTRAM
//------------------------------------------------------------------
`ifdef BC_USE_BOOTRAM
wb_bram #(
    .mem_file_name(`BC_BOOTRAM_FILE),
	.adr_width(`BC_BOOTRAM_WIDTH)
) bootram (
    .clk_i(sys_clk),
    .rst_i(sys_rst),

    .wb_stb_i(bootram_stb),
    .wb_cyc_i(bootram_cyc),
    .wb_we_i(bootram_we),
    .wb_ack_o(bootram_ack),
    .wb_adr_i(bootram_adr),
    .wb_dat_o(bootram_dat_r),
    .wb_dat_i(bootram_dat_w),
    .wb_sel_i(bootram_sel)
    );
`endif

//------------------------------------------------------------------
// CAN
//------------------------------------------------------------------
`ifdef BC_USE_CAN
can_top can (
    .wb_clk_i(sys_clk),
    .wb_rst_i(sys_rst),
    
    .wb_dat_i(can_dat_w),
    .wb_dat_o(can_dat_r),
    .wb_cyc_i(can_cyc),
    .wb_stb_i(can_stb),
    .wb_we_i(can_we),
    .wb_adr_i(can_adr),
    .wb_ack_o(can_ack),
    
    .clk_i(sys_clk),
    .rx_i(CAN_FPGA_RX), 
    .tx_o(CAN_FPGA_TX), 
    .bus_off_on(CAN_FPGA_EN),
    .irq_on(),
    .clkout_o()
    );
`else
assign CAN_FPGA_TX = 1'bz;
assign CAN_FPGA_EN = 1'b0;
`endif

//------------------------------------------------------------------
// SPI
//------------------------------------------------------------------
`ifdef BC_USE_SPI
simple_spi_top spi (
    .clk_i(sys_clk),
    .rst_i(!sys_rst),
    
    .cyc_i(spi_cyc),
    .stb_i(spi_stb),
    .adr_i(spi_adr),
    .we_i(spi_we),
    .dat_i(spi_dat_w),
    .dat_o(spi_dat_r),
    .ack_o(spi_ack),
    .inta_o(),
    
    .sck_o(SPI_SCK),
    .mosi_o(SPI_MOSI),
    .miso_i(SPI_MISO)
    );
`else
assign SPI_SCK = 1'bz;
assign SPI_MOSI = 1'bz;
`endif

//------------------------------------------------------------------
// I2C
//------------------------------------------------------------------
`ifdef BC_USE_I2C
// SCL tristate IOBUF
wire i2cm_scl_i, i2cm_scl_o, i2cm_scl_oe;
assign CAM_SCL = i2cm_scl_oe ? 1'bz : i2cm_scl_o;
assign i2cm_scl_i = CAM_SCL;
// SDA tristate
wire i2cm_sda_i, i2cm_sda_o, i2cm_sda_oe;
assign CAM_SDA = i2cm_sda_oe ? 1'bz : i2cm_sda_o;
assign i2cm_sda_i = CAM_SDA;

i2c_master_top i2c_master (
    .wb_clk_i(sys_clk),
    .wb_rst_i(sys_rst),
    
    // disable async reset
    .arst_i(1'b1),
    
    .wb_adr_i(i2cm_adr),
    .wb_dat_i(i2cm_dat_w),
    .wb_dat_o(i2cm_dat_r),
    .wb_we_i(i2cm_we),
    .wb_stb_i(i2cm_stb),
    .wb_cyc_i(i2cm_cyc),
    .wb_ack_o(i2cm_ack),
    .wb_inta_o(),
    
    // SCL
    .scl_pad_i(i2cm_scl_i),
    .scl_pad_o(i2cm_scl_o),
    .scl_padoen_o(i2cm_scl_oe),
    // SDA
    .sda_pad_i(i2cm_sda_i),
    .sda_pad_o(i2cm_sda_o),
    .sda_padoen_o(i2cm_sda_oe)
    );
`else
assign CAM_SCL = 1'bz;
assign CAM_SDA = 1'bz;
`endif

//------------------------------------------------------------------
// SDCARD DMA
//------------------------------------------------------------------
`ifdef BC_USE_SDCARD_DMA
// board doesn't support card detection
wire sd_card_detect;
assign sd_card_detect = 1'b0; // card always inserted

// SD_CMD tristate
wire sd_cmd_dat_i, sd_cmd_out_o, sd_cmd_oe_o;
assign SD_CMD = sd_cmd_oe_o ? 1'bz : sd_cmd_out_o;
assign sd_cmd_dat_i = SD_CMD;

// SD_DAT[3:0] tristate
wire [3:0] sd_dat_dat_i;
wire [3:0] sd_dat_out_o;
wire sd_dat_oe_o;
assign SD_DAT = sd_dat_oe_o ? 4'bzzzz : sd_dat_out_o;
assign sd_dat_dat_i = SD_DAT;

sdc_controller sdcard (
    .wb_clk_i(sys_clk),
    .wb_rst_i(sys_rst),
    
    // wb master
    .m_wb_adr_o(sdm_adr),
    .m_wb_sel_o(sdm_sel),
    .m_wb_we_o(sdm_we),
    .m_wb_dat_o(sdm_dat_w),
    .m_wb_dat_i(sdm_dat_r),
    .m_wb_cyc_o(sdm_cyc),
    .m_wb_stb_o(sdm_stb),
    .m_wb_ack_i(sdm_ack),
    .m_wb_cti_o(sdm_cti),
    .m_wb_bte_o(),
    
    // wb slave
    .wb_dat_i(sds_dat_w),
    .wb_dat_o(sds_dat_r),
    .wb_adr_i(sds_adr[7:0]),
    .wb_sel_i(sds_sel),
    .wb_we_i(sds_we),
    .wb_cyc_i(sds_cyc),
    .wb_stb_i(sds_stb),
    .wb_ack_o(sds_ack),
    
    // interrupt
    .int_a(),
    .int_b(),
    .int_c(),
    
    // SD card signals
    .card_detect(sd_card_detect),
    
    // CMD
    .sd_cmd_dat_i(sd_cmd_dat_i),
    .sd_cmd_out_o(sd_cmd_out_o),
    .sd_cmd_oe_o(sd_cmd_oe_o),
    
    // DAT[3:0]
    .sd_dat_dat_i(sd_dat_dat_i),
    .sd_dat_out_o(sd_dat_out_o),
    .sd_dat_oe_o(sd_dat_oe_o),
    
    // CLK
    .sd_clk_o_pad(SD_CLK)
    );
`else // BC_USE_SDCARD_DMA
//------------------------------------------------------------------
// SDCARD SPI
//------------------------------------------------------------------
`ifdef BC_USE_SDCARD_SPI
wb_spi sdspi (
	.clk(sys_clk),
	.reset(sys_rst),

	.wb_adr_i(sds_adr),
	.wb_dat_i(sds_dat_w),
	.wb_dat_o(sds_dat_r),
	.wb_stb_i(sds_stb),
	.wb_cyc_i(sds_cyc),
	.wb_we_i(sds_we),
	.wb_sel_i(sds_sel),
	.wb_ack_o(sds_ack),

	.spi_sck(SD_CLK),
	.spi_mosi(SD_CMD),
	.spi_miso(SD_DAT[0]),
	.spi_cs(SD_DAT[3])
);
assign SD_DAT[2:1] = 2'bzz;
`else
assign SD_CLK = 1'bz;
assign SD_CMD = 1'bz;
assign SD_DAT = 4'bzzzz;
`endif // BC_USE_SDCARD_SPI

`endif // BC_USE_SDCARD_DMA

//------------------------------------------------------------------
// GPIO
//------------------------------------------------------------------
wire [31:0] gpio_out;
wire [31:0] gpio_in;
// output mapping
assign SPI_CS = gpio_out[31];
assign ARM_EXPOSURE = gpio_out[30];
// input mapping
assign gpio_in[0] = ARM_BUSY;
assign gpio_in[3:1] = TASTER[3:1];

wb_gpio gpio (
    .clk(sys_clk), 
    .reset(sys_rst), 
    
    .wb_stb_i(gpio_stb), 
    .wb_cyc_i(gpio_cyc), 
    .wb_ack_o(gpio_ack), 
    .wb_we_i(gpio_we), 
    .wb_adr_i(gpio_adr), 
    .wb_sel_i(gpio_sel), 
    .wb_dat_i(gpio_dat_w), 
    .wb_dat_o(gpio_dat_r), 
    .intr(), 
    
    // 32 bit wide IOs
    .gpio_in(gpio_in),
    .gpio_out(gpio_out),
    // for tristate
    .gpio_oe(),
    // inverted 8 bit output
    .gpio_out_small(DEVLED),
    
    // PWM1
    .pwm1_o(POWERLED_PWM),
    .pwm1_en(POWERLED_EN)
    );

//---------------------------------------------------------------------------
// TIMER
//---------------------------------------------------------------------------
wb_timer timer (
	.clk(sys_clk),
	.reset(sys_rst),

	.wb_adr_i(timer_adr),
	.wb_dat_i(timer_dat_w),
	.wb_dat_o(timer_dat_r),
	.wb_stb_i(timer_stb),
	.wb_cyc_i(timer_cyc),
	.wb_we_i(timer_we),
	.wb_sel_i(timer_sel),
	.wb_ack_o(timer_ack),
    
	.intr(timer_intr)
);

endmodule
