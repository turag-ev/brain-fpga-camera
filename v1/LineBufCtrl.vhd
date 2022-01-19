library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity LineBufCtrl is
    Generic (
        data_width: natural := 8;
        dcnt_width: natural := 9
    );
    Port (
        clk     : in  std_logic;
        reset   : in  std_logic;

        -- data input
        dataStr : in  std_logic;
        dataIn  : in  std_logic_vector(data_width-1 downto 0) := (others => '0');
        dataOut : out std_logic_vector(data_width-1 downto 0) := (others => '0');

        -- pipe delayed NewFrame signal through
        inNewFrame  : in  std_logic;
        outNewFrame : out std_logic := '0';

        -- fill level of the FIFOs
        datacountLB1: in  std_logic_vector(dcnt_width-1 downto 0) := (others => '0');
        datacountLB2: in  std_logic_vector(dcnt_width-1 downto 0) := (others => '0');

        -- write to 1. fifo
        weLB1      : out std_logic := '0';

        -- read from 1./2. fifo
        reLB1       : out std_logic := '0';
        reLB2       : out std_logic := '0';

        linesStr    : out std_logic := '0';
        linesValid  : out std_logic := '0'
    );
end LineBufCtrl;

architecture Behavioral of LineBufCtrl is
    constant RES_X : integer := 160;
    constant NEW_FRAME_DELAY : integer := RES_X;
    signal NFDelay : unsigned(8 downto 0) := to_unsigned(NEW_FRAME_DELAY + 1, 9);
begin

fifoctrl: process(clk, reset)
begin
    if (reset = '1') then
        weLB1 <= '0';
        dataOut <= (others => '0');
        reLB1 <= '0';
        reLB2 <= '0';
        linesValid <= '0';
        linesStr <= '0';
    elsif rising_edge(clk) then
        linesStr <= dataStr;

        if (dataStr = '1') then -- new pixel has arrived
            -- write it into first FIFO
            weLB1 <= '1';
            dataOut <= dataIn;

            -- read bytes from fifo when resX bytes are buffered
            if (datacountLB1 >= RES_X) then
                reLB1 <= '1';
            else
                reLB1 <= '0';
            end if;

            if (datacountLB2 >= RES_X) then
                reLB2	<= '1';
                linesValid <= '1';
            else
                reLB2 <= '0';
                linesValid <= '0';
            end if;
        else
            -- don't write into first FIFO
            weLB1 <= '0';
            dataOut <= (others => '0');
            -- don't read from first FIFO
            reLB1 <= '0';
            -- don't read from 2nd FIFO
            reLB2 <= '0';
        end if;
    end if;
end process;

nfd: process(clk, reset)
begin
    if (reset = '1') then
        NFDelay <= to_unsigned(NEW_FRAME_DELAY, 9);
        outNewFrame <= '0';
    elsif rising_edge(clk) then
        if (inNewFrame = '1') then
            -- a new frame has started, count the pixels up
            if (dataStr = '1') then
                NFDelay <= to_unsigned(1, 9);
            else
                NFDelay <= (others => '0');
            end if;

            outNewFrame <= '0';
        elsif (dataStr = '1') then
            if (NFDelay /= NEW_FRAME_DELAY) then
                if (NFDelay = NEW_FRAME_DELAY-1) then
                    outNewFrame <= '1';
                else
                    outNewFrame <= '0';
                end if;

                NFDelay <= NFDelay + 1;
            else
                outNewFrame <= '0';
            end if;
        else
            outNewFrame <= '0';
        end if;
    end if;
end process;

end Behavioral;
