library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ledpwm is
    Port ( CLK : in  STD_LOGIC; -- 48 MHz
           OE : in  STD_LOGIC;
           VAL : in  STD_LOGIC_VECTOR (7 downto 0);
           CLKDIV_OUT : out  STD_LOGIC;
           LED_EN : out  STD_LOGIC;
           LED_PWM : out  STD_LOGIC);
end ledpwm;

architecture Behavioral of ledpwm is
    signal clkdiv : std_logic := '0';
    signal clkcnt : unsigned(4 downto 0) := (others => '0');
    constant CLK_CNT_MAX : integer := 9; -- => 2,400154 MHz
    
    signal cnt : unsigned(7 downto 0) := (others => '0');
    signal val_int : unsigned(7 downto 0) := (others => '0');
    signal led_on : std_logic := '0';
begin

CLKDIV_OUT <= clkdiv;

LED_EN <= OE;
LED_PWM <= led_on;

-- clkdiv should be (10 kHz * 156)
clkdivider: process(CLK)
begin
    if rising_edge(CLK) then
        if (clkcnt = CLK_CNT_MAX) then
            clkcnt <= (others => '0');
            clkdiv <= not clkdiv;
        else
            clkcnt <= clkcnt + 1;
        end if;
    end if;
end process;

count: process(clkdiv)
begin
    if rising_edge(clkdiv) then
        cnt <= cnt + 1;
    end if;
end process;

compare: process(clkdiv)
begin
    if rising_edge(clkdiv) then
        if (cnt = to_unsigned(0, cnt'length)) then
            -- max. value is 0x7f
            val_int(6 downto 0) <= unsigned(VAL(6 downto 0));
            val_int(7) <= '0';
            
            if (unsigned(VAL(6 downto 0)) /= "0000000") then
                led_on <= '1';
            else
                led_on <= '0';
            end if;
        elsif (cnt = val_int) and (val_int /= x"ff") then
            led_on <= '0';
        end if;
    end if;
end process;


end Behavioral;
