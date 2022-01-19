----------------------------------------------------------------------------------
-- IO_Devices.vhd
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
--This hosts all the IO-Devices on the Wb-IO-Bus.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity IO_Devices is
	port(
		CLKxC : in std_logic;
		ResetxS : in std_logic;
        
		--Wishbone-Bus:
		Wb_DatxDI : in std_logic_vector(7 downto 0);
		Wb_DatxDO : out std_logic_vector(7 downto 0);
		Wb_AckxSO : out std_logic;
		Wb_AdrxDI : in std_logic_vector(5 downto 0);
		Wb_CycxSI : in std_logic;
		Wb_StbxSI : in std_logic;
		Wb_WexSI  : in std_logic;
		
        -- GPO
        GPO_0 : out std_logic_vector(7 downto 0);   -- DEVLED
		GPO_1 : out std_logic_vector(7 downto 0);   -- POWERLED_VAL
		GPO_2 : out std_logic_vector(7 downto 0);   -- MISC_OA
		GPO_3 : out std_logic_vector(7 downto 0);   -- MISC_OB
        GPO_4 : out std_logic_vector(7 downto 0);   -- MISC_OC
        GPO_5 : out std_logic_vector(7 downto 0);   -- MISC_OD
		GPO_6 : out std_logic_vector(7 downto 0);   -- STADR
		GPO_7 : out std_logic_vector(7 downto 0);   -- STDAT
        
        -- GPI
		GPI_0 : in std_logic_vector(7 downto 0);    -- TASTER
		GPI_1 : in std_logic_vector(7 downto 0);    -- MISC_IA
		GPI_2 : in std_logic_vector(7 downto 0);    -- MISC_IB
		GPI_3 : in std_logic_vector(7 downto 0);    -- MISC_IC
        
        -- SPI
        SPI_SCK     : out std_logic;
        SPI_MOSI    : out std_logic;
        SPI_MISO    : in  std_logic;
        SPI_INT     : out std_logic;
        
        -- I2C
        I2C_SCL_I   : in  std_logic;                -- i2c clock line input
        I2C_SCL_O   : out std_logic;                -- i2c clock line output
        I2C_SCL_OE  : out std_logic;                -- i2c clock line output enable, active low
        I2C_SDA_I   : in  std_logic;                -- i2c data line input
        I2C_SDA_O   : out std_logic;                -- i2c data line output
        I2C_SDA_OE  : out std_logic                 -- i2c data line output enable, active low
	);
end IO_Devices;

architecture Behavioral of IO_Devices is

--The Conbus works as an arbiter and controls the accesses to the different IO-Devices.
component wb_conbus_top is
	Generic (
			dw 				: integer;
			aw					: integer;
			s0_addr_w 		: integer;
			s0_addr			: integer;
			s1_addr_w		: integer;
			s1_addr			: integer;
			s27_addr_w		: integer;
			s2_addr 		: integer;
			s3_addr 		: integer;
			s4_addr 		: integer;
			s5_addr 		: integer;
			s6_addr 		: integer;
			s7_addr 		: integer);
	Port (
			clk_i		: in  std_logic;
			rst_i		: in  std_logic;
			-- Master 0 Interface
			m0_dat_i	: in  std_logic_vector(dw-1 downto 0);
			m0_dat_o	: out std_logic_vector(dw-1 downto 0);
			m0_adr_i	: in  std_logic_vector(aw-1 downto 0);
			m0_sel_i	: in  std_logic_vector((dw/8)-1 downto 0);
			m0_we_i		: in  std_logic;
			m0_cyc_i	: in  std_logic;
			m0_stb_i	: in  std_logic;
			m0_ack_o	: out std_logic;
			m0_err_o	: out std_logic;
			m0_rty_o	: out std_logic;
			m0_cab_i	: in  std_logic;
			
			-- Master 1 Interface
			m1_dat_i	: in  std_logic_vector(dw-1 downto 0);
			m1_dat_o	: out std_logic_vector(dw-1 downto 0);
			m1_adr_i	: in  std_logic_vector(aw-1 downto 0);
			m1_sel_i	: in  std_logic_vector((dw/8)-1 downto 0);
			m1_we_i		: in  std_logic;
			m1_cyc_i	: in  std_logic;
			m1_stb_i	: in  std_logic;
			m1_ack_o	: out std_logic;
			m1_err_o	: out std_logic;
			m1_rty_o	: out std_logic;
			m1_cab_i	: in  std_logic;

			-- Master 2 Interface
			m2_dat_i	: in  std_logic_vector(dw-1 downto 0);
			m2_dat_o	: out std_logic_vector(dw-1 downto 0);
			m2_adr_i	: in  std_logic_vector(aw-1 downto 0);
			m2_sel_i	: in  std_logic_vector((dw/8)-1 downto 0);
			m2_we_i		: in  std_logic;
			m2_cyc_i	: in  std_logic;
			m2_stb_i	: in  std_logic;
			m2_ack_o	: out std_logic;
			m2_err_o	: out std_logic;
			m2_rty_o	: out std_logic;
			m2_cab_i	: in  std_logic;
			
			-- Master 3 Interface
			m3_dat_i	: in  std_logic_vector(dw-1 downto 0);
			m3_dat_o	: out std_logic_vector(dw-1 downto 0);
			m3_adr_i	: in  std_logic_vector(aw-1 downto 0);
			m3_sel_i	: in  std_logic_vector((dw/8)-1 downto 0);
			m3_we_i		: in  std_logic;
			m3_cyc_i	: in  std_logic;
			m3_stb_i	: in  std_logic;
			m3_ack_o	: out std_logic;
			m3_err_o	: out std_logic;
			m3_rty_o	: out std_logic;
			m3_cab_i	: in  std_logic;
			
			-- Master 4 Interface
			m4_dat_i	: in  std_logic_vector(dw-1 downto 0);
			m4_dat_o	: out std_logic_vector(dw-1 downto 0);
			m4_adr_i	: in  std_logic_vector(aw-1 downto 0);
			m4_sel_i	: in  std_logic_vector((dw/8)-1 downto 0);
			m4_we_i		: in  std_logic;
			m4_cyc_i	: in  std_logic;
			m4_stb_i	: in  std_logic;
			m4_ack_o	: out std_logic;
			m4_err_o	: out std_logic;
			m4_rty_o	: out std_logic;
			m4_cab_i	: in  std_logic;
			
			-- Master 5 Interface
			m5_dat_i	: in  std_logic_vector(dw-1 downto 0);
			m5_dat_o	: out std_logic_vector(dw-1 downto 0);
			m5_adr_i	: in  std_logic_vector(aw-1 downto 0);
			m5_sel_i	: in  std_logic_vector((dw/8)-1 downto 0);
			m5_we_i		: in  std_logic;
			m5_cyc_i	: in  std_logic;
			m5_stb_i	: in  std_logic;
			m5_ack_o	: out std_logic;
			m5_err_o	: out std_logic;
			m5_rty_o	: out std_logic;
			m5_cab_i	: in  std_logic;
			
			-- Master 6 Interface
			m6_dat_i	: in  std_logic_vector(dw-1 downto 0);
			m6_dat_o	: out std_logic_vector(dw-1 downto 0);
			m6_adr_i	: in  std_logic_vector(aw-1 downto 0);
			m6_sel_i	: in  std_logic_vector((dw/8)-1 downto 0);
			m6_we_i		: in  std_logic;
			m6_cyc_i	: in  std_logic;
			m6_stb_i	: in  std_logic;
			m6_ack_o	: out std_logic;
			m6_err_o	: out std_logic;
			m6_rty_o	: out std_logic;
			m6_cab_i	: in  std_logic;
			
			-- Master 7 Interface
			m7_dat_i	: in  std_logic_vector(dw-1 downto 0);
			m7_dat_o	: out std_logic_vector(dw-1 downto 0);
			m7_adr_i	: in  std_logic_vector(aw-1 downto 0);
			m7_sel_i	: in  std_logic_vector((dw/8)-1 downto 0);
			m7_we_i		: in  std_logic;
			m7_cyc_i	: in  std_logic;
			m7_stb_i	: in  std_logic;
			m7_ack_o	: out std_logic;
			m7_err_o	: out std_logic;
			m7_rty_o	: out std_logic;
			m7_cab_i	: in  std_logic;

			--	// Slave 0 Interface
			s0_dat_i	: in  std_logic_vector(dw-1 downto 0);
			s0_dat_o	: out std_logic_vector(dw-1 downto 0);
			s0_adr_o	: out std_logic_vector(aw-1 downto 0);
			s0_sel_o	: out std_logic_vector((dw/8)-1 downto 0);
			s0_we_o		: out std_logic;
			s0_cyc_o	: out std_logic;
			s0_stb_o	: out std_logic;
			s0_ack_i	: in  std_logic;
			s0_err_i	: in  std_logic;
			s0_rty_i	: in  std_logic;
			s0_cab_o	: out std_logic;
			
			--	// Slave 1 Interface
			s1_dat_i	: in  std_logic_vector(dw-1 downto 0);
			s1_dat_o	: out std_logic_vector(dw-1 downto 0);
			s1_adr_o	: out std_logic_vector(aw-1 downto 0);
			s1_sel_o	: out std_logic_vector((dw/8)-1 downto 0);
			s1_we_o		: out std_logic;
			s1_cyc_o	: out std_logic;
			s1_stb_o	: out std_logic;
			s1_ack_i	: in  std_logic;
			s1_err_i	: in  std_logic;
			s1_rty_i	: in  std_logic;
			s1_cab_o	: out std_logic;
			
			--	// Slave 2 Interface
			s2_dat_i	: in  std_logic_vector(dw-1 downto 0);
			s2_dat_o	: out std_logic_vector(dw-1 downto 0);
			s2_adr_o	: out std_logic_vector(aw-1 downto 0);
			s2_sel_o	: out std_logic_vector((dw/8)-1 downto 0);
			s2_we_o		: out std_logic;
			s2_cyc_o	: out std_logic;
			s2_stb_o	: out std_logic;
			s2_ack_i	: in  std_logic;
			s2_err_i	: in  std_logic;
			s2_rty_i	: in  std_logic;
			s2_cab_o	: out std_logic;
			
			--	// Slave 3 Interface
			s3_dat_i	: in  std_logic_vector(dw-1 downto 0);
			s3_dat_o	: out std_logic_vector(dw-1 downto 0);
			s3_adr_o	: out std_logic_vector(aw-1 downto 0);
			s3_sel_o	: out std_logic_vector((dw/8)-1 downto 0);
			s3_we_o		: out std_logic;
			s3_cyc_o	: out std_logic;
			s3_stb_o	: out std_logic;
			s3_ack_i	: in  std_logic;
			s3_err_i	: in  std_logic;
			s3_rty_i	: in  std_logic;
			s3_cab_o	: out std_logic;
			
			--	// Slave 4 Interface
			s4_dat_i	: in  std_logic_vector(dw-1 downto 0);
			s4_dat_o	: out std_logic_vector(dw-1 downto 0);
			s4_adr_o	: out std_logic_vector(aw-1 downto 0);
			s4_sel_o	: out std_logic_vector((dw/8)-1 downto 0);
			s4_we_o		: out std_logic;
			s4_cyc_o	: out std_logic;
			s4_stb_o	: out std_logic;
			s4_ack_i	: in  std_logic;
			s4_err_i	: in  std_logic;
			s4_rty_i	: in  std_logic;
			s4_cab_o	: out std_logic;
			
			--	// Slave 5 Interface
			s5_dat_i	: in  std_logic_vector(dw-1 downto 0);
			s5_dat_o	: out std_logic_vector(dw-1 downto 0);
			s5_adr_o	: out std_logic_vector(aw-1 downto 0);
			s5_sel_o	: out std_logic_vector((dw/8)-1 downto 0);
			s5_we_o		: out std_logic;
			s5_cyc_o	: out std_logic;
			s5_stb_o	: out std_logic;
			s5_ack_i	: in  std_logic;
			s5_err_i	: in  std_logic;
			s5_rty_i	: in  std_logic;
			s5_cab_o	: out std_logic;
			
			--	// Slave 6 Interface
			s6_dat_i	: in  std_logic_vector(dw-1 downto 0);
			s6_dat_o	: out std_logic_vector(dw-1 downto 0);
			s6_adr_o	: out std_logic_vector(aw-1 downto 0);
			s6_sel_o	: out std_logic_vector((dw/8)-1 downto 0);
			s6_we_o		: out std_logic;
			s6_cyc_o	: out std_logic;
			s6_stb_o	: out std_logic;
			s6_ack_i	: in  std_logic;
			s6_err_i	: in  std_logic;
			s6_rty_i	: in  std_logic;
			s6_cab_o	: out std_logic;
			
			--	// Slave 7 Interface
			s7_dat_i	: in  std_logic_vector(dw-1 downto 0);
			s7_dat_o	: out std_logic_vector(dw-1 downto 0);
			s7_adr_o	: out std_logic_vector(aw-1 downto 0);
			s7_sel_o	: out std_logic_vector((dw/8)-1 downto 0);
			s7_we_o		: out std_logic;
			s7_cyc_o	: out std_logic;
			s7_stb_o	: out std_logic;
			s7_ack_i	: in  std_logic;
			s7_err_i	: in  std_logic;
			s7_rty_i	: in  std_logic;
			s7_cab_o	: out std_logic
	);
	end component;
	
-- GPO
	component Wb_GPO
	port(
		CLKxCI : in std_logic;
		ResetxSI : in std_logic;
		Wb_StbxSI : in std_logic;
		Wb_CycxSI : in std_logic;
		Wb_DatainxDI : in std_logic_vector(7 downto 0);
		Wb_AdrxDI : in std_logic_vector(5 downto 0);
		Wb_WexSI : in std_logic;          
		Wb_AckxSO : out std_logic;
		Wb_DataoutxDO : out std_logic_vector(7 downto 0);
		GPO_0 : out std_logic_vector(7 downto 0);   -- DEVLED
		GPO_1 : out std_logic_vector(7 downto 0);   -- POWERLED_VAL
		GPO_2 : out std_logic_vector(7 downto 0);   -- MISC_OA
		GPO_3 : out std_logic_vector(7 downto 0);   -- MISC_OB
		GPO_4 : out std_logic_vector(7 downto 0);   -- MISC_OC
		GPO_5 : out std_logic_vector(7 downto 0);   -- MISC_OD
		GPO_6 : out std_logic_vector(7 downto 0);   -- STADR
		GPO_7 : out std_logic_vector(7 downto 0)    -- STDAT
		);
	end component;
	
-- GPI
	component Wb_GPI is
	port(
		CLKxCI : in std_logic;
		ResetxSI : in std_logic;
		Wb_AckxSO : out std_logic;
		Wb_StbxSI : in std_logic;
		Wb_CycxSI : in std_logic;
		Wb_DatainxDI : in std_logic_vector(7 downto 0);
		Wb_DataoutxDO : out std_logic_vector(7 downto 0);
		Wb_AdrxDI : in std_logic_vector(5 downto 0);
		Wb_WexSI : in std_logic;
		GPI_0 : in std_logic_vector(7 downto 0);    -- TASTER
		GPI_1 : in std_logic_vector(7 downto 0);    -- MISC_IA
		GPI_2 : in std_logic_vector(7 downto 0);    -- MISC_IB
		GPI_3 : in std_logic_vector(7 downto 0)     -- MISC_IC
		);
	end component;

-- I2C
	COMPONENT i2c_master_top
	PORT(
		wb_clk_i : IN std_logic;
		wb_rst_i : IN std_logic;
		arst_i : IN std_logic;
		wb_adr_i : IN std_logic_vector(2 downto 0);
		wb_dat_i : IN std_logic_vector(7 downto 0);
		wb_we_i : IN std_logic;
		wb_stb_i : IN std_logic;
		wb_cyc_i : IN std_logic;
		scl_pad_i : IN std_logic;
		sda_pad_i : IN std_logic;          
		wb_dat_o : OUT std_logic_vector(7 downto 0);
		wb_ack_o : OUT std_logic;
		wb_inta_o : OUT std_logic;
		scl_pad_o : OUT std_logic;
		scl_padoen_o : OUT std_logic;
		sda_pad_o : OUT std_logic;
		sda_padoen_o : OUT std_logic
		);
	END COMPONENT;
    
-- SPI
    COMPONENT simple_spi_top
	PORT(
		clk_i : IN std_logic;
		rst_i : IN std_logic;
		cyc_i : IN std_logic;
		stb_i : IN std_logic;
		adr_i : IN std_logic_vector(1 downto 0);
		we_i : IN std_logic;
		dat_i : IN std_logic_vector(7 downto 0);
		miso_i : IN std_logic;          
		dat_o : OUT std_logic_vector(7 downto 0);
		ack_o : OUT std_logic;
		inta_o : OUT std_logic;
		sck_o : OUT std_logic;
		mosi_o : OUT std_logic
		);
	END COMPONENT;

--For the interconnection between the GPOs and the Conbus:
	signal Wb_GPO_DatxDO : std_logic_vector(7 downto 0);
	signal Wb_GPO_DATxDI : std_logic_vector(7 downto 0);
	signal Wb_GPO_ADRxD : std_logic_vector(5 downto 0);
	signal Wb_GPO_WExS : std_logic;
	signal Wb_GPO_CYCxS : std_logic;
	signal Wb_GPO_STBxS : std_logic;
	signal Wb_GPO_ACKxS : std_logic;

--Interconnection between the GPIs and the Conbus:
	signal Wb_GPI_DatxDO : std_logic_vector(7 downto 0);
	signal Wb_GPI_ADRxD : std_logic_vector(5 downto 0);
	signal Wb_GPI_WExS : std_logic;
	signal Wb_GPI_CYCxS : std_logic;
	signal Wb_GPI_STBxS : std_logic;
	signal Wb_GPI_ACKxS : std_logic;

-- I2C <-> Conbus
	signal Wb_I2C_DATxDI : std_logic_vector(7 downto 0);
	signal Wb_I2C_DATxDO : std_logic_vector(7 downto 0);
	signal Wb_I2C_ADRxD : std_logic_vector(5 downto 0);
	signal Wb_I2C_WExS : std_logic;
	signal Wb_I2C_CYCxS : std_logic;
	signal Wb_I2C_STBxS : std_logic;
	signal Wb_I2C_ACKxS : std_logic;

-- SPI <-> Conbus
	signal Wb_SPI_DATxDI : std_logic_vector(7 downto 0);
	signal Wb_SPI_DATxDO : std_logic_vector(7 downto 0);
	signal Wb_SPI_ADRxD : std_logic_vector(5 downto 0);
	signal Wb_SPI_WExS : std_logic;
	signal Wb_SPI_CYCxS : std_logic;
	signal Wb_SPI_STBxS : std_logic;
	signal Wb_SPI_ACKxS : std_logic;

    signal invResetxS : std_logic;
begin

invResetxS <= not ResetxS;

Wb_IO_conbus_inst : wb_conbus_top
	Generic Map (
		dw 				=> 8, --bus data width
		aw				=> 6, --bus address width
		s0_addr_w 		=> 3,	-- how many bits are decoded to address slave0 ("how many addresses has slave0?) ==> open
		s0_addr			=> 0,	-- 000xxx - higher bits of slave0 address
		s1_addr_w		=> 3,	-- how many bits are decoded to address slave1 - ==> GPO
		s1_addr			=> 1,   -- 001xxx - GPO
		s27_addr_w		=> 3,	-- address widths of slaves 2-7 ==> 2^4=16 Addresses for each slave 2...7
		s2_addr 		=> 2,	-- 010xxx - GPI
		s3_addr 		=> 3,   -- 011xxx - I2C
		s4_addr 		=> 4,   -- 100xxx - SPI
		s5_addr 		=> 5,
		s6_addr 		=> 6,
		s7_addr 		=> 7)
	Port Map (
		clk_i		=> CLKxC,
		rst_i		=> ResetxS,
		-- Master 0 Interface, the AVR translator
		m0_dat_i	=> Wb_DatxDI,
		m0_dat_o	=> Wb_DatxDO,
		m0_adr_i	=> Wb_AdrxDI,
		m0_sel_i	=> "1",		-- dummy signal, no use in 8 bit bus
		m0_we_i	=> Wb_WexSI,
		m0_cyc_i	=> Wb_CycxSI,
		m0_stb_i	=> Wb_StbxSI,
		m0_ack_o	=> Wb_AckxSO,
		m0_err_o	=> open,
		m0_rty_o	=> open,
		m0_cab_i	=> '0',
		-- Master 1 Interface, unused
		m1_dat_i	=> x"00",
		m1_dat_o	=> open,
		m1_adr_i	=> "000000",
		m1_sel_i	=> "0",
		m1_we_i		=> '0',
		m1_cyc_i	=> '0',
		m1_stb_i	=> '0',
		m1_ack_o	=> open,
		m1_err_o	=> open,
		m1_rty_o	=> open,  
		m1_cab_i	=> '0', 
		-- Master 2 Interface, unused
		m2_dat_i	=> x"00",
		m2_dat_o	=> open,
		m2_adr_i	=> "000000",
		m2_sel_i	=> "0",
		m2_we_i		=> '0',
		m2_cyc_i	=> '0',
		m2_stb_i	=> '0',
		m2_ack_o	=> open,
		m2_err_o	=> open,
		m2_rty_o	=> open,  
		m2_cab_i	=> '0', 
		-- Master 3 Interface, unused
		m3_dat_i	=> x"00",
		m3_dat_o	=> open,
		m3_adr_i	=> "000000",
		m3_sel_i	=> "0",
		m3_we_i		=> '0',
		m3_cyc_i	=> '0',
		m3_stb_i	=> '0',
		m3_ack_o	=> open,
		m3_err_o	=> open,
		m3_rty_o	=> open,  
		m3_cab_i	=> '0', 
		-- Master 4 Interface, unused
		m4_dat_i	=> x"00",
		m4_dat_o	=> open,
		m4_adr_i	=> "000000",
		m4_sel_i	=> "0",
		m4_we_i		=> '0',
		m4_cyc_i	=> '0',
		m4_stb_i	=> '0',
		m4_ack_o	=> open,
		m4_err_o	=> open,
		m4_rty_o	=> open,  
		m4_cab_i	=> '0', 
		-- Master 5 Interface, unused
		m5_dat_i	=> x"00",
		m5_dat_o	=> open,
		m5_adr_i	=> "000000",
		m5_sel_i	=> "0",
		m5_we_i		=> '0',
		m5_cyc_i	=> '0',
		m5_stb_i	=> '0',
		m5_ack_o	=> open,
		m5_err_o	=> open,
		m5_rty_o	=> open,  
		m5_cab_i	=> '0', 
		-- Master 6 Interface, unused
		m6_dat_i	=> x"00",
		m6_dat_o	=> open,
		m6_adr_i	=> "000000",
		m6_sel_i	=> "0",
		m6_we_i		=> '0',
		m6_cyc_i	=> '0',
		m6_stb_i	=> '0',
		m6_ack_o	=> open,
		m6_err_o	=> open,
		m6_rty_o	=> open,  
		m6_cab_i	=> '0', 
		-- Master 7 Interface, unused
		m7_dat_i	=> x"00",
		m7_dat_o	=> open,
		m7_adr_i	=> "000000",
		m7_sel_i	=> "0",
		m7_we_i		=> '0',
		m7_cyc_i	=> '0',
		m7_stb_i	=> '0',
		m7_ack_o	=> open,
		m7_err_o	=> open,
		m7_rty_o	=> open,  
		m7_cab_i	=> '0', 
		--	Slave 0 Interface - unused
		s0_dat_i	=> x"00",
		s0_dat_o	=> open,
		s0_adr_o	=> open,
		s0_sel_o	=> open,
		s0_we_o	=> open,
		s0_cyc_o	=> open,
		s0_stb_o	=> open,
		s0_ack_i	=> '0',
		s0_err_i	=> '0',
		s0_rty_i	=> '0',
		s0_cab_o	=> open,
		--	Slave 1 Interface - GPO
		s1_dat_i	=> Wb_GPO_DATxDI,
		s1_dat_o	=> Wb_GPO_DATxDO,
		s1_adr_o	=> Wb_GPO_ADRxD,
		s1_sel_o	=> open,
		s1_we_o	=> Wb_GPO_WExS,
		s1_cyc_o	=> Wb_GPO_CYCxS,
		s1_stb_o	=> Wb_GPO_STBxS,
		s1_ack_i	=> Wb_GPO_ACKxS,
		s1_err_i	=> '0',
		s1_rty_i	=> '0',
		s1_cab_o	=> open, 
		--	Slave 2 Interface - GPI
		s2_dat_i	=> Wb_GPI_DATxDO,
		s2_dat_o	=> open,
		s2_adr_o	=> Wb_GPI_ADRxD,
		s2_sel_o	=> open,
		s2_we_o	=> Wb_GPI_WExS,
		s2_cyc_o	=> Wb_GPI_CYCxS,
		s2_stb_o	=> Wb_GPI_STBxS,
		s2_ack_i	=> Wb_GPI_ACKxS,
		s2_err_i	=> '0',
		s2_rty_i	=> '0',
		s2_cab_o	=> open,
		--	Slave 3 Interface - I2C
		s3_dat_i	=> Wb_I2C_DATxDI,
		s3_dat_o	=> Wb_I2C_DATxDO,
		s3_adr_o	=> Wb_I2C_ADRxD,
		s3_sel_o	=> open,
		s3_we_o     => Wb_I2C_WExS,
		s3_cyc_o	=> Wb_I2C_CYCxS,
		s3_stb_o	=> Wb_I2C_STBxS,
		s3_ack_i	=> Wb_I2C_ACKxS,
		s3_err_i	=> '0',
		s3_rty_i	=> '0',
		s3_cab_o	=> open,
		--	Slave 4 Interface - SPI
		s4_dat_i	=> Wb_SPI_DATxDI,
		s4_dat_o	=> Wb_SPI_DATxDO,
		s4_adr_o	=> Wb_SPI_ADRxD,
		s4_sel_o	=> open,
		s4_we_o     => Wb_SPI_WExS,
		s4_cyc_o	=> Wb_SPI_CYCxS,
		s4_stb_o	=> Wb_SPI_STBxS,
		s4_ack_i	=> Wb_SPI_ACKxS,
		s4_err_i	=> '0',
		s4_rty_i	=> '0',
		s4_cab_o	=> open,
		--	Slave 5 Interface - unused
		s5_dat_i	=> x"00",
		s5_dat_o	=> open,
		s5_adr_o	=> open,
		s5_sel_o	=> open,
		s5_we_o	=> open,
		s5_cyc_o	=> open,
		s5_stb_o	=> open,
		s5_ack_i	=> '0',
		s5_err_i	=> '0',
		s5_rty_i	=> '0',
		s5_cab_o	=> open,
		--	Slave 6 Interface - unused
		s6_dat_i	=> x"00",
		s6_dat_o	=> open,
		s6_adr_o	=> open,
		s6_sel_o	=> open,
		s6_we_o	=> open,
		s6_cyc_o	=> open,
		s6_stb_o	=> open,
		s6_ack_i	=> '0',
		s6_err_i	=> '0',
		s6_rty_i	=> '0',
		s6_cab_o	=> open,
		--	Slave 7 Interface - unused
		s7_dat_i	=> x"00",
		s7_dat_o	=> open,
		s7_adr_o	=> open,
		s7_sel_o	=> open,
		s7_we_o	=> open,
		s7_cyc_o	=> open,
		s7_stb_o	=> open,
		s7_ack_i	=> '0',
		s7_err_i	=> '0',
		s7_rty_i	=> '0',
		s7_cab_o	=> open	
	);
	
Inst_Wb_GPO: Wb_GPO port map(
		CLKxCI => CLKxC,
		ResetxSI => ResetxS,
		Wb_AckxSO => Wb_GPO_ACKxS,
		Wb_StbxSI => Wb_GPO_STBxS,
		Wb_CycxSI => Wb_GPO_CYCxS,
		Wb_DatainxDI => Wb_GPO_DATxDO,
		Wb_DataoutxDO => Wb_GPO_DATxDI,
		Wb_AdrxDI => Wb_GPO_ADRxD,
		Wb_WexSI =>  Wb_GPO_WExS,
		GPO_0 => GPO_0,
		GPO_1 => GPO_1,
        GPO_2 => GPO_2,
        GPO_3 => GPO_3,
        GPO_4 => GPO_4,
        GPO_5 => GPO_5,
        GPO_6 => GPO_6,
        GPO_7 => GPO_7
	);
	
Inst_Wb_GPI: Wb_GPI port map(
		CLKxCI  => CLKxC,
		ResetxSI => ResetxS,
		Wb_AckxSO => Wb_GPI_ACKxS,
		Wb_StbxSI => Wb_GPI_STBxS,
		Wb_CycxSI => WB_GPI_CYCxS,
		Wb_DatainxDI => (others => '0'),
		Wb_DataoutxDO => Wb_GPI_DATxDO,
		Wb_AdrxDI => Wb_GPI_ADRxD,
		Wb_WexSI => Wb_GPI_WExS,
		GPI_0 => GPI_0,
        GPI_1 => GPI_1,
        GPI_2 => GPI_2,
        GPI_3 => GPI_3
	);

Inst_i2c_master_top: i2c_master_top PORT MAP(
		wb_clk_i => CLKxC,
		wb_rst_i => ResetxS,
		arst_i => '1', -- reset is low active
		wb_adr_i => Wb_I2C_ADRxD(2 downto 0),
		wb_dat_i => Wb_I2C_DATxDO,
		wb_dat_o => Wb_I2C_DATxDI,
		wb_we_i => Wb_I2C_WExS,
		wb_stb_i => Wb_I2C_STBxS,
		wb_cyc_i => Wb_I2C_CYCxS,
		wb_ack_o => Wb_I2C_ACKxS,
		wb_inta_o => open,
		scl_pad_i => I2C_SCL_I,
		scl_pad_o => I2C_SCL_O,
		scl_padoen_o => I2C_SCL_OE,
		sda_pad_i => I2C_SDA_I,
		sda_pad_o => I2C_SDA_O,
		sda_padoen_o => I2C_SDA_OE
	);

Inst_simple_spi_top: simple_spi_top PORT MAP(
        clk_i => CLKxC,
        rst_i => invResetxS,
        cyc_i => Wb_SPI_CYCxS,
        stb_i => Wb_SPI_STBxS,
        adr_i => Wb_SPI_ADRxD(1 downto 0),
        we_i => Wb_SPI_WExS,
        dat_i => Wb_SPI_DATxDO,
        dat_o => Wb_SPI_DATxDI,
        ack_o => Wb_SPI_ACKxS,
        inta_o => SPI_INT,
        sck_o => SPI_SCK,
        mosi_o => SPI_MOSI,
        miso_i => SPI_MISO
    );

end Behavioral;
