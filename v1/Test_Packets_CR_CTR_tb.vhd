LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY UNISIM;
USE UNISIM.Vcomponents.ALL;

ENTITY Test_Packets_CR_CTR_tb IS
END Test_Packets_CR_CTR_tb;
ARCHITECTURE behavioral OF Test_Packets_CR_CTR_tb IS 

    COMPONENT Test_Packets_CR_CTR
    PORT( LED	:	OUT	STD_LOGIC_VECTOR (7 DOWNTO 0); 
          TRIG_MODE	:	IN	STD_LOGIC; 
          TRIG_IN	:	IN	STD_LOGIC; 
          PACKET_GOOD	:	IN	STD_LOGIC; 
          PACKET_DATA	:	IN	STD_LOGIC_VECTOR (11 DOWNTO 0); 
          FRM_DONE	:	OUT	STD_LOGIC; 
          RAM_WE	:	OUT	STD_LOGIC; 
          RAM_ADDR	:	OUT	STD_LOGIC_VECTOR (16 DOWNTO 0); 
          RAM_OUT	:	OUT	STD_LOGIC_VECTOR (7 DOWNTO 0); 
          CLK_X3	:	IN	STD_LOGIC; 
          CLK_X1	:	IN	STD_LOGIC; 
          FRM_SHOOT	:	OUT	STD_LOGIC);
    END COMPONENT;

    SIGNAL LED	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL TRIG_MODE	:	STD_LOGIC;
    SIGNAL TRIG_IN	:	STD_LOGIC;
    SIGNAL FRM_DONE	:	STD_LOGIC;
    SIGNAL RAM_WE	:	STD_LOGIC;
    SIGNAL RAM_ADDR	:	STD_LOGIC_VECTOR (16 DOWNTO 0);
    SIGNAL RAM_OUT	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL CLK_X3	:	STD_LOGIC;
    SIGNAL CLK_X1, clk	:	STD_LOGIC;
    SIGNAL FRM_SHOOT	:	STD_LOGIC;
    signal PACKET_DATA, pd : std_logic_vector(11 downto 0) := (others => '0');
    signal PACKET_GOOD, pg : std_logic := '0';

    -- Clock period definitions
    constant clk_period : time := 37.5 ns;
    constant clkx3_period : time := clk_period/3;
 
    constant BIT_STA : integer := 0;
    constant BIT_LV : integer := 9;
    constant BIT_FV : integer := 10;
    constant BIT_STO : integer := 11;
    
    signal pdata : std_logic_vector(7 downto 0) := (others => '0');
BEGIN

    UUT: Test_Packets_CR_CTR PORT MAP(
        LED => LED, 
        TRIG_MODE => TRIG_MODE, 
        TRIG_IN => TRIG_IN, 
        PACKET_GOOD => PACKET_GOOD, 
        PACKET_DATA => PACKET_DATA, 
        FRM_DONE => FRM_DONE, 
        RAM_WE => RAM_WE, 
        RAM_ADDR => RAM_ADDR, 
        RAM_OUT => RAM_OUT, 
        CLK_X3 => CLK_X3, 
        CLK_X1 => CLK_X1, 
        FRM_SHOOT => FRM_SHOOT
    );

    CLK_X1 <= clk;

    -- Clock process definitions
    clk_process :process
    begin
        clk <= '1';
        wait for clk_period/2;
        clk <= '0';
        wait for clk_period/2;
    end process;
    
    clkx3_process :process
    begin
        CLK_X3 <= '1';
        wait for clkx3_period/2;
        CLK_X3 <= '0';
        wait for clkx3_period/2;
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
        do_trigger := '0';
        if (do_trigger = '0') then
            TRIG_MODE <= '0';
            TRIG_IN <= '0';
            wait;
        end if;
        
        TRIG_MODE <= '1';
        
        wait for 16 ms;
        
        if (do_trigger = '0') then
            TRIG_IN <= '0';
        else
            TRIG_IN <= '1';
        end if;
        
        wait for 2 ms;
        TRIG_IN <= '0';
        
        wait;
    end process;

END;
