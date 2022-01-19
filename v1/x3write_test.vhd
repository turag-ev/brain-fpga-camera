LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY x3write_test IS
END x3write_test;
 
ARCHITECTURE behavior OF x3write_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT x3write
    PORT(
         CLK : IN  std_logic;
         CLKX3 : IN  std_logic;
         PXI_LV : IN  std_logic;
         PXI_FV : IN  std_logic;
         PXI_X : IN  std_logic_vector(8 downto 0);
         PXI_Y : IN  std_logic_vector(8 downto 0);
         PXI_A : IN  std_logic_vector(7 downto 0);
         PXI_B : IN  std_logic_vector(7 downto 0);
         PXI_C : IN  std_logic_vector(7 downto 0);
         RAM_ADDR : OUT  std_logic_vector(16 downto 0);
         RAM_OUT : OUT  std_logic_vector(7 downto 0);
         RAM_WE : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal CLKX3 : std_logic := '0';
   signal PXI_LV : std_logic := '0';
   signal PXI_FV : std_logic := '0';
   signal PXI_X, PXI_Y : std_logic_vector(8 downto 0) := (others => '0');
   signal pxx, pxy : unsigned(8 downto 0) := (others => '0');
   signal PXI_A : std_logic_vector(7 downto 0) := (others => '0');
   signal PXI_B : std_logic_vector(7 downto 0) := (others => '0');
   signal PXI_C : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal RAM_ADDR : std_logic_vector(16 downto 0);
   signal RAM_OUT : std_logic_vector(7 downto 0);
   signal RAM_WE : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 30 ns;
   constant CLKX3_period : time := 10 ns;
 
BEGIN
	-- Instantiate the Unit Under Test (UUT)
   uut: x3write PORT MAP (
          CLK => CLK,
          CLKX3 => CLKX3,
          PXI_LV => PXI_LV,
          PXI_FV => PXI_FV,
          PXI_X => PXI_X,
          PXI_Y => PXI_Y,
          PXI_A => PXI_A,
          PXI_B => PXI_B,
          PXI_C => PXI_C,
          RAM_ADDR => RAM_ADDR,
          RAM_OUT => RAM_OUT,
          RAM_WE => RAM_WE
        );

    PXI_X <= std_logic_vector(pxx);
    PXI_Y <= std_logic_vector(pxy);

    -- Clock process definitions
    CLK_process :process
    begin
        CLK <= '0';
        wait for CLK_period/2;
        CLK <= '1';
        wait for CLK_period/2;
    end process;

    CLKX3_process :process
    begin
        CLKX3 <= '0';
        wait for CLKX3_period/2;
        CLKX3 <= '1';
        wait for CLKX3_period/2;
    end process;
 
    stim_proc: process
    begin
        pxx <= (others => '0');
        pxy <= (others => '0');
        wait for CLK_period*2;

        PXI_FV <= '1';
        PXI_LV <= '1';
        PXI_A <= x"01";
        PXI_B <= x"02";
        PXI_C <= x"03";
        wait for CLK_period*5;

        PXI_LV <= '1';
        PXI_A <= x"04";
        PXI_B <= x"05";
        PXI_C <= x"06";
        pxx <= pxx + 1;
        wait for CLK_period;

        PXI_LV <= '0';
        wait for CLK_period*2;
        
        PXI_A <= x"07";
        PXI_B <= x"08";
        PXI_C <= x"09";
        wait for CLK_period;

        PXI_LV <= '1';
        wait for CLK_period*3;
        
        PXI_A <= x"0a";
        PXI_B <= x"0b";
        PXI_C <= x"0c";
        pxx <= pxx + 1;
        wait for CLK_period*5;

        PXI_LV <= '0';
        wait for CLK_period;
        
        pxx <= (others => '0');
        pxy <= (others => '0');
        wait for CLK_period*3;

        wait;
    end process;

END;
