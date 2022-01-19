// BC2_top_ufm defines

// bootram
`define BC_USE_BOOTRAM
`define BC_BOOTRAM_FILE "/home/bob/code/lumiboot/image.ram"
`define BC_BOOTRAM_WIDTH 14 // 2^14 * 32 bit = 65 kB

//`define BC_USE_CAN
`define BC_USE_SPI
//`define BC_USE_I2C

// sdcard using dma
//`define BC_USE_SDCARD_DMA

// sdcard using spi
`define BC_USE_SDCARD_SPI
