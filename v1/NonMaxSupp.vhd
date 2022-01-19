library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity NMS is
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

            -- pipe delayed NewFrame signal through
            inNewFrame  : in  std_logic;
            outNewFrame : out std_logic := '0';

				-- the result of our calculations
            pxOut	: out std_logic_vector(9 downto 0);
				pxStr	: out std_logic
			);
end NMS;

architecture Behavioral of NMS is
   signal lqNF : std_logic := '0';
begin

   process(clk, reset)
      constant ANGLE_0   : std_logic_vector(1 downto 0) := "00";
      constant ANGLE_45  : std_logic_vector(1 downto 0) := "01";
      constant ANGLE_90  : std_logic_vector(1 downto 0) := "10";
      constant ANGLE_135 : std_logic_vector(1 downto 0) := "11";
      variable e_angle : std_logic_vector(1 downto 0);
      variable e_val : unsigned(7 downto 0);
   begin
      if (reset = '1') then
			pxOut	<= (others => '0');
			pxStr <= '0';
		elsif rising_edge(clk) then
         pxStr <= inStr;

			if (bypass = '1') then
				pxOut	<= inE;
			elsif (inStr = '1') then
            e_angle := inE(9 downto 8);
            e_val := unsigned(inE(7 downto 0));

            if (e_angle = ANGLE_0) then
               if (unsigned(inB(7 downto 0)) > e_val) or (unsigned(inC(7 downto 0)) > e_val)
                     or (unsigned(inG(7 downto 0)) > e_val) or (unsigned(inH(7 downto 0)) > e_val) then
                  pxOut <= (others => '0');
               else
                  pxOut <= inE;
               end if;
            elsif (e_angle = ANGLE_45) then
               if (unsigned(inA(7 downto 0)) > e_val) or (unsigned(inD(7 downto 0)) > e_val)
                     or (unsigned(inH(7 downto 0)) > e_val) or (unsigned(inI(7 downto 0)) > e_val) then
                  pxOut <= (others => '0');
               else
                  pxOut <= inE;
               end if;
            elsif (e_angle = ANGLE_90) then
               if (unsigned(inC(7 downto 0)) > e_val) or (unsigned(inD(7 downto 0)) > e_val)
                     or (unsigned(inF(7 downto 0)) > e_val) or (unsigned(inG(7 downto 0)) > e_val) then
                  pxOut <= (others => '0');
               else
                  pxOut <= inE;
               end if;
            elsif (e_angle = ANGLE_135) then
               if (unsigned(inC(7 downto 0)) > e_val) or (unsigned(inD(7 downto 0)) > e_val)
                     or (unsigned(inF(7 downto 0)) > e_val) or (unsigned(inG(7 downto 0)) > e_val) then
                  pxOut <= (others => '0');
               else
                  pxOut <= inE;
               end if;
            end if;
			else
				pxOut	<= (others => '0');
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
