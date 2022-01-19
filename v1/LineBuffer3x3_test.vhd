-- Vhdl test bench created from schematic /home/bob/code/BCam/LineBuffer3x3.sch - Thu Dec 15 23:57:56 2011
--
-- Notes: 
-- 1) This testbench template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the unit under test.
-- Xilinx recommends that these types always be used for the top-level
-- I/O of a design in order to guarantee that the testbench will bind
-- correctly to the timing (post-route) simulation model.
-- 2) To use this template as your testbench, change the filename to any
-- name of your choice with the extension .vhd, and use the "Source->Add"
-- menu in Project Navigator to import the testbench. Then
-- edit the user defined section below, adding code to generate the 
-- stimulus for your design.
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY UNISIM;
USE UNISIM.Vcomponents.ALL;
ENTITY LineBuffer3x3_LineBuffer3x3_sch_tb IS
END LineBuffer3x3_LineBuffer3x3_sch_tb;
ARCHITECTURE behavioral OF LineBuffer3x3_LineBuffer3x3_sch_tb IS 

   COMPONENT LineBuffer3x3
   PORT( linesStr	:	OUT	STD_LOGIC; 
          linesValid	:	OUT	STD_LOGIC; 
          line3	:	OUT	STD_LOGIC_VECTOR (7 DOWNTO 0); 
          dataIn	:	IN	STD_LOGIC_VECTOR (7 DOWNTO 0); 
          dataValid	:	IN	STD_LOGIC; 
          clk	:	IN	STD_LOGIC; 
          reset	:	IN	STD_LOGIC; 
          line1	:	OUT	STD_LOGIC_VECTOR (7 DOWNTO 0); 
          line2	:	OUT	STD_LOGIC_VECTOR (7 DOWNTO 0));
   END COMPONENT;

   SIGNAL linesStr	:	STD_LOGIC;
   SIGNAL linesValid	:	STD_LOGIC;
   SIGNAL line3	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
   SIGNAL dataIn	:	STD_LOGIC_VECTOR (7 DOWNTO 0) := (others => '0');
   SIGNAL dataValid	:	STD_LOGIC;
   SIGNAL clk	:	STD_LOGIC := '0';
   SIGNAL reset	:	STD_LOGIC;
   SIGNAL line1	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
   SIGNAL line2	:	STD_LOGIC_VECTOR (7 DOWNTO 0);

BEGIN

   UUT: LineBuffer3x3 PORT MAP(
		linesStr => linesStr, 
		linesValid => linesValid, 
		line3 => line3, 
		dataIn => dataIn, 
		dataValid => dataValid, 
		clk => clk, 
		reset => reset, 
		line1 => line1, 
		line2 => line2
   );

-- *** Test Bench - User Defined Section ***
   tb : PROCESS
   BEGIN
      reset <= '0';
      clk <= '1';
      wait for 10 ns;
      clk <= '0';
      wait for 10 ns;
   END PROCESS;
   
   dat : process
   begin
      if (unsigned(dataIn) = to_unsigned(160, 8)) then
         dataIn <= x"01";
      else
         dataIn <= std_logic_vector(unsigned(dataIn) + 1);
      end if;
      dataValid <= '1';
      wait for 20 ns;
   end process;
-- *** End Test Bench - User Defined Section ***

END;
