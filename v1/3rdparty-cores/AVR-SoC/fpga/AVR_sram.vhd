----------------------------------------------------------------------------------
-- AVR_sram.vhd
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

--This is the 8kB SRAM for the AVR.
--It needs a 180deg phase shifted clock in order to be able to deliever data at every AVR-clock cycle. (AVR demands data and wants to read it in the next cycle....)


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VComponents.all;


entity AVR_sram is
    Port ( 
			ClkxC 	: in  std_logic;
			RstxR 	: in  std_logic;
			
			AdrxDI 	: in  std_logic_vector(12 downto 0);
			DoutxDO 	: out  std_logic_vector(7 downto 0);
			DinxDI 	: in std_logic_vector(7 downto 0);
			WExSI 	: in std_logic;
			EnxSI 	: in std_logic
			);
end AVR_sram;

architecture Behavioral of AVR_sram is

begin

	BRamInst0 : RAMB16_S4
		generic map (
		INIT => "00", --  Value of output RAM registers at startup
		SRVAL => "00", --  Ouput value upon SSR assertion
		WRITE_MODE => "WRITE_FIRST" --  WRITE_FIRST, READ_FIRST or NO_CHANGE
					)
		port map (
					DO => DoutxDO(3 downto 0),
					ADDR => AdrxDI(11 downto 0),  		-- Address Input
					CLK => ClkxC,    		-- Clock
					DI => DinxDI(3 downto 0),  -- Data Input
					EN => EnxSI,      		-- RAM Enable Input
					SSR => RstxR,    		-- Synchronous Set/Reset Input
					WE => WexSI       		-- Write Enable Input
		);
		
	BRamInst1 : RAMB16_S4
		generic map (
		INIT => "00", --  Value of output RAM registers at startup
		SRVAL => "00", --  Ouput value upon SSR assertion
		WRITE_MODE => "WRITE_FIRST" --  WRITE_FIRST, READ_FIRST or NO_CHANGE
					)
		port map (
					DO => DoutxDO(7 downto 4),
					ADDR => AdrxDI(11 downto 0),  		-- Address Input
					CLK => ClkxC,    		-- Clock
					DI => DinxDI(7 downto 4),  -- Data Input
					EN => EnxSI,      		-- RAM Enable Input
					SSR => RstxR,    		-- Synchronous Set/Reset Input
					WE => WexSI       		-- Write Enable Input
		);

end Behavioral;

