library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity x3write is
    Port (  CLK, CLKX3 : in  STD_LOGIC;

            PXI_LV, PXI_FV : in std_logic;
            PXI_X, PXI_Y : in std_logic_vector(8 downto 0);
            PXI_A, PXI_B, PXI_C: in std_logic_vector(7 downto 0);
           
            RAM_ADDR : out  STD_LOGIC_VECTOR (16 downto 0) := (others => '0');
            RAM_OUT : out  STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
            RAM_WE : out  STD_LOGIC := '0'
    );
end x3write;

architecture Behavioral of x3write is
    signal last_pxx : std_logic_vector(8 downto 0);
    signal last_pxlv : std_logic := '0';
    
    signal abc_valid, last_abc_valid : std_logic := '0';
    signal a_int, b_int, c_int : std_logic_vector(7 downto 0);
    
    signal txcnt : unsigned(1 downto 0) := "00";
    signal addr : unsigned(16 downto 0) := (others => '0');
begin

    RAM_ADDR <= std_logic_vector(addr);

    slowpoke : process(CLK)
    begin
        if rising_edge(CLK) then
            last_pxlv <= PXI_LV;

            if (PXI_LV = '1') and (PXI_FV = '1') and ((last_pxx /= PXI_X) or (last_pxlv = '0')) then
                last_pxx <= PXI_X;
                
                abc_valid <= '1';
                a_int <= PXI_A;
                b_int <= PXI_B;
                c_int <= PXI_C;
            else
                abc_valid <= '0';
            end if;
        end if;
    end process;

    slowking : process(CLKX3)
    begin
        if rising_edge(CLKX3) then
            RAM_WE <= abc_valid;
            
            if (abc_valid = '1') then
                case txcnt is
                    when "00" =>
                        RAM_OUT <= a_int;
                        RAM_WE <= '1';
                        txcnt <= "01";
                    when "01" =>
                        RAM_OUT <= b_int;
                        txcnt <= "10";
                    when "10" =>
                        RAM_OUT <= c_int;
                        txcnt <= "00";
                    when others => null;
                end case;
            end if;
        end if;
    end process;

    addrcnt : process(CLKX3)
    begin
        if rising_edge(CLKX3) then
            last_abc_valid <= abc_valid;
            
            if (PXI_FV = '0') then
                addr <= (others => '0');
            elsif (last_abc_valid = '1') then
                addr <= addr + 1;
            end if;
        end if;
    end process;

end Behavioral;
