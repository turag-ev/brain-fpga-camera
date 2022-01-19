#include <avr/io.h>
#include <util/delay.h>

#include "mt.h"
#include "i2c.h"

void mt_init(void)
{
    uint8_t i;

    for (i = 0; i < 10; i++) {
        // Soft Reset
        mt_reg_write(MT_RESET, 0x0001);
        _delay_ms(2);
    }

    mt_reg_write(MT_RESET, 0x0000);

#if 0        
    _delay_ms(500);
    mt_reg_write(MT_LVDS_INTERNAL_SYNC, 0x0000); // LVDS sync pattern
    _delay_ms(500);
    mt_reg_write(MT_LVDS_INTERNAL_SYNC, 0x0000); // pattern off
    _delay_ms(500);
    mt_reg_write(MT_LVDS_MASTER_CONTROL, 0x0004); // LVDS test mode
    _delay_ms(500);
    mt_reg_write(MT_LVDS_MASTER_CONTROL, 0x0000);
    _delay_ms(500);

    chipver = mt_reg_read(MT_CHIP_VERSION);
    DEVLED = ~((uint8_t)(chipver&0xff));

    _delay_ms(500);
    DEVLED = ~((uint8_t)((chipver>>8)&0xff));
#endif

    for (i = 0; i < 30; i++) {
        // set LVDS Power-down (Bit 1) to 0
        mt_reg_write(MT_LVDS_MASTER_CONTROL, 0x0000);
        _delay_ms(2);

        // set 4x row and 4x col binning
        //mt_reg_write(MT_READ_MODE_CTXA, 0x030A);
        // no binning
        mt_reg_write(MT_READ_MODE_CTXA, 0x0300);
        _delay_ms(2);
        
        // show test pattern
        // horizontal
        //mt_reg_write(MT_DIGITAL_TEST_PATTERN, 0x3000);
        // vertical
        //mt_reg_write(MT_DIGITAL_TEST_PATTERN, 0x2800);
        // diagonal
        //mt_reg_write(MT_DIGITAL_TEST_PATTERN, 0x3800);
        // nothing
        mt_reg_write(MT_DIGITAL_TEST_PATTERN, 0x0000);
        _delay_ms(2);
        
        // invert pixel clock (rising edge)
        mt_reg_write(MT_PCFLV_CTRL, 0x0010);
        _delay_ms(2);
        
        //mt_reg_write(MT_CHIP_CONTROL, 0x0388);
        //_delay_ms(10);
    }
}

// cam: write 16-bit data to a register
void mt_reg_write(uint8_t regaddr, uint16_t data)
{
    // send START and cam address
    i2c_start_write(MT_I2C_ADDR);
    
    // send register address
    i2c_byte_tx(regaddr);
    
    // ACK comes back

    // write MSB of value
    i2c_byte_tx(data>>8);
    // write LSB, send STOP
    i2c_byte_tx(data);

    i2c_stop();
}

uint16_t mt_reg_read(uint8_t regaddr)
{
    uint16_t val = 0;
    uint8_t msb = 0, lsb = 0;
    
    // send register address in write mode
    i2c_start_write(MT_I2C_ADDR);
    i2c_byte_tx(regaddr);
    
    // receive register bytes
    i2c_start_read(MT_I2C_ADDR);
    msb = i2c_byte_rx(0);    
    lsb = i2c_byte_rx(1);
    
    val = (msb<<8) | lsb;
    return val;
}

