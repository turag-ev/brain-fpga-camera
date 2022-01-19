LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY CamMTCtrl_test IS
END CamMTCtrl_test;
 
ARCHITECTURE behavior OF CamMTCtrl_test IS 
    COMPONENT CamMTCtrl
    PORT(
         clk : IN  std_logic;
         led : OUT  std_logic_vector(7 downto 0);
         packet_data : IN  std_logic_vector(11 downto 0);
         packet_good : IN  std_logic;
         trigger_mode : IN  std_logic;
         trigger_in : IN  std_logic;
         frame_done, frame_shoot : OUT  std_logic;
         line_valid : OUT  std_logic;
         frame_valid : OUT  std_logic;
         posx : OUT  std_logic_vector(9 downto 0);
         posy : OUT  std_logic_vector(9 downto 0);
         data_out : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;


    --Inputs
    signal clk : std_logic := '0';
    signal PACKET_DATA, pd : std_logic_vector(11 downto 0) := (others => '0');
    signal PACKET_GOOD, pg : std_logic := '0';
    signal trigger_mode : std_logic := '0';
    signal trigger_in : std_logic := '0';

    --Outputs
    signal led : std_logic_vector(7 downto 0);
    signal frame_done, frame_shoot : std_logic;
    signal line_valid : std_logic;
    signal frame_valid : std_logic;
    signal posx : std_logic_vector(9 downto 0);
    signal posy : std_logic_vector(9 downto 0);
    signal data_out : std_logic_vector(7 downto 0);

    -- Clock period definitions
    constant clk_period : time := 37.5 ns;
 
    constant BIT_STA : integer := 0;
    constant BIT_LV : integer := 9;
    constant BIT_FV : integer := 10;
    constant BIT_STO : integer := 11;
    
    signal pdata : std_logic_vector(7 downto 0) := (others => '0');
BEGIN
    uut: CamMTCtrl PORT MAP (
          clk => clk,
          led => led,
          packet_data => packet_data,
          packet_good => packet_good,
          trigger_mode => trigger_mode,
          trigger_in => trigger_in,
          frame_done => frame_done,
          frame_shoot => frame_shoot,
          line_valid => line_valid,
          frame_valid => frame_valid,
          posx => posx,
          posy => posy,
          data_out => data_out
        );
        
    -- Clock process definitions
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    PACKET_GOOD <= pg;
    PACKET_DATA <= pd;
    pd(8 downto 1) <= pdata;

    -- output data timing modeled after MT9V024 datasheet
    softcam: process
        variable tmp : std_logic_vector(9 downto 0);
    begin
        wait for clk_period*5;
        
        pg <= '0';
        pdata <= (others => '0');
        pd(BIT_STA) <= '1';
        pd(BIT_STO) <= '0';
        wait for clk_period*5;

        -- synced to stream
        report "*** START ***";
        pg <= '1';
        
        for frame_no in 1 to 30 loop
            -- before frame: vertical blanking, 38074 clks => 1.43 ms
            report "vertical blanking";
            for i in 1 to 38074 loop
                pd(BIT_FV) <= '0';
                pd(BIT_LV) <= '0';
                pdata <= (others => '0');
                wait for clk_period;
            end loop;
            
            for row_no in 1 to 480 loop
                -- line start blanking, 71 clks => 2.66 us
                for i in 1 to 71 loop
                    pd(BIT_FV) <= '1';
                    pd(BIT_LV) <= '0';
                    pdata <= (others => '0');
                    wait for clk_period;
                end loop;
                
                -- active data, 752 clks => 28.2 us
                for col_no in 1 to 752 loop
                    pd(BIT_FV) <= '1';
                    pd(BIT_LV) <= '1';
                    tmp := std_logic_vector(to_unsigned(row_no, tmp'length));
                    pdata <= tmp(7 downto 0);
                    wait for clk_period;
                end loop;

                -- line end blanking, 23 clks => 0.86 us
                for i in 1 to 23 loop
                    pd(BIT_FV) <= '1';
                    pd(BIT_LV) <= '0';
                    pdata <= (others => '0');
                    wait for clk_period;
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
    
    -- trigger
    trig: process
        variable do_trigger : std_logic;
    begin
        do_trigger := '1';
        if (do_trigger = '0') then
            trigger_mode <= '0';
        else
            trigger_mode <= '1';
        end if;
        
        wait for 16 ms;
        
        if (do_trigger = '0') then
            trigger_in <= '0';
        else
            trigger_in <= '1';
        end if;
        
        wait for 2 ms;
        trigger_in <= '0';
        
        wait;
    end process;
    
END;
