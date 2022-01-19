library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity ImgPCtrl is
    Generic (
        addr_msb : integer := 16
    );
    Port (
        clk     : in  std_logic;

        -- Bus
        fpAddr      : in  std_logic_vector(6 downto 0);
        fpDataOut   : out std_logic_vector(7 downto 0) := (others => '0');
        fpDataIn    : in  std_logic_vector(7 downto 0);
        fpWrite     : in  std_logic;
        fpValid     : in  std_logic;

        -- RAM control
        ramAddr     : out std_logic_vector(addr_msb downto 0) := (others => '0');

        -- IP input control
        ipReset     : out std_logic := '0';
        ipNewFrame  : out std_logic := '0';
        ipStr       : out std_logic := '0';

        -- IP bypass stuff
        noSmoothing     : out std_logic := '0';
        noEdgeDetect    : out std_logic := '0';
        noNMS           : out std_logic := '0';
        noPT            : out std_logic := '1';
        noCT            : out std_logic := '1';

        -- IS control
        isReset     : out std_logic := '0';
        isNewFrame  : out std_logic := '0';
        isStr       : out std_logic := '0';
        
        -- trigger controlled by AVR
        AVR_SETTINGS : in std_logic_vector(7 downto 0);
        AVR_START, AVR_RST : in std_logic;
        AVR_DONE    : out std_logic := '0';
        
        devled      : out std_logic_vector(7 downto 0) := (others => '0')
    );
end ImgPCtrl;

architecture Behavioral of ImgPCtrl is
    constant RES_X : integer := 160;
    constant RES_Y : integer := 120;
    constant RAM_STEP : integer := 3;
    constant RAM_MAX : integer := RES_X * RES_Y * RAM_STEP;
    constant IPCNT_MAX : unsigned(1 downto 0) := "10";
    
    signal ramAddr_next : unsigned(addr_msb downto 0) := (others => '0');
    signal run_imgproc : std_logic := '0';
    signal ipcnt : unsigned(1 downto 0) := (others => '0');
    signal devleds : std_logic_vector(7 downto 0) := (others => '0');
    signal ipStr_int, isStr_int, ipNewFrame_int, isNewFrame_int, avr_done_int, avr_got_signal : std_logic := '0';
begin

devled <= not devleds;
devleds(0) <= avr_done_int;
devleds(1) <= run_imgproc;
devleds(2) <= ipStr_int;
devleds(3) <= isStr_int;
devleds(4) <= ipNewFrame_int;
devleds(5) <= isNewFrame_int;
devleds(6) <= AVR_START;
devleds(7) <= AVR_RST;

AVR_DONE <= avr_done_int;
ipStr <= ipStr_int;
isStr <= isStr_int;
ipNewFrame <= ipNewFrame_int;
isNewFrame <= isNewFrame_int;

process(clk)
begin
    if rising_edge(clk) then
        ipReset <= '0';
        isReset <= '0';

        -- controls for the AVR
        if (AVR_RST = '1') then
            -- reset imgproc/imgseg
            ipReset <= '1';
            isReset <= '1';
            
            run_imgproc <= '0';
            
            avr_done_int <= '0';
            avr_got_signal <= '1';
        elsif (AVR_START = '1') then
            -- start imgproc/imgseg
            
            -- set imgproc flags for AVR            
            noSmoothing <= AVR_SETTINGS(0);
            noEdgeDetect <= AVR_SETTINGS(1);
            noNMS <= AVR_SETTINGS(2);
            noPT <= AVR_SETTINGS(3);
            noCT <= AVR_SETTINGS(4);

            -- start stuff
            ramAddr <= (others => '0');
            ramAddr_next <= to_unsigned(1, ramAddr_next'length);
            
            ipReset <= '0';
            ipNewFrame_int <= '1';
            ipStr_int <= '0';
            
            isReset <= '0';
            isNewFrame_int <= '1';
            isStr_int <= '0';
            
            ipcnt <= IPCNT_MAX;
            run_imgproc <= '1';
            
            -- status
            avr_done_int <= '0';
            avr_got_signal <= '1';
        elsif (fpValid = '1') then
            if (fpWrite = '1') then
                case fpAddr is
                    when "0100000" =>   -- 0x20 - start imgproc
                        ramAddr <= (others => '0');
                        ramAddr_next <= to_unsigned(1, ramAddr_next'length);
                        ipReset <= '0';
                        ipNewFrame_int <= '1';
                        ipStr_int <= '0';
                        isReset <= '0';
                        isNewFrame_int <= '1';
                        isStr_int <= '0';
                        ipcnt <= IPCNT_MAX;
                        run_imgproc <= '1';
                    when "0100010" =>   -- 0x22 - set imgproc flags
                        noSmoothing <= fpDataIn(0);
                        noEdgeDetect <= fpDataIn(1);
                        noNMS <= fpDataIn(2);
                        noPT <= fpDataIn(3);
                        noCT <= fpDataIn(4);
                    when "0100011" =>   -- 0x23 - reset imgproc
                        ipReset <= '1';
                    when "0100100" =>   -- 0x24 - reset imgseg
                        isReset <= '1';
                    when others => null;
                end case;
            else
                case fpAddr is
                    when "0100001" =>   -- 0x21 - imgproc status
                        fpDataOut <= (others => '0');
                        fpDataOut(0) <= run_imgproc;
                        fpDataOut(1) <= avr_got_signal;
                        fpDataOut(2) <= AVR_START;
                        fpDataOut(3) <= AVR_RST;
                        fpDataOut(4) <= avr_done_int;
                        
                        -- reset the indicator
                        avr_got_signal <= '0';
                    when others => null;
                end case;
            end if;
        elsif (run_imgproc = '1') then
            -- run a frame from RAM through imgproc
            
            ipNewFrame_int <= '0';
            isNewFrame_int <= '0';

            if (ramAddr_next < RAM_MAX) then
                -- IS gets every pixel
                isStr_int <= '1';
                
                -- IP gets every 3rd
                if (ipcnt = IPCNT_MAX) then
                    ipStr_int <= '1';
                    ipcnt <= (others => '0');
                else
                    ipStr_int <= '0';
                    ipcnt <= ipcnt + 1;
                end if;

                ramAddr_next <= ramAddr_next + 1;
                ramAddr <= std_logic_vector(ramAddr_next);
                
                avr_done_int <= '0';
            else
                run_imgproc <= '0';
                ipStr_int <= '0';
                isStr_int <= '0';
                
                -- show the AVR we're done
                avr_done_int <= '1';
            end if;
        end if;
    end if;
end process;

end Behavioral;
