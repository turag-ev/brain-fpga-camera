----------------------------------------------------------------------------------
-- AVR_SoC_Top.vhd
--
-- Copyright (C) 2010 Mario Mauerer
-- 
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or (at
-- your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
-- General Public License for more details.
--
-- You should have received a copy of the GNU General Public License along
-- with this program; if not, write to the Free Software Foundation, Inc.,
-- 51 Franklin St, Fifth Floor, Boston, MA 02110, USA
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;


entity AVR_SoC_Top is
	port(
		CLK_48      : in std_logic;
		RESET       : in std_logic;
		
        -- GPO
        DEVLED : out std_logic_vector(7 downto 0);
        POWERLED_VAL : out std_logic_vector(7 downto 0);
        IPC_SETTINGS : out std_logic_vector(7 downto 0);
        PT_MIN, PT_MAX, STADR, STDAT : out std_logic_vector(7 downto 0);
        
        POWERLED_EN : out std_logic;
        IPC_START, IPC_RST : out std_logic;
        RIM_SEL : out std_logic;
        TRIG_MODE, TRIG_OUT : out std_logic;
        SPI_CS : out std_logic;
        EXPOSURE_TIMESTAMP : out std_logic;

        -- GPI
        TASTER : in  std_logic_vector(3 downto 0);
        
        IPC_DONE : in  std_logic;
        FRM_SHOOT, FRM_DONE : in  std_logic;
        PC_OVERRIDE, FXL_RIM_SEL : in  std_logic;
        CAM_GOOD : in  std_logic;
        ARM_READY : in  std_logic;
        
        -- Img RAM
        CLK_IRAM    : out std_logic;
        IRAM_ADDR   : out std_logic_vector(14 downto 0);
        IRAM_DIN    : in  std_logic_vector(7 downto 0);
        IRAM_DOUT   : out std_logic_vector(7 downto 0);
        IRAM_WE     : out std_logic;
        IRAM_EN     : out std_logic;
        
        -- SPI
        SPI_SCK     : out std_logic;
        SPI_MOSI    : out std_logic;
        SPI_MISO    : in  std_logic;
        
        -- I2C
        I2C_SCL_I   : in  std_logic;                    -- i2c clock line input
        I2C_SCL_O   : out std_logic;                    -- i2c clock line output
        I2C_SCL_OE  : out std_logic;                    -- i2c clock line output enable, active low
        I2C_SDA_I   : in  std_logic;                    -- i2c data line input
        I2C_SDA_O   : out std_logic;                    -- i2c data line output
        I2C_SDA_OE  : out std_logic                     -- i2c data line output enable, active low
	);
end AVR_SoC_Top;

architecture Behavioral of AVR_SoC_Top is
	
	component Clock_Gen --DCM, generates the System Clock (30MHz) from the 50MHz clock
		port(
			CLKIN_IN 	: IN std_logic;
			RST_IN 		: IN std_logic;          
			CLKFX_OUT 	: OUT std_logic;
			CLKFX180_OUT 		: OUT std_logic;
			CLKIN_IBUFG_OUT 	: OUT std_logic;
			CLK0_OUT 	: OUT std_logic;
			LOCKED_OUT 	: OUT std_logic
		);
	end component;
	
	component AVR_Core --This is the AVR core
		port(
		--Clock and reset
			cp2         : in  std_logic;
			cp2en       : in  std_logic;
			ireset      : in  std_logic;
		-- JTAG OCD support
			valid_instr : out std_logic;
			insert_nop  : in  std_logic; 
			block_irq   : in  std_logic;
			change_flow : out std_logic;
      -- Program Memory
			pc          : out std_logic_vector(15 downto 0);   
			inst        : in  std_logic_vector(15 downto 0);
		-- I/O control
			adr         : out std_logic_vector(5 downto 0); 	
			iore        : out std_logic;                       
			iowe        : out std_logic;						
      -- Data memory control
			ramadr      : out std_logic_vector(15 downto 0);
			ramre       : out std_logic;
			ramwe       : out std_logic;
			cpuwait     : in  std_logic;
		-- Data paths
			dbusin      : in  std_logic_vector(7 downto 0);
			dbusout     : out std_logic_vector(7 downto 0);
      -- Interrupt
			irqlines    : in  std_logic_vector(22 downto 0);
			irqack      : out std_logic;
			irqackad    : out std_logic_vector(4 downto 0);
      --Sleep Control
			sleepi	   : out std_logic;
			irqok	     	: out std_logic;
			globint	   : out std_logic;
      --Watchdog
			wdri	      : out std_logic
		);
	end component;
	
	component ProgMem --This is the 16kB Program Memory
		port(
			ClkxC 	: in  STD_LOGIC;
         RstxR 	: in  STD_LOGIC;
         AdrxDI 	: in  STD_LOGIC_VECTOR (13 downto 0); 
         DoutxDO 	: out  STD_LOGIC_VECTOR (15 downto 0)
		);
	end component;
	
	component AVR_sram --This is the 8kB SRAM
		port(
			ClkxC 	: in  std_logic;
			RstxR 	: in  std_logic;
			AdrxDI 	: in  std_logic_vector(12 downto 0);
			
			DoutxDO 	: out  std_logic_vector(7 downto 0);
			DinxDI 	: in std_logic_vector(7 downto 0);
			WExSI 	: in std_logic;
			EnxSI 	: in std_logic
		);
	end component;
	
	component AVR_BusMux --This is the Mux that muxes the data accesses between Wb-Translator and Sram.
		port(
			CLKxC 				: in std_logic;
			ResetxS 				: in std_logic;
	--AVR side:
			AVR_dbusinxDO 		: out std_logic_vector(7 downto 0);
			AVR_dbusoutxDI 	: in std_logic_vector(7 downto 0);
			
			AVR_RamAdrxDI 		: in std_logic_vector(15 downto 0);
			AVR_IoAdrxDI 		: in std_logic_vector(5 downto 0);
			
			AVR_IoWexSI 		: in std_logic;
			AVR_IoRexSI 		: in std_logic;
			AVR_RamWexSI 		: in std_logic;
			AVR_RamRexSI 		: in std_logic;
	--Sram:
			Sram_AdrxDO 		: out std_logic_vector(12 downto 0);
			Sram_DataInxDI 	: in std_logic_vector(7 downto 0);
			Sram_DataOutxDO 	: out std_logic_vector(7 downto 0);
			Sram_WexSO 			: out std_logic;
			Sram_EnxSO 			: out std_logic;
    --Img RAM
			Iram_AdrxDO 		: out std_logic_vector(14 downto 0);
			Iram_DataInxDI		: in std_logic_vector(7 downto 0);
			Iram_DataOutxDO 	: out std_logic_vector(7 downto 0);
			Iram_WexSO 			: out std_logic;
			Iram_EnxSO 			: out std_logic;
	--Wishbone-AVR-Translator:
			AVR_Wb_IoAdrxDO 	: out std_logic_vector(5 downto 0);
			AVR_Wb_RamAdrxDO 	: out std_logic_vector(15 downto 0);
			AVR_Wb_IoRexSO 	: out std_logic;
			AVR_Wb_RamRexSO 	: out std_logic;
			AVR_Wb_IoWexSO 	: out std_logic;
			AVR_Wb_RamWexSO 	: out std_logic;
			AVR_Wb_DatoutxDO 	: out std_logic_vector(7 downto 0);
			AVR_Wb_DatinxDI 	: in std_logic_vector(7 downto 0)
		);
	end component;
	
	component AVR_WB_Translator --This provides a Wishbone-Interface.
		port(
			CLK 			  : in std_logic;
			RST			  : in std_logic;
		--AVR Side:
			--IO Bus in:
			AVR_IO_ADR_I  : in std_logic_vector(5 downto 0);
			AVR_iore_I    : in std_logic;
			AVR_iowe_I 	  : in std_logic;
			--Ram Bus in:
			AVR_RAMADR_I  : in std_logic_vector(15 downto 0);
			AVR_ramre_I   : in std_logic;
			AVR_ramwe_I   : in std_logic;
			--Datapath:
			AVR_DAT_O 	  : out std_logic_vector(7 downto 0);
			AVR_DAT_I     : in std_logic_vector(7 downto 0);
			--CPU wait:
			AVR_Clk_EnxSO : out std_logic;
		
		--IO Wishbone:
			Wb_DAT_IO_O   : out std_logic_vector(7 downto 0);
			Wb_DAT_IO_I   : in std_logic_vector(7 downto 0);
			Wb_ADR_IO_O   : out std_logic_vector(5 downto 0);
			Wb_ACK_IO_I   : in std_logic;
			Wb_CYC_IO_O   : out std_logic;
			Wb_STB_IO_O   : out std_logic;
			Wb_WE_IO_O    : out std_logic;
		
		--RAM Wishbone:
			Wb_DAT_RAM_O  : out std_logic_vector(7 downto 0);
			Wb_DAT_RAM_I  : in std_logic_vector(7 downto 0);
			Wb_ADR_RAM_O  : out std_logic_vector(15 downto 0);
			Wb_ACK_RAM_I  : in std_logic;
			Wb_CYC_RAM_O  : out std_logic;
			Wb_STB_RAM_O  : out std_logic;
			Wb_WE_RAM_O   : out std_logic
		);
	end component;

	component IO_Devices --This provides an Interface to the different IO-Devices
		port(
			CLKxC : in std_logic;
			ResetxS : in std_logic;
			Wb_DatxDI : in std_logic_vector(7 downto 0);
			Wb_AdrxDI : in std_logic_vector(5 downto 0);
			Wb_CycxSI : in std_logic;
			Wb_StbxSI : in std_logic;
			Wb_WexSI : in std_logic;          
			Wb_DatxDO : out std_logic_vector(7 downto 0);
			Wb_AckxSO : out std_logic;
			
            GPO_0 : out std_logic_vector(7 downto 0);   -- DEVLED
            GPO_1 : out std_logic_vector(7 downto 0);   -- POWERLED_VAL
            GPO_2 : out std_logic_vector(7 downto 0);   -- MISC_OA
            GPO_3 : out std_logic_vector(7 downto 0);   -- MISC_OB
            GPO_4 : out std_logic_vector(7 downto 0);   -- MISC_OC
            GPO_5 : out std_logic_vector(7 downto 0);   -- MISC_OD
            GPO_6 : out std_logic_vector(7 downto 0);   -- STADR
            GPO_7 : out std_logic_vector(7 downto 0);   -- STDAT
            
            GPI_0 : in std_logic_vector(7 downto 0);    -- TASTER
            GPI_1 : in std_logic_vector(7 downto 0);    -- MISC_IA
            GPI_2 : in std_logic_vector(7 downto 0);    -- MISC_IB
            GPI_3 : in std_logic_vector(7 downto 0);    -- MISC_IC
            
            SPI_MISO : IN std_logic;
            SPI_SCK : OUT std_logic;
            SPI_MOSI : OUT std_logic;
            SPI_INT : OUT std_logic;
            
            I2C_SCL_I : IN std_logic;
            I2C_SCL_O : OUT std_logic;
            I2C_SCL_OE : OUT std_logic;
            I2C_SDA_I : IN std_logic;
            I2C_SDA_O : OUT std_logic;
            I2C_SDA_OE : OUT std_logic
		);
	end component;
	
-------------------------------------SIGNALS-------------------------------------------	
	
--Basic Signals:
	signal ResetxS : std_logic; --Reset-signal
	signal CLK_AVR : std_logic; --20MHz Clock signal
	signal CLK_AVR_180 : std_logic; --20MHz, 180deg phase shifted signal
	signal DCM_lockedxS : std_logic;--DCM locked
	signal AVR_ResetxS : std_logic; -- = not ResetxS
	signal AVR_Clk_EnxS : std_logic; --enables the Core, used by the Wb-Translator
----
	
--Program Memory:
	signal ProgMemAdrxD : std_logic_vector(15 downto 0);
	signal ProgMemDataxD : std_logic_vector(15 downto 0);
----

--Data/IO-Bus Mux Interconnect
	signal AVR_dbusinxD : std_logic_vector(7 downto 0);
	signal AVR_dbusoutxD : std_logic_vector(7 downto 0);
	signal AVR_IoAdrxD : std_logic_vector(5 downto 0);
	signal AVR_RamAdrxD : std_logic_vector(15 downto 0);
	signal AVR_IoWexS : std_logic;
	signal AVR_IoRexS : std_logic;
	signal AVR_RamWexS : std_logic;
	signal AVR_RamRexs : std_logic;
	
	signal Sram_AdrxD : std_logic_vector(12 downto 0);
	signal Sram_DataInxD : std_logic_vector(7 downto 0);
	signal Sram_DataOutxD : std_logic_vector(7 downto 0);
	signal Sram_WexS : std_logic;
	signal Sram_EnxS : std_logic;
	
    signal Iram_AdrxD : std_logic_vector(14 downto 0);
	signal Iram_DataInxD : std_logic_vector(7 downto 0);
	signal Iram_DataOutxD : std_logic_vector(7 downto 0);
	signal Iram_WexS : std_logic;
	signal Iram_EnxS : std_logic;
    
	signal AVR_Wb_IoAdrxD 	: std_logic_vector(5 downto 0);
	signal AVR_Wb_RamAdrxD 	: std_logic_vector(15 downto 0);
	signal AVR_Wb_IoRexS 	: std_logic;
	signal AVR_Wb_RamRexS	: std_logic;
	signal AVR_Wb_IoWexS		: std_logic; 
	signal AVR_Wb_RamWexS 	: std_logic;
	signal AVR_Wb_DataoutxD 	: std_logic_vector(7 downto 0);
	signal AVR_Wb_DatainxD 	: std_logic_vector(7 downto 0);
	
--Interconnect between Translator and IO-Conbus:
	signal Wb_ACK_IOxS : std_logic;
	signal Wb_STB_IOxS : std_logic;
	signal Wb_CYC_IOxS : std_logic;
	signal Wb_DAT_IOxDO : std_logic_vector(7 downto 0);
	signal Wb_DAT_IOxDI : std_logic_vector(7 downto 0);
	signal Wb_ADR_IOxD : std_logic_vector(5 downto 0);
	signal Wb_WE_IOxS  : std_logic;
----

--Various signals:
    signal gpo_devled, gpo_powerled_val, gpo_misc_oa, gpo_misc_ob, gpo_misc_oc, gpo_misc_od, gpo_stadr, gpo_stdat : std_logic_vector(7 downto 0);
    signal gpi_taster, gpi_misc_ia, gpi_misc_ib, gpi_misc_ic : std_logic_vector(7 downto 0);
begin

-- Img RAM stuff
CLK_IRAM <= CLK_AVR_180;
IRAM_ADDR <= Iram_AdrxD;
Iram_DataInxD <= IRAM_DIN;
IRAM_DOUT <= Iram_DataOutxD;
IRAM_WE <= Iram_WexS;
IRAM_EN <= Iram_EnxS;

-- GPO
DEVLED <= gpo_devled;
POWERLED_VAL <= gpo_powerled_val;

POWERLED_EN <= gpo_misc_oa(0);
IPC_START   <= gpo_misc_oa(1);
IPC_RST     <= gpo_misc_oa(2);
RIM_SEL     <= gpo_misc_oa(3);
TRIG_MODE   <= gpo_misc_oa(4);
TRIG_OUT    <= gpo_misc_oa(5);
EXPOSURE_TIMESTAMP <= gpo_misc_oa(6);
SPI_CS      <= gpo_misc_oa(7);

IPC_SETTINGS <= gpo_misc_ob;

PT_MIN <= gpo_misc_oc;

PT_MAX <= gpo_misc_od;

STADR <= gpo_stadr;
STDAT <= gpo_stdat;

-- GPI
gpi_taster <= "0000" & TASTER;

gpi_misc_ia(0) <= IPC_DONE;
gpi_misc_ia(1) <= FRM_SHOOT;
gpi_misc_ia(2) <= FRM_DONE;
gpi_misc_ia(3) <= FXL_RIM_SEL;
gpi_misc_ia(4) <= CAM_GOOD;
gpi_misc_ia(5) <= PC_OVERRIDE;
gpi_misc_ia(6) <= ARM_READY;
gpi_misc_ia(7) <= '0';

gpi_misc_ib <= (others => '0');

gpi_misc_ic <= (others => '0');

-------------------------------------PROCESSES-------------------------------------

--Assign Reset from Button/DCM to signal:
	Assert_Reset: process(DCM_lockedxS, RESET) is
	begin
		if DCM_lockedxS = '0' or RESET = '1' then
			ResetxS <= '1';
			AVR_ResetxS <= '0'; --AVR needs inverted Reset
		else
			ResetxS <= '0';
			AVR_ResetxS <= '1';
		end if;
		
	end process Assert_Reset;

-------------------------------------INSTANTIATIONS-------------------------------
--AVR CPU:
	CPU_Inst : AVR_Core port map(
	--Clock and reset
		cp2	   	 => CLK_AVR,
		cp2en        => AVR_Clk_EnxS,
		ireset       => AVR_ResetxS,
	-- JTAG OCD support
		valid_instr  => open, --no JTAG is used
		insert_nop   => '0',
		block_irq    => '0',
		change_flow  => open,
   -- Program Memory
		pc           => ProgMemAdrxD, 
		inst         => ProgMemDataxD,
	-- I/O control ==> IO Bus
		adr          => AVR_IoAdrxD,	
		iore         => AVR_IoRexS,            
		iowe         => AVR_IoWexS,					
   -- Data memory control ==> Data Bus
		ramadr       => AVR_RamAdrxD,
		ramre        => AVR_RamRexS,
		ramwe        => AVR_RamWexS,
		cpuwait      => '0',
	-- Data paths for IO / Data Busses
		dbusin       => AVR_dbusinxD,
		dbusout      => AVR_dbusoutxD,
   -- Interrupts
		irqlines     => (others => '0'),
		irqack       => open,
		irqackad     => open,
   --Sleep Control
		sleepi	    => open, 
		irqok	       => open,
		globint	    => open,
   --Watchdog
		wdri	       => open
	);

--Program Memory for the AVR:
	ProgMemInst : ProgMem port map(
		ClkxC 		=> CLK_AVR_180,
      RstxR  		=> ResetxS,
      AdrxDI  		=> ProgMemAdrxD(13 downto 0),
      DoutxDO  	=> ProgMemDataxD
	);
	
--SRAM for the AVR:
	SRAM_Inst : AVR_sram port map(
		ClkxC 	=> CLK_AVR_180,
		RstxR 	=> ResetxS,
		AdrxDI 	=>	Sram_AdrxD,
		DoutxDO 	=> Sram_DataOutxD,
		DinxDI 	=> Sram_DataInxD,
		WExSI 	=> Sram_WexS,
		EnxSI 	=> Sram_EnxS
	);
	
	
--Muxer for Sram/Wishbone-Interface:
	BusMux_Inst : AVR_BusMux port map(
		CLKxC 				=> CLK_AVR,
		ResetxS 				=> ResetxS,
	--AVR side:
		AVR_dbusinxDO  	=> AVR_dbusinxD,
		AVR_dbusoutxDI 	=> AVR_dbusoutxD,
		AVR_RamAdrxDI  	=> AVR_RamAdrxD,
		AVR_IoAdrxDI   	=> AVR_IoAdrxD,
		AVR_IoWexSI 		=>	AVR_IoWexS,
		AVR_IoRexSI 		=> AVR_IoRexS,
		AVR_RamWexSI 		=>	AVR_RamWexS,
		AVR_RamRexSI 		=>	AVR_RamRexS,
	--Sram:
		Sram_AdrxDO 		=> Sram_AdrxD,
		Sram_DataInxDI 	=> Sram_DataOutxD,
		Sram_DataOutxDO 	=> Sram_DataInxD,
		Sram_WexSO 			=> Sram_WexS,	
		Sram_EnxSO			=> Sram_EnxS,
    --Iram
        Iram_AdrxDO => Iram_AdrxD,
		Iram_DataInxDI => Iram_DataInxD,
		Iram_DataOutxDO => Iram_DataOutxD,
		Iram_WexSO => Iram_WexS,
		Iram_EnxSO => Iram_EnxS,
	--Wishbone-AVR-Translator:
		AVR_Wb_IoAdrxDO 	=> AVR_Wb_IoAdrxD,
		AVR_Wb_RamAdrxDO 	=> AVR_Wb_RamAdrxD,
		AVR_Wb_IoRexSO 	=> AVR_Wb_IoRexS,
		AVR_Wb_RamRexSO 	=> AVR_Wb_RamRexS,
		AVR_Wb_IoWexSO 	=> AVR_Wb_IoWexS, 
		AVR_Wb_RamWexSO 	=> AVR_Wb_RamWexS,
		AVR_Wb_DatoutxDO 	=> AVR_Wb_DataoutxD,
		AVR_Wb_DatinxDI 	=> AVR_Wb_DatainxD
	);
	
--AVR to Wishbone Translator/Bridge:
	WB_Transl_Inst : AVR_WB_Translator port map(
		CLK 		 		=> CLK_AVR,
		RST			 	=> ResetxS,
	--AVR Side:	       
		--IO Bus in:	
		AVR_IO_ADR_I 	=>	AVR_Wb_IoAdrxD,
		AVR_iore_I   	=>	AVR_Wb_IoRexS,
		AVR_iowe_I 	 	=>	AVR_Wb_IoWexS,
		--Ram Bus in:	
		AVR_RAMADR_I 	=> AVR_Wb_RamAdrxD,
		AVR_ramre_I  	=> AVR_Wb_RamRexS,
		AVR_ramwe_I  	=> AVR_Wb_RamWexS,
		--Datapath:	    
		AVR_DAT_O 	 	=>	AVR_Wb_DatainxD,
		AVR_DAT_I    	=> AVR_Wb_DataoutxD,
		--CPU wait:	    
		AVR_Clk_EnxSO	=> AVR_Clk_EnxS, 
		                
	--IO Wishbone:	    
		Wb_DAT_IO_O  	=> Wb_DAT_IOxDO,
		Wb_DAT_IO_I  	=> Wb_DAT_IOxDI,
		Wb_ADR_IO_O  	=> Wb_ADR_IOxD,
		Wb_ACK_IO_I  	=> Wb_ACK_IOxS,
		Wb_CYC_IO_O  	=> Wb_CYC_IOxS,
		Wb_STB_IO_O  	=> Wb_STB_IOxS,
		Wb_WE_IO_O   	=> Wb_WE_IOxS,
		               
	--RAM Wishbone:	    
		Wb_DAT_RAM_O 	=> open,
		Wb_DAT_RAM_I 	=> (others => '0'),
		Wb_ADR_RAM_O 	=> open,
		Wb_ACK_RAM_I 	=> '0',
		Wb_CYC_RAM_O 	=> open,
		Wb_STB_RAM_O 	=> open,
		Wb_WE_RAM_O  	=> open
	);
	
	Inst_IO_Devices: IO_Devices PORT MAP(
		CLKxC => CLK_AVR,
		ResetxS => ResetxS,
		Wb_DatxDI => Wb_DAT_IOxDO,
		Wb_DatxDO => Wb_DAT_IOxDI,
		Wb_AckxSO => Wb_ACK_IOxS,
		Wb_AdrxDI => Wb_ADR_IOxD,
		Wb_CycxSI => Wb_CYC_IOxS,
		Wb_StbxSI => Wb_STB_IOxS,
		Wb_WexSI =>  Wb_WE_IOxS,
        
		GPO_0 => gpo_devled,
		GPO_1 => gpo_powerled_val,
        GPO_2 => gpo_misc_oa,
        GPO_3 => gpo_misc_ob,
        GPO_4 => gpo_misc_oc,
        GPO_5 => gpo_misc_od,
        GPO_6 => gpo_stadr,
        GPO_7 => gpo_stdat,
        
		GPI_0 => gpi_taster,
        GPI_1 => gpi_misc_ia,
        GPI_2 => gpi_misc_ib,
        GPI_3 => gpi_misc_ic,
        
        SPI_SCK => SPI_SCK,
		SPI_MOSI => SPI_MOSI,
		SPI_MISO => SPI_MISO,
		SPI_INT => open,
        
		I2C_SCL_I => I2C_SCL_I,
		I2C_SCL_O => I2C_SCL_O,
		I2C_SCL_OE => I2C_SCL_OE,
		I2C_SDA_I => I2C_SDA_I,
		I2C_SDA_O => I2C_SDA_O,
		I2C_SDA_OE => I2C_SDA_OE
	);

--Digital Clock Manager:
	Inst_Clock_Gen : Clock_Gen port map(
		CLKIN_IN => CLK_48,
		RST_IN => '0',              -- don't reset the DCM
		CLKFX_OUT => CLK_AVR,       -- AVR clk
		CLKFX180_OUT => CLK_AVR_180,-- 180deg phase-shifted output
		CLKIN_IBUFG_OUT => open , 
		CLK0_OUT => open,           -- no use for the 48MHz clock
		LOCKED_OUT => DCM_lockedxS  -- use for Reset
	);

end Behavioral;

