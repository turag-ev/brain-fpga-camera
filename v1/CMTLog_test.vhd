LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY CMTLog_test IS
END CMTLog_test;
 
ARCHITECTURE behavior OF CMTLog_test IS 
    COMPONENT CMTLog
    PORT(
         CLK : IN  std_logic;
         PACKET_DATA : IN  std_logic_vector(11 downto 0);
         PACKET_GOOD : IN  std_logic;
         LED : OUT  std_logic_vector(7 downto 0);
         FRAMETIME : OUT  std_logic_vector(23 downto 0);
         FRAMEPART : IN  std_logic_vector(7 downto 0);
         RAM_WE : OUT  std_logic;
         RAM_ADDR : OUT  std_logic_vector(14 downto 0);
         RAM_DOUT : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;


    --Inputs
    signal CLK : std_logic := '0';
    signal PACKET_DATA, pd : std_logic_vector(11 downto 0) := (others => '0');
    signal PACKET_GOOD, pg : std_logic := '0';
    signal FRAMEPART : std_logic_vector(7 downto 0) := (others => '0');

    --Outputs
    signal LED : std_logic_vector(7 downto 0);
    signal FRAMETIME : std_logic_vector(23 downto 0);
    signal RAM_WE : std_logic;
    signal RAM_ADDR : std_logic_vector(14 downto 0);
    signal RAM_DOUT : std_logic_vector(15 downto 0);

    -- Clock period definitions
    constant CLK_period : time := 37.5 ns; -- 26.67 MHz

    constant BIT_STA : integer := 0;
    constant BIT_LV : integer := 9;
    constant BIT_FV : integer := 10;
    constant BIT_STO : integer := 11;
    
    signal pdata : std_logic_vector(7 downto 0) := (others => '0');
BEGIN
 
    -- Instantiate the Unit Under Test (UUT)
    uut: CMTLog PORT MAP (
          CLK => CLK,
          PACKET_DATA => PACKET_DATA,
          PACKET_GOOD => PACKET_GOOD,
          LED => LED,
          FRAMETIME => FRAMETIME,
          FRAMEPART => FRAMEPART,
          RAM_WE => RAM_WE,
          RAM_ADDR => RAM_ADDR,
          RAM_DOUT => RAM_DOUT
        );

    -- Clock process definitions
    CLK_process :process
    begin
        CLK <= '0';
        wait for CLK_period/2;
        CLK <= '1';
        wait for CLK_period/2;
    end process;

    PACKET_GOOD <= pg;
    PACKET_DATA <= pd;
    pd(8 downto 1) <= pdata;

    -- output data timing modeled after MT9V024 datasheet
    softcam: process
    begin
        wait for CLK_period*5;
        
        pg <= '0';
        pdata <= (others => '0');
        pd(BIT_STA) <= '1';
        pd(BIT_STO) <= '0';
        wait for CLK_period*5;

        -- synced to stream
        report "*** START ***";
        pg <= '1';
        
        for frame_no in 1 to 30 loop
            FRAMEPART <= std_logic_vector(to_unsigned(frame_no, FRAMEPART'length) - 1);

            -- before frame: vertical blanking, 38074 clks => 1.43 ms
            report "vertical blanking";
            for i in 1 to 38074 loop
                pd(BIT_FV) <= '0';
                pd(BIT_LV) <= '0';
                pdata <= (others => '0');
                wait for CLK_period;
            end loop;
            
            for row_no in 1 to 480 loop
                -- line start blanking, 71 clks => 2.66 us
                for i in 1 to 71 loop
                    pd(BIT_FV) <= '1';
                    pd(BIT_LV) <= '0';
                    pdata <= (others => '0');
                    wait for CLK_period;
                end loop;
                
                -- active data, 752 clks => 28.2 us
                for col_no in 1 to 752 loop
                    pd(BIT_FV) <= '1';
                    pd(BIT_LV) <= '1';
                    pdata <= std_logic_vector(to_unsigned(row_no, 8));
                    wait for CLK_period;
                end loop;

                -- line end blanking, 23 clks => 0.86 us
                for i in 1 to 23 loop
                    pd(BIT_FV) <= '1';
                    pd(BIT_LV) <= '0';
                    pdata <= (others => '0');
                    wait for CLK_period;
                end loop;
            end loop;
            
            -- end of frame
            report "end of frame";
            pd(BIT_FV) <= '0';
            pd(BIT_LV) <= '0';
        end loop;

        report "*** DONE ***";

        wait;
    end process;

END;
