#include <avr/io.h>
#include <util/delay.h>

#include "cdetect.h"
#include "spi.h"
#include "gpio.h"

void spi_init(void)
{
    gpo_set_SPI_CS(1);
    
    // enable core, select master mode
    SPI_CR = SPI_CR_RESETVAL | SPI_CR_SPE;
}

void spi_send_byte(uint8_t data)
{
    // wait if tx fifo is full
    while (SPI_SR & SPI_SR_WFFULL);
    
    // add byte to TX FIFO
    gpo_set_SPI_CS(0);
    SPI_DR = data;
    
    // wait until finished
    while (!(SPI_SR & SPI_SR_WFEMPTY));
    _delay_us(2);
    gpo_set_SPI_CS(1);
}

void spi_send_bytes(uint8_t *data, uint8_t len)
{
    uint8_t i;
    
    // wait until fifo empty
    while (!(SPI_SR & SPI_SR_WFEMPTY));
    
    // chip select
    gpo_set_SPI_CS(0);
    
    for (i = 0; i < len; i++) {
        // wait if fifo is full
        while (SPI_SR & SPI_SR_WFFULL);
        
        // send byte
        SPI_DR = data[i];
    }
    
    // wait until finished
    while (!(SPI_SR & SPI_SR_WFEMPTY));
    _delay_us(2);
    gpo_set_SPI_CS(1);
}

void spi_send_bytes16(uint8_t *data, uint16_t len)
{
    uint16_t i;
    
    // wait until fifo empty
    while (!(SPI_SR & SPI_SR_WFEMPTY));
    
    // chip select
    gpo_set_SPI_CS(0);
    
    for (i = 0; i < len; i++) {
        // wait if fifo is full
        while (SPI_SR & SPI_SR_WFFULL);
        
        // send byte
        SPI_DR = data[i];
    }
    
    // wait until finished
    while (!(SPI_SR & SPI_SR_WFEMPTY));
    _delay_us(2);
    gpo_set_SPI_CS(1);
}

