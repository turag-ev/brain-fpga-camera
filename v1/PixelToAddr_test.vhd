LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY PixelToAddr_test IS
END PixelToAddr_test;
 
ARCHITECTURE behavior OF PixelToAddr_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT PixelToAddr
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         pxIn : IN  std_logic_vector(7 downto 0);
         pxOut : OUT  std_logic_vector(7 downto 0);
         inStr : IN  std_logic;
         pxStr : OUT  std_logic;
         inNewFrame : IN  std_logic;
         outNewFrame : OUT  std_logic;
         addr : OUT  std_logic_vector(14 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal pxIn : std_logic_vector(7 downto 0) := (others => '0');
   signal inStr : std_logic := '0';
   signal inNewFrame : std_logic := '0';

 	--Outputs
   signal pxOut : std_logic_vector(7 downto 0);
   signal pxStr : std_logic;
   signal outNewFrame : std_logic;
   signal addr : std_logic_vector(14 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: PixelToAddr PORT MAP (
          clk => clk,
          reset => reset,
          pxIn => pxIn,
          pxOut => pxOut,
          inStr => inStr,
          pxStr => pxStr,
          inNewFrame => inNewFrame,
          outNewFrame => outNewFrame,
          addr => addr
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for clk_period*5;

      pxIn <= x"01";
      wait for clk_period;
      assert pxOut = x"00" report "pxOut != 00 1";
      assert addr(7 downto 0) = x"00" report "addr not 00 1";
      
      pxIn <= x"02";
      wait for clk_period;
      assert pxOut = x"00" report "pxOut != 00 2";
      
      inStr <= '1';
      wait for clk_period;
      assert pxStr = '1' report "pxStr != 1 1";
      assert pxOut = x"02" report "pxOut != 02";
      assert addr(7 downto 0) = x"00" report "addr not 00 2";

      pxIn <= x"03";
      wait for clk_period;
      assert pxOut = x"03" report "pxOut != 03";
      assert addr(7 downto 0) = x"01" report "addr not 01";

      pxIn <= x"04";
      wait for clk_period;
      assert pxOut = x"04" report "pxOut != 04 1";
      assert addr(7 downto 0) = x"02" report "addr not 02 1";

      inStr <= '0';
      pxIn <= x"05";
      wait for clk_period;
      assert pxOut = x"00" report "pxOut != 00 3";
      assert pxStr = '0' report "pxStr != 1 2";
      assert addr(7 downto 0) = x"02" report "addr not 02 2";

      wait for 2*clk_period;
      assert pxOut = x"00" report "pxOut != 00 4";
      assert pxStr = '0' report "pxStr != 1 3";
      assert addr(7 downto 0) = x"02" report "addr not 02 3";

      assert outNewFrame = '0' report "outNewFrame != 0 1";
      inNewFrame <= '1';
      wait for clk_period;

      assert outNewFrame = '1' report "outNewFrame != 1 1";
      assert addr(7 downto 0) = x"00" report "addr not 00 3";
      inNewFrame <= '0';
      wait for 2*clk_period;

      pxIn <= x"23";
      inStr <= '1';
      wait for 32*clk_period;
      inStr <= '0';
      wait for 8*clk_period;
      inStr <= '1';
      wait for 32*clk_period;
      assert addr(7 downto 0) = x"3f" report "addr not 3f";

      inNewFrame <= '1';
      wait for clk_period;

      inNewFrame <= '0';
      assert outNewFrame = '1' report "outNewFrame != 1 1";
      assert addr(7 downto 0) = x"00" report "addr not 00 4";

      wait;
   end process;

END;
