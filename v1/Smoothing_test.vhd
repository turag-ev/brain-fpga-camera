--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:05:12 12/22/2011
-- Design Name:   
-- Module Name:   /home/bob/code/BCam/Smoothing_test.vhd
-- Project Name:  BCam_atlys
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Smoothing
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
--USE ieee.numeric_std.ALL;
 
ENTITY Smoothing_test IS
END Smoothing_test;
 
ARCHITECTURE behavior OF Smoothing_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Smoothing
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         enable : IN  std_logic;
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
         pxOut : OUT  std_logic_vector(7 downto 0);
         pxStr : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal enable : std_logic := '0';
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

 	--Outputs
   signal pxOut : std_logic_vector(7 downto 0);
   signal pxStr : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Smoothing PORT MAP (
          clk => clk,
          reset => reset,
          enable => enable,
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
          pxOut => pxOut,
          pxStr => pxStr
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
   end process;
 
	-- trigger reset, enable
	rst: process
	begin
		reset <= '1';
		wait for clk_period;
		reset <= '0';
		wait for clk_period*5;
		enable <= '1';
		wait;
	end process;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      inStr <= '1';

      wait;
   end process;

END;
