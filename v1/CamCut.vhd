library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity CamCut is
    Port (  CLK : in  STD_LOGIC;
    
            -- input
            PXI_LV, PXI_FV : in std_logic;
            PXI_X, PXI_Y : in std_logic_vector(8 downto 0);
            PXI_A, PXI_B, PXI_C : in std_logic_vector(7 downto 0);

            -- output
            PXO_LV, PXO_FV : out std_logic := '0';
            PXO_X, PXO_Y : out std_logic_vector(8 downto 0) := (others => '0');
            PXO_A, PXO_B, PXO_C : out std_logic_vector(7 downto 0) := (others => '0')
    );
end CamCut;

architecture Behavioral of CamCut is
    constant CUT_X : integer := 160;
    signal pxix, pxiy : unsigned(PXI_X'length-1 downto 0) := (others => '0');
begin

pxix <= unsigned(PXI_X);
pxiy <= unsigned(PXI_Y);

bagpipe: process(CLK)
begin
    if rising_edge(CLK) then
        PXO_FV <= PXI_FV;
        PXO_A <= PXI_A;
        PXO_B <= PXI_B;
        PXO_C <= PXI_C;
        PXO_Y <= PXI_Y;
        
        if (PXI_LV = '1') and (pxix < CUT_X) then
            PXO_LV <= '1';
            PXO_X <= PXI_X;
        else
            PXO_LV <= '0';
        end if;
    end if;
end process;

end Behavioral;
