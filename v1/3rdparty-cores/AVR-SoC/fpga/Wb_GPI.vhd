----------------------------------------------------------------------------------
-- Wb_GPI.vhd
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
--This provides a simple Input-Device; Data can be read in using the IO-Wishbone-Bus and the AVR-SoC.
--Up to 8 8-bit vectors can be used as input.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Wb_GPI is
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
		--GPI_4 : in std_logic_vector(7 downto 0);
		--GPI_5 : in std_logic_vector(7 downto 0);
		--GPI_6 : in std_logic_vector(7 downto 0);
		--GPI_7 : in std_logic_vector(7 downto 0);
	);
end Wb_GPI;

architecture Behavioral of Wb_GPI is

--input synchronizing FlipFlops: (2-stage sync in order to avoid metastability)
-- yeah wtf
signal GPI_0_0xDN, GPI_0_0xDP, GPI_0_1xDN, GPI_0_1xDP : std_logic_vector(7 downto 0);
signal GPI_1_0xDN, GPI_1_0xDP, GPI_1_1xDN, GPI_1_1xDP : std_logic_vector(7 downto 0);
signal GPI_2_0xDN, GPI_2_0xDP, GPI_2_1xDN, GPI_2_1xDP : std_logic_vector(7 downto 0);
signal GPI_3_0xDN, GPI_3_0xDP, GPI_3_1xDN, GPI_3_1xDP : std_logic_vector(7 downto 0);

signal ackxSN, ackxSP : std_logic; --ack-FF
signal outputxSN, outputxSP : std_logic_vector(7 downto 0); --output-FF

begin

Wb_DataoutxDO <= outputxSP; --assign output

--Synchronize the Data in:
Input_Sync: process(GPI_0, GPI_0_0xDP, GPI_1, GPI_1_0xDP, GPI_2, GPI_2_0xDP, GPI_3, GPI_3_0xDP) is
begin
    GPI_0_0xDN <= GPI_0;        --first stage
    GPI_0_1xDN <= GPI_0_0xDP;   --second stage.
    
    GPI_1_0xDN <= GPI_1;
	GPI_1_1xDN <= GPI_1_0xDP;
    
    GPI_2_0xDN <= GPI_2;
	GPI_2_1xDN <= GPI_2_0xDP;
    
    GPI_3_0xDN <= GPI_3;
	GPI_3_1xDN <= GPI_3_0xDP;
end process Input_Sync;

--Generate the Wishbone-Ack-Pulse:
Wb_handler : process(Wb_CycxSI, ackxSP, Wb_StbxSI) is 
begin
	Wb_AckxSO <= ackxSP and Wb_StbxSI; --generate ack-pulse.
	ackxSN <= Wb_CycxSI and Wb_StbxSI;
end process Wb_handler;


--Put Data out to the Wishbone-Bus if requested:
Dataread: process(Wb_WexSI, Wb_CycxSI, Wb_StbxSI, Wb_AdrxDI, GPI_0_1xDP, outputxSP) is
begin
    -- if Address = 0x10: (TASTER)
    if Wb_WexSI = '0' and Wb_CycxSI = '1' and Wb_StbxSI = '1' and Wb_AdrxDI = "010000" then
        outputxSN <= GPI_0_1xDP;    --put data out.
    elsif Wb_WexSI = '0' and Wb_CycxSI = '1' and Wb_StbxSI = '1' and Wb_AdrxDI = "010001" then
    -- 0x11
        outputxSN <= GPI_1_1xDP;
    elsif Wb_WexSI = '0' and Wb_CycxSI = '1' and Wb_StbxSI = '1' and Wb_AdrxDI = "010010" then
    -- 0x12
        outputxSN <= GPI_2_1xDP;
    elsif Wb_WexSI = '0' and Wb_CycxSI = '1' and Wb_StbxSI = '1' and Wb_AdrxDI = "010011" then
    -- 0x13
        outputxSN <= GPI_3_1xDP;
    else
        outputxSN <= outputxSP;
    end if;
end process Dataread;

--Update the FlipFlops:
FF_update: process(CLKxCI) is
begin
	if rising_edge(CLKxCI) then
		if ResetxSI = '1' then
			GPI_0_0xDP <= (others => '0');
			GPI_0_1xDP <= (others => '0');
            
            GPI_1_0xDP <= (others => '0');
			GPI_1_1xDP <= (others => '0');
            
            GPI_2_0xDP <= (others => '0');
			GPI_2_1xDP <= (others => '0');
            
            GPI_3_0xDP <= (others => '0');
			GPI_3_1xDP <= (others => '0');
            
			ackxSP <= '0';
			outputxSP <= (others => '0');
		else
			GPI_0_0xDP <= GPI_0_0xDN;
			GPI_0_1xDP <= GPI_0_1xDN;
            
            GPI_1_0xDP <= GPI_1_0xDN;
			GPI_1_1xDP <= GPI_1_1xDN;
            
            GPI_2_0xDP <= GPI_2_0xDN;
			GPI_2_1xDP <= GPI_2_1xDN;
            
            GPI_3_0xDP <= GPI_3_0xDN;
			GPI_3_1xDP <= GPI_3_1xDN;
            
			ackxSP <= ackxSN;
			outputxSP <= outputxSN;
		end if;
	end if;
end process FF_update;

end Behavioral;
