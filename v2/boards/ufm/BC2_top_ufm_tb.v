`timescale 1ns / 1ps

module BC2_top_ufm_tb;

	// Inputs
	reg sys_clk;
	reg sys_rst;
    
	reg FLAGB;
	reg FLAGC;
	reg [3:0] TASTER;
	reg ARM_BUSY;
	reg CAN_FPGA_RX;
	reg SPI_MISO;

	// Outputs
	wire SLOE;
	wire SLRD;
	wire SLWR;
	wire PKTEND;
	wire [1:0] FIFOADR;
	wire [7:0] DEVLED;
	wire ARM_EXPOSURE;
	wire POWERLED_PWM;
	wire POWERLED_EN;
	wire CAN_FPGA_TX;
	wire CAN_FPGA_EN;
	wire SPI_SCK;
	wire SPI_MOSI;
	wire SPI_SS;
	wire SD_CLK;

	// Bidirs
	wire [7:0] FD;
	wire CAM_SDA;
	wire CAM_SCL;
	wire SD_CMD;
	wire [3:0] SD_DAT;

	BC2_top_ufm dut (
		.IFCLK(sys_clk),
        
		.FLAGB(FLAGB), 
		.FLAGC(FLAGC), 
		.SLOE(SLOE), 
		.SLRD(SLRD), 
		.SLWR(SLWR), 
		.PKTEND(PKTEND), 
		.FIFOADR(FIFOADR), 
		.FD(FD), 
        
		.TASTER(TASTER), 
		.DEVLED(DEVLED), 
        
		.ARM_BUSY(ARM_BUSY), 
		.ARM_EXPOSURE(ARM_EXPOSURE), 
        
		.POWERLED_PWM(POWERLED_PWM), 
		.POWERLED_EN(POWERLED_EN), 
        
		.CAN_FPGA_RX(CAN_FPGA_RX), 
		.CAN_FPGA_TX(CAN_FPGA_TX), 
		.CAN_FPGA_EN(CAN_FPGA_EN), 
        
		.SPI_MISO(SPI_MISO), 
		.SPI_SCK(SPI_SCK), 
		.SPI_MOSI(SPI_MOSI), 
		.SPI_SS(SPI_SS), 
        
		.CAM_SDA(CAM_SDA), 
		.CAM_SCL(CAM_SCL), 
        
		.SD_CLK(SD_CLK), 
		.SD_CMD(SD_CMD), 
		.SD_DAT(SD_DAT)
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
      
    //------------------------------------------------------------------
    // Monitor Wishbone transactions
    //------------------------------------------------------------------
    always @(posedge sys_clk)
    begin
        if (dut.cpudbus_ack) begin
            $display( "LM32D transaction: ADR=%x WE=%b DAT=%x", 
                        dut.cpudbus_adr, dut.cpudbus_we, 
                        (dut.cpudbus_we) ? dut.cpudbus_dat_w : dut.cpudbus_dat_r );
        end
    end

    always @(posedge sys_clk)
    begin
        if (dut.cpuibus_ack) begin
            $display( "LM32I transaction: ADR=%x WE=0 DAT=%x", 
                        dut.cpuibus_adr, dut.cpuibus_dat_r );
        end
    end
      
endmodule

