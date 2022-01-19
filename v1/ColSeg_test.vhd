--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:01:29 02/06/2012
-- Design Name:   
-- Module Name:   /home/bob/code/BCam/ColSeg_test.vhd
-- Project Name:  BananaCam_ufm
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ColSeg
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY ColSeg_test IS
END ColSeg_test;
 
ARCHITECTURE behavior OF ColSeg_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ColSeg
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         yccIn : IN  std_logic_vector(7 downto 0);
         strIn : IN  std_logic;
         newFrameIn : IN  std_logic;
         pxOut : OUT  std_logic_vector(3 downto 0);
         strOut : OUT  std_logic;
         newFrameOut : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal yccIn : std_logic_vector(7 downto 0) := (others => '0');
   signal strIn : std_logic := '0';
   signal newFrameIn : std_logic := '0';

 	--Outputs
   signal pxOut : std_logic_vector(3 downto 0);
   signal strOut : std_logic;
   signal newFrameOut : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ColSeg PORT MAP (
          clk => clk,
          reset => reset,
          yccIn => yccIn,
          strIn => strIn,
          newFrameIn => newFrameIn,
          pxOut => pxOut,
          strOut => strOut,
          newFrameOut => newFrameOut
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
    wait for clk_period*10;

    yccIn <= x"11";
    strIn <= '1';
    wait for clk_period;
    yccIn <= x"22";
    wait for clk_period;
    yccIn <= x"33";
    wait for clk_period;
    assert (strOut = '1') report "1";
    assert (pxOut = x"1") report "2";
    yccIn <= x"AA";
    wait for clk_period;
    assert (strOut = '0') report "5";
    yccIn <= x"BB";
    wait for clk_period;
    yccIn <= x"CC";
    wait for clk_period;
    assert (strOut = '1') report "3";
    assert (pxOut = x"A") report "4";
    yccIn <= x"44";
    wait for clk_period;
    assert (strOut = '0') report "6";

    strIn <= '0';
    wait for clk_period;
    newFrameIn <= '1';
    wait for clk_period;
    assert (newFrameOut = '1') report "7";
    newFrameIn <= '0';
    wait for clk_period;
    --assert (newFrameOut = '1') report "7";
   
    yccIn <= x"11";
    strIn <= '1';
    wait for clk_period;
    assert (newFrameOut = '0') report "8";
    yccIn <= x"22";
    wait for clk_period;
    yccIn <= x"33";
    wait for clk_period;
    assert (strOut = '1') report "9";
    assert (pxOut = x"1") report "10";
    yccIn <= x"AA";
    wait for clk_period;
    yccIn <= x"BB";
    wait for clk_period;
    yccIn <= x"CC";
    wait for clk_period;
    assert (strOut = '1') report "11";
    assert (pxOut = x"A") report "12";
    yccIn <= x"44";
    strIn <= '0';
    wait for clk_period*2;
    yccIn <= x"11";
    strIn <= '1';
    wait for clk_period;
    yccIn <= x"22";
    wait for clk_period;
    yccIn <= x"33";
    wait for clk_period;
    strIn <= '0';
    assert (strOut = '1') report "13";
    assert (pxOut = x"1") report "14";

    wait for clk_period*3;
    assert (strOut = '0') report "15";
    newFrameIn <= '1';
    yccIn <= x"11";
    strIn <= '1';
    wait for clk_period;
    newFrameIn <= '0';
    assert (newFrameOut = '1') report "16";
    yccIn <= x"22";
    wait for clk_period;
    --assert (newFrameOut = '1') report "16";
    assert (strOut = '0') report "17";
    yccIn <= x"33";
    wait for clk_period;
    assert (strOut = '1') report "18";
    assert (newFrameOut = '0') report "19";
    yccIn <= x"AA";
    wait for clk_period;
    strIn <= '0';

    wait;
end process;

END;
