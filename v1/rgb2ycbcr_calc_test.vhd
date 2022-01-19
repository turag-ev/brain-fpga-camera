--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:35:04 03/22/2012
-- Design Name:   
-- Module Name:   /home/bob/code/BCam/rgb2ycbcr_calc_test.vhd
-- Project Name:  BananaCam_ufm
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: rgb2ycbcr_calc
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
 
ENTITY rgb2ycbcr_calc_test IS
END rgb2ycbcr_calc_test;
 
ARCHITECTURE behavior OF rgb2ycbcr_calc_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT rgb2ycbcr_calc
    PORT(
         clk : IN  std_logic;
         r : IN  std_logic_vector(7 downto 0);
         g : IN  std_logic_vector(7 downto 0);
         b : IN  std_logic_vector(7 downto 0);
         y : OUT  std_logic_vector(7 downto 0);
         cr : OUT  std_logic_vector(7 downto 0);
         cb : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal r : unsigned(7 downto 0) := (others => '0');
   signal g : unsigned(7 downto 0) := (others => '0');
   signal b : unsigned(7 downto 0) := (others => '0');

 	--Outputs
   signal y : std_logic_vector(7 downto 0);
   signal cr : std_logic_vector(7 downto 0);
   signal cb : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: rgb2ycbcr_calc PORT MAP (
          clk => clk,
          r => std_logic_vector(r),
          g => std_logic_vector(g),
          b => std_logic_vector(b),
          y => y,
          cr => cr,
          cb => cb
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
        assert (unsigned(y) = to_unsigned(16, 8)) and (unsigned(cb) = to_unsigned(128, 8)) and (unsigned(cr) = to_unsigned(128, 8)) report "ycbcr value fucking wrong";

        r <= to_unsigned(12, 8);
        g <= to_unsigned(34, 8);
        b <= to_unsigned(56, 8);
        wait for clk_period;

        r <= to_unsigned(196, 8);
        g <= to_unsigned(253, 8);
        b <= to_unsigned(6, 8);
        wait for clk_period;

        wait;
    end process;

END;
