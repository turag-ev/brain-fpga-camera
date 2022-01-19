LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE STD.TEXTIO.ALL;
use ieee.std_logic_textio.all;
 
ENTITY rgb2ycbcr_test IS
    generic (
        infile: string := "../bctools/bcomm/testbilder/rggb/s4-nicecolor-demosaic.bin";
        outfile:  string := "../bctools/bcomm/testbilder/rggb/s4-nicecolor-demosaic-ycbcr.bin"
    );
END rgb2ycbcr_test;
 
ARCHITECTURE behavior OF rgb2ycbcr_test IS
    COMPONENT rgb2ycbcr
    PORT(
         CLK : IN  std_logic;
         STR_IN : IN  std_logic;
         STR_OUT : OUT  std_logic;
         RED_IN, GREEN_IN, BLUE_IN : IN  std_logic_vector(7 downto 0);
         Y_OUT, CB_OUT, CR_OUT : OUT  std_logic_vector(7 downto 0);
         ADDR_IN : IN  std_logic_vector(16 downto 0);
         ADDR_OUT : OUT  std_logic_vector(16 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal STR_IN : std_logic := '0';
   signal RED_IN, GREEN_IN, BLUE_IN : std_logic_vector(7 downto 0) := (others => '0');
   signal ADDR_IN : std_logic_vector(16 downto 0) := (others => '0');

 	--Outputs
   signal STR_OUT : std_logic;
   signal Y_OUT, CB_OUT, CR_OUT : std_logic_vector(7 downto 0);
   signal ADDR_OUT : std_logic_vector(16 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: rgb2ycbcr PORT MAP (
          CLK => CLK,
          STR_IN => STR_IN,
          STR_OUT => STR_OUT,
          RED_IN => RED_IN,
          GREEN_IN => GREEN_IN,
          BLUE_IN => BLUE_IN,
          Y_OUT => Y_OUT,
          CB_OUT => CB_OUT,
          CR_OUT => CR_OUT,
          ADDR_IN => ADDR_IN,
          ADDR_OUT => ADDR_OUT
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

    read_input : process
        type inf_t is file of character;
        file inf : inf_t;
        variable fstatus: FILE_OPEN_STATUS;
        
        variable imgbyte : character;
        variable wr, wg, wb : std_logic_vector(7 downto 0);
        
        variable naddr : unsigned(16 downto 0) := (others => '0');
    begin
        file_open(fstatus, inf, infile, read_mode);

        STR_IN <= '0';
        wait for CLK_period*2;
        
        -- read RGB image
        while not endfile(inf) loop
            STR_IN <= '1';
        
            -- R
            read(inf, imgbyte);
            wr := std_logic_vector(to_unsigned(character'pos(imgbyte), 8));

            -- G
            if endfile(inf) then
                report "EOF! G";
                exit;
            end if;
            read(inf, imgbyte);
            wg := std_logic_vector(to_unsigned(character'pos(imgbyte), 8));

            -- B
            if endfile(inf) then
                report "EOF! B";
                exit;
            end if;
            read(inf, imgbyte);
            wb := std_logic_vector(to_unsigned(character'pos(imgbyte), 8));
            
            -- output RGB pixels
            RED_IN <= wr;
            GREEN_IN <= wg;
            BLUE_IN <= wb;
            
            -- count address up
            ADDR_IN <= std_logic_vector(naddr);
            naddr := naddr + 1;
            
            wait for CLK_period;
        end loop;
        
        file_close(inf);

        STR_IN <= '0';
        RED_IN <= (others => '0');
        GREEN_IN <= (others => '0');
        BLUE_IN <= (others => '0');
        ADDR_IN <= (others => '0');
        naddr := (others => '0');

        wait;
    end process;

END;
