----------------------------------------------------------------------------------
-- Wb_GPO.vhd
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
--This provides some simple General-Purpose-Outputs on the Wishbone-IO-Bus of the AVR-SoC.
--Up to 8 Output vectors can be addressed. 
--The output vectors can be read back (e.g. "Blabla = Blabla | 0x0000) works.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Wb_GPO is
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
		
		GPO_0 : out std_logic_vector(7 downto 0);   -- DEVLED
		GPO_1 : out std_logic_vector(7 downto 0);   -- POWERLED_VAL
		GPO_2 : out std_logic_vector(7 downto 0);   -- MISC_OA
		GPO_3 : out std_logic_vector(7 downto 0);   -- MISC_OB
		GPO_4 : out std_logic_vector(7 downto 0);   -- MISC_OC
		GPO_5 : out std_logic_vector(7 downto 0);   -- MISC_OD
		GPO_6 : out std_logic_vector(7 downto 0);   -- STADR
		GPO_7 : out std_logic_vector(7 downto 0)    -- STDAT
	);
end Wb_GPO;

architecture Behavioral of Wb_GPO is

signal GPO_0xDN, GPO_0xDP : std_logic_vector(7 downto 0);
signal GPO_1xDN, GPO_1xDP : std_logic_vector(7 downto 0);
signal GPO_2xDN, GPO_2xDP : std_logic_vector(7 downto 0);
signal GPO_3xDN, GPO_3xDP : std_logic_vector(7 downto 0);
signal GPO_4xDN, GPO_4xDP : std_logic_vector(7 downto 0);
signal GPO_5xDN, GPO_5xDP : std_logic_vector(7 downto 0);
signal GPO_6xDN, GPO_6xDP : std_logic_vector(7 downto 0);
signal GPO_7xDN, GPO_7xDP : std_logic_vector(7 downto 0);

signal outputxDN, outputxDP : std_logic_vector(7 downto 0); --data output

signal ackxSN, ackxSP : std_logic; --Ack-Flipflop

begin

Wb_DataoutxDO <= outputxDP; --assign output

--Generate the Wishbone-Ack-Pulse:
Wb_handler : process(Wb_CycxSI, ackxSP, Wb_StbxSI) is 
begin
	ackxSN <= Wb_CycxSI and Wb_StbxSI; 
	Wb_AckxSO <= ackxSP and Wb_StbxSI; --Generate one ack-pulse.
end process Wb_handler;

--Assign the Outputs:
Output_handler : process(GPO_0xDP, GPO_1xDP, GPO_2xDP, GPO_3xDP, GPO_4xDP, GPO_5xDP, GPO_6xDP, GPO_7xDP) is
begin
	GPO_0 <= GPO_0xDP;
	GPO_1 <= GPO_1xDP;
    GPO_2 <= GPO_2xDP;
    GPO_3 <= GPO_3xDP;
    GPO_4 <= GPO_4xDP;
    GPO_5 <= GPO_5xDP;
    GPO_6 <= GPO_6xDP;
    GPO_7 <= GPO_7xDP;
end process Output_handler;

--Read the Data from the Wishbone-Bus:
Dataread: process(Wb_WexSI, Wb_CycxSI, Wb_StbxSI, Wb_AdrxDI, Wb_DatainxDI, GPO_0xDP, GPO_1xDP, GPO_2xDP, GPO_3xDP, GPO_4xDP, GPO_5xDP, GPO_6xDP, GPO_7xDP) is
begin
	-- if Address = 0x08: (LEDs)
	if Wb_WexSI = '1' and Wb_CycxSI = '1' and Wb_StbxSI = '1' and Wb_AdrxDI = "001000" then
		GPO_0xDN <= Wb_DatainxDI;
		GPO_1xDN <= GPO_1xDP;
        GPO_2xDN <= GPO_2xDP;
        GPO_3xDN <= GPO_3xDP;
        GPO_4xDN <= GPO_4xDP;
        GPO_5xDN <= GPO_5xDP;
        GPO_6xDN <= GPO_6xDP;
        GPO_7xDN <= GPO_7xDP;
	-- 0x09
	elsif Wb_WexSI = '1' and Wb_CycxSI = '1' and Wb_StbxSI = '1' and Wb_AdrxDI = "001001" then
		GPO_0xDN <= GPO_0xDP;
        GPO_1xDN <= Wb_DatainxDI;
        GPO_2xDN <= GPO_2xDP;
        GPO_3xDN <= GPO_3xDP;
        GPO_4xDN <= GPO_4xDP;
        GPO_5xDN <= GPO_5xDP;
        GPO_6xDN <= GPO_6xDP;
        GPO_7xDN <= GPO_7xDP;
    -- 0x0a
    elsif Wb_WexSI = '1' and Wb_CycxSI = '1' and Wb_StbxSI = '1' and Wb_AdrxDI = "001010" then
		GPO_0xDN <= GPO_0xDP;
        GPO_1xDN <= GPO_1xDP;
        GPO_2xDN <= Wb_DatainxDI;
        GPO_3xDN <= GPO_3xDP;
        GPO_4xDN <= GPO_4xDP;
        GPO_5xDN <= GPO_5xDP;
        GPO_6xDN <= GPO_6xDP;
        GPO_7xDN <= GPO_7xDP;
    -- 0x0b
    elsif Wb_WexSI = '1' and Wb_CycxSI = '1' and Wb_StbxSI = '1' and Wb_AdrxDI = "001011" then
		GPO_0xDN <= GPO_0xDP;
        GPO_1xDN <= GPO_1xDP;
        GPO_2xDN <= GPO_2xDP;
        GPO_3xDN <= Wb_DatainxDI;
        GPO_4xDN <= GPO_4xDP;
        GPO_5xDN <= GPO_5xDP;
        GPO_6xDN <= GPO_6xDP;
        GPO_7xDN <= GPO_7xDP;
    -- 0x0c
    elsif Wb_WexSI = '1' and Wb_CycxSI = '1' and Wb_StbxSI = '1' and Wb_AdrxDI = "001100" then
		GPO_0xDN <= GPO_0xDP;
        GPO_1xDN <= GPO_1xDP;
        GPO_2xDN <= GPO_2xDP;
        GPO_3xDN <= GPO_3xDP;
        GPO_4xDN <= Wb_DatainxDI;
        GPO_5xDN <= GPO_5xDP;
        GPO_6xDN <= GPO_6xDP;
        GPO_7xDN <= GPO_7xDP;
    -- 0x0d
    elsif Wb_WexSI = '1' and Wb_CycxSI = '1' and Wb_StbxSI = '1' and Wb_AdrxDI = "001101" then
		GPO_0xDN <= GPO_0xDP;
        GPO_1xDN <= GPO_1xDP;
        GPO_2xDN <= GPO_2xDP;
        GPO_3xDN <= GPO_3xDP;
        GPO_4xDN <= GPO_4xDP;
        GPO_5xDN <= Wb_DatainxDI;
        GPO_6xDN <= GPO_6xDP;
        GPO_7xDN <= GPO_7xDP;
    -- 0x0e
    elsif Wb_WexSI = '1' and Wb_CycxSI = '1' and Wb_StbxSI = '1' and Wb_AdrxDI = "001110" then
		GPO_0xDN <= GPO_0xDP;
        GPO_1xDN <= GPO_1xDP;
        GPO_2xDN <= GPO_2xDP;
        GPO_3xDN <= GPO_3xDP;
        GPO_4xDN <= GPO_4xDP;
        GPO_5xDN <= GPO_5xDP;
        GPO_6xDN <= Wb_DatainxDI;
        GPO_7xDN <= GPO_7xDP;
    -- 0x0f
    elsif Wb_WexSI = '1' and Wb_CycxSI = '1' and Wb_StbxSI = '1' and Wb_AdrxDI = "001111" then
		GPO_0xDN <= GPO_0xDP;
        GPO_1xDN <= GPO_1xDP;
        GPO_2xDN <= GPO_2xDP;
        GPO_3xDN <= GPO_3xDP;
        GPO_4xDN <= GPO_4xDP;
        GPO_5xDN <= GPO_5xDP;
        GPO_6xDN <= GPO_6xDP;
        GPO_7xDN <= Wb_DatainxDI;
	else
		GPO_0xDN <= GPO_0xDP;
        GPO_1xDN <= GPO_1xDP;
        GPO_2xDN <= GPO_2xDP;
        GPO_3xDN <= GPO_3xDP;
        GPO_4xDN <= GPO_4xDP;
        GPO_5xDN <= GPO_5xDP;
        GPO_6xDN <= GPO_6xDP;
        GPO_7xDN <= GPO_7xDP;
	end if;
end process Dataread;

--Return the Data to the Wishbone-Bus(IO-Read:)
Datawrite : process(Wb_WexSI, Wb_CycxSI, Wb_StbxSI, Wb_AdrxDI, outputxDP, GPO_0xDP, GPO_1xDP, GPO_2xDP, GPO_3xDP, GPO_4xDP, GPO_5xDP, GPO_6xDP, GPO_7xDP) is
begin
	-- if Address = 0x08: (LEDs)
	if Wb_WexSI = '0' and Wb_CycxSI = '1' and Wb_StbxSI = '1' and Wb_AdrxDI = "001000" then
		outputxDN <= GPO_0xDP; --return current status of the register
	-- 0x09
	elsif Wb_WexSI = '0' and Wb_CycxSI = '1' and Wb_StbxSI = '1' and Wb_AdrxDI = "001001" then
		outputxDN <= GPO_1xDP;
    -- 0x0a
    elsif Wb_WexSI = '0' and Wb_CycxSI = '1' and Wb_StbxSI = '1' and Wb_AdrxDI = "001010" then
		outputxDN <= GPO_2xDP;
    -- 0x0b
    elsif Wb_WexSI = '0' and Wb_CycxSI = '1' and Wb_StbxSI = '1' and Wb_AdrxDI = "001011" then
		outputxDN <= GPO_3xDP;
    -- 0x0c
    elsif Wb_WexSI = '0' and Wb_CycxSI = '1' and Wb_StbxSI = '1' and Wb_AdrxDI = "001100" then
		outputxDN <= GPO_4xDP;
    -- 0x0d
    elsif Wb_WexSI = '0' and Wb_CycxSI = '1' and Wb_StbxSI = '1' and Wb_AdrxDI = "001101" then
		outputxDN <= GPO_5xDP;
    -- 0x0e
    elsif Wb_WexSI = '0' and Wb_CycxSI = '1' and Wb_StbxSI = '1' and Wb_AdrxDI = "001110" then
		outputxDN <= GPO_6xDP;
    -- 0x0f
    elsif Wb_WexSI = '0' and Wb_CycxSI = '1' and Wb_StbxSI = '1' and Wb_AdrxDI = "001111" then
		outputxDN <= GPO_7xDP;
	else
		outputxDN <= outputxDP;
	end if;
end process Datawrite;

--Update the FlipFlops:
FF_update: process(CLKxCI) is
begin
	if rising_edge(CLKxCI) then
		if ResetxSI = '1' then
			GPO_0xDP <= (others => '0');
			GPO_1xDP <= (others => '0');
            GPO_2xDP <= (others => '0');
			GPO_3xDP <= (others => '0');
			GPO_4xDP <= (others => '0');
			GPO_5xDP <= (others => '0');
			GPO_6xDP <= (others => '0');
			GPO_7xDP <= (others => '0');
			ackxSP <= '0';
			outputxDP <= (others => '0');
		else
			GPO_0xDP <= GPO_0xDN;
			GPO_1xDP <= GPO_1xDN;
            GPO_2xDP <= GPO_2xDN;
            GPO_3xDP <= GPO_3xDN;
            GPO_4xDP <= GPO_4xDN;
            GPO_5xDP <= GPO_5xDN;
            GPO_6xDP <= GPO_6xDN;
            GPO_7xDP <= GPO_7xDN;
			ackxSP <= ackxSN;
			outputxDP <= outputxDN;
		end if;
	end if;
end process FF_update;

end Behavioral;
