LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY UNISIM;
USE UNISIM.Vcomponents.ALL;

ENTITY Test_CamToRAM_tb IS
    generic (
        rggbfile: string := "../bctools/bcomm/testbilder/rggb/s4-nicecolor.bin"
    );
END Test_CamToRAM_tb;

ARCHITECTURE behavioral OF Test_CamToRAM_tb IS 

    COMPONENT Test_CamToRAM
    PORT( PXI_DATA	:	IN	STD_LOGIC_VECTOR (7 DOWNTO 0); 
          PXI_Y	:	IN	STD_LOGIC_VECTOR (8 DOWNTO 0); 
          PXI_X	:	IN	STD_LOGIC_VECTOR (8 DOWNTO 0); 
          PXI_FV	:	IN	STD_LOGIC; 
          PXI_LV	:	IN	STD_LOGIC;
          RAM_WE	:	OUT	STD_LOGIC; 
          RAM_ADDR	:	OUT	STD_LOGIC_VECTOR (16 DOWNTO 0); 
          RAM_OUT	:	OUT	STD_LOGIC_VECTOR (7 DOWNTO 0); 
          CLK_X1	:	IN	STD_LOGIC; 
          CLK_X3	:	IN	STD_LOGIC);
    END COMPONENT;

    SIGNAL PXI_DATA	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL PXI_Y	:	STD_LOGIC_VECTOR (8 DOWNTO 0);
    SIGNAL PXI_X	:	STD_LOGIC_VECTOR (8 DOWNTO 0);
    SIGNAL PXI_FV	:	STD_LOGIC;
    SIGNAL PXI_LV	:	STD_LOGIC;
    SIGNAL RAM_WE	:	STD_LOGIC;
    SIGNAL RAM_ADDR	:	STD_LOGIC_VECTOR (16 DOWNTO 0);
    SIGNAL RAM_OUT	:	STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL CLK_X1	:	STD_LOGIC;
    SIGNAL CLK_X3	:	STD_LOGIC;

    constant clkbase_period : time := 10 ns;
    constant clkx1_period : time := clkbase_period*3;
    constant clkx3_period : time := clkbase_period;
    constant RGGB_LINE_LEN : integer := 188*2;
 
    signal pxix, pxix_next, pxiy : unsigned(8 downto 0) := (others => '0');
BEGIN

   UUT: Test_CamToRAM PORT MAP(
		PXI_DATA => PXI_DATA, 
		PXI_Y => PXI_Y, 
		PXI_X => PXI_X, 
		PXI_FV => PXI_FV, 
		PXI_LV => PXI_LV, 
		RAM_WE => RAM_WE, 
		RAM_ADDR => RAM_ADDR, 
		RAM_OUT => RAM_OUT, 
		CLK_X1 => CLK_X1, 
		CLK_X3 => CLK_X3
   );
   
    clockgen_1 : process
    begin
        CLK_X1 <= '1';
        wait for clkx1_period/2;
        CLK_X1 <= '0';
        wait for clkx1_period/2;
    end process;
    
    clockgen_3 : process
    begin
        CLK_X3 <= '1';
        wait for clkx3_period/2;
        CLK_X3 <= '0';
        wait for clkx3_period/2;
    end process;

    PXI_X <= std_logic_vector(pxix);
    PXI_Y <= std_logic_vector(pxiy);
 
    read_input : process
        type rggbf_t is file of character;
        file rggbf : rggbf_t;
        variable fstatus: FILE_OPEN_STATUS;

        variable imgbyte : character;
        variable tmp : unsigned(7 downto 0);
    begin
        file_open(fstatus, rggbf, rggbfile, read_mode);

        PXI_LV <= '0';
        PXI_FV <= '0';
        pxix <= (others => '0');
        pxix_next <= (others => '0');
        pxiy <= (others => '0');
        PXI_DATA <= (others => '0');
        
        wait for clkx1_period*5;

        -- read RGGB image, dumped by bcamstreamer
        PXI_FV <= '1';
        wait for clkx1_period*5;
        
        while not endfile(rggbf) loop
            PXI_LV <= '1';

            -- read two bytes
            for i in 0 to 1 loop
                read(rggbf, imgbyte);
                tmp := to_unsigned(character'pos(imgbyte), 8);
                PXI_DATA <= std_logic_vector(tmp);
                pxix <= pxix_next;
                pxix_next <= pxix_next + 1;
                wait for clkx1_period*2;
            end loop;
            
            -- end of line?
            if (pxix_next >= to_unsigned(RGGB_LINE_LEN, pxix_next'length)) then
                PXI_LV <= '0';
                pxix_next <= (others => '0');
                pxiy <= pxiy + 1;
                wait for clkx1_period*5;
            end if;

            wait for clkx1_period*1;
        end loop;

        file_close(rggbf);

        -- end of frame
        PXI_LV <= '0';
        PXI_FV <= '0';
        pxix <= (others => '0');
        pxix_next <= (others => '0');
        pxiy <= (others => '0');
        PXI_DATA <= (others => '0');

        report "RGGB file read complete";
        wait for clkx1_period*500;
    end process;

END;
