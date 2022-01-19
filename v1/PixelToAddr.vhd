library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PixelToAddr is
    Generic (
        addr_msb : integer := 14
    );
    Port (clk	: in  std_logic;
        reset	: in  std_logic;

        pxIn	: in  std_logic_vector(3 downto 0);
        pxOut	: out std_logic_vector(3 downto 0) := (others => '0');

        inStr	: in  std_logic;
        pxStr : out std_logic;

        -- pipe delayed NewFrame signal through
        inNewFrame  : in  std_logic;
        outNewFrame : out std_logic := '0';

        addr	: out std_logic_vector(addr_msb downto 0) := (others => '0')
    );
end PixelToAddr;

architecture Behavioral of PixelToAddr is
   constant RES_X : integer := 160;
   signal nextAddr : unsigned(addr_msb downto 0) := (others => '0');
begin

	addy: process(clk, reset)
	begin
		if (reset = '1') then
			nextAddr <= (others => '0');
			addr  <= (others => '0');
		elsif rising_edge(clk) then
         -- new frame
         if (inNewFrame = '1') then
            -- reset addr
            addr <= (others => '0');

            if (inStr = '1') then
               -- a pixel has arrived in this cycle, so count up the next time
               nextAddr <= to_unsigned(1, nextAddr'length);
            else
               -- no pixel was there, the next pixel will be the first one
               nextAddr <= (others => '0');
            end if;
         else
            -- just count up --and don't overflow
            if (inStr = '1') and (nextAddr /= "11111111111111111") then
               addr  <= std_logic_vector(nextAddr);
               nextAddr <= nextAddr + 1;
				end if;
			end if;
		end if;
	end process;

   nfpx: process(clk, reset)
   begin
      if (reset = '1') then
         pxOut <= (others => '0');
         pxStr <= '0';
         outNewFrame <= '0';
      elsif rising_edge(clk) then
         if (inStr = '1') then
            pxOut <= pxIn;
         else
            pxOut <= (others => '0');
         end if;

         pxStr <= inStr;
         outNewFrame <= inNewFrame;
      end if;
   end process;

end Behavioral;

