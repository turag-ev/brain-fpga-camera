library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rgb2ycbcr is
    Port (  CLK : in  STD_LOGIC;

            PXI_LV, PXI_FV : in std_logic;
            PXI_X, PXI_Y : in std_logic_vector(8 downto 0);
            PXI_RED, PXI_GREEN, PXI_BLUE : in std_logic_vector(7 downto 0);

            PXO_LV, PXO_FV : out std_logic := '0';
            PXO_PX_X, PXO_PX_Y : out std_logic_vector(8 downto 0) := (others => '0');
            PXO_Y, PXO_CB, PXO_CR : out std_logic_vector(7 downto 0) := (others => '0')
    );
end rgb2ycbcr;


architecture Behavioral of rgb2ycbcr is
    COMPONENT rgb2ycbcr_calc
        PORT(
            CLK : IN std_logic;
            r : IN std_logic_vector(7 downto 0);
            g : IN std_logic_vector(7 downto 0);
            b : IN std_logic_vector(7 downto 0);          
            y : OUT std_logic_vector(7 downto 0);
            cr : OUT std_logic_vector(7 downto 0);
            cb : OUT std_logic_vector(7 downto 0)
        );
    END COMPONENT;

    signal d_lv, d_fv : std_logic := '0';
    signal d_x, d_y : std_logic_vector(8 downto 0) := (others => '0');
begin

inst_rgb2ycrcb_calc: rgb2ycbcr_calc PORT MAP(
    CLK => CLK,
    r => PXI_RED,
    g => PXI_GREEN,
    b => PXI_BLUE,
    y => PXO_Y,
    cr => PXO_CB,
    cb => PXO_CR
);

delay : process(CLK)
begin
    if rising_edge(CLK) then
        d_lv <= PXI_LV;
        PXO_LV <= d_lv;
        
        d_fv <= PXI_FV;
        PXO_FV <= d_fv;
        
        d_x <= PXI_X;
        PXO_PX_X <= d_x;
        
        d_y <= PXI_Y;
        PXO_PX_Y <= d_y;
    end if;
end process;

end Behavioral;
