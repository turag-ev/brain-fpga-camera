library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CamMTCtrl is
    Port (
        clk         : in  std_logic;

        led         : out std_logic_vector(7 downto 0) := (others => '0');

        packet_data : in  std_logic_vector(11 downto 0);
        packet_good : in  std_logic;
        
        cam_good    : out std_logic := '0';

        trigger_mode : in std_logic := '0';
        trigger_in   : in  std_logic := '0';
        frame_shoot  : out std_logic := '0';
        frame_done   : out std_logic := '0';

        line_valid, frame_valid : out std_logic := '0';
        posx, posy   : out std_logic_vector(9 downto 0) := (others => '0');
        data_out     : out std_logic_vector(7 downto 0) := (others => '0')
    );
end CamMTCtrl;

architecture Behavioral of CamMTCtrl is
    constant LINE_VALID_BIT  : integer := 9;
    constant FRAME_VALID_BIT : integer := 10;
    
    signal led_int : std_logic_vector(7 downto 0) := (others => '0');
    
    signal first_line_done : std_logic := '0';
    signal shooting_frame : std_logic := '0';
    signal had_frame : std_logic := '1';
    
    signal posx_int, posx_next, posy_int, posy_next : unsigned(posx'length-1 downto 0) := (others => '0');
begin

led <= not led_int;
frame_shoot <= shooting_frame;
posx <= std_logic_vector(posx_int);
posy <= std_logic_vector(posy_int);

process(clk)
begin
    if rising_edge(clk) then
        cam_good <= packet_good;
        
        if (packet_good = '1') then
            if (trigger_mode = '0') or (shooting_frame = '1') then
                line_valid <= packet_data(LINE_VALID_BIT);
                frame_valid <= packet_data(FRAME_VALID_BIT);
            else
                line_valid <= '0';
                frame_valid <= '0';
            end if;
            
            if (packet_data(FRAME_VALID_BIT) = '0') then
                -- FV = 0
                led_int <= "00000010";
                
                first_line_done <= '0';
                data_out <= (others => '0');
                posx_int <= (others => '0');
                posx_next <= (others => '0');
                posy_int <= (others => '0');
                posy_next <= (others => '0');
                
                -- do this one time after each frame
                if (had_frame = '1') then
                    had_frame <= '0';
                    
                    if (trigger_mode = '1') then
                        if (trigger_in = '0') then
                            -- when in trigger mode and trigger is off, don't capture frame
                            shooting_frame <= '0';
                        else
                            shooting_frame <= '1';
                        end if;

                        if (shooting_frame = '1') then
                            frame_done <= '1';
                        else
                            frame_done <= '0';
                        end if;
                    end if;
                end if;
            elsif (packet_data(LINE_VALID_BIT) = '0') then
                -- LV = 0
                led_int <= "00000100";
                
                if (trigger_mode = '0') or (shooting_frame = '1') then
                    data_out <= (others => '0');
                    posx_next <= (others => '0');
                    if (first_line_done = '1') then
                        posy_next <= posy_int + 1;
                    else
                        posy_next <= (others => '0');
                    end if;
                end if;
            else
                -- valid pixel
                led_int <= "00001000";
                
                had_frame <= '1';
                first_line_done <= '1';

                if (trigger_mode = '0') or (shooting_frame = '1') then
                    data_out <= std_logic_vector(packet_data(8 downto 1));
                    posx_next <= posx_next + 1;
                    posx_int <= posx_next;
                    posy_int <= posy_next;
                end if;
            end if;
        else -- bad packet, reset everything
            led_int <= "00000001";
            
            line_valid <= '0';
            frame_valid <= '0';
            first_line_done <= '0';
            had_frame <= '1';
            shooting_frame <= '0';

            data_out <= (others => '0');
            posx_int <= (others => '0');
            posx_next <= (others => '0');
            posy_int <= (others => '0');
            posy_next <= (others => '0');
        end if;
    end if;
end process;

end Behavioral;
