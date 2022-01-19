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
--
library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FXLink is
	port(
		reset : in std_logic;
		clk : in std_logic;

		-- Data & control from the FX2
		fifoData_io : inout std_logic_vector(7 downto 0);
		gotData_in  : in std_logic;                     -- FLAGC=EF (active-low), so '1' when there's data
		gotRoom_in  : in std_logic;                     -- FLAGB=FF (active-low), so '1' when there's room

		-- Control to the FX2
		sloe_out    : out std_logic;                    -- PA2
		slrd_out    : out std_logic;
		slwr_out    : out std_logic;
		fifoAddr_out: out std_logic_vector(1 downto 0); -- PA4 & PA5
		pktEnd_out  : out std_logic := '1';                    -- PA6

        -- RAM mux
        ramSelect   : out std_logic_vector(2 downto 0) := "000";

        -- Connections to RAM
        ramAddr     : out std_logic_vector(16 downto 0) := (others => '0');
        ramOut      : out std_logic_vector(7 downto 0) := (others => '0');
        ramIn       : in  std_logic_vector(7 downto 0) := (others => '0');
        ramWE       : out std_logic := '0';

		-- Output to other modules
		fpAddr		: out std_logic_vector(6 downto 0); -- register address
		fpDataOut	: out std_logic_vector(7 downto 0); -- received data
		fpDataIn	: in  std_logic_vector(7 downto 0); -- data to send
		fpWrite		: out std_logic;                    -- write to an address
		fpValid		: out std_logic;                    -- data is available to read from FX2

        -- RamInMux1 selection
        ramIM1sel   : out std_logic := '0';
        avr_pc_ctrl : out std_logic := '0';

		-- Onboard peripherals
		led_out      : out std_logic_vector(5 downto 0)
	);
end FXLink;

architecture Behavioural of FXLink is
	type StateType is (
		STATE_IDLE,
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
    constant FIFO_READ  : std_logic_vector(2 downto 0) := "100";  -- assert slrd_out & sloe_out
    constant FIFO_WRITE : std_logic_vector(2 downto 0) := "011";  -- assert slwr_out
    constant FIFO_NOP   : std_logic_vector(2 downto 0) := "111";  -- assert nothing
    constant OUT_FIFO   : std_logic_vector(1 downto 0) := "10";   -- EP6OUT
    constant IN_FIFO    : std_logic_vector(1 downto 0) := "11";   -- EP8IN

	signal state        : StateType := STATE_IDLE;
	signal count        : unsigned(31 downto 0) := (others => '0'); 
	signal addr         : std_logic_vector(6 downto 0) := (others => '0');
	signal isWrite      : std_logic := '0';
	signal isAligned    : std_logic := '0';
	signal r0           : std_logic_vector(7 downto 0) := (others => '0');
    signal testpt, testerr : unsigned(7 downto 0) := (others => '0');
    signal fifoOp       : std_logic_vector(2 downto 0) := FIFO_READ;
    signal cnt          : unsigned(8 downto 0) := (others => '0');
    signal dly          : unsigned(6 downto 0) := (others => '0');
    signal initialized  : std_logic := '0';
    signal nextAddr     : unsigned(ramAddr'length-1 downto 0) := (others => '0');
    signal fill_ram, delay : std_logic := '0';
begin

   initwait: process(clk)
   begin
      if rising_edge(clk) then
         if (cnt < 511) then
            cnt <= cnt + 1;
         else
            initialized <= '1';
         end if;
      end if;
   end process;

   ledoutput: process(clk)
   begin
      if rising_edge(clk) then
         case state is
            when STATE_IDLE => led_out(3 downto 0) <= x"1";
            when STATE_GET_COUNT0 => led_out(3 downto 0) <= x"2";
            when STATE_GET_COUNT1 => led_out(3 downto 0) <= x"3";
            when STATE_GET_COUNT2 => led_out(3 downto 0) <= x"4";
            when STATE_GET_COUNT3 => led_out(3 downto 0) <= x"5";
            when STATE_BEGIN_WRITE => led_out(3 downto 0) <= x"6";
            when STATE_WRITE => led_out(3 downto 0) <= x"7";
            when STATE_END_WRITE_ALIGNED => led_out(3 downto 0) <= x"8";
            when STATE_END_WRITE_NONALIGNED => led_out(3 downto 0) <= x"9";
            when STATE_READ => led_out(3 downto 0) <= x"a";
            when others => led_out(3 downto 0) <= x"f";
         end case;

--         led_out(4 downto 0) <= std_logic_vector(count(4 downto 0));
         
--         led_out(4) <= initialized;
--         led_out(4) <= gotRoom_in;
         if (count(31 downto 5) = "000000000000000000000000000") then
            led_out(5) <= '1';
         else
            led_out(5) <= '0';
         end if;

         if (count(4 downto 0) = "00000") then
            led_out(4) <= '1';
         else
            led_out(4) <= '0';
         end if;
         
--         if (gotRoom_in = '0') then
--            led_out(5) <= '1';
--            dly <= (others => '0');
--         else
--            if (dly /= 6000000) then
--               dly <= dly + 1;
--            else
--               led_out(5) <= '0';
--            end if;
--         end if;
      end if;
   end process;

    fsm: process(clk, reset)
    begin
        if (reset = '1') then
			state     <= STATE_IDLE;
			count     <= (others => '0');
			addr      <= (others => '0');
			isWrite   <= '0';
			isAligned <= '0';
			r0        <= (others => '0');
            testpt    <= (others => '0');
			fpAddr	  <= (others => '0');
			fpDataOut <= (others => '0');
			fpWrite	  <= '0';
            fifoOp    <= FIFO_READ;
            pktEnd_out<= '1';
            delay     <= '0';
            ramSelect <= "000";
		elsif rising_edge(clk) then
            pktEnd_out <= '1';
            fifoData_io <= (others => 'Z');

            if (delay = '1') then
                delay <= '0';
            end if;

            if (fill_ram = '1') then
                ramOut <= std_logic_vector(nextAddr(7 downto 0));
                ramAddr <= std_logic_vector(nextAddr);
                nextAddr <= nextAddr + 1;
                ramWE <= '1';

                if (nextAddr >= 90240) then
                    fill_ram <= '0';
                    nextAddr <= (others => '0');
                    ramOut <= (others => '0');
                    ramWE <= '0';
                end if;
            end if;

            case state is
                when STATE_IDLE =>
                    fifoAddr_out <= OUT_FIFO;  -- Reading from FX2LP
                    fifoOp <= FIFO_READ;

                    fpValid <= '0';

                    if (gotData_in = '1') and (initialized = '1') then
                        addr <= fifoData_io(6 downto 0);
                        isWrite <= fifoData_io(7);

                        state <= STATE_GET_COUNT0;
                    end if;

                when STATE_GET_COUNT0 =>
                    fifoAddr_out <= OUT_FIFO;  -- Reading from FX2LP

                    if (gotData_in = '1') then
                        -- count, high word high byte
                        count(31 downto 24) <= unsigned(fifoData_io);
                        state <= STATE_GET_COUNT1;
                    end if;

                when STATE_GET_COUNT1 =>
                    fifoAddr_out <= OUT_FIFO;  -- Reading from FX2LP

                    if (gotData_in = '1') then
                        -- count, high word low byte
                        count(23 downto 16) <= unsigned(fifoData_io);
                        state <= STATE_GET_COUNT2;
                    end if;

                when STATE_GET_COUNT2 =>
                    fifoAddr_out <= OUT_FIFO;  -- Reading from FX2LP

                    if (gotData_in = '1') then
                        -- count, low word high byte
                        count(15 downto 8) <= unsigned(fifoData_io);
                        state <= STATE_GET_COUNT3;
                    end if;

                when STATE_GET_COUNT3 =>
                    fifoAddr_out <= OUT_FIFO;  -- Reading from FX2LP

                    if (gotData_in = '1') then
                        -- count, low word low byte
                        count(7 downto 0) <= unsigned(fifoData_io);

                        if (isWrite = '1') then -- write to FX2
                            state <= STATE_BEGIN_WRITE;
                        else    -- read from FX2
                            state <= STATE_READ;
                        end if;
                    end if;

                when STATE_BEGIN_WRITE =>
                    fifoAddr_out <= IN_FIFO;   -- Writing to FX2LP
                    fifoOp <= FIFO_NOP;

                    isAligned <= not(count(0) or count(1) or count(2) or count(3) or count(4) or count(5) or count(6) or count(7) or count(8));
                    state <= STATE_WRITE;

                    -- put address and r/w flag to fp bus
                    fpAddr <= addr;
                    fpWrite <= '0';
                    fpValid <= '1';

                when STATE_WRITE =>
                    fifoAddr_out <= IN_FIFO;   -- Writing to FX2LP

                    if (gotRoom_in = '1') and (delay = '0') then -- is there room in the FIFO?
                        fifoOp <= FIFO_WRITE;

                        case addr is
                            -- FXL addresses
                            when "0000000" =>           -- 0x00 - internal register
                                fifoData_io <= r0;
                            when "0000001" =>           -- 0x01 - restart test pattern
                                testpt <= (others => '0');
                                testerr <= (others => '0');
                                fifoData_io <= x"ab";
                            when "0000010" =>           -- 0x02 - read test pattern
                                fifoData_io <= std_logic_vector(testpt);
                                testpt <= testpt + 1;
                            when "0000011" =>           -- 0x03 - read error counter of the write test
                                fifoData_io <= std_logic_vector(testerr);
                            -- RAM addresses
                            when "0010000" =>           -- 0x10 - reset ram addr
                                nextAddr <= to_unsigned(1, nextAddr'length);
                                ramAddr <= (others => '0');
                                ramOut <= (others => '0');
                                ramWE <= '0';
                            when "0010001" =>           -- 0x11 - read from ram
                                fifoData_io <= ramIn;
                                ramAddr <= std_logic_vector(nextAddr); -- set address for next cycle
                                nextAddr <= nextAddr + 1;
                                delay <= '1';   -- TODO: get rid of the delay. last byte gets lost when FIFO is full
                            when "0010010" =>           -- 0x12 - read range(256) from ram
                                fifoData_io <= std_logic_vector(nextAddr(7 downto 0));
                                nextAddr <= nextAddr + 1;
                            -- other addresses
                            when others =>
                                fifoData_io <= fpDataIn;	-- send data (fpDataIn) from address (fpAddr)
                        end case;

                        if (count /= to_unsigned(0, count'length)) then
                            count <= count - 1;
                        end if;

                        if (count = 1) then
                            if (isAligned = '1') then
                                state <= STATE_END_WRITE_ALIGNED;  -- don't assert pktEnd
                            else
                                state <= STATE_END_WRITE_NONALIGNED;  -- assert pktEnd to commit small packet
                            end if;
                            
                            fpValid <= '0';
                        else
                            fpValid <= '1';
                        end if;
                    else
                        fifoOp <= FIFO_NOP;
                        fpValid <= '0';
                    end if;

                when STATE_END_WRITE_ALIGNED =>
                    fifoAddr_out <= IN_FIFO;   -- Writing to FX2LP
                    fifoOp <= FIFO_NOP;

                    state <= STATE_WRITE_DONE;

                when STATE_END_WRITE_NONALIGNED =>
                    fifoAddr_out <= IN_FIFO;   -- Writing to FX2LP
                    fifoOp <= FIFO_NOP;

                    pktEnd_out <= '0';  	   -- Active: FPGA commits the packet.
                    state <= STATE_WRITE_DONE;

                when STATE_WRITE_DONE =>
                    -- this is a wait state, so that STATE_IDLE doesn't get data from IN_FIFO
                    fifoAddr_out <= OUT_FIFO;
                    fifoOp <= FIFO_READ;
                    state <= STATE_IDLE;

                when STATE_READ =>
                    fifoAddr_out <= OUT_FIFO;  -- Reading from FX2LP

                    if (gotData_in = '1') then
                        fpAddr <= addr;
                        fpDataOut <= fifoData_io;	-- received data (fpDataOut) for address (fpAddr)
                        fpWrite <= '1';
                        fpValid <= '1';

                        case addr is
                            -- FXL addresses
                            when "0000000" =>       -- 0x00 - internal register
                                r0 <= fifoData_io;
                            when "0000010" =>       -- 0x02 - write test pattern, check it
                                testpt <= testpt + 1;
                                if (unsigned(fifoData_io) /= testpt) then -- we received an unexpected value1
                                    if (testerr /= x"ff") then
                                        testerr <= testerr + 1; -- increment error counter
                                    end if;
                                end if;
                            -- RAM addresses
                            when "0010000" =>       -- 0x10 - reset ram addr
                                nextAddr <= to_unsigned(0, nextAddr'length);
                                ramAddr <= (others => '0');
                                ramOut <= (others => '0');
                                ramWE <= '0';
                            when "0010001" =>       -- 0x11 - write to ram
                                -- output for RAM
                                ramAddr <= std_logic_vector(nextAddr);
                                ramOut <= fifoData_io;
                                ramWE <= '1';
    
                                nextAddr <= nextAddr + 1;
                            when "0010010" =>       -- 0x12 - fill ram
                                fill_ram <= '1';
                                nextAddr <= to_unsigned(0, nextAddr'length);
                                ramAddr <= (others => '0');
                                ramOut <= (others => '0');
                                ramWE <= '1';
                            when "0011101" =>       -- 0x1d - AVR PC override
                                ramWE <= '0';
                                if (fifoData_io = x"00") then
                                    avr_pc_ctrl <= '0';
                                else
                                    avr_pc_ctrl <= '1';
                                end if;
                            when "0011110" =>       -- 0x1e - ram select (RamInMux1)
                                ramWE <= '0';
                                if (fifoData_io = x"00") then
                                    ramIM1sel <= '0';
                                else
                                    ramIM1sel <= '1';
                                end if;
                            when "0011111" =>       -- 0x1f - ram select (mux)
                                ramWE <= '0';
                                if (fifoData_io = x"00") then
                                    ramSelect <= "000";
                                elsif (fifoData_io = x"01") then
                                    ramSelect <= "001";
                                elsif (fifoData_io = x"02") then
                                    ramSelect <= "011";
                                elsif (fifoData_io = x"03") then
                                    ramSelect <= "111";
                                end if;
                            -- other addresses
                            when others => null;
                        end case;

                        count <= count - 1;
                        if (count = 0) or (count = 1) then
                            state <= STATE_IDLE;
                        end if;
                    end if;
            end case;
        end if;
    end process;

    -- Breakout fifoOp
    sloe_out <= fifoOp(0);
    slrd_out <= fifoOp(1);
    slwr_out <= fifoOp(2);
end Behavioural;
