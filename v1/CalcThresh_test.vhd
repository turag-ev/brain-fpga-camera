LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY CalcThresh_test IS
END CalcThresh_test;
 
ARCHITECTURE behavior OF CalcThresh_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT CalcThresh
    PORT(
         clk : IN  std_logic;
         bypass : IN  std_logic;
         piIn : IN  std_logic_vector(7 downto 0);
         piNewFrame : IN  std_logic;
         piStr : IN  std_logic;
         thrMin : OUT  std_logic_vector(7 downto 0);
         thrMax : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal bypass : std_logic := '0';
   signal piIn : std_logic_vector(7 downto 0) := (others => '0');
   signal piNewFrame : std_logic := '0';
   signal piStr : std_logic := '0';

 	--Outputs
   signal thrMin : std_logic_vector(7 downto 0);
   signal thrMax : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: CalcThresh PORT MAP (
          clk => clk,
          bypass => bypass,
          piIn => piIn,
          piNewFrame => piNewFrame,
          piStr => piStr,
          thrMin => thrMin,
          thrMax => thrMax
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
   end process;
 
   bp: process
   begin
      wait for clk_period*2;
      bypass <= '1';
      wait for clk_period*10;
      bypass <= '0';
      wait;
   end process;

   -- Stimulus process
   stim_proc: process
   begin
      wait for clk_period*160*120;
      piNewFrame <= '1';
      wait for clk_period;
      piNewFrame <= '0';
   end process;

   din: process
   begin
      piStr <= '1';
      piIn <= x"40";
      wait for clk_period;
      piIn <= x"80";
      wait for clk_period;
   end process;

END;
