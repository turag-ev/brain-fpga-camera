library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity EdgeDetect is
    Port (
        clk     : in  std_logic;
        reset   : in  std_logic;
        bypass  : in  std_logic;

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
        inStr : in  std_logic;

        -- pipe delayed NewFrame signal through
        inNewFrame  : in  std_logic;
        outNewFrame : out std_logic := '0';

        -- the result of our calculations
        pxOut   : out std_logic_vector(7 downto 0);
        angleOut: out std_logic_vector(1 downto 0);
        pxStr   : out std_logic
    );
end EdgeDetect;

architecture Behavioral of EdgeDetect is
   signal lqNF : std_logic := '0';
begin

process(clk, reset)
    constant ANGLE_0   : std_logic_vector(1 downto 0) := "00";
    constant ANGLE_45  : std_logic_vector(1 downto 0) := "01";
    constant ANGLE_90  : std_logic_vector(1 downto 0) := "10";
    constant ANGLE_135 : std_logic_vector(1 downto 0) := "11";
    variable A, B, C, D, F, G, H, I : signed(11 downto 0) := (others => '0');
    variable gx, gy : signed(11 downto 0);
    variable abs_gx, abs_gy, sum : unsigned(11 downto 0);
begin
    if (reset = '1') then
        pxOut <= (others => '0');
        pxStr <= '0';
        angleOut <= (others => '0');
    elsif rising_edge(clk) then
        if (bypass = '1') then
            pxOut	<= inE;	-- pipe the central pixel through
            pxStr <= inStr;
        elsif (inStr = '1') then
            -- we need 12 bit wide variables
            A(8 downto 0) := signed('0' & inA);
            B(8 downto 0) := signed('0' & inB);
            C(8 downto 0) := signed('0' & inC);
            D(8 downto 0) := signed('0' & inD);
            F(8 downto 0) := signed('0' & inF);
            G(8 downto 0) := signed('0' & inG);
            H(8 downto 0) := signed('0' & inH);
            I(8 downto 0) := signed('0' & inI);

            -- sobel mask for gradient in horiz. direction
            -- max. value: 4*255 => 10 bits + sign bit needed
            gx := C + shift_left(F, 1) + I - A - shift_left(D, 1) - G;
            -- sobel mask for gradient in vertical direction
            gy := G + shift_left(H, 1) + I - A - shift_left(B, 1) - C;

            abs_gx := unsigned(abs(gx));
            abs_gy := unsigned(abs(gy));

            -- max. value: 2*4*255 => 11 bits + sign bit needed
            sum := abs_gx + abs_gy;

            -- limit the value to 255. this may not be right, but it looks good.
            if (sum(11 downto 10) > 0) then
                pxOut <= x"ff";
            else
                pxOut <= std_logic_vector(sum(9 downto 2));
            end if;
            pxStr <= '1';

            -- calculate _edge_ angle
            -- angleOut = atan(gy/gx)-90deg, rounded to {0,45,90,135} degrees
            if (sum = to_unsigned(0, sum'length)) then
                angleOut <= (others => '0');
            elsif ((gx > 0) and (gy > 0)) or ((gx < 0) and (gy < 0)) then      -- 1st/3rd quadrant
                if (shift_right(abs_gy, 1) > abs_gx) then
                    angleOut <= ANGLE_0;
                elsif (abs_gy > shift_right(abs_gx, 1)) then
                    angleOut <= ANGLE_45;
                else
                    angleOut <= ANGLE_90;
                end if;
            else --if ((gx > 0) and (gy < 0)) or ((gx < 0) and (gy > 0)) then   -- 4th/2nd quadrant
                if (shift_right(abs_gy, 1) > abs_gx) then
                    angleOut <= ANGLE_0;
                elsif (abs_gy > shift_right(abs_gx, 1)) then
                    angleOut <= ANGLE_135;
                else
                    angleOut <= ANGLE_90;
                end if;
            end if;
        else
            pxOut <= (others => '0');
            pxStr <= '0';
            angleOut<= (others => '0');
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
