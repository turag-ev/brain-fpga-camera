library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ColSeg is
    Port (
            clk     : in  std_logic;
            reset   : in  std_logic;

            yccIn   : in  std_logic_vector(7 downto 0);
            strIn   : in  std_logic;
            newFrameIn : in  std_logic;

            pxOut   : out std_logic_vector(3 downto 0) := (others => '0');
            strOut  : out std_logic;
            newFrameOut : out std_logic;
            
            CW_CBMIN, CW_CBMAX, CW_CRMIN, CW_CRMAX, CW_YMIN : in  std_logic_vector(7 downto 0)
        );
end ColSeg;

architecture Behavioral of ColSeg is
    constant DEBUG : std_logic := '0';
    constant MAX_CNT : integer := 2;
    constant FUZZ : integer := 30;
    constant FUZZB : integer := 20;
    constant FUZZC : integer := 25;
    constant FUZZD : integer := 17;
    constant FUZZE : integer := 11;
    signal y, cb : unsigned(7 downto 0) := (others => '0');
    signal cnt : unsigned(2 downto 0) := (others => '0');
    signal cw_cbmin_int, cw_cbmax_int, cw_crmin_int, cw_crmax_int, cw_ymin_int : unsigned(7 downto 0);
begin

cw_cbmin_int <= unsigned(CW_CBMIN);
cw_cbmax_int <= unsigned(CW_CBMAX);
cw_crmin_int <= unsigned(CW_CRMIN);
cw_crmax_int <= unsigned(CW_CRMAX);
cw_ymin_int <= unsigned(CW_YMIN);

process(clk, reset)
    variable cr : unsigned(7 downto 0) := (others => '0');
begin
    if (reset = '1') then
        y <= (others => '0');
        cb <= (others => '0');
        cr := (others => '0');
        pxOut <= (others => '0');
        strOut <= '0';
        cnt <= (others => '0');
    elsif rising_edge(clk) then
        strOut <= '0';

        newFrameOut <= newFrameIn;

        if (newFrameIn = '1') then  -- start of new frame
            y <= (others => '0');
            
            if (strIn = '1') then   -- first pixel of frame arrived
                cb <= unsigned(yccIn);
                cnt <= to_unsigned(1, cnt'length);
            else
                cb <= (others => '0');
                cnt <= (others => '0');
            end if;
        elsif (strIn = '1') then
            y <= cb;
            cb <= unsigned(yccIn);
            cr := unsigned(yccIn);

            if (DEBUG = '1') and (cnt = MAX_CNT) then
                pxOut <= std_logic_vector(y(7 downto 4));
                strOut <= '1';
                cnt <= to_unsigned(0, cnt'length);
            elsif (cnt = MAX_CNT) then
                if (cb > cw_cbmin_int) and (cb < cw_cbmax_int) and (cr > cw_crmin_int) and (cr < cw_crmax_int) and (y > cw_ymin_int) then
                    pxOut <= x"5";  -- weisse CD (cr-fuzz ~13 con)
                elsif (cb > 80-FUZZB) and (cb < 80+FUZZB) and (cr > 148-FUZZB) and (cr < 148+FUZZB) and (y < 50) then
                    pxOut <= x"6";  -- schwarze CD
                elsif (cb > 90-FUZZC) and (cb < 90+FUZZC) and (cr > 145-FUZZ) and (cr < 145+FUZZ) then
                    pxOut <= x"3";  -- gelbe Spielelemente, Insel
                elsif (cb > 92-FUZZB) and (cb < 92+FUZZB) and (cr > 200-FUZZB) then
                    pxOut <= x"4";  -- rote Startecke
                elsif (cb > 125-FUZZE) and (cb < 125+FUZZE) and (cr > 135-FUZZE) and (cr < 135+FUZZE) then
                    pxOut <= x"2";  -- Spielfeld, braunes Deck
                elsif (cb > 127-FUZZD) and (cb < 127+FUZZD) and (cr > 125-FUZZE) and (cr < 125+FUZZE) and (y < 105) then
                    pxOut <= x"1";  -- Spielfeld, blaue Flaeche
                else
                    pxOut <= x"0";
                end if;

                strOut <= '1';
                cnt <= to_unsigned(0, cnt'length);
            else
                cnt <= cnt + 1;
            end if;
        end if;
    end if;
end process;

end Behavioral;
