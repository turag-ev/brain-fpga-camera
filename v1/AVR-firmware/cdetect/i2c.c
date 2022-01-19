#include <avr/io.h>
#include <util/delay.h>

#include "cdetect.h"
#include "i2c.h"

void i2c_init(void)
{
    // disable core
    I2C_CTR = 0x00;

    // set clock prescaler
    I2C_PRERlo = 0x27; // 20 MHz / (5 * 100 kHz) - 1 = 39 = 0x27
    I2C_PRERhi = 0x00;

    // enable core
    I2C_CTR = I2C_CTR_EN;
}

// start condition
void i2c_start_addr(uint8_t addr, uint8_t readmode)
{
    // transmit slave address, bit0 = 0 => writing to slave
    I2C_TXR = (addr & 0xfe) | readmode;
    // send start condition and data
    I2C_CR = I2C_CR_STA | I2C_CR_WR;
    // wait for transfer to finish
    while (I2C_SR & I2C_SR_TIP);
}

void i2c_start_read(uint8_t addr)
{
    i2c_start_addr(addr, 1);
}

void i2c_start_write(uint8_t addr)
{
    i2c_start_addr(addr, 0);
}

// send byte
void i2c_byte_tx(uint8_t data)
{
    I2C_TXR = data;         // data
    I2C_CR = I2C_CR_WR;
    while (I2C_SR & I2C_SR_TIP);
}

// receive byte
uint8_t i2c_byte_rx(uint8_t last)
{
    if (!last)
        I2C_CR = I2C_CR_RD;
    else
        I2C_CR = I2C_CR_RD | I2C_CR_ACK | I2C_CR_STO; // NACK

    while (I2C_SR & I2C_SR_TIP);
    
    return I2C_RXR;
}

void i2c_nack(void)
{
    // NACK
    I2C_CR = I2C_CR_ACK;
}

void i2c_stop(void)
{
    // stop condition
    I2C_CR = I2C_CR_STO;
}

//
void i2c_send_byte(uint8_t addr, uint8_t data)
{
    i2c_start_write(addr);

    i2c_byte_tx(data);
    
    i2c_stop();
}

void i2c_send_bytes(uint8_t addr, uint8_t *data, uint8_t len)
{
    uint8_t i;

    i2c_start_write(addr);

    for (i = 0; i < len; i++)
        i2c_byte_tx(data[i]);
    
    i2c_stop();
}

uint8_t i2c_recv_byte(uint8_t addr)
{
    uint8_t byte;
    
    i2c_start_read(addr);

    byte = i2c_byte_rx(1);
    
    return byte;
}

