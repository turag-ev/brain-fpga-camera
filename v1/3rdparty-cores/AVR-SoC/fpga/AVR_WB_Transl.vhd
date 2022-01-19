----------------------------------------------------------------------------------
-- AVR_WB_Transl.vhd
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
--This converts the AVR-Databusses to Wb-Databusses: an IO-Bus and a RAM-Bus.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity AVR_WB_Translator is
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
end AVR_WB_Translator;

architecture Behavioral of AVR_WB_Translator is

--ffs for the addresses
signal IO_AdrxDP, IO_AdrxDN : std_logic_vector(5 downto 0);
signal RAM_AdrxDP, RAM_AdrxDN : std_logic_vector(15 downto 0);
--
--ffs for the data:
signal IO_DataxDP, IO_DataxDN : std_logic_vector(7 downto 0);
signal RAM_DataxDP, RAM_DataxDN : std_logic_vector(7 downto 0);
--

--ffs for Strobe/Cyc:
signal IO_CycxDN, IO_CycxDP : std_logic;
signal IO_StbxDN, IO_StbxDP : std_logic;
signal RAM_CycxDN, RAM_CycxDP : std_logic;
signal RAM_StbxDN, RAM_StbxDP : std_logic;
--
--ffs for the WE-Signals
signal IO_WexDN, IO_WexDP : std_logic;
signal RAM_WexDN, RAM_WexDP : std_logic;
--

begin

--Handle the IO-Wb-Bus:
--Read the Address:
Read_IO_Adr: process(AVR_iore_I, AVR_iowe_I, Wb_ACK_IO_I, IO_CycxDP,AVR_IO_ADR_I, IO_AdrxDP) is
begin
	IO_AdrxDN <= (others => '0'); --DefAss
	
	if (AVR_iore_I = '1' or AVR_iowe_I = '1' or (Wb_ACK_IO_I = '0' and IO_CycxDP = '0')) and IO_CycxDP = '0' then
		IO_AdrxDN <= AVR_IO_ADR_I;
	else
		IO_AdrxDN <= IO_AdrxDP;
	end if;
end process Read_IO_Adr;
--
--Read the Data:
Read_IO_Data: process(AVR_iowe_I, Wb_ACK_IO_I, IO_CycxDP, AVR_DAT_I, IO_DataxDP) is
begin
	IO_DataxDN <= (others => '0'); --DefAss
	
	if (AVR_iowe_I = '1' or (Wb_ACK_IO_I = '0' and IO_CycxDP = '0')) and IO_CycxDP = '0' then
		IO_DataxDN <= AVR_DAT_I;
	else
		IO_DataxDN <= IO_DataxDP;
	end if;
end process Read_IO_Data;
--
--Set the WE-Signal:
IO_RW_Handle: process(Wb_ACK_IO_I, AVR_iowe_I, AVR_iore_I, IO_WexDP) is
begin
	IO_WexDN <= '0'; --DefAss
	
	if Wb_ACK_IO_I = '0' then
		if AVR_iowe_I = '1' and AVR_iore_I = '0' then
			IO_WexDN <= '1';
		elsif AVR_iowe_I = '0' and AVR_iore_I = '1' then
			IO_WexDN <= '0';
		else
			IO_WexDN <= IO_WexDP;
		end if;
		
	else --Wb_ACK_IO_I = '1' 
		IO_WexDN <= '0';
	end if;
end process IO_RW_Handle;
--
--Set the Strobe and Cycle Signals:
Set_StbCyc_IO: process(Wb_ACK_IO_I, AVR_iore_I, AVR_iowe_I, IO_CycxDP, IO_StbxDP) is
begin
	IO_CycxDN <= '0'; --DefAss
	IO_StbxDN <= '0'; --DefAss

	if Wb_ACK_IO_I = '1' then
		IO_CycxDN <= '0';
		IO_StbxDN <= '0';
	elsif AVR_iowe_I = '1' or AVR_iore_I = '1' then
		IO_CycxDN <= '1';
		IO_StbxDN <= '1';
	else
		IO_CycxDN <= IO_CycxDP;
		IO_StbxDN <= IO_StbxDP;
	end if;
end process Set_StbCyc_IO;
--
--Handle the RAM-Wb-Bus:
--Read the Address:
Read_RAM_Adr: process(AVR_ramre_I, AVR_ramwe_I, Wb_ACK_RAM_I, RAM_CycxDP, AVR_RAMADR_I, RAM_AdrxDP) is
begin
	RAM_AdrxDN <= (others => '0'); --DefAss
	
	if AVR_ramre_I = '1' or AVR_ramwe_I = '1' or (Wb_ACK_RAM_I = '0' and RAM_CycxDP = '0') then
		RAM_AdrxDN <= AVR_RAMADR_I;
	else
		RAM_AdrxDN <= RAM_AdrxDP;
	end if;
end process Read_RAM_Adr;
--
--Read the Data:
Read_RAM_Data: process(AVR_ramwe_I, Wb_ACK_RAM_I, RAM_CycxDP, AVR_DAT_I, RAM_DataxDP) is 
begin
	RAM_DataxDN <= (others => '0'); --DefAss
	
	if AVR_ramwe_I = '1' and (Wb_ACK_RAM_I = '0' and RAM_CycxDP = '0') then
		RAM_DataxDN <= AVR_DAT_I;
	else
		RAM_DataxDN <= RAM_DataxDP;
	end if;
end process Read_RAM_Data;
--
--Set the WE-Signal on the RAM Wb-Bus:
Ram_RW_Handle: process(AVR_ramre_I, AVR_ramwe_I, Wb_ACK_RAM_I, RAM_WexDP) is
begin
	RAM_WexDN <= '0'; --DefAss
	
	if Wb_ACK_RAM_I = '0' then
		if AVR_ramwe_I = '1' and AVR_ramre_I = '0' then
			RAM_WexDN <= '1';
		elsif AVR_ramwe_I = '0' and AVR_ramre_I = '1' then
			RAM_WexDN <= '0';
		else
			RAM_WexDN <= RAM_WexDP;
		end if;
		
	else --Wb_ACK_IO_I = '1' 
		RAM_WexDN <= '0';
	end if;
end process Ram_RW_Handle;
--
--Set Strobe/Cycle to the Ram-Wb-Bus:
Set_StbCyc_RAM: process(Wb_ACK_RAM_I, AVR_ramre_I, AVR_ramwe_I, RAM_CycxDP, RAM_StbxDP) is
begin
	RAM_CycxDN <= '0'; --DefAss
	RAM_StbxDN <= '0'; --DefAss

	if Wb_ACK_RAM_I = '1' then
		RAM_CycxDN <= '0';
		RAM_StbxDN <= '0';
	elsif AVR_ramwe_I = '1' or AVR_ramre_I = '1' then
		RAM_CycxDN <= '1';
		RAM_StbxDN <= '1';
	else
		RAM_CycxDN <= RAM_CycxDP;
		RAM_StbxDN <= RAM_StbxDP;
	end if;
end process Set_StbCyc_RAM;
--
--Common Actions to both Busses:
--Stall the CPU while the Bus is transferring:
Set_CpuWait: process(AVR_iore_I, AVR_iowe_I, Wb_ACK_IO_I, IO_CycxDP, Wb_ACK_RAM_I, RAM_CycxDP, AVR_ramre_I, AVR_ramwe_I) is
begin
	AVR_Clk_EnxSO <= '1'; --DefAss
	
	if Wb_ACK_IO_I = '1' or Wb_ACK_RAM_I = '1' then
		AVR_Clk_EnxSO <= '1';
	else
		if (AVR_iore_I = '1' or AVR_iowe_I = '1' or IO_CycxDP = '1') or (AVR_ramre_I = '1' or AVR_ramwe_I = '1' or RAM_CycxDP = '1') then
			AVR_Clk_EnxSO <= '0';
		else
			AVR_Clk_EnxSO <= '1';
		end if;
	end if;
end process Set_CpuWait;
--
--Route the incoming data to the AVR Databus-Input:
Data_Mux: process(AVR_iore_I, AVR_iowe_I, AVR_ramre_I, AVR_ramwe_I, Wb_DAT_IO_I, Wb_DAT_RAM_I) is
begin
	AVR_DAT_O <= (others=> '0'); --DefAss
	
	if (AVR_iore_I = '1' or AVR_iowe_I ='1') and (AVR_ramre_I = '0' and AVR_ramwe_I = '0') then
		AVR_DAT_O <= Wb_DAT_IO_I;
	elsif (AVR_ramre_I = '1' or AVR_ramwe_I = '1') and (AVR_iore_I = '0' and AVR_iowe_I = '0') then
		AVR_DAT_O <= Wb_DAT_RAM_I;
	end if;
end process Data_Mux;
--
--Update the FlipFlops:
FF_update: process(CLK) is
begin
	if rising_edge(CLK) then
		if RST = '1' then
			IO_AdrxDP <= (others=> '0');
			IO_StbxDP <= '0';
			IO_CycxDP <= '0';
			IO_WexDP <= '0';
			IO_DataxDP <= (others => '0');
			
			RAM_AdrxDP <= (others=> '0');
			RAM_StbxDP <= '0';
			RAM_CycxDP <= '0';
			RAM_WexDP <= '0';
			RAM_DataxDP <= (others => '0');
		else	
			IO_AdrxDP <= IO_AdrxDN;
			IO_CycxDP <= IO_CycxDN;
			IO_StbxDP <= IO_StbxDN;
			IO_WexDP <= IO_WexDN;
			IO_DataxDP <= IO_DataxDN;
			
			RAM_AdrxDP <= RAM_AdrxDN;
			RAM_CycxDP <= RAM_CycxDN;
			RAM_StbxDP <= RAM_StbxDN;
			RAM_WexDP <= RAM_WexDN;
			RAM_DataxDP <= RAM_DataxDN;
		end if;
	end if;
end process FF_update;


--Route the Data output directly to both Wb Outputs:
Wb_DAT_IO_O <= IO_DataxDP;
Wb_DAT_RAM_O <= RAM_DataxDP;
--

--Route the address signals to the corresponding Wb adr busses:
Wb_ADR_IO_O <= IO_AdrxDP;
Wb_ADR_RAM_O <= RAM_AdrxDP;
--

--Assign Cycle/Strobe Outputs:
Wb_CYC_IO_O <= IO_CycxDP;
Wb_STB_IO_O <= IO_StbxDP;

Wb_CYC_RAM_O <= RAM_CycxDP;
Wb_STB_RAM_O <= RAM_StbxDP;
--

--Assign WE Outputs:
Wb_WE_IO_O <= IO_WexDP;
Wb_WE_RAM_O <= RAM_WexDP;
--


end Behavioral;

