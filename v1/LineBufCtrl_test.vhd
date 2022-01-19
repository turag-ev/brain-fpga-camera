LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY LineBufCtrl_test IS
END LineBufCtrl_test;
 
ARCHITECTURE behavior OF LineBufCtrl_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT LineBufCtrl
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         dataStr : IN  std_logic;
         dataIn : IN  std_logic_vector(7 downto 0);
         dataOut : OUT  std_logic_vector(7 downto 0);
         inNewFrame : IN  std_logic;
         outNewFrame : OUT  std_logic;
         datacountLB1 : IN  std_logic_vector(8 downto 0);
         datacountLB2 : IN  std_logic_vector(8 downto 0);
         weLB1 : OUT  std_logic;
         reLB1 : OUT  std_logic;
         reLB2 : OUT  std_logic;
         linesValid : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal dataStr : std_logic := '0';
   signal dataIn : std_logic_vector(7 downto 0) := (others => '0');
   signal inNewFrame : std_logic := '0';
   signal datacountLB1 : std_logic_vector(8 downto 0) := (others => '0');
   signal datacountLB2 : std_logic_vector(8 downto 0) := (others => '0');

 	--Outputs
   signal dataOut : std_logic_vector(7 downto 0);
   signal outNewFrame : std_logic;
   signal weLB1 : std_logic;
   signal reLB1 : std_logic;
   signal reLB2 : std_logic;
   signal linesValid : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: LineBufCtrl PORT MAP (
          clk => clk,
          reset => reset,
          dataStr => dataStr,
          dataIn => dataIn,
          dataOut => dataOut,
          inNewFrame => inNewFrame,
          outNewFrame => outNewFrame,
          datacountLB1 => datacountLB1,
          datacountLB2 => datacountLB2,
          weLB1 => weLB1,
          reLB1 => reLB1,
          reLB2 => reLB2,
          linesValid => linesValid
        );
       
   -- Clock process definitions
   clk_process :process
   begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
   end process;

   assr: process
   begin
      wait for clk_period/2;
      assert (dataIn = dataOut) report "dataIn != dataOut";
   end process;

   ass2: process
   begin
      inNewFrame <= '1';
      wait for clk_period;
      inNewFrame <= '0';
      wait for clk_period*320;
      assert (outNewFrame = '1') report "ONF didn't go on";
      wait for clk_period;
      assert (outNewFrame = '0') report "ONF didn't go off";
      wait;
   end process;

   dat : process
   begin
      if (unsigned(dataIn) = to_unsigned(160, 8)) then
         dataIn <= x"01";
      else
         dataIn <= std_logic_vector(unsigned(dataIn) + 1);
      end if;
      dataStr <= '1';
      wait for clk_period;
   end process;

   d1cnt : process
   begin
      if (weLB1 = '1') then
         if (reLB1 = '0') then
            datacountLB1 <= std_logic_vector(unsigned(datacountLB1) + 1);
         end if;
      else
         if (reLB1 = '1') then
            datacountLB1 <= std_logic_vector(unsigned(datacountLB1) - 1);
         end if;
      end if;
      wait for clk_period;
   end process;

   d2cnt : process
   begin
      if (reLB1 = '1') then
         if (reLB2 = '0') then
            datacountLB2 <= std_logic_vector(unsigned(datacountLB2) + 1);
         end if;
      else
         if (reLB2 = '1') then
            datacountLB2 <= std_logic_vector(unsigned(datacountLB2) - 1);
         end if;
      end if;
      wait for clk_period;
   end process;

END;
