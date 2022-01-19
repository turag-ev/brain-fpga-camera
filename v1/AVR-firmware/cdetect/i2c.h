#ifndef i2c_H_
#define i2c_H_

void i2c_init(void);
void i2c_start_addr(uint8_t addr, uint8_t readmode);
void i2c_start_read(uint8_t addr);
void i2c_start_write(uint8_t addr);
void i2c_byte_tx(uint8_t data);
uint8_t i2c_byte_rx(uint8_t last);
void i2c_nack(void);
void i2c_stop(void);
void i2c_send_byte(uint8_t addr, uint8_t data);
void i2c_send_bytes(uint8_t addr, uint8_t *data, uint8_t len);
uint8_t i2c_recv_byte(uint8_t addr);

// I2C module registers
#define I2C_CTR_EN  (0x80)

#define I2C_SR_TIP  (0x02)

#define I2C_CR_STA  (0x80)
#define I2C_CR_STO  (0x40)
#define I2C_CR_RD   (0x20)
#define I2C_CR_WR   (0x10)
#define I2C_CR_ACK  (0x04)

#endif
