LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY AVR_SoC_Top_tb IS
END AVR_SoC_Top_tb;
 
ARCHITECTURE behavior OF AVR_SoC_Top_tb IS 

    -- Component Declaration for the Unit Under Test (UUT)

    COMPONENT AVR_SoC_Top
    PORT(
        CLK_48 : IN  std_logic;
        RESET : IN  std_logic;
        DEVLED : OUT  std_logic_vector(7 downto 0);
        POWERLED_VAL : OUT  std_logic_vector(7 downto 0);
        POWERLED_EN : OUT  std_logic;
        IPC_START : OUT  std_logic;
        IPC_RST : OUT  std_logic;
        PC_OVERRIDE, FXL_RIM_SEL : in  std_logic;
        CAM_GOOD : in  std_logic;
        TRIG_MODE, RIM_SEL : OUT  std_logic;
        TRIG_OUT : OUT  std_logic;
        SPI_CS : OUT  std_logic;
        TASTER : IN  std_logic_vector(3 downto 0);
        IPC_DONE : IN  std_logic;
        FRM_SHOOT : IN  std_logic;
        FRM_DONE : IN  std_logic;
        CLK_IRAM : OUT  std_logic;
        IRAM_ADDR : OUT  std_logic_vector(14 downto 0);
        IRAM_DIN : IN  std_logic_vector(7 downto 0);
        IRAM_DOUT : OUT  std_logic_vector(7 downto 0);
        IRAM_WE : OUT  std_logic;
        IRAM_EN : OUT  std_logic;
        SPI_SCK : OUT  std_logic;
        SPI_MOSI : OUT  std_logic;
        SPI_MISO : IN  std_logic;
        ARM_READY : in  std_logic;
        EXPOSURE_TIMESTAMP : out std_logic;
        I2C_SCL_I : IN  std_logic;
        I2C_SCL_O : OUT  std_logic;
        I2C_SCL_OE : OUT  std_logic;
        I2C_SDA_I : IN  std_logic;
        I2C_SDA_O : OUT  std_logic;
        I2C_SDA_OE : OUT  std_logic
        );
    END COMPONENT;


    --Inputs
    signal CLK_48 : std_logic := '0';
    signal RESET : std_logic := '0';
    signal TASTER : std_logic_vector(3 downto 0) := (others => '0');
    signal IPC_DONE : std_logic := '0';
    signal FRM_SHOOT, ARM_READY : std_logic := '0';
    signal FRM_DONE : std_logic := '0';
    signal FXL_RIM_SEL, CAM_GOOD, PC_OVERRIDE : std_logic := '0';
    signal IRAM_DIN : std_logic_vector(7 downto 0) := (others => '0');
    signal SPI_MISO : std_logic := '0';
    signal I2C_SCL_I : std_logic := '0';
    signal I2C_SDA_I : std_logic := '0';

    --Outputs
    signal DEVLED : std_logic_vector(7 downto 0);
    signal POWERLED_VAL : std_logic_vector(7 downto 0);
    signal POWERLED_EN : std_logic;
    signal IPC_START : std_logic;
    signal IPC_RST : std_logic;
    signal RIM_SEL : std_logic;
    signal TRIG_MODE : std_logic;
    signal TRIG_OUT, EXPOSURE_TIMESTAMP : std_logic;
    signal SPI_CS : std_logic;
    signal CLK_IRAM : std_logic;
    signal IRAM_ADDR : std_logic_vector(14 downto 0);
    signal IRAM_DOUT : std_logic_vector(7 downto 0);
    signal IRAM_WE : std_logic;
    signal IRAM_EN : std_logic;
    signal SPI_SCK : std_logic;
    signal SPI_MOSI : std_logic;
    signal I2C_SCL_O : std_logic;
    signal I2C_SCL_OE : std_logic;
    signal I2C_SDA_O : std_logic;
    signal I2C_SDA_OE : std_logic;

    -- Clock period definitions
    constant CLK_48_period : time := 20.833 ns;
 
BEGIN
 
    -- Instantiate the Unit Under Test (UUT)
    uut: AVR_SoC_Top PORT MAP (
        CLK_48 => CLK_48,
        RESET => RESET,
        DEVLED => DEVLED,
        POWERLED_VAL => POWERLED_VAL,
        POWERLED_EN => POWERLED_EN,
        IPC_START => IPC_START,
        IPC_RST => IPC_RST,
        RIM_SEL => RIM_SEL,
        TRIG_MODE => TRIG_MODE,
        TRIG_OUT => TRIG_OUT,
        SPI_CS => SPI_CS,
        TASTER => TASTER,
        IPC_DONE => IPC_DONE,
        FRM_SHOOT => FRM_SHOOT,
        FRM_DONE => FRM_DONE,
        FXL_RIM_SEL => FXL_RIM_SEL,
        PC_OVERRIDE => PC_OVERRIDE,
        CAM_GOOD => CAM_GOOD,
        CLK_IRAM => CLK_IRAM,
        ARM_READY => ARM_READY,
        EXPOSURE_TIMESTAMP => EXPOSURE_TIMESTAMP,
        IRAM_ADDR => IRAM_ADDR,
        IRAM_DIN => IRAM_DIN,
        IRAM_DOUT => IRAM_DOUT,
        IRAM_WE => IRAM_WE,
        IRAM_EN => IRAM_EN,
        SPI_SCK => SPI_SCK,
        SPI_MOSI => SPI_MOSI,
        SPI_MISO => SPI_MISO,
        I2C_SCL_I => I2C_SCL_I,
        I2C_SCL_O => I2C_SCL_O,
        I2C_SCL_OE => I2C_SCL_OE,
        I2C_SDA_I => I2C_SDA_I,
        I2C_SDA_O => I2C_SDA_O,
        I2C_SDA_OE => I2C_SDA_OE
    );

    -- Clock process definitions
    CLK_48_process :process
    begin
        CLK_48 <= '0';
        wait for CLK_48_period/2;
        CLK_48 <= '1';
        wait for CLK_48_period/2;
    end process; 

    woot: process
    begin
        report "bla";
        wait for 100 us;
        CAM_GOOD <= '1';
        PC_OVERRIDE <= '0';
        FRM_SHOOT <= '1';
        FRM_DONE <= '1';
        IPC_DONE <= '1';
        TASTER <= x"0";
        IRAM_DIN <= x"A5";
        ARM_READY <= '1';
        PC_OVERRIDE <= '0';
        report "set";

        wait;
    end process;

END;
