library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity PixelThreshold is
   Port (clk		: in  std_logic;
			reset		: in  std_logic;
			bypass	: in  std_logic;

         -- inputs from neighboring pixels
         inA	: in  std_logic_vector(9 downto 0);
         inB	: in  std_logic_vector(9 downto 0);
         inC	: in  std_logic_vector(9 downto 0);
         inD	: in  std_logic_vector(9 downto 0);
         inE	: in  std_logic_vector(9 downto 0);	-- central pixel
         inF	: in  std_logic_vector(9 downto 0);
         inG	: in  std_logic_vector(9 downto 0);
         inH	: in  std_logic_vector(9 downto 0);
         inI	: in  std_logic_vector(9 downto 0);
         inStr	: in	std_logic;

         pxOut	: out std_logic_vector(3 downto 0);
         pxStr : out std_logic;

         -- pipe delayed NewFrame signal through
         inNewFrame  : in  std_logic;
         outNewFrame : out std_logic := '0';

         threshold_min	: in  std_logic_vector(7 downto 0) := x"10";
         threshold_max	: in  std_logic_vector(7 downto 0) := x"30"
         );
end PixelThreshold;

architecture Behavioral of PixelThreshold is
   constant ANGLE_0   : std_logic_vector(1 downto 0) := "00";
   constant ANGLE_45  : std_logic_vector(1 downto 0) := "01";
   constant ANGLE_90  : std_logic_vector(1 downto 0) := "10";
   constant ANGLE_135 : std_logic_vector(1 downto 0) := "11";
   signal lqNF : std_logic := '0';
begin

	process(clk, reset)
      variable angle : std_logic_vector(1 downto 0) := (others => '0');
      variable pxval : std_logic_vector(7 downto 0) := (others => '0');
	begin
      if (reset = '1') then
         pxOut <= (others => '0');
         pxStr <= '0';
		elsif rising_edge(clk) then
         if (bypass = '1') then
            pxOut <= inE(7 downto 4);
         else
            angle := inE(9 downto 8);
            pxval := inE(7 downto 0);

            if (pxval < threshold_min) then     -- no edge
               pxOut <= (others => '0');
            elsif (pxval > threshold_max) then  -- an edge
               pxOut(3 downto 2) <= angle;
               pxOut(1 downto 0) <= "11";
            else                                -- maybe an edge
               -- it's an edge if it's connected to a pixel above the upper threshold
               if (angle = ANGLE_0) then
                  if (inD > threshold_max) or (inF > threshold_max) or (inC > threshold_max) or (inG > threshold_max) or (inA > threshold_max) or (inI > threshold_max) then
                     pxOut(3 downto 2) <= angle;
                     pxOut(1 downto 0) <= "11";
                  else
                     pxOut <= (others => '0');
                  end if;
               elsif (angle = ANGLE_45) then
                  if (inC > threshold_max) or (inG > threshold_max) or (inB > threshold_max) or (inH > threshold_max) or (inD > threshold_max) or (inF > threshold_max) then
                     pxOut(3 downto 2) <= angle;
                     pxOut(1 downto 0) <= "11";
                  else
                     pxOut <= (others => '0');
                  end if;
               elsif (angle = ANGLE_90) then
                  if (inB > threshold_max) or (inH > threshold_max) or (inA > threshold_max) or (inC > threshold_max) or (inG > threshold_max) or (inI > threshold_max) then
                     pxOut(3 downto 2) <= angle;
                     pxOut(1 downto 0) <= "11";
                  else
                     pxOut <= (others => '0');
                  end if;
               elsif (angle = ANGLE_135) then
                  if (inA > threshold_max) or (inI > threshold_max) or (inB > threshold_max) or (inH > threshold_max) or (inD > threshold_max) or (inF > threshold_max)then
                     pxOut(3 downto 2) <= angle;
                     pxOut(1 downto 0) <= "11";
                  else
                     pxOut <= (others => '0');
                  end if;
               end if;
            end if;
         end if;

			pxStr <= inStr;
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
