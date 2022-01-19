LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY demosaic_test IS
    generic (
        rggbfile: string := "../bctools/bcomm/testbilder/rggb/s4-nicecolor.bin";
        rgbfile:  string := "../bctools/bcomm/testbilder/rggb/s4-nicecolor-demosaic.bin" -- generate file with demosaic.py
    );
END demosaic_test;
 
ARCHITECTURE behavior OF demosaic_test IS
    -- Component Declaration for the Unit Under Test (UUT)

    COMPONENT demosaic
    PORT(
         CLK : IN  std_logic;
         PXI_LV : IN  std_logic;
         PXI_FV : IN  std_logic;
         PXI_X : IN  std_logic_vector(8 downto 0);
         PXI_Y : IN  std_logic_vector(8 downto 0);
         PXI_DATA : IN  std_logic_vector(7 downto 0);
         PXO_LV : OUT  std_logic;
         PXO_FV : OUT  std_logic;
         PXO_X : OUT  std_logic_vector(8 downto 0);
         PXO_Y : OUT  std_logic_vector(8 downto 0);
         PXO_RED : OUT  std_logic_vector(7 downto 0);
         PXO_GREEN : OUT  std_logic_vector(7 downto 0);
         PXO_BLUE : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;


    --Inputs
    signal CLK : std_logic := '0';
    signal PXI_LV : std_logic := '0';
    signal PXI_FV : std_logic := '0';
    signal PXI_X : std_logic_vector(8 downto 0) := (others => '0');
    signal PXI_Y : std_logic_vector(8 downto 0) := (others => '0');
    signal PXI_DATA : std_logic_vector(7 downto 0) := (others => '0');

    --Outputs
    signal PXO_LV : std_logic;
    signal PXO_FV : std_logic;
    signal PXO_X : std_logic_vector(8 downto 0);
    signal PXO_Y : std_logic_vector(8 downto 0);
    signal PXO_RED : std_logic_vector(7 downto 0);
    signal PXO_GREEN : std_logic_vector(7 downto 0);
    signal PXO_BLUE : std_logic_vector(7 downto 0);

    -- Clock period definitions
    constant CLK_period : time := 10 ns;
    constant RGGB_LINE_LEN : integer := 188*2;
 
    signal pxix, pxix_next, pxiy : unsigned(8 downto 0) := (others => '0');
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: demosaic PORT MAP (
          CLK => CLK,
          PXI_LV => PXI_LV,
          PXI_FV => PXI_FV,
          PXI_X => PXI_X,
          PXI_Y => PXI_Y,
          PXI_DATA => PXI_DATA,
          PXO_LV => PXO_LV,
          PXO_FV => PXO_FV,
          PXO_X => PXO_X,
          PXO_Y => PXO_Y,
          PXO_RED => PXO_RED,
          PXO_GREEN => PXO_GREEN,
          PXO_BLUE => PXO_BLUE
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
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
        
        wait for CLK_period*5;

        -- read RGGB image, dumped by bcamstreamer
        PXI_FV <= '1';
        wait for CLK_period*71;
        
        while not endfile(rggbf) loop
            PXI_LV <= '1';

            -- read two bytes
            for i in 0 to 1 loop
                read(rggbf, imgbyte);
                tmp := to_unsigned(character'pos(imgbyte), 8);
                PXI_DATA <= std_logic_vector(tmp);
                pxix <= pxix_next;
                pxix_next <= pxix_next + 1;
                wait for CLK_period*2;
            end loop;
            
            -- end of line?
            if (pxix_next >= to_unsigned(RGGB_LINE_LEN, pxix_next'length)) then
                PXI_LV <= '0';
                pxix_next <= (others => '0');
                pxiy <= pxiy + 1;
                wait for CLK_period*94;
            end if;

            wait for CLK_period*1;
        end loop;

        file_close(rggbf);

        -- end of frame
        PXI_FV <= '0';

        report "RGGB file read complete";
        wait for CLK_period*23;
    end process;

    verify_output : process
        type rgbf_t is file of character;
        file rgbf : rgbf_t;
        variable fstatus: FILE_OPEN_STATUS;

        variable imgbyte : character;
        variable wr, wg, wb : std_logic_vector(7 downto 0);
        variable last_pxx, last_pxy : std_logic_vector(8 downto 0);
        variable good : std_logic := '1';
    begin
        file_open(fstatus, rgbf, rgbfile, read_mode);
        good := '1';

        wait until (PXO_FV = '1');
        wait until (PXO_LV = '1');
        report "starting check";

        while not endfile(rgbf) loop
            -- R
            read(rgbf, imgbyte);
            wr := std_logic_vector(to_unsigned(character'pos(imgbyte), 8));

            -- G
            if endfile(rgbf) then
                report "EOF! G";
                good := '0';
                exit;
            end if;
            read(rgbf, imgbyte);
            wg := std_logic_vector(to_unsigned(character'pos(imgbyte), 8));

            -- B
            if endfile(rgbf) then
                report "EOF! B";
                good := '0';
                exit;
            end if;
            read(rgbf, imgbyte);
            wb := std_logic_vector(to_unsigned(character'pos(imgbyte), 8));
            
            -- compare
            loop
                if (PXO_FV = '0') then
                    report "end";
                    exit;
                end if;
                
                if (PXO_LV = '1') and ((last_pxx /= PXO_X) or (last_pxy /= PXO_Y)) then
                    exit;
                end if;
                
                wait for CLK_period;
            end loop;

            if (wr /= PXO_RED) or (wg /= PXO_GREEN) or (wb /= PXO_BLUE) then
                wait for CLK_period*5;
                report "RGB bad" severity FAILURE;
                good := '0';
            end if;

            if (PXO_FV = '0') and (good = '0') then
                report "RGB output check done";
                exit;
            end if;

            last_pxx := PXO_X;
            last_pxy := PXO_Y;
        end loop;

        file_close(rgbf);

        if (good = '1') then
            report "YAY! output data was good!";
        else
            report "NAY! output was shit!";
        end if;
    end process;

END;
