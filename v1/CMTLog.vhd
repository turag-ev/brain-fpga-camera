library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CMTLog is
    Port (
        CLK : in  std_logic;

        PACKET_DATA : in  std_logic_vector(11 downto 0);
        PACKET_GOOD : in  std_logic;

        LED : out std_logic_vector(7 downto 0) := (others => '0');

        FRAMETIME : out std_logic_vector(23 downto 0) := (others => '0');
        FRAMEPART : in std_logic_vector(7 downto 0);
        
        RAM_WE : out std_logic := '0';
        RAM_ADDR : out std_logic_vector(14 downto 0) := (others => '0'); -- eat 32768 packets
        RAM_DOUT : out std_logic_vector(15 downto 0) := (others => '0')
    );
end CMTLog;

architecture Behavioral of CMTLog is
    constant LINE_VALID_BIT  : integer := 9;
    constant FRAME_VALID_BIT : integer := 10;
    
    signal ram_we_int : std_logic := '0';
    signal led_int : std_logic_vector(7 downto 0) := (others => '0');
    signal frametime_int : std_logic_vector(FRAMETIME'length-1 downto 0) := (others => '0');
    
    signal frm_cnt : unsigned(FRAMETIME'length-1 downto 0) := (others => '0');
    signal frmlvl : std_logic := '0';
begin

FRAMETIME <= frametime_int;
RAM_WE <= ram_we_int;

LED <= not led_int;
led_int(0) <= ram_we_int;
led_int(1) <= PACKET_GOOD;
led_int(2) <= PACKET_DATA(FRAME_VALID_BIT);
led_int(3) <= PACKET_DATA(LINE_VALID_BIT);
led_int(7 downto 4) <= frametime_int(18 downto 15);

frmtm: process(CLK)
begin
    if rising_edge(CLK) then
        if (PACKET_GOOD = '1') then
            frmlvl <= PACKET_DATA(FRAME_VALID_BIT);

            if (PACKET_DATA(FRAME_VALID_BIT) = '0') then
                if (frmlvl = '1') then
                    -- end of frame
                    frametime_int <= std_logic_vector(frm_cnt);
                end if;
                
                frm_cnt <= (others => '0');
            else
                frm_cnt <= frm_cnt + 1;
            end if;
        end if;
    end if;
end process;

fillram: process(CLK)
begin
    if rising_edge(CLK) then
        if (PACKET_GOOD = '1') then
            if (std_logic_vector(frm_cnt(22 downto 15)) = FRAMEPART) then
                ram_we_int <= '1';
                RAM_ADDR <= std_logic_vector(frm_cnt(14 downto 0));
                RAM_DOUT(15 downto 12) <= FRAMEPART(3 downto 0);
                RAM_DOUT(11 downto 0) <= PACKET_DATA;
            else
                ram_we_int <= '0';
            end if;
        end if;
    end if;
end process;

end Behavioral;
