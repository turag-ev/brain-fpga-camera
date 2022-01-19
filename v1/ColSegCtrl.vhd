library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ColSegCtrl is
    Port (  CLK : in  STD_LOGIC;
    
            STADR, STDAT : in std_logic_vector(7 downto 0);
    
            CW_CBMIN, CW_CBMAX, CW_CRMIN, CW_CRMAX, CW_YMIN : out std_logic_vector(7 downto 0) := (others => '0')
    );
end ColSegCtrl;

architecture Behavioral of ColSegCtrl is

begin

    process(CLK)
    begin
        if rising_edge(CLK) then
            if (STADR /= std_logic_vector(to_unsigned(0, 8))) then
                case STADR is
                    when x"01" =>
                        CW_CBMIN <= STDAT;
                    when x"02" =>
                        CW_CBMAX <= STDAT;
                    when x"03" =>
                        CW_CRMIN <= STDAT;
                    when x"04" =>
                        CW_CRMAX <= STDAT;
                    when x"05" =>
                        CW_YMIN <= STDAT;
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;

end Behavioral;
