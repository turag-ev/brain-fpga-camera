----------------------------------------------------------------------------------
-- AVR_ProgMem.vhd
--
-- Copyright (C) 2010 Lukas Schrittwieser, Mario Mauerer
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

--This is the 32kB Program Memory for the AVR. (16k Words) It is initialized with the Program Code. The Init-constants
--are generated with the "data2mem" tool and are stored in the file progMemInit.vhd.
--The file prog_mem.bmm defines the memory structure.
--It needs a 180deg phase shifted clock in order to be able to deliever data at every AVR-clock cycle. (AVR demands data and wants to read it in the next cycle....)

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_arith.all;
library UNISIM;
use UNISIM.VComponents.all;

use work.progMemInit_pkg_prog_adr_space.all;


entity ProgMem is
    Port (
        ClkxC   : in  std_logic;
        RstxR   : in  std_logic;
        AdrxDI  : in  std_logic_vector(13 downto 0);
        DoutxDO : out std_logic_vector(15 downto 0)
    );
end ProgMem;

architecture Behavioral of ProgMem is
    constant ADRWIDTH   : integer := 12;
    constant DI_INIT    : std_logic_vector(3 downto 0) := (others => '0');
    signal AdrxDI_x     : std_logic_vector(ADRWIDTH-1 downto 0);
begin
    AdrxDI_x <= AdrxDI(ADRWIDTH-1 downto 0);

		BRamInst0 : RAMB16_S4
		generic map (
			INIT => X"00000", --  Value of output RAM registers at startup
			SRVAL => X"00000", --  Ouput value upon SSR assertion
			INIT_00 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_00,
			INIT_01 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_01,
			INIT_02 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_02,
			INIT_03 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_03,
			INIT_04 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_04,
			INIT_05 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_05,
			INIT_06 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_06,
			INIT_07 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_07,
			INIT_08 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_08,
			INIT_09 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_09,
			INIT_0A => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_0A,
			INIT_0B => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_0B,
			INIT_0C => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_0C,
			INIT_0D => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_0D,
			INIT_0E => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_0E,
			INIT_0F => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_0F,
			INIT_10 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_10,
			INIT_11 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_11,
			INIT_12 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_12,
			INIT_13 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_13,
			INIT_14 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_14,
			INIT_15 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_15,
			INIT_16 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_16,
			INIT_17 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_17,
			INIT_18 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_18,
			INIT_19 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_19,
			INIT_1A => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_1A,
			INIT_1B => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_1B,
			INIT_1C => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_1C,
			INIT_1D => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_1D,
			INIT_1E => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_1E,
			INIT_1F => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_1F,
			INIT_20 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_10,
			INIT_21 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_21,
			INIT_22 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_22,
			INIT_23 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_23,
			INIT_24 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_24,
			INIT_25 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_25,
			INIT_26 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_26,
			INIT_27 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_27,
			INIT_28 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_28,
			INIT_29 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_29,
			INIT_2A => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_2A,
			INIT_2B => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_2B,
			INIT_2C => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_2C,
			INIT_2D => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_2D,
			INIT_2E => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_2E,
			INIT_2F => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_2F,
			INIT_30 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_30,
			INIT_31 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_31,
			INIT_32 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_32,
			INIT_33 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_33,
			INIT_34 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_34,
			INIT_35 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_35,
			INIT_36 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_36,
			INIT_37 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_37,
			INIT_38 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_38,
			INIT_39 => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_39,
			INIT_3A => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_3A,
			INIT_3B => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_3B,
			INIT_3C => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_3C,
			INIT_3D => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_3D,
			INIT_3E => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_3E,
			INIT_3F => instSofti_instAVR_ProgMemInst_BRamInst0_INIT_3F,                     
			WRITE_MODE => "WRITE_FIRST" --  WRITE_FIRST, READ_FIRST or NO_CHANGE
		)
			port map (
			DO => DoutxDO(3 downto 0),
			ADDR => AdrxDI_x,  		-- Address Input
			CLK => ClkxC,    		-- Clock
			DI => DI_INIT,      		-- Data Input
			EN => '1',      		-- RAM Enable Input
			SSR => RstxR,    		-- Synchronous Set/Reset Input
			WE => '0'       		-- Write Enable Input
		);
--	end generate;
		BRamInst1 : RAMB16_S4
		generic map (
			INIT => X"00000", --  Value of output RAM registers at startup
			SRVAL => X"00000", --  Ouput value upon SSR assertion
			INIT_00 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_00,
			INIT_01 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_01,
			INIT_02 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_02,
			INIT_03 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_03,
			INIT_04 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_04,
			INIT_05 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_05,
			INIT_06 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_06,
			INIT_07 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_07,
			INIT_08 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_08,
			INIT_09 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_09,
			INIT_0A => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_0A,
			INIT_0B => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_0B,
			INIT_0C => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_0C,
			INIT_0D => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_0D,
			INIT_0E => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_0E,
			INIT_0F => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_0F,
			INIT_10 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_10,
			INIT_11 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_11,
			INIT_12 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_12,
			INIT_13 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_13,
			INIT_14 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_14,
			INIT_15 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_15,
			INIT_16 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_16,
			INIT_17 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_17,
			INIT_18 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_18,
			INIT_19 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_19,
			INIT_1A => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_1A,
			INIT_1B => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_1B,
			INIT_1C => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_1C,
			INIT_1D => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_1D,
			INIT_1E => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_1E,
			INIT_1F => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_1F,
			INIT_20 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_10,
			INIT_21 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_21,
			INIT_22 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_22,
			INIT_23 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_23,
			INIT_24 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_24,
			INIT_25 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_25,
			INIT_26 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_26,
			INIT_27 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_27,
			INIT_28 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_28,
			INIT_29 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_29,
			INIT_2A => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_2A,
			INIT_2B => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_2B,
			INIT_2C => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_2C,
			INIT_2D => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_2D,
			INIT_2E => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_2E,
			INIT_2F => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_2F,
			INIT_30 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_30,
			INIT_31 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_31,
			INIT_32 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_32,
			INIT_33 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_33,
			INIT_34 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_34,
			INIT_35 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_35,
			INIT_36 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_36,
			INIT_37 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_37,
			INIT_38 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_38,
			INIT_39 => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_39,
			INIT_3A => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_3A,
			INIT_3B => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_3B,
			INIT_3C => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_3C,
			INIT_3D => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_3D,
			INIT_3E => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_3E,
			INIT_3F => instSofti_instAVR_ProgMemInst_BRamInst1_INIT_3F,
			WRITE_MODE => "WRITE_FIRST" --  WRITE_FIRST, READ_FIRST or NO_CHANGE
		)
			port map (
			DO => DoutxDO(7 downto 4),
			ADDR => AdrxDI_x,  		-- Address Input
			CLK => ClkxC,    		-- Clock
			DI => DI_INIT,      		-- Data Input
			EN => '1',      		-- RAM Enable Input
			SSR => RstxR,    		-- Synchronous Set/Reset Input
			WE => '0'       		-- Write Enable Input
		);
		BRamInst2 : RAMB16_S4
		generic map (
			INIT => X"00000", --  Value of output RAM registers at startup
			SRVAL => X"00000", --  Ouput value upon SSR assertion   
			INIT_00 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_00,
			INIT_01 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_01,
			INIT_02 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_02,
			INIT_03 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_03,
			INIT_04 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_04,
			INIT_05 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_05,
			INIT_06 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_06,
			INIT_07 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_07,
			INIT_08 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_08,
			INIT_09 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_09,
			INIT_0A => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_0A,
			INIT_0B => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_0B,
			INIT_0C => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_0C,
			INIT_0D => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_0D,
			INIT_0E => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_0E,
			INIT_0F => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_0F,
			INIT_10 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_10,
			INIT_11 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_11,
			INIT_12 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_12,
			INIT_13 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_13,
			INIT_14 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_14,
			INIT_15 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_15,
			INIT_16 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_16,
			INIT_17 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_17,
			INIT_18 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_18,
			INIT_19 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_19,
			INIT_1A => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_1A,
			INIT_1B => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_1B,
			INIT_1C => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_1C,
			INIT_1D => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_1D,
			INIT_1E => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_1E,
			INIT_1F => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_1F,
			INIT_20 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_10,
			INIT_21 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_21,
			INIT_22 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_22,
			INIT_23 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_23,
			INIT_24 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_24,
			INIT_25 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_25,
			INIT_26 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_26,
			INIT_27 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_27,
			INIT_28 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_28,
			INIT_29 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_29,
			INIT_2A => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_2A,
			INIT_2B => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_2B,
			INIT_2C => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_2C,
			INIT_2D => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_2D,
			INIT_2E => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_2E,
			INIT_2F => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_2F,
			INIT_30 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_30,
			INIT_31 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_31,
			INIT_32 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_32,
			INIT_33 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_33,
			INIT_34 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_34,
			INIT_35 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_35,
			INIT_36 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_36,
			INIT_37 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_37,
			INIT_38 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_38,
			INIT_39 => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_39,
			INIT_3A => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_3A,
			INIT_3B => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_3B,
			INIT_3C => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_3C,
			INIT_3D => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_3D,
			INIT_3E => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_3E,
			INIT_3F => instSofti_instAVR_ProgMemInst_BRamInst2_INIT_3F,
			WRITE_MODE => "WRITE_FIRST" --  WRITE_FIRST, READ_FIRST or NO_CHANGE
		)
			port map (
			DO => DoutxDO(11 downto 8),
			ADDR => AdrxDI_x,  		-- Address Input
			CLK => ClkxC,    		-- Clock
			DI => DI_INIT,      		-- Data Input
			EN => '1',      		-- RAM Enable Input
			SSR => RstxR,    		-- Synchronous Set/Reset Input
			WE => '0'       		-- Write Enable Input
		);
		BRamInst3 : RAMB16_S4
		generic map (
			INIT => X"00000", --  Value of output RAM registers at startup
			SRVAL => X"00000", --  Ouput value upon SSR assertion
			INIT_00 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_00,
			INIT_01 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_01,
			INIT_02 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_02,
			INIT_03 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_03,
			INIT_04 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_04,
			INIT_05 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_05,
			INIT_06 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_06,
			INIT_07 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_07,
			INIT_08 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_08,
			INIT_09 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_09,
			INIT_0A => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_0A,
			INIT_0B => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_0B,
			INIT_0C => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_0C,
			INIT_0D => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_0D,
			INIT_0E => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_0E,
			INIT_0F => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_0F,
			INIT_10 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_10,
			INIT_11 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_11,
			INIT_12 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_12,
			INIT_13 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_13,
			INIT_14 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_14,
			INIT_15 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_15,
			INIT_16 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_16,
			INIT_17 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_17,
			INIT_18 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_18,
			INIT_19 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_19,
			INIT_1A => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_1A,
			INIT_1B => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_1B,
			INIT_1C => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_1C,
			INIT_1D => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_1D,
			INIT_1E => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_1E,
			INIT_1F => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_1F,
			INIT_20 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_10,
			INIT_21 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_21,
			INIT_22 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_22,
			INIT_23 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_23,
			INIT_24 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_24,
			INIT_25 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_25,
			INIT_26 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_26,
			INIT_27 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_27,
			INIT_28 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_28,
			INIT_29 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_29,
			INIT_2A => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_2A,
			INIT_2B => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_2B,
			INIT_2C => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_2C,
			INIT_2D => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_2D,
			INIT_2E => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_2E,
			INIT_2F => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_2F,
			INIT_30 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_30,
			INIT_31 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_31,
			INIT_32 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_32,
			INIT_33 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_33,
			INIT_34 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_34,
			INIT_35 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_35,
			INIT_36 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_36,
			INIT_37 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_37,
			INIT_38 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_38,
			INIT_39 => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_39,
			INIT_3A => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_3A,
			INIT_3B => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_3B,
			INIT_3C => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_3C,
			INIT_3D => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_3D,
			INIT_3E => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_3E,
			INIT_3F => instSofti_instAVR_ProgMemInst_BRamInst3_INIT_3F,
			
			WRITE_MODE => "WRITE_FIRST" --  WRITE_FIRST, READ_FIRST or NO_CHANGE
		)
			port map (
			DO => DoutxDO(15 downto 12),
			ADDR => AdrxDI_x,  		-- Address Input
			CLK => ClkxC,    		-- Clock
			DI => DI_INIT,      		-- Data Input
			EN => '1',      		-- RAM Enable Input
			SSR => RstxR,    		-- Synchronous Set/Reset Input
			WE => '0'       		-- Write Enable Input
		);
		
end Behavioral;

