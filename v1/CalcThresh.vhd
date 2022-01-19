library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity CalcThresh is
   Port (clk         : in  std_logic;
         bypass      : in  std_logic := '0';

         piIn			: in  std_logic_vector(7 downto 0);
         piNewFrame	: in  std_logic := '0';
         piStr			: in  std_logic := '0';

         thrMin      : out std_logic_vector(7 downto 0) := (others => '0');
         thrMax      : out std_logic_vector(7 downto 0) := (others => '0')
         );
end CalcThresh;

architecture Behavioral of CalcThresh is
   signal cval : unsigned(17 downto 0) := (others => '0');
begin

   process(clk)
      variable tmin, tmax : unsigned(17 downto 0) := (others => '0');
   begin
      if rising_edge(clk) then
         if (bypass = '1') then
            thrMin <= x"14";
            thrMax <= x"3c";
         elsif (piNewFrame = '1') then
            if (cval(0) = '1') then
               thrMin <= x"80";
               thrMax <= x"ff";
            else
               tmin := shift_right(unsigned(cval), 10);
               thrMin <= std_logic_vector(tmin(7 downto 0));
               tmax := shift_right(unsigned(cval), 9);
               thrMax <= std_logic_vector(tmax(7 downto 0));
            end if;
  
            cval <= (others => '0');
         else
            cval <= cval + shift_right(unsigned(piIn), 5);
         end if;
      end if;
   end process;

end Behavioral;

