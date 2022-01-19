LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY UNISIM;
USE UNISIM.Vcomponents.ALL;
ENTITY Test_Packets_CamResize_tb IS
END Test_Packets_CamResize_tb;
ARCHITECTURE behavioral OF 
      Test_Packets_CamResize_tb IS 

    COMPONENT Test_Packets_CamResize
    PORT( LED	:	OUT	STD_LOGIC_VECTOR (7 DOWNTO 0); 
          TRIG_MODE	:	IN	STD_LOGIC; 
          TRIG_IN	:	IN	STD_LOGIC; 
          FRM_DONE	:	OUT	STD_LOGIC; 
          PX_LV	:	OUT	STD_LOGIC; 
          PX_FV	:	OUT	STD_LOGIC; 
          PX_X	:	OUT	STD_LOGIC_VECTOR (8 DOWNTO 0); 
          PX_Y	:	OUT	STD_LOGIC_VECTOR (8 DOWNTO 0); 
          PX_DATA	:	OUT	STD_LOGIC_VECTOR (7 DOWNTO 0); 
          CLK	:	IN	STD_LOGIC; 
          PACKET_GOOD	:	IN	STD_LOGIC; 
          PACKET_DATA	:	IN	STD_LOGIC_VECTOR (11 DOWNTO 0));
    END COMPONENT;

    SIGNAL LED	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL TRIG_MODE	:	STD_LOGIC;
    SIGNAL TRIG_IN	:	STD_LOGIC;
    SIGNAL FRM_DONE	:	STD_LOGIC;
    SIGNAL PX_LV	:	STD_LOGIC;
    SIGNAL PX_FV	:	STD_LOGIC;
    SIGNAL PX_X	:	STD_LOGIC_VECTOR (8 DOWNTO 0);
    SIGNAL PX_Y	:	STD_LOGIC_VECTOR (8 DOWNTO 0);
    SIGNAL PX_DATA	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL CLK	:	STD_LOGIC;
    signal PACKET_DATA, pd : std_logic_vector(11 downto 0) := (others => '0');
    signal PACKET_GOOD, pg : std_logic := '0';

    -- Clock period definitions
    constant clk_period : time := 37.5 ns;
 
    constant BIT_STA : integer := 0;
    constant BIT_LV : integer := 9;
    constant BIT_FV : integer := 10;
    constant BIT_STO : integer := 11;
    
    signal pdata : std_logic_vector(7 downto 0) := (others => '0');
BEGIN

   UUT: Test_Packets_CamResize PORT MAP(
		LED => LED, 
		TRIG_MODE => TRIG_MODE, 
		TRIG_IN => TRIG_IN, 
		FRM_DONE => FRM_DONE, 
		PX_LV => PX_LV, 
		PX_FV => PX_FV, 
		PX_X => PX_X, 
		PX_Y => PX_Y, 
		PX_DATA => PX_DATA, 
		CLK => CLK, 
		PACKET_GOOD => PACKET_GOOD, 
		PACKET_DATA => PACKET_DATA
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
        variable do_trigger : std_logic;
    begin
        do_trigger := '0';
        if (do_trigger = '0') then
            TRIG_MODE <= '0';
            TRIG_IN <= '0';
        else
            TRIG_MODE <= '1';
            TRIG_IN <= '0';
        end if;
        
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
                    pdata <= std_logic_vector(to_unsigned(row_no, 8));
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
    
END;
