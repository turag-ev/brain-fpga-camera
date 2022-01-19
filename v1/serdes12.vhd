library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity serdes12 is
    generic (
        ADJ         : integer := 2;     -- PLL clock must be 400 - 1080 MHz, adjust multiplication factor
        PLLD        : integer := 1;     -- PLL division factor
        PLLX        : integer := 24;    -- PLL multiplication factor = wanted factor * ADJ
        S           : integer := 6;     -- serdes factor of a single SERDES 1..8
        CLKIN_PERIOD: real := 37.45318352059;   -- (in ns) => 26.7 MHz input clock
        sys_w       : integer := 1;     -- number of data pins
        dev_w       : integer := 6      -- single SERDES parallel data width
    );
    port (
        CLK_IN          : in    std_logic;  -- pixel clock = camera clock = 26.7 MHz
        CLK_SLOW_X1_OUT, CLK_SLOW_X2_OUT, CLK_SLOW_X3_OUT    : out   std_logic;
        CLK_FAST_OUT    : out   std_logic;  -- LVDS clock (12*26.7 MHz = 320.4 MHz)

        CLK_RESET       : in    std_logic;
        IO_RESET        : in    std_logic;

        DATA_IN_FROM_PINS_P : in    std_logic_vector(sys_w-1 downto 0);
        DATA_IN_FROM_PINS_N : in    std_logic_vector(sys_w-1 downto 0);
        DATA_IN_TO_DEVICE   : out   std_logic_vector(dev_w-1 downto 0);

        BITSLIP         : in    std_logic
    );
end serdes12;

architecture lol of serdes12 is
    -- PLL + BUFPLL stuff
    signal dummy        : std_logic;
    signal pllout_xs    : std_logic;
    signal pllout_x1, pllout_x2, pllout_x3, pllout_x4    : std_logic;
    signal pll_lckd     : std_logic;
    signal clk_slow_x1, clk_slow_x2, clk_slow_x3, clk_slow_x4  : std_logic;
    signal ioclk        : std_logic;
    signal buf_pll_lckd : std_logic;

    -- core-generator-generated stuff
    -- After the buffer
    signal data_in_from_pins_int     : std_logic_vector(sys_w-1 downto 0);
    -- Between the delay and serdes
    signal data_in_from_pins_delay   : std_logic_vector(sys_w-1 downto 0);
    constant num_serial_bits         : integer := dev_w/sys_w;
    type serdarr is array (0 to 7) of std_logic_vector(sys_w-1 downto 0);
    -- Array to use intermediately from the serdes to the internal
    --  devices. bus "0" is the leftmost bus
    -- * fills in starting with 0
    signal iserdes_q                 : serdarr := (( others => (others => '0')));
    signal serdesstrobe             : std_logic;
    signal icascade                 : std_logic_vector(sys_w-1 downto 0);
    signal slave_shiftout           : std_logic_vector(sys_w-1 downto 0);
begin

-- PLL
pll_adv_inst : PLL_ADV generic map (
    BANDWIDTH           => "OPTIMIZED", -- "high", "low" or "optimized"
    CLKFBOUT_MULT       => PLLX,        -- multiplication factor for all output clocks  => P = 26.7*24 = 640.8 MHz
    CLKFBOUT_PHASE      => 0.0,     	-- phase shift (degrees) of all output clocks
    CLKIN1_PERIOD       => CLKIN_PERIOD,-- clock period (ns) of input clock on clkin1
    CLKIN2_PERIOD       => CLKIN_PERIOD,-- clock period (ns) of input clock on clkin2
    CLKOUT0_DIVIDE      => 1*ADJ,       -- division factor for clkout0 (1 to 128)       => X12,     P/2  = 320.4 MHz
    CLKOUT0_DUTY_CYCLE  => 0.5,         -- duty cycle for clkout0 (0.01 to 0.99)
    CLKOUT0_PHASE       => 0.0,         -- phase shift (degrees) for clkout0 (0.0 to 360.0)
    CLKOUT1_DIVIDE      => 1*ADJ,       -- division factor for clkout1 (1 to 128)       => open
    CLKOUT1_DUTY_CYCLE  => 0.5,         -- duty cycle for clkout1 (0.01 to 0.99)
    CLKOUT1_PHASE       => 0.0,         -- phase shift (degrees) for clkout1 (0.0 to 360.0)
    CLKOUT2_DIVIDE      => S*ADJ,       -- division factor for clkout2 (1 to 128)       =>  X2,     P/12 = 53.4 MHz
    CLKOUT2_DUTY_CYCLE  => 0.5,         -- duty cycle for clkout2 (0.01 to 0.99)
    CLKOUT2_PHASE       => 0.0,         -- phase shift (degrees) for clkout2 (0.0 to 360.0)
    CLKOUT3_DIVIDE      => S/2*ADJ,     -- division factor for clkout3 (1 to 128)       =>  X4,     P/6  = 106.8 MHz
    CLKOUT3_DUTY_CYCLE  => 0.5,         -- duty cycle for clkout3 (0.01 to 0.99)
    CLKOUT3_PHASE       => 0.0,         -- phase shift (degrees) for clkout3 (0.0 to 360.0)
    CLKOUT4_DIVIDE      => 2*S*ADJ,       -- division factor for clkout4 (1 to 128)     => X1,      P/24 = 26.7 MHz
    CLKOUT4_DUTY_CYCLE  => 0.5,         -- duty cycle for clkout4 (0.01 to 0.99)
    CLKOUT4_PHASE       => 0.0,         -- phase shift (degrees) for clkout4 (0.0 to 360.0)
    CLKOUT5_DIVIDE      => 4*ADJ,       -- division factor for clkout5 (1 to 128)       =>  X3,     P/8  = 80.1 MHz
    CLKOUT5_DUTY_CYCLE  => 0.5,         -- duty cycle for clkout5 (0.01 to 0.99)
    CLKOUT5_PHASE       => 0.0,         -- phase shift (degrees) for clkout5 (0.0 to 360.0)
    COMPENSATION        => "INTERNAL",  -- "SYSTEM_SYNCHRONOUS", "SOURCE_SYNCHRONOUS", "INTERNAL", "EXTERNAL", "DCM2PLL", "PLL2DCM"
    DIVCLK_DIVIDE       => PLLD,        -- division factor for all clocks (1 to 52)
    REF_JITTER          => 0.100        -- input reference jitter (0.000 to 0.999 ui%)
)
port map (
    CLKFBDCM    => open,                -- output feedback signal used when pll feeds a dcm
    CLKFBOUT    => dummy,               -- general output feedback signal
    CLKOUT0     => pllout_xs,           -- x12 clock for transmitter
    CLKOUT1     => open,
    CLKOUT2     => pllout_x2,           -- x2 clock for BUFG
    CLKOUT3     => pllout_x4,           -- x4 clock for BUFG
    CLKOUT4     => pllout_x1,                -- one of six general clock output signals
    CLKOUT5     => pllout_x3,                -- one of six general clock output signals
    CLKOUTDCM0  => open,                -- one of six clock outputs to connect to the dcm
    CLKOUTDCM1  => open,                -- one of six clock outputs to connect to the dcm
    CLKOUTDCM2  => open,                -- one of six clock outputs to connect to the dcm
    CLKOUTDCM3  => open,                -- one of six clock outputs to connect to the dcm
    CLKOUTDCM4  => open,                -- one of six clock outputs to connect to the dcm
    CLKOUTDCM5  => open,                -- one of six clock outputs to connect to the dcm
    DO          => open,                -- dynamic reconfig data output (16-bits)
    DRDY        => open,                -- dynamic reconfig ready output
    LOCKED      => pll_lckd,            -- active high pll lock signal
    CLKFBIN     => dummy,               -- clock feedback input
    CLKIN1      => CLK_IN,              -- primary clock input
    CLKIN2      => '0',                 -- secondary clock input
    CLKINSEL    => '1',                 -- selects '1' = clkin1, '0' = clkin2
    DADDR       => "00000",             -- dynamic reconfig address input (5-bits)
    DCLK        => '0',                 -- dynamic reconfig clock input
    DEN         => '0',                 -- dynamic reconfig enable input
    DI          => "0000000000000000",  -- dynamic reconfig data input (16-bits)
    DWE         => '0',                 -- dynamic reconfig write enable input
    RST         => '0',                 -- asynchronous pll reset
    REL         => '0'                  -- used to force the state of the PFD outputs (test only)
);

bufg_x1 : BUFG port map (I => pllout_x1, O => clk_slow_x1 ) ;
bufg_x2 : BUFG port map (I => pllout_x2, O => clk_slow_x2 ) ;
bufg_x3 : BUFG port map (I => pllout_x3, O => clk_slow_x3 ) ;
bufg_x4 : BUFG port map (I => pllout_x4, O => clk_slow_x4 ) ;

-- BUFPLL
bufpll_inst : BUFPLL generic map(
    DIVIDE      => S                      -- PLLIN0 divide-by value to produce SERDESSTROBE (1 to 8)
)
port map (
    PLLIN       => pllout_xs,       -- PLL Clock input
    GCLK        => clk_slow_x4,     -- Global Clock input
    LOCKED      => pll_lckd,        -- Clock0 locked input
    IOCLK       => ioclk,           -- Output PLL Clock
    LOCK        => buf_pll_lckd,    -- BUFPLL Clock and strobe locked
    SERDESSTROBE=> serdesstrobe     -- Output SERDES strobe
);

-- clk outputs
CLK_SLOW_X1_OUT <= clk_slow_x1;
CLK_SLOW_X2_OUT <= clk_slow_x2;
CLK_SLOW_X3_OUT <= clk_slow_x3;
CLK_FAST_OUT <= ioclk;
  
-- We have multiple bits- step over every bit, instantiating the required elements
pins: for pin_count in 0 to sys_w-1 generate 
begin
    -- Instantiate the buffers
    ----------------------------------
    -- Instantiate a buffer for every bit of the data bus
    ibufds_inst : IBUFDS
        generic map (
            DIFF_TERM   => FALSE,
            IOSTANDARD  => "LVDS_33"
        )
        port map (
            I   => DATA_IN_FROM_PINS_P(pin_count),
            IB  => DATA_IN_FROM_PINS_N(pin_count),
            O   => data_in_from_pins_int(pin_count)
        );

    -- Pass through the delay
    -----------------------------------
    data_in_from_pins_delay(pin_count) <= data_in_from_pins_int(pin_count);

    -- Instantiate the serdes primitive
    ----------------------------------
    -- declare the iserdes
    iserdes2_master : ISERDES2
        generic map (
            BITSLIP_ENABLE  => TRUE,
            DATA_RATE       => "SDR",
            DATA_WIDTH      => 6,
            INTERFACE_TYPE  => "RETIMED",
            SERDES_MODE     => "MASTER"
        )
        port map (
            Q1          => iserdes_q(3)(pin_count),
            Q2          => iserdes_q(2)(pin_count),
            Q3          => iserdes_q(1)(pin_count),
            Q4          => iserdes_q(0)(pin_count),
            SHIFTOUT    => icascade(pin_count),
            INCDEC      => open,
            VALID       => open,
            BITSLIP     => BITSLIP, -- 1-bit Invoke Bitslip. This can be used with any DATA_WIDTH, cascaded or not.
                                    -- The amount of bitslip is fixed by the DATA_WIDTH selection.
            CE0         => '1',     -- 1-bit Clock enable input
            CLK0        => ioclk,   -- 1-bit IO Clock network input. Optionally Invertible. This is the primary clock
                                    -- input used when the clock doubler circuit is not engaged (see DATA_RATE
                                    -- attribute).
            CLK1        => '0',
            CLKDIV      => clk_slow_x2,                         -- 1-bit Global clock network input. This is the clock for the fabric domain.
            D           => data_in_from_pins_delay(pin_count),  -- 1-bit Input signal from IOB.
            IOCE        => serdesstrobe,                        -- 1-bit Data strobe signal derived from BUFIO CE. Strobes data capture for
                                                                -- NETWORKING and NETWORKING_PIPELINES alignment modes.

            RST        => IO_RESET, -- 1-bit Asynchronous reset only.
            SHIFTIN    => slave_shiftout(pin_count),

            -- unused connections
            FABRICOUT  => open,
            CFB0       => open,
            CFB1       => open,
            DFB        => open
        );

    iserdes2_slave : ISERDES2
        generic map (
            BITSLIP_ENABLE => TRUE,
            DATA_RATE      => "SDR",
            DATA_WIDTH     => 6,
            INTERFACE_TYPE => "RETIMED",
            SERDES_MODE    => "SLAVE"
        )
        port map (
            Q1         => iserdes_q(7)(pin_count),
            Q2         => iserdes_q(6)(pin_count),
            Q3         => iserdes_q(5)(pin_count),
            Q4         => iserdes_q(4)(pin_count),
            SHIFTOUT   => slave_shiftout(pin_count),
            BITSLIP    => BITSLIP,  -- 1-bit Invoke Bitslip. This can be used with any DATA_WIDTH, cascaded or not.
                                    -- The amount of bitslip is fixed by the DATA_WIDTH selection.
            CE0        => '1',      -- 1-bit Clock enable input
            CLK0       => ioclk,    -- 1-bit IO Clock network input. Optionally Invertible. This is the primary clock
                                    -- input used when the clock doubler circuit is not engaged (see DATA_RATE
                                    -- attribute).
            CLK1       => '0',
            CLKDIV     => clk_slow_x2,-- 1-bit Global clock network input. This is the clock for the fabric domain.
            D          => '0',       -- 1-bit Input signal from IOB.
            IOCE       => serdesstrobe, -- 1-bit Data strobe signal derived from BUFIO CE. Strobes data capture for
                                        -- NETWORKING and NETWORKING_PIPELINES alignment modes.

            RST        => IO_RESET,     -- 1-bit Asynchronous reset only.
            SHIFTIN    => icascade(pin_count),

            -- unused connections
            FABRICOUT  => open,
            CFB0       => open,
            CFB1       => open,
            DFB        => open
        );

    -- Concatenate the serdes outputs together. Keep the timesliced
    --   bits together, and placing the earliest bits on the right
    --   ie, if data comes in 0, 1, 2, 3, 4, 5, 6, 7, ...
    --       the output will be 3210, 7654, ...
    -------------------------------------------------------------

    in_slices: for slice_count in 0 to num_serial_bits-1 generate begin
    -- This places the first data in time on the right
        DATA_IN_TO_DEVICE(slice_count) <= iserdes_q(num_serial_bits-slice_count-1)(0);
    -- To place the first data in time on the left, use the
    --   following code, instead
    -- DATA_IN_TO_DEVICE(slice_count) <=
    --   iserdes_q(slice_count);
    end generate in_slices;
end generate pins;

end lol;
