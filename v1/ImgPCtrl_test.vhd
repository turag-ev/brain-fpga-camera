LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY ImgPCtrl_test IS
END ImgPCtrl_test;
 
ARCHITECTURE behavior OF ImgPCtrl_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ImgPCtrl
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         fpAddr : IN  std_logic_vector(6 downto 0);
         fpDataOut : OUT  std_logic_vector(7 downto 0);
         fpDataIn : IN  std_logic_vector(7 downto 0);
         fpWrite : IN  std_logic;
         fpValid : IN  std_logic;
         ramAddr : OUT  std_logic_vector(15 downto 0);
         ipReset : OUT  std_logic;
         ipNewFrame : OUT  std_logic;
         ipStr : OUT  std_logic;
         noSmoothing : OUT  std_logic;
         noEdgeDetect : OUT  std_logic;
         noNMS : OUT  std_logic;
         noPT : OUT  std_logic;
         noCT : OUT  std_logic;
         isReset : OUT  std_logic;
         isNewFrame : OUT  std_logic;
         isStr : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal fpAddr : std_logic_vector(6 downto 0) := (others => '0');
   signal fpDataIn : std_logic_vector(7 downto 0) := (others => '0');
   signal fpWrite : std_logic := '0';
   signal fpValid : std_logic := '0';

 	--Outputs
   signal fpDataOut : std_logic_vector(7 downto 0);
   signal ramAddr : std_logic_vector(15 downto 0);
   signal ipReset : std_logic;
   signal ipNewFrame : std_logic;
   signal ipStr : std_logic;
   signal noSmoothing : std_logic;
   signal noEdgeDetect : std_logic;
   signal noNMS : std_logic;
   signal noPT : std_logic;
   signal noCT : std_logic;
   signal isReset : std_logic;
   signal isNewFrame : std_logic;
   signal isStr : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ImgPCtrl PORT MAP (
          clk => clk,
          reset => reset,
          fpAddr => fpAddr,
          fpDataOut => fpDataOut,
          fpDataIn => fpDataIn,
          fpWrite => fpWrite,
          fpValid => fpValid,
          ramAddr => ramAddr,
          ipReset => ipReset,
          ipNewFrame => ipNewFrame,
          ipStr => ipStr,
          noSmoothing => noSmoothing,
          noEdgeDetect => noEdgeDetect,
          noNMS => noNMS,
          noPT => noPT,
          noCT => noCT,
          isReset => isReset,
          isNewFrame => isNewFrame,
          isStr => isStr
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
stim_proc: process
begin
    wait for clk_period*5;
    
    -- set imgproc flags
    fpAddr <= "0100010";
    fpDataIn <= x"AA";
    fpValid <= '1';
    fpWrite <= '1';
    wait for clk_period;
    assert (noSmoothing = '0') report "a";
    assert (noEdgeDetect = '1') report "b";
    assert (noNMS = '0') report "c";
    assert (noPT = '1') report "d";
    assert (noCT = '0') report "e";

    fpDataIn <= x"55";
    wait for clk_period;
    assert (noSmoothing = '1') report "f";
    assert (noEdgeDetect = '0') report "g";
    assert (noNMS = '1') report "h";
    assert (noPT = '0') report "i";
    assert (noCT = '1') report "j";

    fpValid <= '0';
    
    wait for clk_period*2;
    fpWrite <= '0';
    fpDataIn <= x"AA";
    wait for clk_period;

for a in 0 to 2 loop
    -- start img processing
    fpAddr <= "0100000";
    fpValid <= '1';
    fpWrite <= '1';
    wait for clk_period;
    fpValid <= '0';

    assert (ipNewFrame = '1') report "1";
    assert (isNewFrame = '1') report "2";
    assert (ipStr = '0') report "3";
    assert (isStr = '0') report "4";
    wait for clk_period;

    for i in 0 to 19200-1 loop
        assert (ipNewFrame = '0') report "5";
        assert (isNewFrame = '0') report "6";
        assert (ipStr = '1') report "7";
        assert (isStr = '1') report "8";
        wait for clk_period;

        assert (ipNewFrame = '0') report "9";
        assert (isNewFrame = '0') report "10";
        assert (ipStr = '0') report "11";
        assert (isStr = '1') report "12";
        wait for clk_period;

        assert (ipNewFrame = '0') report "9";
        assert (isNewFrame = '0') report "10";
        assert (ipStr = '0') report "11";
        assert (isStr = '1') report "12";
        wait for clk_period;
    end loop;

    assert (ipNewFrame = '0') report "13";
    assert (isNewFrame = '0') report "14";
    assert (ipStr = '0') report "15";
    assert (isStr = '0') report "16";
    wait for clk_period*100;
end loop;

    wait;
end process;

END;
