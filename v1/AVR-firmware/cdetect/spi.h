#ifndef spi_H_
#define spi_H_

void spi_init(void);
void spi_send_byte(uint8_t data);
void spi_send_bytes(uint8_t *data, uint8_t len);
void spi_send_bytes16(uint8_t *data, uint16_t len);

#define SPI_CR_SPIE (0x80)
#define SPI_CR_SPE  (0x40)
#define SPI_CR_MSTR (0x10)
#define SPI_CR_CPOL (0x08)
#define SPI_CR_CPHA (0x04)

// use master mode, for SCK divide wb_clk by 16
#define SPI_CR_RESETVAL (SPI_CR_MSTR | 0x02)

#define SPI_SR_SPIF (0x80)
#define SPI_SR_WCOL (0x40)
#define SPI_SR_WFFULL   (0x08)
#define SPI_SR_WFEMPTY  (0x04)
#define SPI_SR_RFFULL   (0x02)
#define SPI_SR_RFEMPTY  (0x01)

#endif
