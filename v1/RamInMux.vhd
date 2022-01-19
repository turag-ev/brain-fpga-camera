library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RamInMux17 is
    Generic (
        addr_msb : integer := 16
    );
    Port ( 
        sel : in  STD_LOGIC;

        addrA : in  STD_LOGIC_VECTOR (addr_msb downto 0);
        inA : in  STD_LOGIC_VECTOR (7 downto 0);
        outA : out  STD_LOGIC_VECTOR (7 downto 0);
        weA : in  STD_LOGIC;

        addrB : in  STD_LOGIC_VECTOR (addr_msb downto 0);
        inB : in  STD_LOGIC_VECTOR (7 downto 0);
        outB : out  STD_LOGIC_VECTOR (7 downto 0);
        weB : in  STD_LOGIC;

        addrOut : out  STD_LOGIC_VECTOR (addr_msb downto 0);
        dataOut : out  STD_LOGIC_VECTOR (7 downto 0);
        dataIn : in  STD_LOGIC_VECTOR (7 downto 0);
        weOut : out  STD_LOGIC
    );
end RamInMux17;

architecture Behavioral of RamInMux17 is

begin
    outB <= dataIn;
    outA <= dataIn;

    process(sel, addrA, inA, weA, addrB, inB, weB)
    begin
        if (sel = '0') then
            addrOut <= addrA;
            dataOut <= inA;
            weOut <= weA;
        else
            addrOut	<= addrB;
            dataOut	<= inB;
            weOut <= weB;
        end if;
    end process;

end Behavioral;

------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RamInMux15 is
    Generic (
        addr_msb : integer := 14
    );
    Port ( 
        sel : in  STD_LOGIC;

        addrA : in  STD_LOGIC_VECTOR (addr_msb downto 0);
        inA : in  STD_LOGIC_VECTOR (3 downto 0);
        outA : out  STD_LOGIC_VECTOR (3 downto 0);
        weA : in  STD_LOGIC;

        addrB : in  STD_LOGIC_VECTOR (addr_msb+2 downto 0);
        inB : in  STD_LOGIC_VECTOR (7 downto 0);
        outB : out  STD_LOGIC_VECTOR (7 downto 0);
        weB : in  STD_LOGIC;

        addrOut : out  STD_LOGIC_VECTOR (addr_msb downto 0);
        dataOut : out  STD_LOGIC_VECTOR (3 downto 0);
        dataIn : in  STD_LOGIC_VECTOR (3 downto 0);
        weOut : out  STD_LOGIC
    );
end RamInMux15;

architecture Behavioral of RamInMux15 is

begin
    outB(7 downto 4) <= (others => '0');
    outB(3 downto 0) <= dataIn;
    outA <= dataIn;

    process(sel, addrA, inA, weA, addrB, inB, weB)
    begin
        if (sel = '0') then
            addrOut <= addrA;
            dataOut <= inA;
            weOut <= weA;
        else
            addrOut	<= addrB(addr_msb downto 0);
            dataOut	<= inB(3 downto 0);
            weOut <= weB;
        end if;
    end process;

end Behavioral;
