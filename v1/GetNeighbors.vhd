library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity GetNeighbors is
    Port (  clk		: in  std_logic;
            reset		: in  std_logic;

				-- Neighbor pixels, E is the central pixel
				--  A | B | C 
				--  D |(E)| F
				--  G | H | I
            qA	: out std_logic_vector(7 downto 0);
            qB	: out std_logic_vector(7 downto 0);
            qC	: out std_logic_vector(7 downto 0);
            qD	: out std_logic_vector(7 downto 0);
            qE	: out std_logic_vector(7 downto 0);
            qF	: out std_logic_vector(7 downto 0);
            qG	: out std_logic_vector(7 downto 0);
            qH	: out std_logic_vector(7 downto 0);
            qI	: out std_logic_vector(7 downto 0);
				qStr : out std_logic;

            -- pipe delayed NewFrame signal through
            inNewFrame  : in  std_logic := '0';
            outNewFrame : out std_logic := '0';

				-- source image FIFOs
				linesStr		: in  std_logic;
				line1in		: in  std_logic_vector(7 downto 0);
				line2in		: in  std_logic_vector(7 downto 0);
				line3in		: in  std_logic_vector(7 downto 0)
			);
end GetNeighbors;

architecture Behavioral of GetNeighbors is
	signal lqA, lqB, lqC, lqD, lqE, lqF, lqG, lqH, lqI : unsigned(7 downto 0) := (others => '0');
	signal lqStr, lqNF, lrNF : std_logic := '0';
begin

	process(clk, reset)
	begin
		if (reset = '1') then
			qA			<= (others => '0');
			qB			<= (others => '0');
			qC			<= (others => '0');
			qD			<= (others => '0');
			qE			<= (others => '0');
			qF			<= (others => '0');
			qG			<= (others => '0');
			qH			<= (others => '0');
			qI			<= (others => '0');
			lqA		<= (others => '0');
			lqB		<= (others => '0');
			lqC		<= (others => '0');
			lqD		<= (others => '0');
			lqE		<= (others => '0');
			lqF		<= (others => '0');
			lqG		<= (others => '0');
			lqH		<= (others => '0');
			lqI		<= (others => '0');
			lqStr		<= '0';
		elsif rising_edge(clk) then
			if (linesStr = '1') then
				-- line 1
				lqC <= lqB;
				lqB <= lqA;
				lqA <= unsigned(line1in);
				-- line 2
				lqF <= lqE;
				lqE <= lqD;
				lqD <= unsigned(line2in);
				-- line 3
				lqI <= lqH;
				lqH <= lqG;
				lqG <= unsigned(line3in);
				-- strobe signal
				lqStr <= '1';
			else
				lqStr <= '0';
			end if;

			qA <= std_logic_vector(lqA);
			qB <= std_logic_vector(lqB);
			qC <= std_logic_vector(lqC);
			qD <= std_logic_vector(lqD);
			qE <= std_logic_vector(lqE);
			qF <= std_logic_vector(lqF);
			qG <= std_logic_vector(lqG);
			qH <= std_logic_vector(lqH);
			qI <= std_logic_vector(lqI);
			qStr <= lqStr;
		end if;
	end process;

   nfOne: process(clk)
   begin
      if rising_edge(clk) then
         -- pipe NF through one cycle additional latency
         if (inNewFrame = '1') then
            if (linesStr = '1') then
               lqNF <= '0'; -- a pixel came, NF high after one cycle
               lrNF <= '1';
            else
               lqNF <= '1'; -- no pixel, so oNF high after two cycles
               lrNF <= '0';
            end if;

            outNewFrame <= '0';
         elsif (linesStr = '1') then
            outNewFrame <= lrNF;
            lrNF <= lqNF;
            lqNF <= '0';
         end if;
      end if;
   end process;

end Behavioral;

