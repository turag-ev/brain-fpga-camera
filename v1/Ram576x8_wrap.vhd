library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity Ram576x8_wrap is
    Port (
        addra : in    std_logic_vector (16 downto 0); 
        addrb : in    std_logic_vector (16 downto 0); 
        clka  : in    std_logic; 
        clkb  : in    std_logic; 
        dina  : in    std_logic_vector (7 downto 0); 
        dinb  : in    std_logic_vector (7 downto 0); 
        wea   : in    std_logic_vector (0 downto 0); 
        web   : in    std_logic_vector (0 downto 0); 
        douta : out   std_logic_vector (7 downto 0); 
        doutb : out   std_logic_vector (7 downto 0)
    );
end Ram576x8_wrap;

architecture Behavioral of Ram576x8_wrap is
COMPONENT Ram576x8
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    clkb : IN STD_LOGIC;
    web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addrb : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    dinb : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END COMPONENT;

    signal addra_int, addrb_int : std_logic_vector (15 downto 0);
begin

addra_int <= addra(15 downto 0);
addrb_int <= addrb(15 downto 0);

inst_Ram576x8 : Ram576x8
    port map (
        clka => clka,
        wea => wea,
        addra => addra_int,
        dina => dina,
        douta => douta,
        clkb => clkb,
        web => web,
        addrb => addrb_int,
        dinb => dinb,
        doutb => doutb
    );

end Behavioral;

