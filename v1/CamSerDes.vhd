LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity CamSerDes is
    Port (
        clk         : in  std_logic; -- 26.7 MHz
        
        cam_data_p  : in  std_logic;
        cam_data_n  : in  std_logic;
        
        clk_slow_x1, clk_slow_x2, clk_slow_x3 : out std_logic := '0';
        clk_fast    : out std_logic := '0';
        
        data_out    : out std_logic_vector(11 downto 0) := (others => '0');
        data_good   : out std_logic := '0'
    );
end CamSerDes;

architecture Behavioral of CamSerDes is
    COMPONENT serdes12
    Generic (
        -- width of the data for the system
        sys_w       : integer := 1;
        -- width of the data for the device
        dev_w       : integer := 6
    );
    Port (
        -- From the system into the device
        DATA_IN_FROM_PINS_P     : in    std_logic_vector(sys_w-1 downto 0);
        DATA_IN_FROM_PINS_N     : in    std_logic_vector(sys_w-1 downto 0);
        DATA_IN_TO_DEVICE       : out   std_logic_vector(dev_w-1 downto 0);

        BITSLIP                 : in    std_logic;
        
        -- Clock and reset signals
        CLK_IN                  : in    std_logic;
        CLK_SLOW_X1_OUT, CLK_SLOW_X2_OUT, CLK_SLOW_X3_OUT         : out   std_logic;
        CLK_FAST_OUT            : out   std_logic;
        CLK_RESET               : in    std_logic;
        IO_RESET                : in    std_logic
    );
    end component;

    --Inputs
    signal BITSLIP : std_logic := '0';

    --Outputs
    signal DATA_IN_TO_DEVICE : std_logic_vector(5 downto 0);
    signal CLK_SLOW_X1_OUT, CLK_SLOW_X2_OUT, CLK_SLOW_X3_OUT : std_logic;
    signal CLK_FAST_OUT : std_logic;

    -- process deco
    signal packet_first : std_logic_vector(5 downto 0) := (others => '0');
    signal packet : std_logic_vector(11 downto 0) := (others => '0');
    signal pkg_first : std_logic := '1';
    signal good : std_logic := '0';
    signal badcnt : unsigned(4 downto 0) := (others => '0');
begin

instSerdes12 : serdes12
port map (
    DATA_IN_FROM_PINS_P(0) =>   cam_data_p,
    DATA_IN_FROM_PINS_N(0) =>   cam_data_n,
    DATA_IN_TO_DEVICE =>        DATA_IN_TO_DEVICE,

    BITSLIP =>     BITSLIP,

    CLK_IN =>      clk,
    CLK_SLOW_X1_OUT => CLK_SLOW_X1_OUT,
    CLK_SLOW_X2_OUT => CLK_SLOW_X2_OUT,
    CLK_SLOW_X3_OUT => CLK_SLOW_X3_OUT,
    CLK_FAST_OUT => CLK_FAST_OUT,
    CLK_RESET =>   '0',
    IO_RESET =>    '0');

clk_slow_x1 <= CLK_SLOW_X1_OUT;
clk_slow_x2 <= CLK_SLOW_X2_OUT;
clk_slow_x3 <= CLK_SLOW_X3_OUT;
clk_fast <= CLK_FAST_OUT;

data_out <= packet;
data_good <= good;

deco: process(CLK_SLOW_X2_OUT)
begin
    if rising_edge(CLK_SLOW_X2_OUT) then
        if (pkg_first = '1') then
            -- lower 6 bits
            packet_first <= DATA_IN_TO_DEVICE;

            if (DATA_IN_TO_DEVICE(0) = '1') then
                pkg_first <= '0';
            else
                -- no start bit
                badcnt <= badcnt + 1;
                good <= '0';
            end if;
        else
            -- higher 6 bits
            pkg_first <= '1';
            BITSLIP <= '0';
            packet(5 downto 0) <= packet_first;
            packet(11 downto 6) <= DATA_IN_TO_DEVICE;
            
            -- look for stop bit
            if (DATA_IN_TO_DEVICE(5) = '0') then
                badcnt <= (others => '0');
                good <= '1';
            else
                badcnt <= badcnt + 1;
                good <= '0';
            end if;
        end if;
        
        if (badcnt = "11111") then
            BITSLIP <= '1';
            badcnt <= (others => '0');
        else
            BITSLIP <= '0';
        end if;
    end if;
end process;

end Behavioral;
