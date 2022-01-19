--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:23:35 12/22/2011
-- Design Name:   
-- Module Name:   /home/bob/code/BCam/GetNeighbors_test.vhd
-- Project Name:  BCam_atlys
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: GetNeighbors
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
 
ENTITY GetNeighbors_test IS
END GetNeighbors_test;
 
ARCHITECTURE behavior OF GetNeighbors_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT GetNeighbors
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         qA : OUT  std_logic_vector(7 downto 0);
         qB : OUT  std_logic_vector(7 downto 0);
         qC : OUT  std_logic_vector(7 downto 0);
         qD : OUT  std_logic_vector(7 downto 0);
         qE : OUT  std_logic_vector(7 downto 0);
         qF : OUT  std_logic_vector(7 downto 0);
         qG : OUT  std_logic_vector(7 downto 0);
         qH : OUT  std_logic_vector(7 downto 0);
         qI : OUT  std_logic_vector(7 downto 0);
         qStr : OUT  std_logic;
         linesStr : IN  std_logic;
         line1in : IN  std_logic_vector(7 downto 0);
         line2in : IN  std_logic_vector(7 downto 0);
         line3in : IN  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal linesStr : std_logic := '0';
   signal line1in : std_logic_vector(7 downto 0) := (others => '0');
   signal line2in : std_logic_vector(7 downto 0) := (others => '0');
   signal line3in : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal qA : std_logic_vector(7 downto 0);
   signal qB : std_logic_vector(7 downto 0);
   signal qC : std_logic_vector(7 downto 0);
   signal qD : std_logic_vector(7 downto 0);
   signal qE : std_logic_vector(7 downto 0);
   signal qF : std_logic_vector(7 downto 0);
   signal qG : std_logic_vector(7 downto 0);
   signal qH : std_logic_vector(7 downto 0);
   signal qI : std_logic_vector(7 downto 0);
   signal qStr : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: GetNeighbors PORT MAP (
          clk => clk,
          reset => reset,
          qA => qA,
          qB => qB,
          qC => qC,
          qD => qD,
          qE => qE,
          qF => qF,
          qG => qG,
          qH => qH,
          qI => qI,
          qStr => qStr,
          linesStr => linesStr,
          line1in => line1in,
          line2in => line2in,
          line3in => line3in
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
	-- trigger reset, enable
	rst: process
	begin
		reset <= '1';
		wait for clk_period;
		reset <= '0';
		wait for clk_period;
		wait;
	end process;

   -- insert line data
	stim_proc: process
	begin
		-- 1.
		line1in <= x"01";
		line2in <= x"04";
		line3in <= x"07";
		linesStr <= '1';
		wait for clk_period;

		line1in <= x"02";
		line2in <= x"05";
		line3in <= x"08";
		linesStr <= '1';
		wait for clk_period;

		line1in <= x"03";
		line2in <= x"06";
		line3in <= x"09";
		linesStr <= '1';
		wait for clk_period;

		-- 4
		line1in <= x"10";
		line2in <= x"40";
		line3in <= x"70";
		linesStr <= '1';
		wait for clk_period;

		line1in <= x"20";
		line2in <= x"50";
		line3in <= x"80";
		linesStr <= '1';
		wait for clk_period;

		line1in <= x"30";
		line2in <= x"60";
		line3in <= x"90";
		linesStr <= '1';
		wait for clk_period;

		-- 7
		line1in <= x"11";
		line2in <= x"21";
		line3in <= x"31";
		linesStr <= '1';
		wait for clk_period;

		line1in <= x"12";
		line2in <= x"22";
		line3in <= x"32";
		linesStr <= '1';
		wait for clk_period;

		line1in <= x"13";
		line2in <= x"23";
		line3in <= x"33";
		linesStr <= '1';
		wait for clk_period;

	end process;

END;
