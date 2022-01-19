library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity CamResize is
    Port (  CLK : in  STD_LOGIC;
    
            -- input
            PXI_LV, PXI_FV : in std_logic;
            PXI_X, PXI_Y : in std_logic_vector(9 downto 0);
            PXI_DATA : in std_logic_vector(7 downto 0);

            -- output
            PXO_LV, PXO_FV : out std_logic := '0';
            PXO_X, PXO_Y : out std_logic_vector(8 downto 0) := (others => '0');
            PXO_DATA : out std_logic_vector(7 downto 0) := (others => '0')
        );
end CamResize;

architecture Behavioral of CamResize is
    signal first_line_done : std_logic := '0';
    signal posx_int, posx_next, posy_int, posy_next : unsigned(PXO_X'length-1 downto 0) := (others => '0');
begin

    PXO_X <= std_logic_vector(posx_int);
    PXO_Y <= std_logic_vector(posy_int);

    process(CLK)
    begin
        if rising_edge(CLK) then
            PXO_LV <= PXI_LV;
            PXO_FV <= PXI_FV;
            
            if (PXI_FV = '0') then
                first_line_done <= '0';
                posx_int <= (others => '0');
                posx_next <= (others => '0');
                posy_int <= (others => '0');
                posy_next <= (others => '0');
            elsif (PXI_LV = '0') then
                posx_next <= (others => '0');
                if (first_line_done = '1') then
                    posy_next <= posy_int + 1;
                else
                    posy_next <= (others => '0');
                end if;
            else
                if (PXI_Y(1) = '0') then
                    if (PXI_X(1) = '0') then
                        first_line_done <= '1';
                        PXO_DATA <= PXI_DATA;
                        
                        posx_next <= posx_next + 1;
                        posx_int <= posx_next;
                        posy_int <= posy_next;
                    end if;
                end if;
            end if;
        end if;
    end process;

end Behavioral;

