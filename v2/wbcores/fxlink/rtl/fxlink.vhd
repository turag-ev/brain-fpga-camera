--
-- Copyright (C) 2011-2012 spezifisch
-- Copyright (C) 2009-2011 Chris McClelland
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fxlink is
	port(
        CLK         : in std_logic;

        -- Data & control from the FX2
        FIFODATA_IO : inout std_logic_vector(7 downto 0);
        GOTDATA_IN  : in std_logic;                     -- FLAGC=EF (active-low), so '1' when there's data
        GOTROOM_IN  : in std_logic;                     -- FLAGB=FF (active-low), so '1' when there's room

        -- Control to the FX2
        SLOE    : out std_logic;                    -- PA2
        SLRD    : out std_logic;
        SLWR    : out std_logic;
        FIFOADR : out std_logic_vector(1 downto 0); -- PA4 & PA5
        PKTEND  : out std_logic := '1';             -- PA6

        -- Wishbone
        WB_DAT_O    : out std_logic_vector(31 downto 0) := (others => '0');
        WB_DAT_I    : in  std_logic_vector(31 downto 0);
        WB_ADR_O    : out std_logic_vector(31 downto 0) := (others => '0');
        WB_ACK_I    : in  std_logic;
        WB_CYC_O    : out std_logic := '0';
        WB_STB_O    : out std_logic := '0';
        WB_WE_O     : out std_logic := '0';
        
        -- CPU control
        CPU_RST     : out std_logic := '0';

        -- Onboard peripherals
        DEVLED     : out std_logic_vector(7 downto 0)
	);
end fxlink;

architecture Behavioural of fxlink is
	type StateType is (
		STATE_IDLE,
        STATE_GET_ADDR1,
        STATE_GET_ADDR2,
        STATE_GET_ADDR3,
		STATE_GET_COUNT0,
		STATE_GET_COUNT1,
		STATE_GET_COUNT2,
		STATE_GET_COUNT3,
		STATE_BEGIN_WRITE,
		STATE_WRITE,
		STATE_END_WRITE_ALIGNED,
		STATE_END_WRITE_NONALIGNED,
        STATE_WRITE_DONE,
		STATE_READ
	);
    constant FIFO_READ  : std_logic_vector(2 downto 0) := "100";  -- assert SLRD & SLOE
    constant FIFO_WRITE : std_logic_vector(2 downto 0) := "011";  -- assert SLWR
    constant FIFO_NOP   : std_logic_vector(2 downto 0) := "111";  -- assert nothing
    constant OUT_FIFO   : std_logic_vector(1 downto 0) := "10";   -- EP6OUT
    constant IN_FIFO    : std_logic_vector(1 downto 0) := "11";   -- EP8IN

	signal state        : StateType := STATE_IDLE;
	signal count        : unsigned(31 downto 0) := (others => '0'); 
	signal addr         : std_logic_vector(WB_ADR_O'length-1 downto 0) := (others => '0');
    signal autoInc      : std_logic := '0';
	signal isWrite      : std_logic := '0';
	signal isAligned    : std_logic := '0';
    signal fifoOp       : std_logic_vector(2 downto 0) := FIFO_READ;
    signal cnt          : unsigned(8 downto 0) := (others => '0');
    signal dly          : unsigned(6 downto 0) := (others => '0');
    signal initialized  : std_logic := '0';
    signal dled         : std_logic_vector(7 downto 0) := (others => '0');
    signal inbuf, outbuf : std_logic_vector(31 downto 0) := (others => '0');
begin
    DEVLED <= not dled;

    initwait: process(CLK)
    begin
        if rising_edge(CLK) then
            if (cnt < 511) then
                cnt <= cnt + 1;
            else
                initialized <= '1';
            end if;
        end if;
    end process;

    ledoutput: process(CLK)
    begin
        if rising_edge(CLK) then
            case state is
                when STATE_IDLE => dled(3 downto 0) <= x"1";
                when STATE_GET_ADDR1 => dled(3 downto 0) <= x"2";
                when STATE_GET_ADDR2 => dled(3 downto 0) <= x"3";
                when STATE_GET_ADDR3 => dled(3 downto 0) <= x"4";
                when STATE_GET_COUNT0 => dled(3 downto 0) <= x"5";
                when STATE_GET_COUNT1 => dled(3 downto 0) <= x"6";
                when STATE_GET_COUNT2 => dled(3 downto 0) <= x"7";
                when STATE_GET_COUNT3 => dled(3 downto 0) <= x"8";
                when STATE_BEGIN_WRITE => dled(3 downto 0) <= x"9";
                when STATE_WRITE => dled(3 downto 0) <= x"a";
                when STATE_END_WRITE_ALIGNED => dled(3 downto 0) <= x"b";
                when STATE_END_WRITE_NONALIGNED => dled(3 downto 0) <= x"c";
                when STATE_READ => dled(3 downto 0) <= x"d";
                when others => dled(3 downto 0) <= x"f";
            end case;

--            dled(4 downto 0) <= std_logic_vector(count(4 downto 0));
--            dled(6) <= initialized;
--            dled(6) <= GOTROOM_IN;
--            if (count(31 downto 5) = "000000000000000000000000000") then
--                dled(5) <= '1';
--            else
--                dled(5) <= '0';
--            end if;
--
--            if (count(4 downto 0) = "00000") then
--                dled(4) <= '1';
--            else
--                dled(4) <= '0';
--            end if;
--         
--            dled(7) <= '0';
         
            dled(6 downto 4) <= std_logic_vector(count(2 downto 0));
         
            if (GOTROOM_IN = '0') then
                dled(7) <= '1';
                dly <= (others => '0');
            else
                if (dly /= 6000000) then
                    dly <= dly + 1;
                else
                    dled(7) <= '0';
                end if;
            end if;
        end if;
    end process;

    WB_ADR_O <= addr;

    fsm: process(CLK)
    begin
        if rising_edge(CLK) then
            PKTEND <= '1';
            FIFODATA_IO <= (others => 'Z');
            WB_CYC_O <= '0';
            WB_STB_O <= '0';

            case state is
                when STATE_IDLE =>
                    FIFOADR <= OUT_FIFO;  -- Reading from FX2LP
                    fifoOp <= FIFO_READ;

                    WB_WE_O <= '0';

                    if (GOTDATA_IN = '1') and (initialized = '1') then
                        addr(31 downto 24) <= FIFODATA_IO;
                        state <= STATE_GET_ADDR1;
                    end if;
                    
                when STATE_GET_ADDR1 =>
                    FIFOADR <= OUT_FIFO;  -- Reading from FX2LP

                    if (GOTDATA_IN = '1') then
                        addr(23 downto 16) <= FIFODATA_IO;
                        state <= STATE_GET_ADDR2;
                    end if;
                    
                when STATE_GET_ADDR2 =>
                    FIFOADR <= OUT_FIFO;  -- Reading from FX2LP

                    if (GOTDATA_IN = '1') then
                        addr(15 downto 8) <= FIFODATA_IO;
                        state <= STATE_GET_ADDR3;
                    end if;
                    
                when STATE_GET_ADDR3 =>
                    FIFOADR <= OUT_FIFO;  -- Reading from FX2LP

                    if (GOTDATA_IN = '1') then
                        addr(7 downto 0) <= FIFODATA_IO;
                        state <= STATE_GET_COUNT0;
                    end if;

                when STATE_GET_COUNT0 =>
                    FIFOADR <= OUT_FIFO;  -- Reading from FX2LP

                    if (GOTDATA_IN = '1') then
                        -- flags: write, addr. auto increment
                        isWrite <= FIFODATA_IO(7);
                        autoInc <= FIFODATA_IO(6);
                        
                        -- count, high word high byte
                        -- count is length in dwords, multiply by 4 to get length in bytes
                        count(31 downto 26) <= unsigned(FIFODATA_IO(5 downto 0));
                        state <= STATE_GET_COUNT1;
                    end if;

                when STATE_GET_COUNT1 =>
                    FIFOADR <= OUT_FIFO;  -- Reading from FX2LP

                    if (GOTDATA_IN = '1') then
                        -- count, high word low byte
                        count(25 downto 18) <= unsigned(FIFODATA_IO);
                        state <= STATE_GET_COUNT2;
                    end if;

                when STATE_GET_COUNT2 =>
                    FIFOADR <= OUT_FIFO;  -- Reading from FX2LP

                    if (GOTDATA_IN = '1') then
                        -- count, low word high byte
                        count(17 downto 10) <= unsigned(FIFODATA_IO);
                        state <= STATE_GET_COUNT3;
                    end if;

                when STATE_GET_COUNT3 =>
                    FIFOADR <= OUT_FIFO;  -- Reading from FX2LP

                    if (GOTDATA_IN = '1') then
                        if (addr = x"fffffffe") then
                            -- write to "special" address -> set some settings
                            -- 32 bit were submitted:
                            -- - bit 31 and 30 in regs isWrite, autoInc
                            -- - bit 29 downto 8 in count(31 downto 10)
                            -- - bit 7 downto 0 in FIFODATA_IO
                            
                            -- bit 0: trigger lm32 CPU reset
                            CPU_RST <= FIFODATA_IO(0);
                            
                            -- do nothing on wb bus
                            WB_CYC_O <= '0';
                            WB_STB_O <= '0';
                            count <= (others => '0');
                            state <= STATE_IDLE;
                        else
                            -- pipe other addresses through to wb
                            
                            -- count, low word low byte
                            count(9 downto 2) <= unsigned(FIFODATA_IO);
                            count(1 downto 0) <= "00";

                            if (isWrite = '1') then -- write to FX2 (read from wb)
                                state <= STATE_BEGIN_WRITE;
                            else                    -- read from FX2 (write to wb)
                                state <= STATE_READ;
                            end if;
                        end if;
                    end if;

                when STATE_BEGIN_WRITE =>
                    FIFOADR <= IN_FIFO;   -- Writing to FX2LP
                    fifoOp <= FIFO_NOP;

                    isAligned <= not(count(0) or count(1) or count(2) or count(3) or count(4) or count(5) or count(6) or count(7) or count(8));
                    state <= STATE_WRITE;
                    
                    -- start a wishbone cycle for reading
                    WB_WE_O <= '0';
                    WB_CYC_O <= '1';
                    WB_STB_O <= '1';

                when STATE_WRITE =>
                    FIFOADR <= IN_FIFO;   -- Writing to FX2LP
                    fifoOp <= FIFO_NOP;
                    
                    WB_CYC_O <= '1';
                    WB_STB_O <= '1';
                        
                    -- is there room in the FIFO and we got data?
                    if (GOTROOM_IN = '1') and ((WB_ACK_I = '1') or (count(1 downto 0) /= "00")) then
                        fifoOp <= FIFO_WRITE;

                        -- output 32 bit wishbone data 8 bit at a time
                        case count(1 downto 0) is
                            when "00" =>
                                outbuf <= WB_DAT_I;
                                FIFODATA_IO <= WB_DAT_I(31 downto 24);
                            when "11" =>
                                FIFODATA_IO <= outbuf(23 downto 16);
                            when "10" =>
                                FIFODATA_IO <= outbuf(15 downto 8);
                            when "01" =>
                                FIFODATA_IO <= outbuf(7 downto 0);
                            when others => null;
                        end case;

                        -- decrease remaining byte count
                        if (count /= to_unsigned(0, count'length)) then
                            count <= count - 1;
                        end if;
   
                        -- last byte
                        if (count = 1) then
                            if (isAligned = '1') then
                                state <= STATE_END_WRITE_ALIGNED;  -- don't assert pktEnd
                            else
                                state <= STATE_END_WRITE_NONALIGNED;  -- assert pktEnd to commit small packet
                            end if;
                            
                            -- close wishbone bus cycle
                            WB_STB_O <= '0';
                            WB_CYC_O <= '0';
                        elsif (count(1 downto 0) = "01") then
                            -- get next bunch of data from bus
                            WB_STB_O <= '1';
                            
                            -- increment address if needed
                            if (autoInc = '1') then
                                addr <= std_logic_vector(unsigned(addr) + 4);
                            end if;
                        end if;
                    end if;

                when STATE_END_WRITE_ALIGNED =>
                    FIFOADR <= IN_FIFO;   -- Writing to FX2LP
                    fifoOp <= FIFO_NOP;

                    state <= STATE_WRITE_DONE;
                    WB_STB_O <= '0';
                    WB_CYC_O <= '0';

                when STATE_END_WRITE_NONALIGNED =>
                    FIFOADR <= IN_FIFO;   -- Writing to FX2LP
                    fifoOp <= FIFO_NOP;

                    PKTEND <= '0';  	   -- Active: FPGA commits the packet.
                    state <= STATE_WRITE_DONE;
                    WB_STB_O <= '0';
                    WB_CYC_O <= '0';

                when STATE_WRITE_DONE =>
                    -- this is a wait state, so that STATE_IDLE doesn't get data from IN_FIFO
                    FIFOADR <= OUT_FIFO;
                    fifoOp <= FIFO_READ;
                    state <= STATE_IDLE;

                when STATE_READ =>
                    FIFOADR <= OUT_FIFO;  -- Reading from FX2LP
                    
                    WB_CYC_O <= '1';
                    WB_STB_O <= '1';

                    if (GOTDATA_IN = '1') or (count(1 downto 0) /= "00") then
                        WB_DAT_O(7 downto 0) <= FIFODATA_IO;	-- received data (WB_DAT_O) for address (WB_ADR_O)
                        WB_WE_O <= '1';
                        WB_CYC_O <= '1';
                        WB_STB_O <= '0';
                        
                        case count(1 downto 0) is
                            when "00" =>
                                inbuf(31 downto 24) <= FIFODATA_IO;
                            when "11" =>
                                inbuf(23 downto 16) <= FIFODATA_IO;
                            when "10" =>
                                inbuf(15 downto 8) <= FIFODATA_IO;
                            when "01" =>
                                WB_DAT_O(31 downto 8) <= inbuf(31 downto 8);
                                WB_DAT_O(7 downto 0) <= FIFODATA_IO;
                                WB_STB_O <= '1';
                            when others => null;
                        end case;

                        count <= count - 1;
                        if (count = 0) or (count = 1) then
                            state <= STATE_IDLE;
                        end if;
                    else
                        WB_STB_O <= '0';
                    end if;
            end case;
        end if;
    end process;

    -- Breakout fifoOp
    SLOE <= fifoOp(0);
    SLRD <= fifoOp(1);
    SLWR <= fifoOp(2);
end Behavioural;
