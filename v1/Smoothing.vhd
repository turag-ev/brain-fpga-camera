library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity Smoothing is
		Port (clk		: in  std_logic;
				reset		: in  std_logic;
				bypass	: in  std_logic;

				-- inputs from neighboring pixels
            inA	: in  std_logic_vector(7 downto 0);
            inB	: in  std_logic_vector(7 downto 0);
            inC	: in  std_logic_vector(7 downto 0);
            inD	: in  std_logic_vector(7 downto 0);
            inE	: in  std_logic_vector(7 downto 0);	-- central pixel
            inF	: in  std_logic_vector(7 downto 0);
            inG	: in  std_logic_vector(7 downto 0);
            inH	: in  std_logic_vector(7 downto 0);
            inI	: in  std_logic_vector(7 downto 0);
				inStr	: in	std_logic;

            -- pipe delayed NewFrame signal through
            inNewFrame  : in  std_logic;
            outNewFrame : out std_logic := '0';

				-- the result of our calculations
				pxOut	: out std_logic_vector(7 downto 0);
				pxStr	: out std_logic
			);
end Smoothing;

architecture Behavioral of Smoothing is
   signal lqNF : std_logic := '0';
begin

	process(clk, reset)
		variable calc : unsigned(15 downto 0);
	begin
		if (reset = '1') then
			pxOut	<= (others => '0');
			pxStr <= '0';
		elsif rising_edge(clk) then
         pxStr <= inStr;

			if (bypass = '1') then
				pxOut	<= inE;	-- pipe the central pixel through
			else
				if (inStr = '1') then
					-- 1  8  1
					-- 8 64  8
					-- 1  8  1
					--/ 100
					calc := unsigned(inA) + unsigned(inC) + unsigned(inG) + unsigned(inI) + 10 * unsigned(inB) + 10 * unsigned(inD) + 10 * unsigned(inF) + 10 * unsigned(inH) + 84 * unsigned(inE);
					pxOut <= std_logic_vector(calc(14 downto 7));
				end if;
			end if;
		end if;
	end process;

   nf: process(clk)
   begin
      if rising_edge(clk) then
         -- pipe NF through without additional latency
         if (inNewFrame = '1') then
            if (inStr = '1') then
               lqNF <= '0'; -- a pixel came, NF high now
               outNewFrame <= '1';
            else
               lqNF <= '1'; -- no pixel, so oNF high at the next cycle when a pixel comes
               outNewFrame <= '0';
            end if;
         elsif (inStr = '1') then
            outNewFrame <= lqNF;
            lqNF <= '0';
         end if;
      end if;
   end process;

end Behavioral;

