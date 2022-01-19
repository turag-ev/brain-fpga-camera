LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY SerDesTest IS
END SerDesTest;
 
ARCHITECTURE behavior OF SerDesTest IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT serdes12
generic
 (-- width of the data for the system
  sys_w       : integer := 1;
  -- width of the data for the device
  dev_w       : integer := 6);
port
 (
  -- From the system into the device
  DATA_IN_FROM_PINS_P     : in    std_logic_vector(sys_w-1 downto 0);
  DATA_IN_FROM_PINS_N     : in    std_logic_vector(sys_w-1 downto 0);
  DATA_IN_TO_DEVICE       : out   std_logic_vector(dev_w-1 downto 0);

--  DEBUG_IN                : in    std_logic_vector (1 downto 0);       -- Input debug data. Tie to "00" if not used
--  DEBUG_OUT               : out   std_logic_vector ((3*sys_w)+5 downto 0); -- Ouput debug data. Leave NC if not required
  BITSLIP                 : in    std_logic;
-- Clock and reset signals
  CLK_IN                  : in    std_logic;                    -- Single ended Fast clock from IOB
  CLK_SLOW_OUT             : out   std_logic;                    -- Slow clock output
  CLK_FAST_OUT             : out   std_logic;
  CLK_RESET               : in    std_logic;                    -- Reset signal for Clock circuit
  IO_RESET                : in    std_logic);                   -- Reset signal for IO circuit
end component;
    
   constant sys_w       : integer := 1;

   --Inputs
   signal DATA_IN_FROM_PINS_P : std_logic_vector(0 downto 0) := (others => '0');
   signal DATA_IN_FROM_PINS_N : std_logic_vector(0 downto 0) := (others => '0');
   signal DEBUG_IN : std_logic_vector (1 downto 0) := (others => '0');
   signal BITSLIP : std_logic := '0';
   signal CLK_IN : std_logic := '0';
   signal CLK_RESET : std_logic := '0';
   signal IO_RESET : std_logic := '0';

 	--Outputs
   signal DATA_IN_TO_DEVICE : std_logic_vector(5 downto 0);
   signal DEBUG_OUT : std_logic_vector ((3*sys_w)+5 downto 0);
   signal CLK_FAST_OUT : std_logic;
   signal CLK_SLOW_OUT : std_logic;

   -- Clock period definitions
   constant CLK_IN_period : time := 37.45318352059 ns;  -- 26.7 MHz
   constant CLK_FAST_period : time := 3.12109862671 ns; -- 12*26.7 MHz = 320.4 MHz
 
   signal data : std_logic := '0';
   signal bs : std_logic_vector(7 downto 0) := (others => '0');
   
   signal packet_first : std_logic_vector(5 downto 0) := (others => '0');
   signal packet : std_logic_vector(11 downto 0) := (others => '0');
   signal pkg_first : std_logic := '1';
   signal good : std_logic := '0';
   signal badcnt : unsigned(4 downto 0) := (others => '0');
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: serdes12 PORT MAP (
          DATA_IN_FROM_PINS_P => DATA_IN_FROM_PINS_P,
          DATA_IN_FROM_PINS_N => DATA_IN_FROM_PINS_N,
          DATA_IN_TO_DEVICE => DATA_IN_TO_DEVICE,
--          DEBUG_IN => DEBUG_IN,
--          DEBUG_OUT => DEBUG_OUT,
          BITSLIP => BITSLIP,
          CLK_IN => CLK_IN,
          CLK_SLOW_OUT => CLK_SLOW_OUT,
          CLK_FAST_OUT => CLK_FAST_OUT,
          CLK_RESET => CLK_RESET,
          IO_RESET => IO_RESET
        );
 
   CLK_IN_process :process
   begin
		CLK_IN <= '0';
		wait for CLK_IN_period/2;
		CLK_IN <= '1';
		wait for CLK_IN_period/2;
   end process;

    DATA_IN_FROM_PINS_P(0) <= data;
    DATA_IN_FROM_PINS_N(0) <= not data;

    data_proc: process
    begin
        for a in 0 to 9 loop
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
    end process;

    goodcheck: process(good)
    begin
        if falling_edge(good) then
            report "not good";
        elsif rising_edge(good) then
            report "very good";
        end if;
    end process;

    deco: process(CLK_SLOW_OUT)
    begin
        if rising_edge(CLK_SLOW_OUT) then
            if (pkg_first = '1') then
                -- lower 6 bits
                packet_first <= DATA_IN_TO_DEVICE;

                if (DATA_IN_TO_DEVICE(0) = '1') then
                    pkg_first <= '0';
                else
                    -- no start bit
                    badcnt <= badcnt + 1;
                    good <= '0';
                end if;
            else
                -- higher 6 bits
                pkg_first <= '1';
                bitslip <= '0';
                packet(5 downto 0) <= packet_first;
                packet(11 downto 6) <= DATA_IN_TO_DEVICE;
                
                -- look for stop bit
                if (DATA_IN_TO_DEVICE(5) = '0') then
                    badcnt <= (others => '0');
                    good <= '1';
                else
                    badcnt <= badcnt + 1;
                    good <= '0';
                end if;
            end if;
            
            if (badcnt = "11111") then
                bitslip <= '1';
                badcnt <= (others => '0');
            else
                bitslip <= '0';
            end if;
        end if;
    end process;
END;
