#ifndef mt_H_
#define mt_H_

void mt_init(void);
void mt_reg_write(uint8_t regaddr, uint16_t data);
uint16_t mt_reg_read(uint8_t regaddr);

// cam
#define MT_I2C_ADDR             (0x90)

#define MT_CHIP_VERSION         (0x00)
#define MT_CHIP_CONTROL         (0x07)
#define MT_RESET                (0x0c)
#define MT_READ_MODE_CTXA       (0x0d)
#define MT_PCFLV_CTRL           (0x72)
#define MT_DIGITAL_TEST_PATTERN (0x7f)
#define MT_LVDS_MASTER_CONTROL  (0xb1)
#define MT_LVDS_INTERNAL_SYNC   (0xb5)

#endif
