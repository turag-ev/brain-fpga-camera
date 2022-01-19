LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY EdgeDetect_test IS
END EdgeDetect_test;
 
ARCHITECTURE behavior OF EdgeDetect_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT EdgeDetect
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         bypass : IN  std_logic;
         inA : IN  std_logic_vector(7 downto 0);
         inB : IN  std_logic_vector(7 downto 0);
         inC : IN  std_logic_vector(7 downto 0);
         inD : IN  std_logic_vector(7 downto 0);
         inE : IN  std_logic_vector(7 downto 0);
         inF : IN  std_logic_vector(7 downto 0);
         inG : IN  std_logic_vector(7 downto 0);
         inH : IN  std_logic_vector(7 downto 0);
         inI : IN  std_logic_vector(7 downto 0);
         inStr : IN  std_logic;
         inNewFrame : IN  std_logic;
         outNewFrame : OUT  std_logic;
         pxOut : OUT  std_logic_vector(7 downto 0);
         angleOut : OUT  std_logic_vector(1 downto 0);
         pxStr : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal bypass : std_logic := '0';
   signal inA : std_logic_vector(7 downto 0) := (others => '0');
   signal inB : std_logic_vector(7 downto 0) := (others => '0');
   signal inC : std_logic_vector(7 downto 0) := (others => '0');
   signal inD : std_logic_vector(7 downto 0) := (others => '0');
   signal inE : std_logic_vector(7 downto 0) := (others => '0');
   signal inF : std_logic_vector(7 downto 0) := (others => '0');
   signal inG : std_logic_vector(7 downto 0) := (others => '0');
   signal inH : std_logic_vector(7 downto 0) := (others => '0');
   signal inI : std_logic_vector(7 downto 0) := (others => '0');
   signal inStr : std_logic := '0';
   signal inNewFrame : std_logic := '0';

 	--Outputs
   signal outNewFrame : std_logic;
   signal pxOut : std_logic_vector(7 downto 0);
   signal angleOut : std_logic_vector(1 downto 0);
   signal pxStr : std_logic;

   -- Clock period definitions
    constant clk_period : time := 10 ns;
    constant ANGLE_0   : std_logic_vector(1 downto 0) := "00";
    constant ANGLE_45  : std_logic_vector(1 downto 0) := "01";
    constant ANGLE_90  : std_logic_vector(1 downto 0) := "10";
    constant ANGLE_135 : std_logic_vector(1 downto 0) := "11";
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: EdgeDetect PORT MAP (
          clk => clk,
          reset => reset,
          bypass => bypass,
          inA => inA,
          inB => inB,
          inC => inC,
          inD => inD,
          inE => inE,
          inF => inF,
          inG => inG,
          inH => inH,
          inI => inI,
          inStr => inStr,
          inNewFrame => inNewFrame,
          outNewFrame => outNewFrame,
          pxOut => pxOut,
          angleOut => angleOut,
          pxStr => pxStr
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

stim_proc: process
begin		
    wait for clk_period*5;

    inA <= x"00";
    inB <= x"00";
    inC <= x"00";
    inD <= x"00";
    inE <= x"00";
    inF <= x"00";
    inG <= x"00";
    inH <= x"00";
    inI <= x"00";
    inStr <= '1';
    wait for clk_period;
    inStr <= '0';
    assert (pxOut = x"00") report "1";
    wait for clk_period;

    inA <= x"00";
    inB <= x"00";
    inC <= x"00";
    inD <= x"00";
    inE <= x"00";
    inF <= x"00";
    inG <= x"ff";
    inH <= x"ff";
    inI <= x"ff";
    inStr <= '1';
    wait for clk_period;
    inStr <= '0';
    assert (pxOut = x"ff") report "2";
    assert (angleOut = ANGLE_0) report "3";
    wait for clk_period;

    inA <= x"ff";
    inB <= x"ff";
    inC <= x"ff";
    inD <= x"00";
    inE <= x"00";
    inF <= x"00";
    inG <= x"00";
    inH <= x"00";
    inI <= x"00";
    inStr <= '1';
    wait for clk_period;
    inStr <= '0';
    assert (pxOut = x"ff") report "4";
    assert (angleOut = ANGLE_0) report "5";
    wait for clk_period;

    inA <= x"ff";
    inB <= x"00";
    inC <= x"00";
    inD <= x"ff";
    inE <= x"00";
    inF <= x"00";
    inG <= x"ff";
    inH <= x"00";
    inI <= x"00";
    inStr <= '1';
    wait for clk_period;
    inStr <= '0';
    assert (pxOut = x"ff") report "6";
    assert (angleOut = ANGLE_90) report "7";
    wait for clk_period;

    inA <= x"ff";
    inB <= x"00";
    inC <= x"00";
    inD <= x"ff";
    inE <= x"ff";
    inF <= x"00";
    inG <= x"ff";
    inH <= x"ff";
    inI <= x"ff";
    inStr <= '1';
    wait for clk_period;
    inStr <= '0';
    assert (pxOut = x"ff") report "8";
    assert (angleOut = ANGLE_135) report "9";
    wait for clk_period;

    inA <= x"00";
    inB <= x"00";
    inC <= x"ff";
    inD <= x"00";
    inE <= x"ff";
    inF <= x"ff";
    inG <= x"ff";
    inH <= x"ff";
    inI <= x"ff";
    inStr <= '1';
    wait for clk_period;
    inStr <= '0';
    assert (pxOut = x"ff") report "10";
    assert (angleOut = ANGLE_45) report "11";
    wait for clk_period;

    inA <= x"ff";
    inB <= x"00";
    inC <= x"ff";
    inD <= x"00";
    inE <= x"00";
    inF <= x"00";
    inG <= x"ff";
    inH <= x"00";
    inI <= x"ff";
    inStr <= '1';
    wait for clk_period;
    inStr <= '0';
    assert (pxOut = x"00") report "12";
    wait for clk_period;

    wait;
end process;

END;
