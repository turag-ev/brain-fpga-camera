library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity con_2x4to8 is
    Port ( LO : in  STD_LOGIC_VECTOR (3 downto 0);
           HI : in  STD_LOGIC_VECTOR (3 downto 0);
           Y  : out  STD_LOGIC_VECTOR (7 downto 0));
end con_2x4to8;

architecture Behavioral of con_2x4to8 is

begin

Y(3 downto 0) <= LO;
Y(7 downto 4) <= HI;

end Behavioral;

------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity con_8to2x4 is
    Port ( LO : out STD_LOGIC_VECTOR (3 downto 0);
           HI : out STD_LOGIC_VECTOR (3 downto 0);
           Y  : in  STD_LOGIC_VECTOR (7 downto 0));
end con_8to2x4;

architecture Behavioral of con_8to2x4 is

begin

LO <= Y(3 downto 0);
HI <= Y(7 downto 4);

end Behavioral;

------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity con_pxram is
    Port (
        CLK : in std_logic;
        
        PX_LV, PX_FV : in std_logic;
        PX_X, PX_Y : in std_logic_vector(8 downto 0);
        PX_DATA : in std_logic_vector(7 downto 0);
        
        RAM_WE : out std_logic := '0';
        RAM_ADDR : out std_logic_vector(16 downto 0) := (others => '0');
        RAM_OUT : out std_logic_vector(7 downto 0) := (others => '0')
        );
end con_pxram;

architecture Behavioral of con_pxram is
    constant VALID : std_logic := '1';
    
    signal addr_next : unsigned(RAM_ADDR'length-1 downto 0) := (others => '0');
    signal pxx_last, pxy_last : std_logic_vector(PX_X'length-1 downto 0) := (others => '1');
begin

process(CLK)
begin
    if rising_edge(CLK) then
        if (PX_FV /= VALID) then
            -- end of frame
            RAM_WE <= '0';
            RAM_ADDR <= (others => '0');
            addr_next <= (others => '0');
            pxx_last <= (others => '1');
            pxy_last <= (others => '1');
        elsif (PX_LV = VALID) then
            RAM_WE <= '0';
            
            if (PX_X /= pxx_last) or (PX_Y /= pxy_last) then
                RAM_ADDR <= std_logic_vector(addr_next);
                addr_next <= addr_next + 1;
                RAM_OUT <= PX_DATA;
                RAM_WE <= '1';
            end if;
            
            pxx_last <= PX_X;
            pxy_last <= PX_Y;
        end if;
    end if;
end process;

end Behavioral;

------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity con_8x1to8 is
    Port (  A : in  STD_LOGIC;
            B : in  STD_LOGIC;
            C : in  STD_LOGIC;
            D : in  STD_LOGIC;
            E : in  STD_LOGIC;
            F : in  STD_LOGIC;
            G : in  STD_LOGIC;
            H : in  STD_LOGIC;
            Y  : out STD_LOGIC_VECTOR (7 downto 0));
end con_8x1to8;

architecture Behavioral of con_8x1to8 is
    signal y_int : STD_LOGIC_VECTOR (7 downto 0);
begin

Y <= not y_int;
y_int(0) <= A;
y_int(1) <= B;
y_int(2) <= C;
y_int(3) <= D;
y_int(4) <= E;
y_int(5) <= F;
y_int(6) <= G;
y_int(7) <= H;

end Behavioral;

------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity con_17to16 is
    Port ( A : in  STD_LOGIC_VECTOR (16 downto 0);
           Y : out STD_LOGIC_VECTOR (15 downto 0));
end con_17to16;

architecture Behavioral of con_17to16 is

begin

Y <= A(Y'length-1 downto 0);

end Behavioral;
