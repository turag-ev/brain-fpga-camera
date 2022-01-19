--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:55:05 01/07/2012
-- Design Name:   
-- Module Name:   /home/bob/code/BCam/LineBuf1_test.vhd
-- Project Name:  BCam_atlys
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: LineBuf1
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
 
ENTITY LineBuf1_test IS
END LineBuf1_test;
 
ARCHITECTURE behavior OF LineBuf1_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT LineBuf1
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         din : IN  std_logic_vector(7 downto 0);
         wr_en : IN  std_logic;
         rd_en : IN  std_logic;
         dout : OUT  std_logic_vector(7 downto 0);
         full : OUT  std_logic;
         empty : OUT  std_logic;
         data_count : OUT  std_logic_vector(8 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal din : std_logic_vector(7 downto 0) := (others => '0');
   signal wr_en : std_logic := '0';
   signal rd_en : std_logic := '0';

 	--Outputs
   signal dout : std_logic_vector(7 downto 0);
   signal full : std_logic;
   signal empty : std_logic;
   signal data_count : std_logic_vector(8 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
   constant RES_X : integer := 160;
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: LineBuf1 PORT MAP (
          clk => clk,
          rst => rst,
          din => din,
          wr_en => wr_en,
          rd_en => rd_en,
          dout => dout,
          full => full,
          empty => empty,
          data_count => data_count
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
   end process;

   rsty: process
   begin
      wait for clk_period*3;
      rst <= '1';
      wait for clk_period;
      rst <= '0';
      wait;
   end process;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

   dat : process
   begin
      if (unsigned(din) = to_unsigned(RES_X, 8)) then
         din <= x"01";
      else
         din <= std_logic_vector(unsigned(din) + 1);
      end if;
      wr_en <= '1';

      wait for clk_period;
   end process;

   rectrl: process
   begin
		if (unsigned(data_count) > (RES_X - 3)) then
			rd_en	<= '1';
		else
			rd_en <= '0';
		end if;

      wait for clk_period;
   end process;

END;
