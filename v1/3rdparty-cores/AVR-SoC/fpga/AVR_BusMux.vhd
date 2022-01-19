----------------------------------------------------------------------------------
-- AVR_BusMux.vhd
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
--This is the Bus-Muxer. It directs the data from the AVR to the correct locations (Wb-Translator, SRAM or "Dummy-Device").


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity AVR_BusMux is
	port(
			CLKxC 				: in std_logic;
			ResetxS 				: in std_logic;
	--AVR side:
			AVR_dbusinxDO 		: out std_logic_vector(7 downto 0);
			AVR_dbusoutxDI		: in std_logic_vector(7 downto 0);
			
			AVR_RamAdrxDI 		: in std_logic_vector(15 downto 0);
			AVR_IoAdrxDI 		: in std_logic_vector(5 downto 0);
			
			AVR_IoWexSI 		: in std_logic;
			AVR_IoRexSI 		: in std_logic;
			AVR_RamWexSI 		: in std_logic;
			AVR_RamRexSI 		: in std_logic;
	--Sram:
			Sram_AdrxDO 		: out std_logic_vector(12 downto 0);
			Sram_DataInxDI		: in std_logic_vector(7 downto 0);
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
			AVR_Wb_RamAdrxDO	: out std_logic_vector(15 downto 0);
			AVR_Wb_IoRexSO 	: out std_logic;
			AVR_Wb_RamRexSO 	: out std_logic;
			AVR_Wb_IoWexSO 	: out std_logic;
			AVR_Wb_RamWexSO 	: out std_logic;
			AVR_Wb_DatoutxDO 	: out std_logic_vector(7 downto 0);
			AVR_Wb_DatinxDI 	: in std_logic_vector(7 downto 0)
	);
end AVR_BusMux;

architecture Behavioral of AVR_BusMux is

	signal AVR_DataOut_DelayxDN, AVR_DataOut_DelayxDP : std_logic_vector(7 downto 0); --The Data on the Ram-Bus need to be delayed by one cycle! ==> this FF does that. (But the delay may not affect the IO-transfers!)

begin
	
	DelayData: process(AVR_dbusoutxDI) is
	begin
		AVR_DataOut_DelayxDN <= AVR_dbusoutxDI; --Load the data-delay-FF
	end process DelayData;

--Direct the datastreams:
	DataMux : process(AVR_RamAdrxDI, AVR_IoAdrxDI, AVR_RamRexSI, AVR_RamWexSI, Sram_DatainxDI, Iram_DatainxDI, AVR_Wb_DatinxDI, AVR_IoRexSI, AVR_RamRexSI, AVR_IoWexSI, AVR_RamWexSI) is
	begin
	--Bus Mux For SRAM/RAM_Wishbone:
		if AVR_RamAdrxDI >= 0 and AVR_RamAdrxDI <= x"1fff" and (AVR_RamRexSI = '1' or AVR_RamWexSI = '1') then
            -- Sram, 8 kB max.
			AVR_dbusinxDO <= Sram_DataInxDI;
			Sram_EnxSO <= '1';
            Iram_EnxSO <= '0';
			
			AVR_Wb_RamRexSO <= '0';
			AVR_Wb_RamWexSO <= '0';
		elsif AVR_RamAdrxDI(15) = '1' and (AVR_RamRexSI = '1' or AVR_RamWexSI = '1') then
            -- Img RAM, addresses 0x8000 - 0xffff => 32 kB max
			AVR_dbusinxDO <= Iram_DataInxDI;
			Iram_EnxSO <= '1';
            Sram_EnxSO <= '0';
			
			AVR_Wb_RamRexSO <= '0';
			AVR_Wb_RamWexSO <= '0';	
		else
            -- Wb
			AVR_dbusinxDO <= AVR_Wb_DatinxDI;
			Sram_EnxSO <= '0';
            Iram_EnxSO <= '0';
			
			AVR_Wb_RamRexSO <= AVR_RamRexSI;
			AVR_Wb_RamWexSO <= AVR_RamWexSI;
		end if;
        
		--Bus Mux for "Dummy Device"/IO_Wishbone	
		--dummy-device-access(output of stack pointer etc. at IO Bus) ==> ignore all of them!
		if AVR_IoAdrxDI >= x"34" and AVR_IoAdrxDI <= x"3F" then --
			AVR_Wb_IoRexSO <= '0'; --dont allow the Wb-Translator to do anything (e.g stalling the cpu and getting no ack...)
			AVR_Wb_IoWexSO <= '0';
		else
			AVR_Wb_IoRexSO <= AVR_IoRexSI; --normal access to Wb-Interface
			AVR_Wb_IoWexSO <= AVR_IoWexSI;
		end if;
	end process DataMux;
	
--Delay ONLY the databus:
	DelayDataBus : process(AVR_DataOut_DelayxDP, AVR_RamRexSI, AVR_RamWexSI, AVR_dbusoutxDI) is
	begin
		Sram_DataOutxDO <= AVR_DataOut_DelayxDP; --The SRAM always gets the delayed data.
        Iram_DataOutxDO <= AVR_DataOut_DelayxDP;
        
		--Wb-Side: Only delay the Data, if an access to the RAM-Bus is made!
		if AVR_RamRexSI = '1' or AVR_RamWexSI = '1' then --Delay, if there is a RAM-Wb-Access!
			AVR_Wb_DatoutxDO <= AVR_DataOut_DelayxDP;
		else --Access to IO-Bus:
			AVR_Wb_DatoutxDO <= AVR_dbusoutxDI; --don't delay the data!
		end if;
	end process DelayDataBus;

--Direct the datastreams:
	SignalDistribution : process (AVR_dbusoutxDI, AVR_DataOut_DelayxDP, AVR_RamWexSI, AVR_RamAdrxDI, AVR_IoAdrxDI, AVR_RamAdrxDI, AVR_IoRexSI, AVR_IoWexSI) is
	begin
		Sram_WexSO <= AVR_RamWexSI;
		Sram_AdrxDO <= AVR_RamAdrxDI(12 downto 0);
		
        Iram_WexSO <= AVR_RamWexSI;
		Iram_AdrxDO <= AVR_RamAdrxDI(14 downto 0);
        
		AVR_Wb_IoAdrxDO <= AVR_IoAdrxDI;
		AVR_Wb_RamAdrxDO <= AVR_RamAdrxDI;
	end process SignalDistribution;
	
--Update the FlipFlops:
	FF_update: process(CLKxC) is
	begin
		if rising_edge(CLKxC) then
			if ResetxS = '1' then
				AVR_DataOut_DelayxDP <= (others => '0');
			else
				AVR_DataOut_DelayxDP <= AVR_DataOut_DelayxDN;
			end if;
		end if;
	end process FF_update;
	
end Behavioral;

