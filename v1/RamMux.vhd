library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RamMux is
    Generic (
        DWIDTH : integer := 17
    );
    Port (
        sel : in  STD_LOGIC;

        -- RAM master
        rWE : in  STD_LOGIC;
        rAddr : in  STD_LOGIC_VECTOR (DWIDTH-1 downto 0);
        rIn : in  STD_LOGIC_VECTOR (7 downto 0);
        rOut : out  STD_LOGIC_VECTOR (7 downto 0);

        -- RAM #1
        r1we : out  STD_LOGIC;
        r1addr : out  STD_LOGIC_VECTOR (DWIDTH-1 downto 0);
        r1out : out  STD_LOGIC_VECTOR (7 downto 0);
        r1in : in  STD_LOGIC_VECTOR (7 downto 0);

        -- RAM #2
        r2we : out  STD_LOGIC;
        r2addr : out  STD_LOGIC_VECTOR (DWIDTH-1 downto 0);
        r2out : out  STD_LOGIC_VECTOR (7 downto 0);
        r2in : in  STD_LOGIC_VECTOR (7 downto 0));
end RamMux;

architecture Behavioral of RamMux is

begin

process (sel, rWE, rAddr, rIn, r1in, r2in)
begin
    if (sel = '0') then
        r1we <= rWE;
        r1addr <= rAddr;
        r1out <= rIn;
        rOut <= r1in;
    else
        r2we <= rWE;
        r2addr <= rAddr;
        r2out <= rIn;
        rOut <= r2in;
    end if;
end process;

end Behavioral;

