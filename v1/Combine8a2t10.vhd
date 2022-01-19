library ieee;
use ieee.std_logic_1164.all;

entity Combine8a2t10 is
    Port ( upper : in  STD_LOGIC_VECTOR (1 downto 0);
           lower : in  STD_LOGIC_VECTOR (7 downto 0);
           y : out  STD_LOGIC_VECTOR (9 downto 0));
end Combine8a2t10;

architecture Behavioral of Combine8a2t10 is

begin

   y(9 downto 8) <= upper;
   y(7 downto 0) <= lower;

end Behavioral;

