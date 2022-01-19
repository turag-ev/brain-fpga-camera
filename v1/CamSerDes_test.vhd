--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:19:03 03/20/2012
-- Design Name:   
-- Module Name:   /home/bob/code/BCam/CamSerDes_test.vhd
-- Project Name:  BananaCam_ufm
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: CamSerDes
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
 
ENTITY CamSerDes_test IS
END CamSerDes_test;
 
ARCHITECTURE behavior OF CamSerDes_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT CamSerDes
    PORT(
         clk : IN  std_logic;
         cam_data_p : IN  std_logic;
         cam_data_n : IN  std_logic;
         clk_slow_x1, clk_slow_x2, clk_slow_x3, clk_fast     : out std_logic := '0';
         data_out : OUT  std_logic_vector(11 downto 0);
         data_good : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal cam_data_p : std_logic := '0';
   signal cam_data_n : std_logic := '0';

 	--Outputs
   signal clk_slow_x1, clk_slow_x2, clk_slow_x3, clk_fast : std_logic;
   signal data_out : std_logic_vector(11 downto 0);
   signal data_good : std_logic;

   -- Clock period definitions
   constant clk_period : time := 37.45318352059 ns;  -- 26.7 MHz
   constant CLK_FAST_period : time := 3.12109862671 ns; -- 12*26.7 MHz = 320.4 MHz
   
   signal data : std_logic := '0';
   signal bs : std_logic_vector(7 downto 0) := (others => '0');
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: CamSerDes PORT MAP (
          clk => clk,
          cam_data_p => cam_data_p,
          cam_data_n => cam_data_n,
          clk_slow_x1 => clk_slow_x1,
          clk_slow_x2 => clk_slow_x2,
          clk_slow_x3 => clk_slow_x3,
          clk_fast => clk_fast,
          data_out => data_out,
          data_good => data_good
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;

    cam_data_p <= data;
    cam_data_n <= not data;

    data_proc: process
    begin
        wait for CLK_FAST_period/2;
        
--        for a in 0 to 9 loop
        while true loop
            -- send pixel bytes from 0 - 255
            for b in 0 to 255 loop
                bs <= std_logic_vector(to_unsigned(b, 8));
                
                -- start bit
                data <= '1';
                wait for CLK_FAST_period;
            
                -- pixel bits
                for i in 0 to 7 loop
                    data <= bs(i);
                    wait for CLK_FAST_period;
                end loop;
                
                -- line-valid bit
                data <= '1';
                wait for CLK_FAST_period;
                
                -- frame-valid bit
                data <= '1';
                wait for CLK_FAST_period;
                
                -- stop bit
                data <= '0';
                wait for CLK_FAST_period;
            end loop;
        end loop;
        
--        wait for CLK_IN_period;
        report "restarting data_proc with 1 clk delay";
        wait;
    end process;

    goodcheck: process(data_good)
    begin
        if falling_edge(data_good) then
            report "not good";
        elsif rising_edge(data_good) then
            report "very good";
        end if;
    end process;

END;
