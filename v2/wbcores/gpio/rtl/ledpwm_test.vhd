--------------------------------------------------------------------------------
-- Company: 
-- Engineer: spezifisch
--
-- Create Date:   14:01:58 03/19/2012
-- Design Name:   
-- Module Name:   /home/bob/code/BCam/ledpwm_test.vhd
-- Project Name:  BananaCam_ufm
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ledpwm
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
 
ENTITY ledpwm_test IS
END ledpwm_test;
 
ARCHITECTURE behavior OF ledpwm_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ledpwm
    PORT(
         CLK : IN  std_logic;
         OE : IN  std_logic;
         VAL : IN  std_logic_vector(7 downto 0);
         CLKDIV_OUT : out  STD_LOGIC;
         LED_EN : OUT  std_logic;
         LED_PWM : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal OE : std_logic := '0';
   signal VAL : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal CLKDIV_OUT : std_logic;
   signal LED_EN : std_logic;
   signal LED_PWM : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 20.8333 ns;
   constant PWM_period : time := 106.65984 us;
 
   signal uval : unsigned(7 downto 0) := (others => '0');
BEGIN
   VAL <= std_logic_vector(uval);
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ledpwm PORT MAP (
          CLK => CLK,
          OE => OE,
          VAL => VAL,
          CLKDIV_OUT => CLKDIV_OUT,
          LED_EN => LED_EN,
          LED_PWM => LED_PWM
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
    stim_proc: process
    begin
        OE <= '0';
        wait for CLK_period*5;

        uval <= x"7f";
        wait for CLK_period*5;

        OE <= '1';
        wait for PWM_period*5;

        OE <= '0';
        wait for PWM_period*5;
    
        OE <= '1';
        for i in 0 to 255 loop
            uval <= to_unsigned(i, uval'length);
            wait for PWM_period*2;
        end loop;
    
        wait;
    end process;

END;
