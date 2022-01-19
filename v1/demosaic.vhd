library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity demosaic is
    Port (  CLK : in  STD_LOGIC;
            DA, DB, DC : out std_logic := '0';

            -- input
            PXI_LV, PXI_FV : in std_logic;
            PXI_X, PXI_Y : in std_logic_vector(8 downto 0);
            PXI_DATA : in std_logic_vector(7 downto 0);

            -- output
            PXO_LV, PXO_FV : out std_logic := '0';
            PXO_X, PXO_Y : out std_logic_vector(8 downto 0) := (others => '0');
            PXO_RED, PXO_GREEN, PXO_BLUE : out std_logic_vector(7 downto 0) := (others => '0')
    );
end demosaic;

architecture Behavioral of demosaic is
    -- FIFO
    COMPONENT LineBuffer512
        PORT (
            CLK : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            wr_en : IN STD_LOGIC;
            rd_en : IN STD_LOGIC;
            dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            full : OUT STD_LOGIC;
            almost_full : OUT STD_LOGIC;
            empty : OUT STD_LOGIC;
            almost_empty : OUT STD_LOGIC;
            data_count : OUT STD_LOGIC_VECTOR(8 DOWNTO 0)
        );
    END COMPONENT;
    
    constant LINE_LENGTH : integer := 188;
    constant FIFO_LENGTH : integer := 2*LINE_LENGTH; -- buffer one BGBG... line
    
    signal pxifv_last, pxilv_last : std_logic := '0';
    signal pxix_last, pxiy_last : std_logic_vector(PXI_X'length-1 downto 0) := (others => '0');
    
    signal newpx_read, frame_valid, line_valid, pixel_valid, pixel_valid_d, rgbput_ready, last_pixel, last_pixel_dy1, last_pixel_dy2 : std_logic := '0';
    signal line1_px1, line1_px2, line2_px1, line2_px2, l2buf, l2buf2 : std_logic_vector(7 downto 0) := (others => '0');
    
    signal fifo_rst, fifo_wr_en, fifo_rd_en, fifo_empty : std_logic := '0';
    signal fifo_want_reset : std_logic := '1';
    signal fifo_dcnt : unsigned(8 downto 0) := (others => '0');
    signal fifo_din, fifo_dout : std_logic_vector(7 downto 0) := (others => '0');
    
    signal r_int, g_int, b_int : std_logic_vector(7 downto 0) := (others => '0');
    signal pxx_int, pxy_int, pxx_next : unsigned(8 downto 0) := (others => '0');
    signal pxo_fv_int, pxo_lv_int : std_logic := '0';
begin

linebuf : LineBuffer512
    PORT MAP (
        CLK => CLK,
        rst => fifo_rst,
        din => fifo_din,
        wr_en => fifo_wr_en,
        rd_en => fifo_rd_en,
        dout => fifo_dout,
        full => open,
        almost_full => open,
        empty => fifo_empty,
        almost_empty => open,
        unsigned(data_count) => fifo_dcnt
    );

-- outputs
PXO_LV <= pxo_lv_int;
PXO_FV <= pxo_fv_int;
PXO_X <= std_logic_vector(pxx_int);
PXO_Y <= std_logic_vector(pxy_int);
PXO_RED <= r_int;
PXO_GREEN <= g_int;
PXO_BLUE <= b_int;

eatlast : process(CLK)
begin
    if rising_edge(CLK) then
        pxifv_last <= PXI_FV;
        pxilv_last <= PXI_LV;
        pxix_last <= PXI_X;
        pxiy_last <= PXI_Y;
    end if;
end process;

fifoctl : process(CLK)
begin
    if rising_edge(CLK) then
        if (PXI_LV = '1') and (PXI_FV = '1') and ((pxix_last /= PXI_X) or (pxilv_last = '0')) then
            -- on every new pixel in a valid line
            fifo_wr_en <= '1';
            fifo_din <= PXI_DATA;

            -- read from FIFO when one line is buffered
            if (fifo_dcnt >= FIFO_LENGTH) then
                fifo_rd_en <= '1';
            else
                fifo_rd_en <= '0';
            end if;
        else
            fifo_wr_en <= '0';
            fifo_rd_en <= '0';
        end if;
    end if;
end process;

fiforst : process(CLK)
begin
    if rising_edge(CLK) then
        -- at end of frame, reset fifo
        if (PXI_FV = '0') and (pxifv_last = '1') then
            fifo_want_reset <= '1';
        else
            fifo_want_reset <= '0';
        end if;
        
        -- delay the reset, we want to read the last pixel
        fifo_rst <= fifo_want_reset;
    end if;
end process;

DA <= newpx_read;
DB <= pxiy_last(0);
DC <= fifo_rd_en;

pxdelayedvalid : process(CLK)
begin
    if rising_edge(CLK) then
        -- check if the pixel that falls out of the fifo is valid
        -- RGGB pixel group is valid in every odd line, odd column
        if (fifo_rd_en = '1') and (pxiy_last(0) = '1') and (pxix_last(0) = '0') then
            pixel_valid <= '1';
        else
            pixel_valid <= '0';
        end if;
        newpx_read <= fifo_rd_en and not pxiy_last(0) and pxix_last(0);

        frame_valid <= pxifv_last;
        
        -- every odd input line produces a valid output line
        if (pxifv_last = '1') and (pxilv_last = '1') and (pxiy_last(0) = '1') then
            line_valid <= '1';
        else
            line_valid <= '0';
        end if;
    end if;
end process;

pxdelay : process(CLK)
begin
    if rising_edge(CLK) then
        -- end of line gets a special treatment as there's still a valid pixel in the pipeline
        if (fifo_rd_en = '1') or ((line_valid = '1') and (pxilv_last = '0')) then
            -- before FIFO
            line1_px2 <= fifo_dout;
            line1_px1 <= line1_px2;
            -- after FIFO
            l2buf <= fifo_din;
            line2_px2 <= l2buf;
            line2_px1 <= line2_px2;
        end if;
        
        last_pixel <= line_valid and not pxilv_last;
    end if;
end process;

rgbput : process(CLK)
    variable R, G1, G2, B : std_logic_vector(7 downto 0) := (others => '0');
begin
    if rising_edge(CLK) then
        if ((newpx_read = '1')) or (last_pixel = '1') then
            B := line1_px1;
            G1 := line1_px2;
            G2 := line2_px1;
            R := line2_px2;
            
            if (rgbput_ready = '1') then
                r_int <= R;
                g_int <= G1;
                b_int <= B;

                pxx_next <= pxx_next + 1;
                pxx_int <= pxx_next;
                
                pxo_lv_int <= '1';
            else
                rgbput_ready <= '1';
                pxo_lv_int <= '0';
            end if;
        else
            if (frame_valid = '0') then
                pxx_int <= (others => '0');
                pxx_next <= (others => '0');
                pxy_int <= (others => '0');
            end if;
            
            if (line_valid = '0') then
                pxo_lv_int <= '0';
            end if;
            
            if (last_pixel_dy2 = '1') then
                -- at end of line
                pxy_int <= pxy_int + 1;
                pxx_int <= (others => '0');
                pxx_next <= (others => '0');
                rgbput_ready <= '0';
            end if;
        end if;

        pxo_fv_int <= frame_valid;
        
        -- uber delay, holds the last pixel for 2 additional clock cycles
        last_pixel_dy1 <= last_pixel;
        last_pixel_dy2 <= last_pixel_dy1;
    end if;
end process;

end Behavioral;
